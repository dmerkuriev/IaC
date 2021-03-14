# Домашнее задание № 2.

Развернуть при помощи Terraform тестовую среду, включающую в себя хосты для front-end, back-end и базы данных.
Цель: Развернуть при помощи Terraform тестовую среду, включающую в себя хосты для front-end, back-end и базы данных. 

1. ### Установим terraform на рабочую станцию.  
   Инструкция по установке доступна на оф. сайте https://www.terraform.io/downloads.html  
   Инструкция по установке в Ubuntu https://www.terraform.io/docs/cli/install/apt.html  
   После установки проверим версию terraform:  
   ```
   $ terraform -v
   Terraform v0.14.7
   ```

2. ### Опишим тестовую среду.  
   Документация по провайдеру для я.облака доступна по ссылке: https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs  
   В самом начале опишем в файле main.tf, что будем работать с я.облаком:  
   ```
   terraform {
     required_providers {
       yandex = {
         source = "yandex-cloud/yandex"
     }
    }
   }

   provider "yandex" {
     cloud_id  = var.cloud_id
     folder_id = var.folder_id
     zone      = var.zone
     token     = var.yc_token
   }
   ```
  
   Опишем переменные в файле variables.tf  
   ```
   variable "zone" {
     type = string
   }

   variable "cloud_id" {
     type = string
   }

   variable "folder_id" {
     type = string
   }

   variable "yc_token" {
     type = string
   }

   variable "image_id" {
     type = string
   }
   ```  

   Выставим значение переменных в файле terraform.tfvars  
   ```
   yc_token  = "<OAuth>"
   cloud_id  = "<идентификатор облака>"
   folder_id = "<идентификатор каталога>"
   zone      = "ru-central1-a"
   image_id  = "fd8vmcue7aajpmeo39kk"
   ```

   узнать список image_id можно запустив команду:  
   ```
   $ yc compute image list --folder-id standard-image
   ```  
   Далее нужно выполнить команду terraform init.  

   Добавим описание создания двух ВМ, которые в будущем будут использоваться для back-end серверов.  
   ```
   resource "yandex_compute_instance" "back" {
     count = 2
     name  = "back-${count.index}"

     resources {
       cores  = 2
       memory = 2
     }

     boot_disk {
       initialize_params {
         image_id = var.image_id
       }
     }

     network_interface {
       subnet_id = yandex_vpc_subnet.subnet-1.id
       nat       = true
     }

     metadata = {
       ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
     }

     connection {
       type        = "ssh"
       user        = "ubuntu"
       private_key = file("~/.ssh/id_rsa")
       host        = self.network_interface.0.nat_ip_address
     }

     provisioner "remote-exec" {
       inline = [
         "sudo echo 'Hello back'",
       ]
     }
   }
   ```  
   Добавим создание сети и подсети.  
   ```
   resource "yandex_vpc_network" "network-1" {
     name = "network1"
   }

   resource "yandex_vpc_subnet" "subnet-1" {
     name           = "subnet1"
     zone           = "ru-central1-c"
     network_id     = yandex_vpc_network.network-1.id
     v4_cidr_blocks = ["192.168.10.0/24"]
   }
   ```  
   Аналогично тому как мы добавили создание ВМ для back-end, опишем создание ВМ для front-end и db серверов.
   ```
   resource "yandex_compute_instance" "front" {
     count = 2
     name  = "web-${count.index}"

     resources {
       cores  = 2
       memory = 2
     }

     boot_disk {
       initialize_params {
         image_id = var.image_id
       }
     }

     network_interface {
       subnet_id = yandex_vpc_subnet.subnet-1.id
       nat       = true
     }

     metadata = {
       ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
     }

     connection {
       type        = "ssh"
       user        = "ubuntu"
       private_key = file("~/.ssh/id_rsa")
       host        = self.network_interface.0.nat_ip_address
     }

     provisioner "remote-exec" {
       inline = [
         "sudo echo 'hello front'",
       ]
     }
   }

   resource "yandex_compute_instance" "db" {
     count = 2
     name  = "db-${count.index}"

     resources {
       cores  = 2
       memory = 2
     }

     boot_disk {
       initialize_params {
         image_id = var.image_id
       }
     }

     network_interface {
       subnet_id = yandex_vpc_subnet.subnet-1.id
       nat       = true
     }

     metadata = {
       ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
     }

     connection {
       type        = "ssh"
       user        = "ubuntu"
       private_key = file("~/.ssh/id_rsa")
       host        = self.network_interface.0.nat_ip_address
     }

     provisioner "remote-exec" {
       inline = [
         "sudo echo 'hello db'",
       ]
     }
   }
   ```  

3. ### Добавим вывод внешних и внутренних адресов в выводные переменные. 
   Для удобства вынесем внешние переменные в отдельный файл outputs.tf:
   ```
   output "internal_ip_address_front" {
     value = yandex_compute_instance.front.*.network_interface.0.ip_address
   }

   output "external_ip_address_front" {
     value = yandex_compute_instance.front.*.network_interface.0.nat_ip_address
   }

   output "internal_ip_address_back" {
     value = yandex_compute_instance.back.*.network_interface.0.ip_address
   }

   output "external_ip_address_back" {
     value = yandex_compute_instance.back.*.network_interface.0.nat_ip_address
   }

   output "internal_ip_address_db" {
     value = yandex_compute_instance.db.*.network_interface.0.ip_address
   }

   output "external_ip_address_db" {
     value = yandex_compute_instance.db.*.network_interface.0.nat_ip_address
   }
   ```
4. ### Проверка и запуск.
      
   Проверим написаный нами код с помощью команды:  
   ```
   $ terraform validate
   Success! The configuration is valid.
   ```

   Проверим какие ресурсы будут созданы с помощью команды:  
   ```
   $ terraform plan
   ...
   
   ```  

   Запустим выполнение:  
   ```
   $ terraform apply
   ...
   yandex_compute_instance.back[1] (remote-exec): Hello back
   yandex_compute_instance.back[0] (remote-exec): Hello back
   yandex_compute_instance.front[0] (remote-exec): hello front
   yandex_compute_instance.front[1] (remote-exec): hello front
   yandex_compute_instance.db[0] (remote-exec): hello db
   yandex_compute_instance.db[1] (remote-exec): hello db
   ...
   Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

   Outputs:

   external_ip_address_back = [
     "178.154.213.144",
     "178.154.208.143",
   ]
   external_ip_address_db = [
     "178.154.210.214",
     "178.154.208.112",
   ]
   external_ip_address_front = [
     "178.154.210.143",
     "178.154.211.254",
   ]
   internal_ip_address_back = [
     "192.168.10.22",
     "192.168.10.12",
   ]
   internal_ip_address_db = [
     "192.168.10.18",
     "192.168.10.13",
   ]
   internal_ip_address_front = [
     "192.168.10.25",
     "192.168.10.9",
   ]
   ```
   В конце видим результат наш выводных переменных с адресами. Можно зайти в веб-интерфейс я.облака и убедится что описанные нами выше ресурсы созданы.

