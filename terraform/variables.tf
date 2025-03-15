
variable "cloud_id" {
  description = "ID облака"
  default = "b1gttf81lmg2v759uobi"
  type        = string
}

variable "folder_id" {
  description = "ID папки"
  default = "b1g8381i07tsfq06pnmc"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  default = "ru-central1-a"
  type        = string
}

variable "token" {
  type        = string
  description = "Переменная в  которой хранится токен доступа к аккаунту"
  sensitive = true
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH ключу"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vpc_name" {
  description = "Имя виртуальной сети k8s"
  type        = string
}

variable "subnet_zone" {
  type        = list(string)
  description = "Список зон"
}

variable "cidr" {
  type        = list(string)
  description = "Список CIDR-ов"
}

variable "master" {
  type = map
  description = "Описание ресурсов для master нод"

}

variable "worker" {
 type = map
 description = "Описание ресурсов для worker нод"
}

variable "bastion" {
  type = map
  description = "Описание ресурсов для master нод"

}






