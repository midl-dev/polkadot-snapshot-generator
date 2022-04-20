locals {
  cloud_variables = {
       "project" : module.terraform-gke-blockchain.project,
       "website_bucket_url": google_storage_bucket.snapshot_bucket.url,
  }
}

resource "google_service_account" "snapshot_engine_account" {
  account_id   = "${var.kubernetes_name_prefix}-snapshot-engine"
  display_name = "Snapshot engine for ${var.kubernetes_name_prefix}"
  project = module.terraform-gke-blockchain.project 
}

# based on workload identity docs
# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
resource "google_service_account_iam_binding" "snapshot_engine_account_binding" {
  service_account_id = google_service_account.snapshot_engine_account.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${module.terraform-gke-blockchain.project}.svc.id.goog[${var.kubernetes_namespace}/${var.kubernetes_name_prefix}-snapshot-engine]"
  ]
}

# the below to be able to run kubectl commands from within a kubectl pod (so we can create volume snapshots, and mount them, on a cron)
resource "google_project_iam_member" "snapshot_engine_account_k8s_permission" {
  role               = "roles/container.developer"
  project = module.terraform-gke-blockchain.project 

  member = "serviceAccount:${var.kubernetes_name_prefix}-snapshot-engine@${module.terraform-gke-blockchain.project}.iam.gserviceaccount.com"
}

resource "null_resource" "push_containers" {

  triggers = {
    host = md5(module.terraform-gke-blockchain.kubernetes_endpoint)
    cluster_ca_certificate = md5(
      module.terraform-gke-blockchain.cluster_ca_certificate,
    )
  }
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOF
set -x

build_container () {
  set -x
  cd $1
  container=$(basename $1)
  cp Dockerfile.template Dockerfile
  sed -i "s/((polkadot_version))/${var.polkadot_version}/" Dockerfile
  cat << EOY > cloudbuild.yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', "gcr.io/${module.terraform-gke-blockchain.project}/$container:${var.kubernetes_namespace}-latest", '.']
images: ["gcr.io/${module.terraform-gke-blockchain.project}/$container:${var.kubernetes_namespace}-latest"]
EOY
  gcloud builds submit --project ${module.terraform-gke-blockchain.project} --config cloudbuild.yaml .
  rm -v Dockerfile
  rm cloudbuild.yaml
}
export -f build_container
find ${path.module}/../docker -mindepth 1 -maxdepth 1 -type d -exec bash -c 'build_container "$0"' {} \; -printf '%f\n'
EOF
  }
}

resource "kubernetes_namespace" "polkadot_snapshot_namespace" {
  metadata {
    name = var.kubernetes_namespace
  }
  depends_on = [ module.terraform-gke-blockchain ]
}

resource "null_resource" "apply" {
  provisioner "local-exec" {

    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOF
set -e
set -x
gcloud container clusters get-credentials "${module.terraform-gke-blockchain.name}" --region="${module.terraform-gke-blockchain.location}" --project="${module.terraform-gke-blockchain.project}"

cd ${abspath(path.module)}/k8s-${var.kubernetes_namespace}
kubectl apply -k .
EOF

  }
  depends_on = [ null_resource.push_containers, null_resource.generate_templates, kubernetes_namespace.polkadot_snapshot_namespace ]
}

resource "random_id" "rnd_bucket" {
  byte_length = 4
}

resource "google_storage_bucket" "snapshot_bucket" {
  name     = "polkadot-snapshot-bucket-${var.kubernetes_name_prefix}-${random_id.rnd_bucket.hex}"
  project = module.terraform-gke-blockchain.project
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  lifecycle_rule {
    condition {
      age = var.num_days_to_keep
    }
    action {
      type = "Delete"
    }
  }
  force_destroy = true
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.snapshot_bucket.name
  role        = "roles/storage.objectAdmin"
  member      = "serviceAccount:${google_service_account.snapshot_engine_account.email}"
}

resource "google_storage_bucket_iam_member" "make_public" {
  bucket = google_storage_bucket.snapshot_bucket.name
  role        = "roles/storage.objectViewer"
  member      = "allUsers"
}
