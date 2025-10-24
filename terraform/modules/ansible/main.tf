# =================================================================
# Groups
# =================================================================

resource "ansible_group" "postgres" {
    name = "spm-postgres"
}

# =================================================================
# Hosts
# =================================================================

resource "ansible_host" "postgres" {
    name     = var.postgres_host
    groups   = [ansible_group.postgres.name]

    variables = {
        ansible_user = var.provision_user
        ansible_ssh_private_key_file = "${path.root}/.terraform/deploy_key.pem"
        ansible_port = var.provision_ssh_port
    }
}

# =================================================================
# Playbooks
# =================================================================

resource "local_file" "postgres" {
    filename = "${path.root}/.terraform/playbooks/postgres-${ansible_host.postgres.name}.yml"
    content  = templatefile("${path.module}/playbooks/postgres.yml.tftpl", {
        provision_host    = ansible_host.postgres.name,
        provision_port    = var.provision_ssh_port,
        provision_user   = var.provision_user,
        postgres_version = local.postgres_version,
        postgres_db      = local.postgres_db,
        postgres_user    = local.postgres_user,
        postgres_password= local.postgres_password,
    })
}

resource "ansible_playbook" "postgres" {
    name     = ansible_host.postgres.name
    playbook = local_file.postgres.filename
    replayable = true
}