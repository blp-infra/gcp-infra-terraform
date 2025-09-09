resource "google_service_account" "compute_engine" {
  account_id   = "${var.name}-sa"
  display_name = "Custom service account for VM instance ${var.name}"
}

resource "google_compute_instance" "compute_engine" {
  depends_on = [ google_service_account.compute_engine , data.google_secret_manager_secret.password,data.google_secret_manager_secret.username]
  count        = local.username ? 1: 0
  name         = "${var.name}-ce"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["${var.name}-ce"]

  boot_disk {
    initialize_params {
      image   =  var.image
      size    =  var.disk_size
      type    =  var.disk_type  
    }
  }

  // Local SSD disk
  # scratch_disk {
  #   interface = "NVME"
  # }

  network_interface {
    network = "default"
    # subnetwork

    access_config {
      // Ephemeral public IP
      network_tier = "STANDARD"
    }
  }
  # Scheduling - spot 
  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = "SPOT"
  }

  # metadata = {
  #   foo = "bar" #ssh 
  # }

  # Render startup script with Terraform variable
   metadata_startup_script = templatefile("${path.module}/startup.sh.tmpl", {
     user_name = local.username # send username variable to script
     password = local.password 
     role_name = var.name
   })

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.compute_engine.email
    scopes = ["cloud-platform"]
  }
}