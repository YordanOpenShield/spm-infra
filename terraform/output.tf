output "ssh_private_key" {
    description = "Private key for SSH access to provisioned servers"
    value       = module.infrastructure.ssh_private_key
    sensitive   = true
}

output "ssh_public_key" {
    description = "Public key for SSH access to provisioned servers"
    value       = module.infrastructure.ssh_public_key
}