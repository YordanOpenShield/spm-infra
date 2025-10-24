# =================================================================
# Connection Variables
# =================================================================

variable "provision_user" {
    description = "The user to provision the servers with Ansible"
    type        = string
    default     = "deploy"
}

# =================================================================
# Hosts Variables
# =================================================================

variable "postgres_host" {
    description = "PostgreSQL server IP address"
    type        = string
}

variable "provision_ssh_port" {
    description = "SSH port for the provisioned user on servers"
    type        = number
}