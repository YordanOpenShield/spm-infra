# ===================================================================
# Module: Infrastructure
# ===================================================================

module "infrastructure" {
    source = "./modules/infrastructure"

    hetzner_token = var.hetzner_token
    provision_user = local.provision_user
    provision_ssh_port = local.provision_ssh_port
}

# ===================================================================
# Module: Ansible
# ===================================================================

module "ansible" {
  source = "./modules/ansible"

  provision_user = local.provision_user
  provision_ssh_port = local.provision_ssh_port
  postgres_host = module.infrastructure.postgres_host
}