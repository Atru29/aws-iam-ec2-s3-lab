variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AZ donde se lanza la EC2"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
  default     = "t3.micro"
}

variable "name" {
  description = "Prefijo para los nombres de la política, el rol y la instancia"
  type        = string
  default     = "lab-iam-s3"
}
