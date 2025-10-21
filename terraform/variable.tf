# ===========================================================
# API Tokens
# ===========================================================

variable "hetzner_token" {
    description = "API token for Hetzner Cloud"
    type        = string
    sensitive   = true
}

variable "cloudflare_token" {
    description = "API token for Cloudflare"
    type        = string
    sensitive   = true
}
