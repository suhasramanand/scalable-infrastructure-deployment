# IAM Module Variables

variable "name" {
  description = "Name prefix for IAM resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
