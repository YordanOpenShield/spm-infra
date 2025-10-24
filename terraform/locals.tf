locals {
    base_domain = "openshield.io"
    spm_subdomain = "spm.${local.base_domain}"

    provision_user = "deploy"
    provision_ssh_port = 2222
}