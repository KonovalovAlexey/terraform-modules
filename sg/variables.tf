variable "allowed_ports" {
  default     = ["80", "443", "8080", "22", "3000"]
  description = "List of ports allowed on servers"
}


variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "env" {
  default = "dev"
}

//variable "subnet_id" { type = string}


variable "vpc_id" { type = string }

variable "alfabetic" {
  default = ["a", "b", "c"]
}
