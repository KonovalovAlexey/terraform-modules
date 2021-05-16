variable "allowed_ports" {
  default     = ["80", "443", "8080", "22", "9100", "9090"]
  description = "List of ports allowed on servers"
}


variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "env" {
  default = "dev"
}

variable "subnet_id" {}

variable "key_pub" {
  default = "id_rsa"
}
