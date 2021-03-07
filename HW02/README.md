# Домашнее задание № 2.

Развернуть при помощи Terraform тестовую среду, включающую в себя хосты для front-end, back-end и базы данных.
Цель: Развернуть при помощи Terraform тестовую среду, включающую в себя хосты для front-end, back-end и базы данных. 

1. Установим terraform на рабочую станцию.
   Инструкция по установке доступна на оф. сайте https://www.terraform.io/downloads.html
   Инструкция по установке в Ubuntu https://www.terraform.io/docs/cli/install/apt.html
   После установки проверим версию terraform
   $ terraform -v
   Terraform v0.14.7

2. Начнем описывать тестовую среду.
   Документация по провайдеру для я.оьлака доступна по ссылке: https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs
   В самом начале опишем в файле mail.tf, что будем работать с я.облаком:
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
   provider "yandex" {
     token     = "<OAuth>"
     cloud_id  = "<идентификатор облака>"
     folder_id = "<идентификатор каталога>"
     zone      = "ru-central1-a"
   }

   Выполним команду terraform init
   
   узнать список id можно запустив команду
   $ yc compute image list --folder-id standard-image
   | fd8vmcue7aajpmeo39kk | ubuntu-2004-lts-1590073935                               | ubuntu-2004-lts              | f2e8e855i10b6gs5pom0 | READY  |
| fd8vp7kchohg5tb9c4rs | debian-9-1538731924                                      | debian-9                     | f2evfhkcsl5npdcfb09t | READY  |
| fd8vpdk1hs9b1kuiiu13 | ubuntu-2004-lts-gpu-1606751539                           | ubuntu-2004-lts-gpu          | f2eclsqdgklas1fb97bu | READY  |
| fd8vpento05muq6pc1oa | fedora-28-1540828205                                     | fedora-28                    | f2eo5pfo65mj806q0hb5 | READY  |
| fd8vqk0bcfhn31stn2ts | ubuntu-1804-lts-1593428267-1593437760                    | ubuntu-1804-lts              | f2e59sb6j1acjjkhb4sc | READY  |
| fd8vu2kvvdomdcfe0i0r | fedora-28-1537474623                                     | fedora-28                    | f2evncnukp6qfbclotnu | READY  |
+----------------------+----------------------------------------------------------+------------------------------+----------------------+--------+


3. dfdsfsd