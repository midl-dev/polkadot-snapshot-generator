locals {
  terraform_variables = {
       "polkadot_version": var.polkadot_version,
       "kubernetes_namespace": var.kubernetes_namespace,
       "kubernetes_name_prefix": var.kubernetes_name_prefix,
       "firebase_project": var.firebase_project,
       "firebase_subdomain": var.firebase_subdomain,
       "firebase_token": var.firebase_token,
       "data_bucket_url": var.data_bucket_url,
       "data_bucket_public_url": var.data_bucket_public_url,
       "aws_access_key_id": var.aws_access_key_id,
       "aws_secret_access_key": var.aws_secret_access_key,
       "chain": var.chain,
       "database": var.database,
       "kubernetes_pool_name": var.kubernetes_pool_name,
       "snapshot_url": var.snapshot_url,
       "node_storage_size": var.node_storage_size
  }
}

resource "null_resource" "generate_templates" {
  provisioner "local-exec" {

    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOF
set -e
set -x

rm -rvf ${path.module}/k8s-${var.kubernetes_namespace}
mkdir -p ${path.module}/k8s-${var.kubernetes_namespace}
cp -rv ${path.module}/../k8s/*base* ${path.module}/k8s-${var.kubernetes_namespace}
cd ${abspath(path.module)}/k8s-${var.kubernetes_namespace}
cat <<EOK > kustomization.yaml
${templatefile("${path.module}/../k8s/kustomization.yaml.tmpl",
    merge(local.terraform_variables, local.cloud_variables))}
EOK

mkdir -pv polkadot-private-node
cat <<EOK > polkadot-private-node/kustomization.yaml
${templatefile("${path.module}/../k8s/polkadot-private-node-tmpl/kustomization.yaml.tmpl",
    merge(local.terraform_variables, local.cloud_variables))}
EOK
cat <<EOPPVN > polkadot-private-node/prefixedpvnode.yaml
${templatefile("${path.module}/../k8s/polkadot-private-node-tmpl/prefixedpvnode.yaml.tmpl", local.terraform_variables)}
EOPPVN
cat <<EONPN > polkadot-private-node/nodepool.yaml
${templatefile("${path.module}/../k8s/polkadot-private-node-tmpl/nodepool.yaml.tmpl", {"kubernetes_pool_name": var.kubernetes_pool_name})}
EONPN

mkdir -pv polkadot-snapshot-engine
cat <<EOK > polkadot-snapshot-engine/kustomization.yaml
${templatefile("${path.module}/../k8s/polkadot-snapshot-engine-tmpl/kustomization.yaml.tmpl",
    merge(local.terraform_variables, local.cloud_variables))}
EOK
cat <<EONPN > polkadot-snapshot-engine/nodepool.yaml
${templatefile("${path.module}/../k8s/polkadot-snapshot-engine-tmpl/nodepool.yaml.tmpl", {"kubernetes_pool_name": var.kubernetes_pool_name})}
EONPN
cat <<EONPN > polkadot-snapshot-engine/serviceaccountannotate.yaml
${templatefile("${path.module}/../k8s/polkadot-snapshot-engine-tmpl/serviceaccountannotate.yaml.tmpl",
    merge(local.terraform_variables, local.cloud_variables))}
EONPN
cat <<EONPN > polkadot-snapshot-engine/crontime.yaml
${templatefile("${path.module}/../k8s/polkadot-snapshot-engine-tmpl/crontime.yaml.tmpl", {"snapshot_cron_schedule": var.snapshot_cron_schedule})}
EONPN
EOF
  }
}
