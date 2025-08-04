// list of elastic ip ids
output "elastic_ip_ids" {
  description = "List of Elastic IP IDs"
  value       = aws_eip.kubeip[*].id
}

// list of elastic ip addresses
output "elastic_ip_addresses" {
  description = "List of Elastic IP addresses"
  value       = aws_eip.kubeip[*].public_ip
}

// list of elastic ip tags
output "elastic_ip_tags" {
  description = "List of Elastic IP tags"
  value       = aws_eip.kubeip[*].tags_all
}

// transform the list of elastic ip addresses to the list of dns names
output "elastic_ip_dns" {
  description = "List of Elastic IP DNS names in ec2-xxx-xxx-xxx-xxx.region.compute.amazonaws.com format"
  value = [
    for ip in aws_eip.kubeip[*].public_ip :
    data.aws_region.current.name == "us-east-1" 
      ? "ec2-${replace(ip, ".", "-")}.compute-1.amazonaws.com"
      : "ec2-${replace(ip, ".", "-")}.${data.aws_region.current.name}.compute.amazonaws.com"
  ]
}

output "elastic_private_ip_dns" {
  description = "List of Elastic Private IP DNS names in ip-xxx-xxx-xxx-xxx.region.compute.amazonaws.com format"
  value = [
    for ip in aws_eip.kubeip[*].private_ip :
    data.aws_region.current.name == "us-east-1" 
      ? "ip-${replace(ip, ".", "-")}.compute-1.amazonaws.com"
      : "ip-${replace(ip, ".", "-")}.${data.aws_region.current.name}.compute.amazonaws.com"
  ]
}

// map of elastic privates dns to public dns
output "private_to_public_dns_map" {
  description = "Map of private DNS names to public DNS names for Elastic IPs"
  value = zipmap(
    [
      for ip in aws_eip.kubeip[*].private_ip :
      data.aws_region.current.name == "us-east-1" 
        ? "ip-${replace(ip, ".", "-")}.compute-1.amazonaws.com"
        : "ip-${replace(ip, ".", "-")}.${data.aws_region.current.name}.compute.internal"
    ],
    [
      for ip in aws_eip.kubeip[*].public_ip :
      data.aws_region.current.name == "us-east-1" 
        ? "ec2-${replace(ip, ".", "-")}.compute-1.amazonaws.com"
        : "ec2-${replace(ip, ".", "-")}.${data.aws_region.current.name}.compute.amazonaws.com"
    ]
  )
}