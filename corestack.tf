resource "local_file" "k3s_upgrade_plan" {
  content = templatefile("${path.root}/templates/k3s_upgrade_plan.yaml", {
    k3s_channel = var.k3s_channel
  })
  filename        = "deployment/k3s_upgrade_plan.yaml"
  file_permission = "644"
}

resource "null_resource" "upgrade_controller_manifests" {
  provisioner "local-exec" {
    command     = "./bin/kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/${var.upgrade_controller_version}/system-upgrade-controller.yaml"
    interpreter = ["bash", "-c"]
  }
  provisioner "local-exec" {
    command     = <<EOC
      while ! ./bin/kubectl get crd | grep 'plans.upgrade.cattle.io' &> /dev/null; do sleep 1; done
      ./bin/kubectl apply -f deployment/k3s_upgrade_plan.yaml
    EOC
    interpreter = ["bash", "-c"]
  }
  depends_on = [local_file.kubectl_scripts, local_file.k3s_upgrade_plan]
}

resource "null_resource" "longhorn_manifest" {
  provisioner "local-exec" {
    command     = "./bin/kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/${var.longhorn_version}/deploy/longhorn.yaml"
    interpreter = ["bash", "-c"]
  }
  depends_on = [local_file.kubectl_scripts]
}

resource "null_resource" "certmanager_manifests" {
  provisioner "local-exec" {
    command     = "./bin/kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${var.certmanager_version}/cert-manager.yaml"
    interpreter = ["bash", "-c"]
  }
  depends_on = [local_file.kubectl_scripts]
}

resource "null_resource" "k8s_dashboard_manifests" {
  provisioner "local-exec" {
    command     = "./bin/kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${var.k8s_dashboard_version}/aio/deploy/recommended.yaml"
    interpreter = ["bash", "-c"]
  }
  provisioner "local-exec" {
    command     = <<EOC
      while ! ./bin/kubectl get ns | grep 'kubernetes-dashboard' &> /dev/null; do sleep 1; done
      ./bin/kubectl apply -f manifests/k8s_dashboard_admin.yaml
    EOC
    interpreter = ["bash", "-c"]
  }

  depends_on = [local_file.kubectl_scripts]
}
