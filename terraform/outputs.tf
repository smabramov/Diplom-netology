output "all_vms" {
  description = "Information about the instances"
  value = {
    bastion-nat = [
         {  name = yandex_compute_instance.bastion-nat.name
            nat_ip_address = yandex_compute_instance.bastion-nat.network_interface[0].nat_ip_address
        }
        ],    
    master = [
       {
        name = yandex_compute_instance.master.name
        ip_address = yandex_compute_instance.master.network_interface[0].ip_address
              
      }],       
}

}

output "web" {
  value = [
    for listener in yandex_lb_network_load_balancer.web-app.listener : {
      name    = listener.name
      port    = listener.port
      address = [for addr in listener.external_address_spec : addr.address][0]
    }
  ]
}

output "monitoring" {
  value = [
    for listener in yandex_lb_network_load_balancer.monitoring-app.listener : {
      name    = listener.name
      port    = listener.port
      address = [for addr in listener.external_address_spec : addr.address][0]
    }
  ]
}
