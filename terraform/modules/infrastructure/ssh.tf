resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "ssh_key" {
  name       = "spm-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  labels = {
    solution = "spm"
  }
}

resource "local_file" "deploy_key_file" {
  filename        = "${path.root}/.terraform/deploy_key.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}
