# ----------------------------------------
#    Main module Input variables
# ----------------------------------------

variable "region_target" {
  description = "The host AWS region for services usage"
  type        = string
}

variable "resource_tags" {
  description = "Baseline tags to identify resources"
  type        = map(string)
}

variable "ssh_public_key_path" {
  description = "SSH public key path"
  type        = string
}

variable "ssh_private_key_path" {
  description = "SSH private key path - WARN just for ephemeral demo usage ! No prod concern"
  type        = string
}

variable "key_pair_name" {
  description = "Key pair name"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The main vpc cidr block definition"
  type = string
}

variable "public_subnet_cidr_block" {
  description = "Public subnet cidr block definition"
  type = string
}

variable "ingress-rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    port        = number
    proto       = string
    cidr_blocks = list(string) 
  }))
}

variable "number_of_instances" {
  description = "Number of nodes to create in the cluster"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Instance type to use for the nodes"
  type        = string
  default     = "t3.medium"
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp2"
}   

variable "ami_id" {
  description = "AMI ID to use for the instances"
  type        = string
}   