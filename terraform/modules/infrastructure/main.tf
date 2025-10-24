# ================================================================= 
# Backend Server
# =================================================================

resource "hcloud_server" "backend" {
  name        = "spm-backend"
  image       = local.backend_server_image
  server_type = local.backend_server_type
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]

  user_data = templatefile("${path.module}/templates/backend.yml.tftpl", {
    module_path = path.module,
    provision_user = var.provision_user,
    provision_ssh_port = var.provision_ssh_port,
    ssh_key = hcloud_ssh_key.ssh_key.public_key,
  })

  labels = {
    role     = "backend"
    solution = "spm"
  }
}


# =================================================================
# PostgreSQL Database Server
# =================================================================

resource "hcloud_server" "postgres" {
  name        = "spm-postgres"
  image       = local.postgres_server_image
  server_type = local.postgres_server_type
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]

  user_data = templatefile("${path.module}/templates/postgres.yml.tftpl", {
    module_path = path.module,
    provision_user = var.provision_user,
    provision_ssh_port = var.provision_ssh_port,
    ssh_key = hcloud_ssh_key.ssh_key.public_key,
  })

  labels = {
    role     = "database"
    solution = "spm"
  }
}

# =================================================================
# OpenSearch Servers
# =================================================================

resource "hcloud_server" "opensearch_master" {
  name        = "spm-opensearch-master"
  image       = local.opensearch_server_image
  server_type = local.opensearch_server_type
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]

  user_data = templatefile("${path.module}/templates/opensearch.yml.tftpl", {
    module_path = path.module,
    provision_user = var.provision_user,
    provision_ssh_port = var.provision_ssh_port,
    ssh_key = hcloud_ssh_key.ssh_key.public_key,
  })

  labels = {
    role     = "opensearch"
    solution = "spm"
  }
}

resource "hcloud_server" "opensearch_node" {
  count       = var.opensearch_node_count
  name        = "spm-opensearch-node-${count.index + 1}"
  image       = local.opensearch_server_image
  server_type = local.opensearch_server_type
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]
  location    = hcloud_server.opensearch_master.location

  user_data = templatefile("${path.module}/templates/opensearch.yml.tftpl", {
    module_path = path.module,
    provision_user = var.provision_user,
    provision_ssh_port = var.provision_ssh_port,
    ssh_key = hcloud_ssh_key.ssh_key.public_key,
  })

  labels = {
    role     = "opensearch"
    solution = "spm"
  }
}

# =================================================================
# Volumes
# =================================================================

resource "hcloud_volume" "postgres_data" {
  name        = "spm-postgres-data"
  size        = 50
  format      = "ext4"
  location    = hcloud_server.postgres.location

  labels = {
    role     = "database-data"
    solution = "spm"
  }
}

resource "hcloud_volume" "postgres_backup_data" {
  name        = "spm-postgres-backup-data"
  size        = hcloud_volume.postgres_data.size + 20
  format      = "ext4"
  location    = hcloud_server.postgres.location

  labels = {
    role     = "database-data"
    role     = "backup-data"
    solution = "spm"
  }
}

resource "hcloud_volume_attachment" "postgres_data_attachment" {
  volume_id = hcloud_volume.postgres_data.id
  server_id = hcloud_server.postgres.id
  automount = true
}

resource "hcloud_volume_attachment" "postgres_backup_data_attachment" {
  volume_id = hcloud_volume.postgres_backup_data.id
  server_id = hcloud_server.postgres.id
  automount = true
}

# =================================================================
# Firewalls
# =================================================================

resource "hcloud_firewall" "spm_backend_firewall" {
  name = "spm-backend-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "${var.provision_ssh_port}"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
    destination_ips = []
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
    destination_ips = []
  }

  labels = {
    solution = "spm"
  }
}

resource "hcloud_firewall" "spm_postgres_firewall" {
  name = "spm-postgres-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "${var.provision_ssh_port}"
    source_ips = ["0.0.0.0/0", "::/0"]
    destination_ips = []
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "${var.provision_ssh_port}"
    source_ips = []
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "5432"
    source_ips = concat([hcloud_server.opensearch_master.ipv4_address], hcloud_server.opensearch_node.*.ipv4_address)
    destination_ips = []
  }

  labels = {
    solution = "spm"
  }
}

resource "hcloud_firewall" "spm_opensearch_firewall" {
  name = "spm-opensearch-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "${var.provision_ssh_port}"
    source_ips = ["0.0.0.0/0", "::/0"]
    destination_ips = []
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9200-9300"
    source_ips = concat([hcloud_server.backend.ipv4_address, hcloud_server.opensearch_master.ipv4_address], hcloud_server.opensearch_node.*.ipv4_address)
    destination_ips = []
  }

  labels = {
    solution = "spm"
  }
}

resource "hcloud_firewall_attachment" "backend" {
  firewall_id  = hcloud_firewall.spm_backend_firewall.id
  server_ids   = [hcloud_server.backend.id]
}

resource "hcloud_firewall_attachment" "postgres" {
  firewall_id  = hcloud_firewall.spm_postgres_firewall.id
  server_ids   = [hcloud_server.postgres.id]
}

resource "hcloud_firewall_attachment" "opensearch" {
  firewall_id  = hcloud_firewall.spm_opensearch_firewall.id
  server_ids   = concat([hcloud_server.opensearch_master.id], hcloud_server.opensearch_node.*.id)
}