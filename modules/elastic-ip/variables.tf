variable "name" {
  type        = string
  description = "Name of the Elastic IP"
  default     = "elastic-ip"
}

variable "number_of_ips" {
  type        = number
  description = "Number of Elastic IPs to create"
  default     = 1
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Elastic IP"
  default     = {}
}