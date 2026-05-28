terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "project-a4d08db4-7eb7-4947-b50"
  region  = "asia-south1"
  zone    = "asia-south1-a"
}

resource "google_compute_instance" "docker_vm" {
name         = "docker-vm"
machine_type = "e2-micro"

boot_disk {
initialize_params {
image = "ubuntu-os-cloud/ubuntu-2204-lts"
size  = 20
}
}

network_interface {
    network = "default"

    access_config {
    }
  }

metadata_startup_script = <<-EOF
#!/bin/bash

apt update
apt install -y docker.io git

systemctl start docker
systemctl enable docker
EOF

tags = ["docker"]
}

resource "google_compute_firewall" "allow_ports" {
name    = "allow-docker-ports"
network = "default"

allow {
protocol = "tcp"
ports    = ["22", "80", "443", "3000"]
}

source_ranges = ["0.0.0.0/0"]

target_tags = ["docker"]
}

output "vm_external_ip" {
value = google_compute_instance.docker_vm.network_interface[0].access_config[0].nat_ip
}
