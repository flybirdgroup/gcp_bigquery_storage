provider "google" {
  credentials = "${file("${var.credentials_file}")}"
  project = "${var.project}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}

resource "google_bigquery_dataset" "dataset" {
  depends_on = ["google_compute_instance.default"]
  dataset_id                  = "fakedatas"
  friendly_name               = "fakedatas"
  description                 = "This is a data generation dataset description"
  labels = {
    env = "default"
  }
  access = {
    role          = "OWNER"
    user_by_email = "${google_compute_instance.default.service_account.0.email}"
  }

  access = {
    role          = "OWNER"
    user_by_email = "flybirdgroup16@gmail.com"
  }

  access = {
    role   = "READER"
    domain = "hashicorp.com"
  }
}



resource "google_compute_instance" "default" {
  project      = "${var.project}"
  name         = "terraform"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"
  tags         = ["web", "dev","http-server","https-server"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  service_account {scopes = ["userinfo-email", "compute-rw", "storage-full","bigquery"]}
  allow_stopping_for_update = "true"
  network_interface {
    network = "default"
    access_config {
      nat_ip = "${google_compute_address.vm_static_ip.address}"
    }
  }

  metadata_startup_script = "${file("${var.jupyter_sh}")}" 
}


resource "google_storage_bucket_access_control" "public_rule" {
  bucket = "${google_storage_bucket.example_bucket.name}"
  role   = "WRITER"
  entity = "allUsers"
}

resource "google_storage_bucket" "example_bucket" {
  depends_on = ["google_compute_instance.default"]
  name     = "${var.bucket_name}"
  location = "US"
  force_destroy = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}