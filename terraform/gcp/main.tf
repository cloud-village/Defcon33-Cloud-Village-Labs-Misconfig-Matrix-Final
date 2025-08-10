# Top 50 GCP Misconfigurations - Lab Deployment
# This intentionally misconfigures resources for training purposes.

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

variable "project_id" {default = "cloud-inventory-cspm"}
variable "region" { default = "us-west1" }     
variable "zone"   { default = "us-west1-a" }   

# 1. Allow SSH from anywhere (0.0.0.0/0)
resource "google_compute_firewall" "allow_ssh_anywhere" {
  name    = "allow-ssh-anywhere"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# 2. Allow RDP from anywhere
resource "google_compute_firewall" "allow_rdp_anywhere" {
  name    = "allow-rdp-anywhere"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}



# 4. Ensure default network exists
resource "google_compute_network" "default_network_copy" {
  name                    = "default"
  auto_create_subnetworks = true
}

# 5. Publicly accessible storage bucket
resource "google_storage_bucket" "public_bucket" {
  name     = "public-bucket-${random_id.rand.hex}"
  location = var.region
  force_destroy = true

  uniform_bucket_level_access = false
}

resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.public_bucket.name

  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

resource "random_id" "rand" {
  byte_length = 4
}

# 6. Enable overly permissive firewall rule
resource "google_compute_firewall" "allow_all" {
  name    = "allow-all"
  network = "default"

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

# 7. VM instance with external IP
resource "google_compute_instance" "public_vm" {
  name         = "public-vm"
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral public IP
    }
  }

  tags = ["http-server", "https-server"]
}

# 8. Bucket with public write access
resource "google_storage_bucket_iam_binding" "public_write" {
  bucket = google_storage_bucket.public_bucket.name
  role   = "roles/storage.objectAdmin"
  members = ["allUsers"]
}

# 9. Unrestricted API key (simulated)
resource "google_project_service" "apikeys" {
  service = "apikeys.googleapis.com"
}

# 10. IAM user with owner role
resource "google_project_iam_member" "user_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "user:example@example.com"
}

# 11. Cloud Functions without authentication
resource "google_cloudfunctions_function" "no_auth" {
  name        = "noauth-func"
  description = "Function without auth"
  runtime     = "nodejs16"
  available_memory_mb = 128
  source_archive_bucket = google_storage_bucket.public_bucket.name
  source_archive_object = "function-source.zip"
  entry_point = "helloWorld"
  trigger_http = true
  https_trigger_security_level = "SECURE_OPTIONAL"
}

# 12. Pub/Sub topic with allUsers access
resource "google_pubsub_topic" "public_topic" {
  name = "public-topic"
}

resource "google_pubsub_topic_iam_binding" "public_binding" {
  topic  = google_pubsub_topic.public_topic.name
  role   = "roles/pubsub.publisher"
  members = ["allUsers"]
}

# 13. Compute image with allUsers read
resource "google_compute_image" "public_image" {
  name = "public-image"
  raw_disk {
    source = "https://storage.googleapis.com/cloud-training/archinfra/ubuntu-1604-x86_64.tar.gz"
  }
}

resource "google_compute_image_iam_binding" "public_image_read" {
  image = google_compute_image.public_image.name
  role  = "roles/compute.imageUser"
  members = ["allUsers"]
}

# 14. Storage bucket without logging
resource "google_storage_bucket" "no_logging" {
  name     = "nolog-bucket-${random_id.rand.hex}"
  location = var.region
  force_destroy = true
}

# 15. Disabled audit logs for Admin Read
resource "google_project_iam_audit_config" "no_admin_read" {
  project = var.project_id
  service = "allServices"
  audit_log_config {
    log_type = "ADMIN_READ"
    exempted_members = ["allUsers"]
  }
}

# 16. Cloud SQL instance without SSL
resource "google_sql_database_instance" "no_ssl" {
  name             = "nosqlssl"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
  }
}



# 19. App Engine app with insecure domain (simulated)
resource "google_app_engine_application" "insecure_app" {
  project     = var.project_id
  location_id = var.region
  auth_domain = "example.com"
}


# 21. IAM role with wildcard permissions
resource "google_project_iam_custom_role" "wildcard_role" {
  role_id     = "wildcardRole"
  title       = "Wildcard Role"
  description = "Role with overly broad permissions"
  permissions = ["*"]
  project     = var.project_id
}

# 22. Enable legacy access control on a bucket
resource "google_storage_bucket_iam_binding" "legacy_auth" {
  bucket = google_storage_bucket.no_logging.name
  role   = "roles/storage.legacyBucketReader"
  members = ["allUsers"]
}

# 23. IAM user with overly broad permissions
resource "google_project_iam_member" "user_broad" {
  project = var.project_id
  role    = "roles/*"
  member  = "user:broad@example.com"
}

# 24. GKE cluster with legacy auth
resource "google_container_cluster" "legacy_auth" {
  name     = "legacy-cluster"
  location = var.zone

  initial_node_count = 1
  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

# 25. GKE cluster with public endpoint
resource "google_container_cluster" "public_cluster" {
  name     = "public-cluster"
  location = var.zone

  initial_node_count = 1
  private_cluster_config {
    enable_private_nodes = false
  }
}

# 26. Cloud SQL instance without automated backups
resource "google_sql_database_instance" "no_backup" {
  name             = "nobackupsql"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled = false
    }
  }
}

# 27. Cloud Run without authentication
resource "google_cloud_run_service" "no_auth" {
  name     = "cloudrun-noauth"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# 28. Enable overly broad API permissions
resource "google_project_iam_member" "bigquery_full" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "user:bqadmin@example.com"
}

# 29. Cloud Storage signed URL without expiration (simulated)

# 30. VM with serial port access enabled
resource "google_compute_instance" "serial_access" {
  name         = "serial-vm"
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  enable_display = true
  can_ip_forward = true

  metadata = {
    serial-port-enable = "1"
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

# More misconfigurations to follow...
