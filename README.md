# Homework 09 - terraform-2
## packer
Создано 2 семейства образов из образа `ubuntu-1604-lts`:

 `reddit-app` - базовый образ для приложения (с ruby на борту)

 `reddit-db` - базовый образ для БД (c mongod на борту)



# Homework 08 - terraform-1
## 1 Базовое ДЗ
### 1-3 список параметров
Name | Req | Default value | Description
-|-|-|-
app_port | N | 9292 | Port for puma service
disk_image | N | reddit-base | The name of the image family to which the resulting image belongs
private_key_path | Y |  | private key path (local machine)
project | Y |  | The project ID that will be used to launch instances and store images
public_key_path | Y |  | public key path (local machine)
zone | N | europe-west1-c | zone name

В процессе работы сделал шаблон [puma.service.tpl](./terraform/files/puma.service.tpl) для параметризации порта.
Потребовалось еще раз выполнить команду
```
terraform init
```
для того, чтобы terraform подкачал провайдера.

### 4. команда terraform fmt
Команда работает, но для себя поставил в IDE Atom плагины:

[atom-beautify](https://atom.io/packages/atom-beautify) - автоформатирование, поддерживает кучу синтаксисов

[language-terraform](https://atom.io/packages/language-terraform) - удобная подсветка кода и автодополнения для terraform

### 5. Создан файл [terraform.tfvars.example](./terraform/terraform.tfvars.example)

## 1* Расширенное ДЗ
Создан модуль для terraform [userkeymodule](./terraform/modules/userkeymodule), отвечающий за динамическое формирование ключей.

Добавлена переменная `users_public_keys` типа `map` для задания пользователей и их ключей в формате `user:public_key_path`

При добавлении еще одного пользователя c ключем в список, через переменную, он появляется в списке ssh-ключей

При добавлении пользователя руками, а затем выполнение команды `terraform apply`, пользователь, добавленный руками, удаляется. Т.е. все ssh-ключи проекта перезаписываются.

## 2* Создание балансировщика
Создан балансировщик ;) Количество эксземпляров указывается в переменной `instance_count` (по-умолчанию, 2).
Сделал проверку - запустил 2 экземпляра, посмотрел, что на один идет трафик, остановил его, трафик пошел на второй.
Не сразу понял, что балансировщику требуется время на запуск. Потом вспомнил, что об этом в лекции говорили.


# Homework 07 - packer
## 1 и 2. Создание базового образа 2 вариантами
Используется шаблон [ubuntu16.json](./packer/ubuntu16.json)
Параметры для вылидации и сборки передаются как аргумента командной строки:
```
packer validate \
    -var 'gc_project_id=windy-skyline-188819' \
    -var 'gc_source_image_family=ubuntu-1604-lts' \
    ubuntu16.json
packer build \
    -var 'gc_project_id=windy-skyline-188819' \
    -var 'gc_source_image_family=ubuntu-1604-lts' \
    ubuntu16.json
```
Параметры передаются в файле параметров:
```
packer validate -var-file=ubuntu16.vars.json ubuntu16.json
packer build -var-file=ubuntu16.vars.json ubuntu16.json
```

#### Список параметров шаблона:

 Name | Req | Default value | Description
-|-|-|-
gc_machine_type | N | f1-micro | machine type
gc_disk_size | N | 10 | disk size (gb)
gc_disk_type | N | pd-standard | disk type (pd-ssd / pd-standard)
gc_image_description | N | long descr | image description
gc_image_label_ruby_ver | N | 2-3-0 | ruby version (oonly label for image)
gc_image_label_mongod_ver | N | 3-2-18 | mongod version (only label for image)
gc_network | N | default | network name
gc_preemptible | N | true | preemptible status of VM
gc_project_id | Y | null | The project ID that will be used to launch instances and store images
gc_source_image_family | Y | ubuntu-1604-lts | The name of the image family to which the resulting image belongs
gz_zone | N | europe-west1-c | The zone in which to launch the instance used to create the image


#### Коментарии к п.1 ДЗ:
* Параметр "tag" убрал из описания, т.к. он присываивается instance-у только в момент создания образа, а далее не указыватеся
* Добавил параметр "preemptible", для выключения VM, в случае, если оставил ее включенной (образ ubuntu16.json используется только для сборки)
* В образ добавляются метки с версиями ruby и mongod

## 1\* и 2\* Создание immutable образа

Используется шаблон [immutablejson](./packer/immutable.json), который создает образ на базе образа reddit-base, созданного в предыдущем пункте.

Параметры для вылидации и сборки передаются как аргумента командной строки:
```
packer validate \
    -var 'gc_project_id=windy-skyline-188819' \
    immutable.json
packer build \
    -var 'gc_project_id=windy-skyline-188819' \
    immutable.json
```
Параметры передаются в файле параметров:
```
packer validate -var-file=immutable.vars.json immutable.json
packer build -var-file=immutable.vars.json immutable.json
```

Из списка параметров убраны параметры
* gc_source_image_family (т.к. мы завязаны на семейство образов reddit-base)
* gc_image_label_ruby_ver (здесь мы не устанавливаем ruby)
* gc_image_label_mongod_ver (здесь мы не устанавливаем mongod)

Запуск reddit app производится через systemd-service unit [puma.service](./packer/files/puma.service)

Информация о строке запуска находится в файле
[create-reddit-vm.sh](./config-scripts/create-reddit-vm.sh)


# Homework 06 - gcp
## 1. install scripts

```
./runner.sh <command_file.txt> - read and executes commands from file with checks
./ruby.txt - ruby install commands
./mongodb.txt - mongodb install commands
./deploy.txt - deploy app install commands
```

## 2. gcloud startup

Запуск из удаленного репозитория
В качестве параметра передается файл со списком команд для выполнения
```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url="https://raw.githubusercontent.com/Otus-DevOps-2017-11/andywow_infra/master/runner.sh",\
cmdlist="https://raw.githubusercontent.com/Otus-DevOps-2017-11/andywow_infra/master/startup.txt"
```
Запуск с локальной системы:
```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script="projects/andywow_infra/runner.sh" \
  --metadata cmdlist="https://raw.githubusercontent.com/Otus-DevOps-2017-11/andywow_infra/master/startup.txt"
```

# Homework 05 - ssh & vpn
## 1. page 36 task
подключение к someinternalhost (1 команда):

`
ssh -i ~/.ssh/appuser -A -o ProxyCommand="ssh -W %h:%p %r@35.205.18.133" appuser@someinternalhost
`

либо, если версия ssh новее (проверял на bash for win ;)

`
ssh -i ~/.ssh/appuser -J appuser@35.205.18.133 appuser@someinternalhost
`

доп. задание:
В каталоге ~/.ssh создать файл config с правами 600 и следующим содержимым

```
Host someinternalhost
        HostName someinternalhost
        IdentityFile ~/.ssh/appuser
        User appuser
	# old version
        ProxyCommand ssh -A -W %h:%p %r@35.205.18.133
	# new version
	# ProxyJump %r@35.205.18.133
```

## 3. Network configuration

Host bastion, EXTERNAL IP: 35.205.18.133, INTERNAL IP: 10.132.0.2
Host someinternalhost, INTERNAL IP: 10.132.0.3
