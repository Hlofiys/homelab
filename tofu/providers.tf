terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.34.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.68.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.1"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.20.0"
    }
  }

  backend "s3" {
    bucket = "tofu"
    key = "homelab/terraform.tfstate"
    region = "us-east-1"
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_metadata_api_check = true
    skip_region_validation = true
    use_path_style = true
    endpoints = {
      s3 = "http://100.93.109.17:7012"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  insecure = var.proxmox.insecure
  api_token = var.proxmox.api_token
  
  ssh {
    agent    = true
    username = var.proxmox.username
  }
}

provider "restapi" {
  uri                  = var.proxmox.endpoint
  insecure             = var.proxmox.insecure
  write_returns_object = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "PVEAPIToken=${var.proxmox.api_token}"
  }
}

provider "kubernetes" {
  host = module.talos.kube_config.kubernetes_client_configuration.host
  client_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
  client_key = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
}
