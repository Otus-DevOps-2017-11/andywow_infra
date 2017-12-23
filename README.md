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
-|-|-
gc_machine_type | N | f1-micro | machine type
gc_disk_size | N | 10 | disk size (gb)
gc_disk_type | N | pd-standard | disk type (pd-ssd / pd-standard)
gc_image_description | N | long descr | image description
gc_image_label_ruby_ver | N | 2-3-0 | ruby version (oonly label for image)
gc_image_label_mongod_ver | N | 3-2-18 | mongod version (only label for image)
gc_network | N | default | network name
gc_preemptible | N | true | preemptible status of VM
gc_project_id | Y | null | The project ID that will be used to launch instances and store images
gc_source_image_family | N | ubuntu-1604-lts | network name
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
