variable "project" {
  description = "project name"
}

variable "location" {
  description = "Location of the resource group."
}

variable "env" {
  description = "Environment deployed"
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    org = "jeremypageitcompany",
    env = "lab"
  }
}

variable "subnet_vnet" {
  description = "subnet for the VNET"
  default     = "10.0.0.0/16"
}

variable "subnet" {
  description = "prefixes and names for different subnets"
  default = {
    "mgmt" = {
      "prefix" = ["10.0.0.0/24"]
    },
    "untrust" = {
      "prefix" = ["10.0.1.0/24"]
    },
    "trust" = {
      "prefix" = ["10.0.2.0/24"]
    }
  }
}

variable "public_ip_sku" {
  description = "Type of SKU for public IP"
  default     = "Standard"
}

variable "lb_sku" {
  description = "Type of SKU for lb"
  default     = "Standard"
}

variable "palovm" {
  description = "variables for each of the palovm"
  default = {
    "palovm1" = {
      "mgmt_ip"    = "10.0.0.4"
      "untrust_ip" = "10.0.1.4"
      "trust_ip"   = "10.0.2.4"
    },
    "palovm2" = {
      "mgmt_ip"    = "10.0.0.5"
      "untrust_ip" = "10.0.1.5"
      "trust_ip"   = "10.0.2.5"
    }
  }
}

variable "vm_size" {
  description = "Size of the VM for the Palo Alto"
  default     = "Standard_DS3_v2" #vm100
}

variable "vm_publisher" {
  default = "paloaltonetworks"
}

variable "vm_sku" {
  default = "byol"
}

variable "vm_offer" {
  default = "vmseries-flex"
}

variable "vm_version" {
  default = "latest"
}

variable "vm_username" {
  description = "vm username"
  type        = string
  sensitive   = true
}

variable "vm_password" {
  description = "vm password"
  type        = string
  sensitive   = true
}

variable "subnet_server" {
  description = "prefix for the servers subnet"
  default     = ["10.0.100.0/24"]
}

variable "frontend_ip_internal_lb" {
  description = "IP"
  default     = "10.0.2.100"
}