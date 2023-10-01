AWS VPC Terraform module
Terraform module which creates VPC resources on AWS.

By default this module will provision new Elastic IPs for the VPC's NAT Gateways. This means that when creating a new VPC, new IPs are allocated, and when that VPC is destroyed those IPs are released. Sometimes it is handy to keep the same IPs even after the VPC is destroyed and re-created. To that end, it is possible to assign existing IPs to the NAT Gateways. This prevents the destruction of the VPC from releasing those IPs, while making it possible that a re-created VPC uses the same IPs.

To achieve this, allocate the IPs outside the VPC module declaration.