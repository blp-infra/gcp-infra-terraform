resource "google_compute_subnetwork" "test_subnet" {
  name          = "test-subnetwork"
  ip_cidr_range = var.cidr
  region        = var.region
  network       = google_compute_network.my_test_vpc.id

}

