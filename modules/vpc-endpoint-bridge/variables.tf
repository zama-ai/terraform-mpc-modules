variable "service_details" {
  description = "List of MPC service details to create VPC endpoint services for"
  type        = list(object({
    display_name        = string
    lb_arn              = string
  }))
}

//variable "nlb_names" {
//  description = "List of Network Load Balancer names to create VPC endpoint services for"
//  type        = list(string)
//
//  validation {
//    condition     = length(var.nlb_names) > 0
//    error_message = "At least one NLB name must be provided."
//  }
//}
//
//variable "service_names" {
//  description = "List of MPC service names to create VPC endpoint services for"
//  type        = list(string)
//
//  validation {
//    condition     = length(var.service_names) > 0
//    error_message = "At least one MPC service name must be provided."
//  }
//}

variable "acceptance_required" {
  description = "Whether or not VPC endpoint connection requests to the service must be accepted by the service owner"
  type        = bool
  default     = false
}

variable "supported_regions" {
  description = "List of AWS regions supported by the VPC endpoint service"
  type        = list(string)
  default     = []
}

variable "allowed_principals" {
  description = "List of AWS principal ARNs allowed to discover and connect to the endpoint service. Use ['*'] to allow all principals"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the VPC endpoint services"
  type        = map(string)
  default     = {}
} 