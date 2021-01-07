resource "null_resource" "k8s_dry_run" {
  provisioner "local-exec" {

    interpreter = [ "/bin/bash", "-c" ]
    command = <<EOF
set -e
set -x

cd ${abspath(path.module)}/k8s-${var.kubernetes_namespace}
kubectl apply --dry-run=client -k .
cd ${abspath(path.module)}
rm -rf k8s-${var.kubernetes_namespace}
EOF

  }
  depends_on = [ null_resource.generate_templates ]
}
