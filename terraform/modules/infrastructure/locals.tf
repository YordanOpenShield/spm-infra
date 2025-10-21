locals {
    postgres_server_image = "ubuntu-22.04"
    postgres_server_type  = data.hcloud_server_type.selected_postgres[0].name

    opensearch_server_image = "ubuntu-22.04"
    opensearch_server_type = data.hcloud_server_type.selected_opensearch[0].name
}