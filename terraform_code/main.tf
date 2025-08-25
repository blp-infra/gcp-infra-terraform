module "project" {
  source          = "./project"
  for_each        = var.projects
  project_id      = each.value["project_id"]
  project_name    = each.value["name"]
  organization_id = each.value["organization_id"]
  billing_account = each.value["billing_account"]
}
# module "vpc" {
#   source = "./vpc"
# }