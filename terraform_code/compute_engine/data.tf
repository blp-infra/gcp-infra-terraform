# Get the latest version of the secret
data "google_secret_manager_secret_version" "username" {
  secret  = "admin_user"
  project = var.project_id
}

data "google_secret_manager_secret_version" "password" {
  secret  = "admin_password"
  project = var.project_id
}

# Pass secret values into variables
locals {
  username = data.google_secret_manager_secret_version.username.secret_data
  password = data.google_secret_manager_secret_version.password.secret_data
}
