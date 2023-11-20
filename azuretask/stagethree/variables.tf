variable "vmpass" {
  type        = string
  default     = ""
  description = "my-vm-password"
}

variable virtualnet {
  default     = ["192.168.0.0/16"]
  description = "description"
}

variable "location" {
  type        = string
  default     = "East US 2"
  description = "rg location"
}

variable mysubnetcidr {
  default     = ["192.168.21.0/24"]
  description = "subnet cidr"
}

variable mysecsubnetcidr {
  default     = ["192.168.0.0/24"]
  description = "my-sec-subnet-cidr"
}

variable thirdsubnetcidr {
  default     = ["192.168.1.0/24"]
  description = "third subnet cidr"
}

variable "client_secret" {
}

variable "client_id" {
}

variable "tenant_id" {
}

variable "subscription_id" {
}




