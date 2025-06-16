// Configure the terraform google provider

terraform {
  required_providers {
    google = {
    source  = "hashicorp/google"
    version = "6.8.0"
    }
}
}

provider "google" {
    project = "${var.project_id}"
    region  = "${var.region}"
}

resource "google_cloud_run_service" "default" {
    name     = "financial-advisor-${random_id.rand_id_1.hex}"
    location = "${var.region}"

    template {
        spec {
            containers {
                image = "us-central1-docker.pkg.dev/eternal-argon-461501-a8/cloud-run-source-deploy/fin-advisor:latest"

                env {
                    name  = "GOOGLE_CLOUD_PROJECT"
                    value = "${var.project_id}"
                }

                env {
                    name  = "GOOGLE_CLOUD_LOCATION"
                    value = "${var.region}"
                }

                env {
                    name  = "GOOGLE_GENAI_USE_VERTEXAI"
                    value = "True"
                }
            }
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }
}

resource "google_cloud_run_service_iam_policy" "unauth" {
    location    = google_cloud_run_service.default.location
    service     = google_cloud_run_service.default.name

    policy_data = <<EOF
{
    "bindings": [
        {
            "role": "roles/run.invoker",
            "members": [
                "allUsers"
            ]
        }
    ]
}
EOF
}


resource "random_id" "rand_id_1" {
  byte_length = 4
}

output "Financial-Advisor-URI" {
  value = google_cloud_run_service.default.status[0].url 
}

