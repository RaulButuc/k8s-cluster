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
  priority      = 65535
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
