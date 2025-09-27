###############################################################################
#@ SSH configuration
###############################################################################

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_ssh_key" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "${path.root}/ssh/id_digitalocean_droplet_rsa"
}

resource "digitalocean_ssh_key" "ssh" {
  name       = "videochat-droplet-ssh-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

###############################################################################
#@ VM instance
###############################################################################

resource "digitalocean_droplet" "videochat" {
  name   = "videochat-droplet"
  region = var.digitalocean_region

  image = var.digitalocean_droplet_image
  size  = var.digitalocean_droplet_size
  user_data = templatefile("${path.root}/config/cloud-init.tmpl.yaml", {
    node_name                   = "videochat-droplet"
    k3s_version                 = var.k3s_version
    argocd_version              = var.argocd_version
    argocd_repo_path            = "argocd-apps"
    argocd_repo_url             = "https://github.com/khaykingleb/selfhosted-videochat.git"
    argocd_repo_target_revision = "backbone"
  })

  ssh_keys = [digitalocean_ssh_key.ssh.fingerprint]
}

resource "digitalocean_firewall" "videochat" {
  name        = "videochat-firewall"
  droplet_ids = [digitalocean_droplet.videochat.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  # HTTP connections
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS connections
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # TCP WebRTC connections of Matrix RTC Backend
  inbound_rule {
    protocol         = "tcp"
    port_range       = "30881"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Muxed WebRTC connections of Matrix RTC Backend
  inbound_rule {
    protocol         = "udp"
    port_range       = "30882"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

###############################################################################
#@ DNS
###############################################################################

# data "cloudflare_zone" "khaykingleb_com" {
#   zone_id = var.cloudflare_zone_id
# }

resource "cloudflare_dns_record" "videochat" {
  zone_id = var.cloudflare_zone_id
  name    = "videochat"
  type    = "A"
  content = digitalocean_droplet.videochat.ipv4_address
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "wildcard_videochat" {
  zone_id = var.cloudflare_zone_id
  name    = "*.videochat"
  type    = "A"
  content = digitalocean_droplet.videochat.ipv4_address
  proxied = false
  ttl     = 1
}
