data "hcloud_server_types" "all" {}

data "hcloud_server_type" "selected_backend" {
  for_each = {
    for st in data.hcloud_server_types.all.server_types : st.name => st if st.cores >= var.backend_cpu && st.memory >= var.backend_ram && st.architecture == "x86" && st.cpu_type == "shared"
  }
  name = each.key
}

data "hcloud_server_type" "selected_postgres" {
  for_each = {
    for st in data.hcloud_server_types.all.server_types : st.name => st if st.cores >= var.postgres_cpu && st.memory >= var.postgres_ram && st.architecture == "x86" && st.cpu_type == "shared"
  }
  name = each.key
}

data "hcloud_server_type" "selected_opensearch" {
  for_each = {
    for st in data.hcloud_server_types.all.server_types : st.name => st if st.cores >= var.opensearch_cpu && st.memory >= var.opensearch_ram && st.architecture == "x86" && st.cpu_type == "shared"
  }
  name = each.key
}
