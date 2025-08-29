resource "google_bigquery_dataset" "bigquery" {
  dataset_id                  = "sensor_data_${var.project_id}_bqds"
  description                 = "This is bigquery used for project ${var.project_id}"
  location                    = "asia-south1"
  # default_table_expiration_ms = 3600000
  project                     = var.project_id

  labels = {
    env = "development",
    project="${var.project_id}-dataset"
  }
}

resource "google_bigquery_table" "bq_table" {
  dataset_id = google_bigquery_dataset.bigquery.dataset_id
  table_id   = "temperature_${var.project_id}_tbl"
  project    = var.project_id 

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "development",
    project="${var.project_id}-table"
  }

schema = file("${path.module}/schema.json")


}

