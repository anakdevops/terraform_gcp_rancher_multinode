provider "google" {
  project     = "adysur"
  region      = "us-central1"
  credentials = "./adysur-89e7e934541b2fd.json"
}

# Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "terraform-key.pem"
}

# Create a VPC Network
resource "google_compute_network" "vpc_network" {
  name = "rancher-k8s-vpc"
}

# Create Subnets within the VPC
resource "google_compute_subnetwork" "rancher_subnet" {
  name          = "rancher-subnet"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
}

# Create a Firewall Rule to Allow SSH (Port 22)
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create a Firewall Rule to Allow HTTP (Port 80)
resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create a Firewall Rule to Allow Kubernetes API Server (Port 6443)
resource "google_compute_firewall" "k8s-api" {
  name    = "allow-k8s-api"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create Firewall Rule to Allow All Internal Traffic
resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/16"]
}

# Create VM Instances for Rancher Kubernetes Cluster
resource "google_compute_instance" "vm_instance" {
  count        = 2
  name         = "rancher-node-${count.index + 1}"
  machine_type = "n2-standard-4"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20230615"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.rancher_subnet.name

    access_config {
      # Allows external SSH access via the external IP
    }
  }

  metadata = {
    ssh-keys = "terraform:${tls_private_key.ssh_key.public_key_openssh}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl git ansible"
    ]

    connection {
      type        = "ssh"
      user        = "terraform"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  tags = ["ssh", "k8s-api"]
}

# Output the public IPs of all instances
output "instance_ips" {
  value = [for instance in google_compute_instance.vm_instance : instance.network_interface[0].access_config[0].nat_ip]
}

# Output the internal IPs of all instances
output "instance_internal_ips" {
  value = [for instance in google_compute_instance.vm_instance : instance.network_interface[0].network_ip]
}
