# Дипломный практикум в Yandex.Cloud - Абрамов Сергей 
   * [Цели:](#цели)
   * [Этапы выполнения:](#этапы-выполнения)
      * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
      * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
      * [Создание тестового приложения](#создание-тестового-приложения)
      * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
      * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
   * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
   * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)
 
 **Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**
 
 ---
 ## Цели:
 
 1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
 2. Запустить и сконфигурировать Kubernetes кластер.
 3. Установить и настроить систему мониторинга.
 4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
 5. Настроить CI для автоматической сборки и тестирования.
 6. Настроить CD для автоматического развёртывания приложения.
 
 ---
 ## Этапы выполнения:
 
 
 ### Создание облачной инфраструктуры
 
 Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).
 
 Особенности выполнения:
 
 - Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
 Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
 
 Предварительная подготовка к установке и запуску Kubernetes кластера.
 
 1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
 2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
    а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
    б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
 3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
 4. Создайте VPC с подсетями в разных зонах доступности.
 5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
 6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.
 
 Ожидаемые результаты:
 
 1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
 2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.
 
 ---
 ### Создание Kubernetes кластера
 
 На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.
 
 Это можно сделать двумя способами:
 
 1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
    а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
    б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
    в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
 2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
   а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
   б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
   
 Ожидаемый результат:
 
 1. Работоспособный Kubernetes кластер.
 2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
 3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.
 
 ---
 ### Создание тестового приложения
 
 Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.
 
 Способ подготовки:
 
 1. Рекомендуемый вариант:  
    а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
    б. Подготовьте Dockerfile для создания образа приложения.  
 2. Альтернативный вариант:  
    а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.
 
 Ожидаемый результат:
 
 1. Git репозиторий с тестовым приложением и Dockerfile.
 2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.
 
 ---
 ### Подготовка cистемы мониторинга и деплой приложения
 
 Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
 Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.
 
 Цель:
 1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
 2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.
 
 Способ выполнения:
 1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).
 
 2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.
 
 Ожидаемый результат:
 1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
 2. Http доступ на 80 порту к web интерфейсу grafana.
 3. Дашборды в grafana отображающие состояние Kubernetes кластера.
 4. Http доступ на 80 порту к тестовому приложению.
 ---
 ### Установка и настройка CI/CD
 
 Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.
 
 Цель:
 
 1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
 2. Автоматический деплой нового docker образа.
 
 Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.
 
 Ожидаемый результат:
 
 1. Интерфейс ci/cd сервиса доступен по http.
 2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
 3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.


### Проект

### Создание облачной инфраструктуры

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя.

2. Подготовил S3 bucket в созданном ЯО аккаунте(создание бакета через TF).

3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.

4. Создайте VPC с подсетями в разных зонах доступности.

5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.

### Решение.

Подготовил конфигурацию и запустил её.Результат выполнения.

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # local_file.backend will be created
  + resource "local_file" "backend" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "../terraform/secret.backend.tfvars"
      + id                   = (known after apply)
    }

  # yandex_iam_service_account.sa will be created
  + resource "yandex_iam_service_account" "sa" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + name       = "sa-diplom"
    }

  # yandex_iam_service_account_static_access_key.sa-static-key will be created
  + resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
      + access_key                   = (known after apply)
      + created_at                   = (known after apply)
      + encrypted_secret_key         = (known after apply)
      + id                           = (known after apply)
      + key_fingerprint              = (known after apply)
      + output_to_lockbox_version_id = (known after apply)
      + secret_key                   = (sensitive value)
      + service_account_id           = (known after apply)
    }

  # yandex_resourcemanager_folder_iam_member.sa-editor will be created
  + resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
      + folder_id = "b1g8381i07tsfq06pnmc"
      + id        = (known after apply)
      + member    = (known after apply)
      + role      = "storage.editor"
    }

  # yandex_storage_bucket.tstate will be created
  + resource "yandex_storage_bucket" "tstate" {
      + access_key            = (known after apply)
      + acl                   = "private"
      + bucket                = "bucket-smabramov-2025"
      + bucket_domain_name    = (known after apply)
      + default_storage_class = (known after apply)
      + folder_id             = (known after apply)
      + force_destroy         = true
      + id                    = (known after apply)
      + secret_key            = (sensitive value)
      + website_domain        = (known after apply)
      + website_endpoint      = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_iam_service_account.sa: Creating...
yandex_iam_service_account.sa: Creation complete after 2s [id=ajetoavnj8dp03150chc]
yandex_resourcemanager_folder_iam_member.sa-editor: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creating...
yandex_iam_service_account_static_access_key.sa-static-key: Creation complete after 1s [id=ajefqno6m57m200kge0f]
yandex_storage_bucket.tstate: Creating...
yandex_resourcemanager_folder_iam_member.sa-editor: Creation complete after 3s [id=b1g8381i07tsfq06pnmc/storage.editor/serviceAccount:ajetoavnj8dp03150chc]
yandex_storage_bucket.tstate: Still creating... [11s elapsed]
yandex_storage_bucket.tstate: Creation complete after 13s [id=bucket-smabramov-2025]
local_file.backend: Creating...
local_file.backend: Creation complete after 0s [id=b0d6139aabb3b4733f00c7cfe6d4b6d208036d54]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```
![sa](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/sa.png)

![bucket](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/bucket.png)

Установил утилиту yc - порядок установки описан в этой статье [yandex-cloud](https://yandex.cloud/ru/docs/cli/quickstart)

Файл конфигурации сохранился по ../terraform/secret.backend.tfvars, для инициализации конфигурации использовал команду.

```
serg@k8snode:~/diplom/Diplom-netology/terraform$ 

Initializing the backend...
Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.135.0...
- Installed yandex-cloud/yandex v0.135.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

╷
│ Warning: Missing backend configuration
│ 
│ -backend-config was used without a "backend" block in the configuration.
│ 
│ If you intended to override the default local backend configuration,
│ no action is required, but you may add an explicit backend block to your
│ configuration to clear this warning:
│ 
│ terraform {
│   backend "local" {}
│ }
│ 
│ However, if you intended to override a defined backend, please verify that
│ the backend configuration is present and valid.
│ 
╵

╷
│ Warning: Incomplete lock file information for providers
│ 
│ Due to your customized provider installation methods, Terraform was forced to calculate lock file checksums locally
│ for the following providers:
│   - yandex-cloud/yandex
│ 
│ The current .terraform.lock.hcl file only includes checksums for linux_amd64, so Terraform running on another platform
│ will fail to install these providers.
│ 
│ To calculate additional checksums for another platform, run:
│   terraform providers lock -platform=linux_amd64
│ (where linux_amd64 is the platform to generate)
╵

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Подготовил конфигурацию для создания сети VPC-k8s под кластер и проверил terraform apply и terraform destroy.

```
serg@k8snode:~/diplom/Diplom-netology/terraform$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # yandex_vpc_network.k8s will be created
  + resource "yandex_vpc_network" "k8s" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "VPC-k8s"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.ru-central1-a will be created
  + resource "yandex_vpc_subnet" "ru-central1-a" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "ru-central1-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.ru-central1-b will be created
  + resource "yandex_vpc_subnet" "ru-central1-b" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "ru-central1-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.2.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.ru-central1-d will be created
  + resource "yandex_vpc_subnet" "ru-central1-d" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "ru-central1-d"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.3.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-d"
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.k8s: Creating...
yandex_vpc_network.k8s: Creation complete after 2s [id=enpno0pkk2ldefqigupg]
yandex_vpc_subnet.ru-central1-a: Creating...
yandex_vpc_subnet.ru-central1-d: Creating...
yandex_vpc_subnet.ru-central1-b: Creating...
yandex_vpc_subnet.ru-central1-a: Creation complete after 0s [id=e9bnptpqt8b439reu964]
yandex_vpc_subnet.ru-central1-d: Creation complete after 1s [id=fl8oc6mggrch4aju4bl0]
yandex_vpc_subnet.ru-central1-b: Creation complete after 1s [id=e2l72mik1cqetlr8m9q5]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
serg@k8snode:~/diplom/Diplom-netology/terraform$ terraform destroy
yandex_vpc_network.k8s: Refreshing state... [id=enpno0pkk2ldefqigupg]
yandex_vpc_subnet.ru-central1-a: Refreshing state... [id=e9bnptpqt8b439reu964]
yandex_vpc_subnet.ru-central1-b: Refreshing state... [id=e2l72mik1cqetlr8m9q5]
yandex_vpc_subnet.ru-central1-d: Refreshing state... [id=fl8oc6mggrch4aju4bl0]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  - destroy

Terraform will perform the following actions:

  # yandex_vpc_network.k8s will be destroyed
  - resource "yandex_vpc_network" "k8s" {
      - created_at                = "2025-01-30T12:06:01Z" -> null
      - default_security_group_id = "enppbhnk5ol5ba7gsc1a" -> null
      - folder_id                 = "b1g8381i07tsfq06pnmc" -> null
      - id                        = "enpno0pkk2ldefqigupg" -> null
      - labels                    = {} -> null
      - name                      = "VPC-k8s" -> null
      - subnet_ids                = [
          - "e2l72mik1cqetlr8m9q5",
          - "e9bnptpqt8b439reu964",
          - "fl8oc6mggrch4aju4bl0",
        ] -> null
        # (1 unchanged attribute hidden)
    }

  # yandex_vpc_subnet.ru-central1-a will be destroyed
  - resource "yandex_vpc_subnet" "ru-central1-a" {
      - created_at     = "2025-01-30T12:06:04Z" -> null
      - folder_id      = "b1g8381i07tsfq06pnmc" -> null
      - id             = "e9bnptpqt8b439reu964" -> null
      - labels         = {} -> null
      - name           = "ru-central1-a" -> null
      - network_id     = "enpno0pkk2ldefqigupg" -> null
      - v4_cidr_blocks = [
          - "10.10.1.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-a" -> null
        # (2 unchanged attributes hidden)
    }

  # yandex_vpc_subnet.ru-central1-b will be destroyed
  - resource "yandex_vpc_subnet" "ru-central1-b" {
      - created_at     = "2025-01-30T12:06:04Z" -> null
      - folder_id      = "b1g8381i07tsfq06pnmc" -> null
      - id             = "e2l72mik1cqetlr8m9q5" -> null
      - labels         = {} -> null
      - name           = "ru-central1-b" -> null
      - network_id     = "enpno0pkk2ldefqigupg" -> null
      - v4_cidr_blocks = [
          - "10.10.2.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-b" -> null
        # (2 unchanged attributes hidden)
    }

  # yandex_vpc_subnet.ru-central1-d will be destroyed
  - resource "yandex_vpc_subnet" "ru-central1-d" {
      - created_at     = "2025-01-30T12:06:04Z" -> null
      - folder_id      = "b1g8381i07tsfq06pnmc" -> null
      - id             = "fl8oc6mggrch4aju4bl0" -> null
      - labels         = {} -> null
      - name           = "ru-central1-d" -> null
      - network_id     = "enpno0pkk2ldefqigupg" -> null
      - v4_cidr_blocks = [
          - "10.10.3.0/24",
        ] -> null
      - v6_cidr_blocks = [] -> null
      - zone           = "ru-central1-d" -> null
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 4 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

yandex_vpc_subnet.ru-central1-b: Destroying... [id=e2l72mik1cqetlr8m9q5]
yandex_vpc_subnet.ru-central1-d: Destroying... [id=fl8oc6mggrch4aju4bl0]
yandex_vpc_subnet.ru-central1-a: Destroying... [id=e9bnptpqt8b439reu964]
yandex_vpc_subnet.ru-central1-b: Destruction complete after 1s
yandex_vpc_subnet.ru-central1-a: Destruction complete after 1s
yandex_vpc_subnet.ru-central1-d: Destruction complete after 1s
yandex_vpc_network.k8s: Destroying... [id=enpno0pkk2ldefqigupg]
yandex_vpc_network.k8s: Destruction complete after 1s

Destroy complete! Resources: 4 destroyed.
```
![state](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/state.png)

![VPC](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/VPC.png)


### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

### Решение.

Для развертывания кластера используются версии ПО:
Terraform v1.8.4-dev
ansible [core 2.17.8]
Ubuntu 22.04.5 LTS

Подготовил конфигурацию и добавил bastion для безопасности структуры.
Занчения для переменных в файле personal.auto.tfvars:

```
cloud_id = " "
folder_id = " "
zone = "ru-central1-a"
token = " "
vpc_name = "VPC-k8s"
subnet_zone = ["ru-central1-a","ru-central1-b","ru-central1-d"]
cidr = ["10.10.1.0/24","10.10.2.0/24","10.10.3.0/24","10.0.0.0/24"]

master = {
    cores = 4, 
    memory = 4, 
    core_fraction = 20,  
    platform_id = "standard-v3", 
    count = 1,image_id = "fd8slhpjt2754igimqu8", 
    disk_sze = 40,
    scheduling_policy = "true"
    }

worker = {
    cores = 4, 
    memory = 4, 
    core_fraction = 20,  
    platform_id = "standard-v3", 
    count = 2,image_id = "fd8slhpjt2754igimqu8", 
    disk_sze = 40,
    scheduling_policy = "true"
    } 

bastion = {
    cores = 2, 
    memory = 2, 
    core_fraction = 20, 
    image_id = "fd8m30o437b5c6b9en6r", 
    disk_sze = 20,
    scheduling_policy = "true"
    }
```
Применил изменения:

```
Apply complete! Resources: 8 added, 3 changed, 0 destroyed.

Outputs:

all_vms = {
  "bastion-nat" = [
    {
      "name" = "bastion-nat"
      "nat_ip_address" = "158.160.59.138"
    },
  ]
  "master" = [
    {
      "ip_address" = "10.10.1.26"
      "name" = "k8s-master"
    },
  ]
}
```

![vm](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/vm.png)

Также автоматически создался файл /ansible/host.yaml:

```
all:
    hosts:
        k8s-master:
            ansible_host:
            ip: 10.10.1.26
            ansible_user: ubuntu
            ansible_ssh_common_args: -J ubuntu@158.160.59.138

        k8s-worker-1:
            ansible_host:
            ip: 10.10.1.6
            ansible_user: ubuntu
            ansible_ssh_common_args: -J ubuntu@158.160.59.138
        
        k8s-worker-2:
            ansible_host:
            ip: 10.10.2.19
            ansible_user: ubuntu
            ansible_ssh_common_args: -J ubuntu@158.160.59.138
         
        
        
kube_control_plane:
    hosts: 
        k8s-master:
kube_node:
    hosts:
        k8s-worker-1:
        k8s-worker-2:
etcd:
    hosts: 
        k8s-master:
```
Подключаюсь к кластеру:

```
serg@k8snode:~/diplom$ ssh ubuntu@10.10.1.26 -J ubuntu@158.160.59.138
The authenticity of host '158.160.59.138 (158.160.59.138)' can't be established.
ED25519 key fingerprint is SHA256:MKU6286F/iJvYlaW8zaxf83YS0bd350tQVZwxqNkd8U.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '158.160.59.138' (ED25519) to the list of known hosts.
The authenticity of host '10.10.1.26 (<no hostip for proxy command>)' can't be established.
ED25519 key fingerprint is SHA256:YKXQp0r5S15+7apJseZoIsCmDANMwQ64mmH/MHNuQYo.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.10.1.26' (ED25519) to the list of known hosts.
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-130-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Jan 30 04:35:40 PM UTC 2025

  System load:  0.0                Processes:             147
  Usage of /:   10.3% of 39.28GB   Users logged in:       0
  Memory usage: 5%                 IPv4 address for eth0: 10.10.1.26
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
```
Устанавливаю кластер при помощи ansible и сам ansible на машины кластера. Он понадобится нам для небольшой автоматизации установи мониторинга и деплоя приложения:

```
serg@k8snode:~/diplom/Diplom-netology/ansible/kubernetes$ ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../hosts.yaml playbook.yml -K
BECOME password: 

PLAY [install docker and kubectl] *********************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
[WARNING]: Platform linux on host k8s-master is using the discovered Python interpreter at /usr/bin/python3.10, but future
installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [k8s-master]
[WARNING]: Platform linux on host k8s-worker-1 is using the discovered Python interpreter at /usr/bin/python3.10, but future
installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [k8s-worker-1]
[WARNING]: Platform linux on host k8s-worker-2 is using the discovered Python interpreter at /usr/bin/python3.10, but future
installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [k8s-worker-2]
PLAY RECAP ********************************************************************************************************************
k8s-master                 : ok=34   changed=27   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-worker-1               : ok=31   changed=24   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-worker-2               : ok=31   changed=24   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0     
```
Проверяю на ошибки подключившись к мастер ноде:

```
ubuntu@k8s-master:~$ kubectl cluster-info
Kubernetes control plane is running at https://10.10.1.26:6443
CoreDNS is running at https://10.10.1.26:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
ubuntu@k8s-master:~$ kubectl get nodes 
NAME           STATUS   ROLES           AGE     VERSION
k8s-master     Ready    control-plane   6m12s   v1.30.9
k8s-worker-1   Ready    <none>          5m58s   v1.30.9
k8s-worker-2   Ready    <none>          5m58s   v1.30.9
ubuntu@k8s-master:~$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-7dc5458bc6-zv5z8   1/1     Running   0          6m25s
kube-system   calico-node-4htfv                          1/1     Running   0          6m19s
kube-system   calico-node-knwbf                          1/1     Running   0          6m19s
kube-system   calico-node-w4lvb                          1/1     Running   0          6m25s
kube-system   coredns-55cb58b774-rc94g                   1/1     Running   0          6m25s
kube-system   coredns-55cb58b774-xsbqk                   1/1     Running   0          6m25s
kube-system   etcd-k8s-master                            1/1     Running   0          6m30s
kube-system   kube-apiserver-k8s-master                  1/1     Running   0          6m30s
kube-system   kube-controller-manager-k8s-master         1/1     Running   0          6m30s
kube-system   kube-proxy-6jr6p                           1/1     Running   0          6m19s
kube-system   kube-proxy-8kxsz                           1/1     Running   0          6m25s
kube-system   kube-proxy-fn46d                           1/1     Running   0          6m19s
kube-system   kube-scheduler-k8s-master                  1/1     Running   0          6m30s
```
### Создание тестового приложения
 
 Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.
 
 Способ подготовки:
 
 1. Рекомендуемый вариант:  
    а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
    б. Подготовьте Dockerfile для создания образа приложения.  
 2. Альтернативный вариант:  
    а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.
 
 Ожидаемый результат:
 
 1. Git репозиторий с тестовым приложением и Dockerfile.
 2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---

### Решение.

Ход выполнения представлен в репозитории 

[my-app](https://github.com/smabramov/my-app.git)

 ---
 ### Подготовка cистемы мониторинга и деплой приложения
 
 Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
 Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.
 
 Цель:
 1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
 2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.
 
 Способ выполнения:
 1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).
 
 2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.
 
 Ожидаемый результат:
 1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
 2. Http доступ на 80 порту к web интерфейсу grafana.
 3. Дашборды в grafana отображающие состояние Kubernetes кластера.
 4. Http доступ на 80 порту к тестовому приложению.
 ---

 ### Решение

 Отправляю папку с фаилами с помощью ansible на мастер ноду:

 ```
 serg@k8snode:~/diplom/Diplom-netology/ansible$ ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.yaml file.yaml -K
BECOME password: 

PLAY [Copy files to remote server] ********************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************
[WARNING]: Platform linux on host k8s-master is using the discovered Python interpreter at /usr/bin/python3.10, but future
installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [k8s-master]

TASK [Ensure target directory exists] *****************************************************************************************
changed: [k8s-master]

TASK [Copy files to remote server] ********************************************************************************************
changed: [k8s-master]

PLAY RECAP ********************************************************************************************************************
k8s-master                 : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

Подключаюсь к мастер ноде, перехожу в папку и запускаю playbook monitoring.yml, который установит нам мониторинг и деплой приложения:

```
ubuntu@k8s-master:~$ 
ubuntu@k8s-master:~$ cd files/k8s/
ubuntu@k8s-master:~/files/k8s$ ansible-playbook monitoring.yml 
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that
the implicit localhost does not match 'all'

PLAY [Install monitoring stack] ************************************************

TASK [Clone kube-prometheus] ***************************************************
changed: [localhost]

TASK [Create the namespace and CRDs] *******************************************
changed: [localhost]

TASK [Wait for CRDs to be established] *****************************************
changed: [localhost]

TASK [Create namespace my-app] *************************************************
changed: [localhost]

TASK [Deploy kube-prometheus] **************************************************
changed: [localhost]

TASK [Set permissions for grafana-service.yml] *********************************
changed: [localhost]

TASK [Apply my-app resources] **************************************************
changed: [localhost] => (item=app-deployment.yml)
changed: [localhost] => (item=app-networkpolicy.yml)
changed: [localhost] => (item=app-service.yml)

TASK [Apply grafana resources] *************************************************
changed: [localhost] => (item=grafana-service.yml)
changed: [localhost] => (item=grafana-networkpolicy.yml)

PLAY RECAP *********************************************************************
localhost                  : ok=8    changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```
Дополню конфигурацию terraform в файлах balanser.tf и outputs.tf

```
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
```

```
utput "web" {
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
```
Запускаю terraform apply:

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

all_vms = {
  "bastion-nat" = [
    {
      "name" = "bastion-nat"
      "nat_ip_address" = "158.160.59.58"
    },
  ]
  "master" = [
    {
      "ip_address" = "10.10.1.9"
      "name" = "k8s-master"
    },
  ]
}
monitoring = [
  {
    "address" = "158.160.173.85"
    "name" = "app-grafana"
    "port" = 80
  },
]
web = [
  {
    "address" = "158.160.172.134"
    "name" = "app-web"
    "port" = 80
  },
]
```
Добавлю в hosts фаил записи (ip-web  app-web.ru  и ip-monitoring  monitoring.ru), проверяю доступность на 80 порту:

!(web)[https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/web.png]

!(grafana)[https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/grafana.png]


 ### Установка и настройка CI/CD
 
 Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.
 
 Цель:
 
 1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
 2. Автоматический деплой нового docker образа.
 
 Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.
 
 Ожидаемый результат:
 
 1. Интерфейс ci/cd сервиса доступен по http.
 2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
 3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

 ### Решение

 Для автоматической сборки docker image и деплоя приложения при изменении кода будет использоваться Github Actions.

 Добавим в Github Actions секреты для работы с DockerHub.

 ![secret](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/secret.png)

 Для соединения с Githud Actions подключусь с мастер ноды при помощи runner:

 ```
 ubuntu@k8s-master:~/actions-runner$ ./config.sh --url https://github.com/smabramov/my-app --token APDURI4Y2V5AQORPU7VCZ53H2W3YY

--------------------------------------------------------------------------------
|        ____ _ _   _   _       _          _        _   _                      |
|       / ___(_) |_| | | |_   _| |__      / \   ___| |_(_) ___  _ __  ___      |
|      | |  _| | __| |_| | | | | '_ \    / _ \ / __| __| |/ _ \| '_ \/ __|     |
|      | |_| | | |_|  _  | |_| | |_) |  / ___ \ (__| |_| | (_) | | | \__ \     |
|       \____|_|\__|_| |_|\__,_|_.__/  /_/   \_\___|\__|_|\___/|_| |_|___/     |
|                                                                              |
|                       Self-hosted runner registration                        |
|                                                                              |
--------------------------------------------------------------------------------

# Authentication


√ Connected to GitHub

# Runner Registration

Enter the name of the runner group to add this runner to: [press Enter for Default] 

Enter the name of runner: [press Enter for k8s-master] 

This runner will have the following labels: 'self-hosted', 'Linux', 'X64' 
Enter any additional labels (ex. label-1,label-2): [press Enter to skip] 

√ Runner successfully added
√ Runner connection is good

# Runner settings

Enter name of work folder: [press Enter for _work] 

√ Settings Saved.

ubuntu@k8s-master:~/actions-runner$ ./run.sh

√ Connected to GitHub

Current runner version: '2.322.0'
2025-03-15 16:27:22Z: Listening for Jobs
```
Использую [workflow](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/git%20action/workflow)

При изменении в репозитории будет пушется новый tag на Dockerhub и на кластере пересоздоваться мой deployment.

![docker](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/docker.png)

![git](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/git.png)

![web1](https://github.com/smabramov/Diplom-netology/blob/fab352ab4a94d916c5399123e5a3446f1d698241/png/web1.png)



## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

