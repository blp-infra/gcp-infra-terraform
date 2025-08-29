# module "project" {
#   source              = "./project"
#   for_each            = var.projects
#   project_id          = each.value["project_id"]
#   project_name        = each.value["name"]
#   # organization_id     = each.value["organization_id"]
#   billing_account     = var.billing_account #each.value["billing_account"]
  
# }
# module "vpc" {
#   source = "./vpc"
#   cidr   = var.cidr
#   region =var.af_region
# }
module "compute_engine" {
  source          = "./compute_engine"
  for_each        = var.compute_engine
  name            = each.key
  machine_type    = each.value["machine_type"]
  zone            = each.value["zone"] 
  image           = each.value["image"] 
  disk_type       = each.value["disk_type"]
  disk_size       = each.value["disk_size"]
  project_id      = var.project_id
}