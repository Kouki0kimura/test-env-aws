# variable setting
### region ###
variable "region"{
  default     = "ap-northeast-1"
}

### AZ ###
variable "az_a" {
  default     = "ap-northeast-1a"
}

### IAM user info ###
variable "access_key" {
  default     = "AKIATDWOFAUWBFKSZO7G"
}
variable "secret_key" {
  default     = "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"
}

### Key pair ###
variable "key_name" {
  default = "access-test"
}

### VPC ###
## vpc_01
# cider block-a1
variable "cider_block_a1" {
  default = "10.0.0.0/16"
}
# subnet-a1
variable "subnet-a1" {
  default = "10.0.0.0/24"
}
## vpc_02
# cider block-b1
variable "cider_block_b1" {
  default = "10.1.0.0/16"
}
# subnet-b1
variable "subnet-b1" {
  default = "10.1.0.0/24"
}

### tag ###
variable "test_tag"{
  default = "test"
}

