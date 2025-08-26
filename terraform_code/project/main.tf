resource "google_project" "infra_project" {
  name                = var.project_name
  project_id          = var.project_id
  #org_id     = var.organization_id // under which organization
  billing_account     = var.billing_account
  auto_create_network = false
}