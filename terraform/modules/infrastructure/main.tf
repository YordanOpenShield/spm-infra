# =================================================================
# PostgreSQL Database Server
# =================================================================

resource "hcloud_server" "postgres" {
  name        = "spm-postgres"
  image       = local.postgres_server_image
  server_type = local.postgres_server_type
  ssh_keys    = [hcloud_ssh_key.spm_ssh_key.id]

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
  ssh_keys    = [hcloud_ssh_key.spm_ssh_key.id]

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
  ssh_keys    = [hcloud_ssh_key.spm_ssh_key.id]
  location    = hcloud_server.opensearch_master.location

  labels = {
    role     = "opensearch"
    solution = "spm"
  }
}