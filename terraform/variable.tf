variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "project" {
    type = string
    default = "success"
}

variable "app_subnet1_cidr" {
  type = string
  default = "10.0.0.0/24"
}

variable "app_subnet2_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "db_subnet1_cidr" {
  type = string
  default = "10.0.2.0/24"
}

variable "db_subnet2_cidr" {
  type = string
  default = "10.0.3.0/24"
}

variable "web_subnet1_cidr" {
  type = string
  default = "10.0.4.0/24"
}

variable "web_subnet2_cidr" {
  type = string
  default = "10.0.5.0/24"
}

variable "ssh-port" {
    type = number
    default = 22
}

variable "db_username_file" {
  type = string
  default = "db_username.txt"
}

variable "db_password_file" {
  type = string
  default = "db_password.txt"
}

variable "db_username" {
  type = string
  default = "successadmin"
}