# ============================================================
# Hetzner Token
# ============================================================

variable "hetzner_token" {
    description = "API token for Hetzner Cloud"
    type        = string
    sensitive   = true
}

# ============================================================
# Postgres Variables
# ============================================================

variable "postgres_cpu" {
    description = "Number of CPU cores for the Postgres server"
    type        = number
    default     = 2
}

variable "postgres_ram" {
    description = "Amount of RAM for the Postgres server"
    type        = number
    default     = 4
}

# ============================================================
# OpenSearch Variables
# ============================================================

variable "opensearch_cpu" {
    description = "Number of CPU cores for the OpenSearch server"
    type        = number
    default     = 4
}

variable "opensearch_ram" {
    description = "Amount of RAM for the OpenSearch server"
    type        = number
    default     = 8
}

variable "opensearch_node_count" {
    description = "Number of OpenSearch nodes to deploy"
    type        = number
    default     = 2
}