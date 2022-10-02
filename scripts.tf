resource "local_file" "known_hosts" {
  content         = join("", [for v in concat(module.hcloud_k3s_server_nodes.*, module.hcloud_k3s_agent_nodes.*) : "${v.ip} ${v.hostkey}"])
  filename        = "deployment/known_hosts"
  file_permission = "644"
}

resource "local_file" "client_priv_key" {
  content         = module.hcloud_ssh_key.private_key_pem
  filename        = "deployment/id_ecdsa"
  file_permission = "600"
}

resource "local_file" "ssh_script_servers" {
  count = var.server_node_count
  content = templatefile("${path.root}/templates/ssh.sh", {
    node_ip = module.hcloud_k3s_server_nodes[count.index].ip
  })
  filename        = "bin/ssh-k3s-server-${count.index + 1}"
  file_permission = "700"
  depends_on      = [local_file.known_hosts]
}

resource "local_file" "ssh_script_agents" {
  count = var.agent_node_count
  content = templatefile("${path.root}/templates/ssh.sh", {
    node_ip = module.hcloud_k3s_agent_nodes[count.index].ip
  })
  filename        = "bin/ssh-k3s-agent-${count.index + 1}"
  file_permission = "700"
  depends_on      = [local_file.known_hosts]
}

resource "null_resource" "kubeconfigs" {
  count = var.server_node_count
  provisioner "local-exec" {
    command     = <<EOC
      while ! ./bin/ssh-k3s-server-1 "cat /root/k3s-admin.yaml &> /dev/null" &> /dev/null; do sleep 1; done
      ./bin/ssh-k3s-server-1 cat /root/k3s-admin.yaml > ./deployment/k3s-admin-server-${count.index + 1}.yaml
      chmod 400 ./deployment/k3s-admin-server-${count.index + 1}.yaml
    EOC
    interpreter = ["bash", "-c"]
  }
  provisioner "local-exec" {
    when        = destroy
    command     = <<EOC
      rm ./deployment/k3s-admin-server-${count.index + 1}.yaml || true
    EOC
    interpreter = ["bash", "-c"]
  }
  depends_on = [module.hcloud_k3s_server_nodes]
}

resource "local_file" "kubectl_scripts" {
  count = var.server_node_count
  content = templatefile("${path.root}/templates/kubectl.sh", {
    kubeconfig = "k3s-admin-server-${count.index + 1}.yaml"
  })
  filename        = "bin/kubectl-k3s-server-${count.index + 1}"
  file_permission = "700"
  depends_on      = [null_resource.kubeconfigs]
  provisioner "local-exec" {
    command     = <<EOC
      ln -s kubectl-k3s-server-1 bin/kubectl || true
    EOC
    interpreter = ["bash", "-c"]
  }
  provisioner "local-exec" {
    when        = destroy
    command     = <<EOC
      rm ./bin/kubectl || true
    EOC
    interpreter = ["bash", "-c"]
  }
}

resource "local_file" "helm_script" {
  content = templatefile("${path.root}/templates/helm.sh", {
    kubeconfig = "k3s-admin-server-1.yaml"
  })
  filename        = "bin/helm"
  file_permission = "700"
  depends_on      = [null_resource.kubeconfigs]
  provisioner "local-exec" {
    when        = destroy
    command     = <<EOC
      rm ./bin/helm || true
    EOC
    interpreter = ["bash", "-c"]
  }
}
