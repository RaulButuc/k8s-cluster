terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.60.0"
    }
  }
}

provider "google" {

  credentials = file("k8s-cluster.json")

  project = "k8s-cluster-7"
  region  = "europe-west2"
  zone    = "europe-west2-c"

}

resource "google_compute_firewall" "vpc_firewall_rule" {
  name    = "k8s-cluster-firewall-allow-all"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 65534
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "k8s-cluster-subnet"
  ip_cidr_range = "10.2.0.0/16"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_network" "vpc_network" {
  name                    = "k8s-cluster-network"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1500
}

data "google_compute_image" "vm_image" {
  family  = "centos-7"
  project = "centos-cloud"
}

resource "google_compute_instance" "master_node_1" {
  name         = "kubemaster-001"
  machine_type = "n1-standard-2" # 2 vCPU, 7.5 GB memory
  zone         = "europe-west2-c"

  tags = ["master", "true"]

  boot_disk {
    device_name = "master-001"

    initialize_params {
      image = data.google_compute_image.vm_image.self_link
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id
    
    access_config {
      # Auto-generate an Ephemeral IP
    }
  }
}

resource "google_compute_instance" "worker_node_1" {
  name         = "kubeworker-001"
  machine_type = "n1-standard-2" # 2 vCPU, 7.5 GB memory
  zone         = "europe-west2-c"

  boot_disk {
    device_name = "worker-001"

    initialize_params {
      image = data.google_compute_image.vm_image.self_link
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id

    access_config {
      # Auto-generate an Ephemeral IP
    }
  }
}
