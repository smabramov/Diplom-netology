
# Создание групп целей для балансировщика нагрузки
resource "yandex_lb_target_group" "k8s-cluster" {
  name = "k8s-cluster"
  target {
    subnet_id = yandex_vpc_subnet.ru-central1-a.id
    address   = yandex_compute_instance.worker-1.network_interface[0].ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.ru-central1-b.id
    address   = yandex_compute_instance.worker-2.network_interface[0].ip_address
  }
 }

#Создание сетевого балансировщика приложения

resource "yandex_lb_network_load_balancer" "web-app" {
  name = "web-app"

  listener {
    name        = "app-web"
    port        = 80
    target_port = 31080
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s-cluster.id
    healthcheck {
      name = "web"
      tcp_options {
        port = 22

      }
    }
  }
}

#Создание сетевого балансировщика мониторинга

resource "yandex_lb_network_load_balancer" "monitoring-app" {
  name = "monitoring-app"

  listener {
    name        = "app-grafana"
    port        = 80
    target_port = 31000

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s-cluster.id
    healthcheck {
      name = "monitoring"
      tcp_options {
        port = 22

      }
    }
  }
}

