# Homework 07 - packer
## 1.
create image with params from console
```
packer build \
    -var 'gc_project_id=windy-skyline-188819' \
    -var 'gc_source_image_family=ubuntu-1604-lts' \
    ubuntu16.json
```
create image with params from param file
```
packer build -var-file=variables.json ubuntu16.json
```

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
