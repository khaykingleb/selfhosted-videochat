output "droplet_ip" {
  value       = digitalocean_droplet.videochat.ipv4_address
  description = "Droplet IP address"
}
