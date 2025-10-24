output "provision_ssh_port" {
    description = "SSH port for server provisioning"
    value       = var.provision_ssh_port
}

output "postgres_host" {
    description = "List of PostgreSQL server IP addresses"
    value       = hcloud_server.postgres.ipv4_address
}

output "ssh_private_key" {
    description = "Private key for SSH access to provisioned servers"
    value       = tls_private_key.ssh_key.private_key_pem
    sensitive   = true
}

output "ssh_public_key" {
    description = "Public key for SSH access to provisioned servers"
    value       = tls_private_key.ssh_key.public_key_openssh
}