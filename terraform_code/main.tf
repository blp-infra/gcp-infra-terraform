module "project" {
  source          = "./project"
  project_id      = var.project_id
  project_name    = var.project_name
  organization_id = var.organization_id
  billing_account = var.billing_account
}
# module "vpc" {
#   source = "./vpc"
# }