variable "digitalocean_token" {
  type        = string
  description = "DigitalOcean API token"
  sensitive   = true
}

variable "digitalocean_region" {
  type        = string
  description = "DigitalOcean region"
  default     = "ams3"
}

variable "digitalocean_droplet_image" {
  type        = string
  description = "DigitalOcean droplet image"
  default     = "ubuntu-24-04-x64"
}

variable "digitalocean_droplet_size" {
  type        = string
  description = "DigitalOcean droplet size"
  default     = "s-2vcpu-4gb"
}

variable "k3s_version" {
  type        = string
  description = "K3s version"
  default     = "1.33.4+k3s1"
}

variable "argocd_version" {
  type        = string
  description = "ArgoCD version"
  default     = "3.1.4"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID of the domain"
  sensitive   = true
}
