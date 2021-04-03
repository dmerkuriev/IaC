variable "zone" {
  type = string
  default = "ru-central1-c"
}

variable "image_family" {
  description = "Yandex Cloud Compute Image family"
  type = string
  default = "ubuntu-2004-lts"
}

variable "platform_id" {
  description = "The type of virtual machine to create"
  type        = string
  default     = "standard-v2"
}

variable "instance_count" {
  description = "Yandex Cloud Compute instance count"
  type        = number
  default     = 1
}

variable "name" {
  description = "Yandex Cloud Compute instance name"
  type        = string
}

variable "hostname" {
  description = "Host name for the instance. This field is used to generate the instance fqdn value"
  type        = string
}

# Preemtible VM: https://cloud.yandex.ru/docs/compute/concepts/preemptible-vm
variable "preemptible" {
  description = "Specifies if the instance is preemptible"
  type        = bool
  default     = false
}

variable "is_nat" {
  description = "Provide a public address for instance to access the internet over NAT"
  type        = bool
  default     = false
}

variable "size" {
  description = "Size of the boot disk in GB"
  type        = string
  default     = "10"
}

variable "cores" {
  description = "CPU cores for the instance"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory size for the instance in GB"
  type        = number
  default     = 2
}

variable "core_fraction" {
  description = "Baseline performance for a core as a percent"
  type        = number
  default     = 100
}

variable "ip_address" {
  description = "The private IP address to assign to the instance. If empty, the address will be automatically assigned from the specified subnet"
  type        = string
  default     = ""
}
