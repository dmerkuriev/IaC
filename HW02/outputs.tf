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