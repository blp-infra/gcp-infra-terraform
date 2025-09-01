resource "google_cloud_run_service" "default" {
  name     = "myapp"
  location = var.region

  template {
    spec {
      service_account_name = "jenkins-server@zeta-flare-449207-r0.iam.gserviceaccount.com"
      containers {
        image = "asia-south1-docker.pkg.dev/zeta-flare-449207-r0/docker-repo/myapp:v1.0"
        # resources {
        #           limits = {
        #             "cpu" = "1"
        #             "memory" = "2Gi"
        #             # "nvidia.com/gpu" = "1"
        #           }
        #         }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}