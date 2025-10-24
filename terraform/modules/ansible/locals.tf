locals {
  postgres_version = "13"
  postgres_db = "spm"
  postgres_user = "spm"
  postgres_password = random_password.postgres_password.result
}