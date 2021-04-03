terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.53.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  token     = var.yc_token
}

module "compute" {
    source = "../../modules/compute"
    zone   = "ru-central1-c"
    
    name   = "web"
    hostname = "webserver"

    cores  = 2
    memory = 2
    size   = "5"
    core_fraction = "50"
    
    instance_count = 2

    is_nat = true

    preemptible = true
}

output "external_ip" {
    value = module.compute.external_ip
}

output "internal_ip" {
    value = module.compute.internal_ip
}
