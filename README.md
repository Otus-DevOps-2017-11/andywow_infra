[![Build Status](https://travis-ci.org/Otus-DevOps-2017-11/andywow_infra.svg?branch=ansible-3)]
(https://travis-ci.org/Otus-DevOps-2017-11/andywow_infra)

# Homework 12 - ansible-3
## Базовая часть

Для открытия 80-го порта поменял переменную в файле `terraform.tfvars`
```
app_port = "80"
```
Сама переменная была добавлена в предыдущих ДЗ.
Вызов роли также был добавлен. Плейбук `site.xml` применен, приложение работает
на 80-м порту успешно.

```
ansible-playbook playbooks/site.yml
```

## Задание *

Здесь столкнулся с проблемой:

Как определять хосты GCE по группам, если они создаются динамически.
Решение было найдено просмотром результатов команды
```
./gce.py --list
```
Выяснил, что к GCE хостам можно обращаться по их тегам, т.е. имя группы будет
иметь вид, `tag_%tag-name%`, например `tag_reddit-app`


# Homework 11 - ansible-2
## Базовая часть

Было создано несколько плейбуков:
- `reddit_app.yml`, в котором любой сценарий может быть применен к любому хосту

Файл `puma.service` пришлось также шаблонизировать (
[puma.service.j2](./ansible/templates/puma.service.j2)), чтобы иметь возможность указать
произвольный порт, на котором будет служать запросы приложение.
Выяснилось, что демон puma не умееть reload-ить свой state. Для исправления
пришлось добавить строчку `ExecReload=/bin/kill -USR2 $MAINPID`, чтобы он
перечитывал свой конфиг. Но т.к. у нас адрес БД хранится не в конфиге, а
задается переменной окружения, то сервис придется все равно перестартовывать.
Плюс пришлось добавить handler `systemd reload`, чтобы вызывалась команда
`systemctl daemon-reload` при изменении файла `puma.service`.

В остальном все прошло успешно:
```
ansible-playbook reddit_app_one_play.yml --limit db --tags db-tag --check
ansible-playbook reddit_app_one_play.yml --limit db --tags db-tag
ansible-playbook reddit_app_one_play.yml --limit app --tags app-tag --check
ansible-playbook reddit_app_one_play.yml --limit app --tags app-tag
ansible-playbook reddit_app_one_play.yml --limit app --tags deploy-tag --check
ansible-playbook reddit_app_one_play.yml --limit app --tags deploy-tag
```

Думал, как проверить изменения для deploy-я, но ветка в гите у нас одна и она
уже есть в составе образа.

- `reddit_app_multiple_plays.yml`, в котором сценарии могут применять лишь на конкретные хосты

```
ansible-playbook reddit_app_multiple_plays.yml --tags db-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags db-tag
ansible-playbook reddit_app_multiple_plays.yml --tags app-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags app-tag
ansible-playbook reddit_app_multiple_plays.yml --tags deploy-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags deploy-tag
```

- `site.yml`, в котором импортировали три других шаблона: `app.yml`, `db.yml` и
`deploy.yml`.

```
ansible-playbook site.yml --check
ansible-playbook site.yml
```

Здесь мы уже не указываем теги и хосты, на которые применять конфигруацию.

## Задание *

Так уж получилось, что я сделал его в предыдущем ДЗ10 - смотреть п. ДЗ-10 UPD

## Сборка  с packer
Здесь пришлось повозиться. Сначало пришлось добавить правило фаервола в GCE,
которое разрешает коннект на ssh порт для машин с сетевым тегом `packer-ssh`,
т.к. предыдущее дефолтовое правило успешно удалилось вместе с
`terraform destroy`. Для образов был добавлен соответствующий тег.

Чтобы можно было запускать сборку из каталога `packer` был добавлен symlink на
каталог `ansible`.

В процессе создания образа для `app` решил попробовать указать список пакетов
списком без использования циклов, и это работает. Работу с циклами также проверил.

В playbook-и `app.yml`, `db.yml`, `deploy.yml` добавил маски имен GCE хостов,
т.к. перебивать Ip адреса в статическом inventory надоело ;).

```
ansible-playbook -i gce.py site.yml --check
ansible-playbook -i gce.py site.yml
```

Проверил работу приложения - посты создаются.

# Homework 10 - ansible-1
## Базовая часть

Все сделано по описанию - установлен ansible с помощью файла [requirements.txt](./ansible/requirements.txt)
```
sudo pip install -r requirements.txt
```
Далее было поднято тестовое откружение, созданы inventory файлы (
[ini](./ansible/inventory) и [yml](./ansible/inventory.yml)),
проверен ping до хостов.

На работе использую saltstack, все очень похоже - там тоже есть группы хостов,
но нет возможности вложенности групп одну в другую.

## Задание *

Создан inventory файл в формате json [inventory.json](./ansible/inventory.json)

UPD. не правильно понял задание (выяснилось на 11-й лекции ;)
Что было сделано - установлен пакет `apache-libcloud`
```
sudo pip install apache-libcloud
```
Далее создана временная папка, в нее скопирован репозиторий ansible с github-а
```
git clone https://github.com/ansible/ansible
```
Далее из этого репозитория скопировано 2 файла:
`ansible/contrib/inventory/gce.py ` и `ansible/contrib/inventory/gce.ini`.

Далее в настройках GCE был создан service account с именем `ansible` и скачан
его json-файл. Отредактирован файл `gce.ini` - в нем указаны настройки для
подключения к GCE.

Проверяем настройки подключения к GCE:
```
./gce.py --list
```
Появляется список того, что у нас есть в проекте GCE в формате json.
Далее пытаемся сделать ping виртуальных машин.

```
➜  ansible git:(ansible-1) ✗ ansible -i gce.py all -m ping
reddit-db | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
reddit-app-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
Все выше указанные файлы лежат в каталоге `ansible` за исключением `gce.ini` и
`key.json` (по соображениям безопасности).
Надеюсь сейчас я правильно понял ДЗ ;)

UPD 2. Видимо все такие нет ;) Установил старую версию ansible
```
git clone -b stable-2.3 --recursive https://github.com/ansible/ansible.git
source ansible/hacking/env-setup
```

проверяем версию
```
➜  ansible git:(stable-2.3) ansible --version                                       
ansible 2.3.3.0 (stable-2.3 2c116617de) last updated 2018/01/13 09:33:33 (GMT +300)
  config file =
  configured module search path = Default w/o overrides
  python version = 2.7.12 (default, Nov 20 2017, 18:23:56) [GCC 5.4.0 20160609]
```
проверяем ping
```
➜  ansible git:(ansible-1) ansible -i inventory.json dbserver -m ping
dbserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

UPD 3. Добавил скрипт `ansiblejson.py`, форматирущий файл с параметрами
`inventory20.json` - это работает на версии `ansible` < `2.1`.

При выполении команд, тоже наблюдается схожесть со saltstack-ом.
По аналогии в `shell` и `command`, там есть state `cmd` с функциями `exec_code`
и `run`.

При использовании `git` модуля пришлось задать другую папку в параметре `dest`,
чтобы результат был `changed=true`. Хотя в обоих случаях модуль возвращает `SUCCESS`. Если же использовать `command`, то любой rc != 0, трактуется как
ошибка.

Вообщем понятен смысл и преимущество использования различных модулей вместо
вызова модуля `command` с аргументами.

# Homework 09 - terraform-2
## packer
Создано 2 семейства образов из образа `ubuntu-1604-lts`:

 `reddit-app-base` - базовый образ для приложения (с ruby на борту)

 `reddit-db-base` - базовый образ для БД (c mongod на борту)

## terraform
В процессе создания instance-ов появилась ошибка "only 1 static address allowed".
Вспомнил, что ранее назначали статиеский IP для машины bastion. Убрал из нее и все заработало.

В модуль `app` перенес шаблон `puma.service.tpl` из предыдущего задания.
В процессе выснили, как ссылаться на файлы внутри модуля по относительным путям (${path.module})

Был создан модуль `vpc`. При создании ставится приоритет 1000 и ресурс пересоздается,
т.к. по-умолчанию у правил гугла прироритет 65534.

Также доработал свой модуль из предыдущего ДЗ для создания ssh ключей на уровне проекта.

## Самостоятельное ДЗ:

source_range | результат
-|-
0.0.0.0 | пускает
my-ip | пускает
not-my-ip | не пускает


При разбиении структуры на `stage` и `prod` в каждой их них пришлось делать
`terraform get && terraform init`

При попытке параллельного изменения возникает ошибка

```
Error: Error loading state: writing "gs://andywow/terraform/state/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
Lock Info:
  ID:        7283473f-73a1-2405-40c8-03fdfbaa90dd
  Path:      
  Operation: OperationTypeApply
  Who:       andy@andyvm
  Version:   0.11.1
  Created:   2018-01-10 17:06:00.680041135 +0000 UTC
  Info:
```

## Самостоятельное ДЗ* - backend в GCS

Предварительно создал backend в GCS.
Далее описал GCS в файле [main.tf](./terraform/code/main.tf).
Сделал бэкап текущего state-файла.

Выполнил инициализацию в папке prod `terraform init -backend-config=backend.conf`

Пример файла `backend.conf` - `backend.conf.example`

Было предложение перенести state из локального хранилица в gcs. Перенес.
Локальный `terraform.tfstate` исчез с диска.
Проверил `terraform plan` - конфигруация не поменялась, значит работает.
Перешел в папку `prod`. Выполнил ту же команду, но на вопрос об загрузке state-а
ответил, что надо брать из удаленного хранилища.
Проверил `terraform plan` - предложил сменить только IP-адрес для SSH-правила
фаервола, значит работает. Попробовал `terraform apply`. Изменения применились.

## Самостоятельное ДЗ** - provision
Файлы [deploy.sh](./terraform/modules/app/files/deploy.sh) и [puma.service.tpl](./terraform/modules/app/files/puma.service.tpl) перенесены.

Файл `puma.service.tpl` изменен - помимо порта, из предыдущего ДЗ, в шаблон
добавлена также переменная окружения `DATABASE_URL`, указывающая на адрес БД.

В [outputs.tf](./terraform/modules/db/outputs.tf) добавлена output `db_internal_ip`,
указывающая на внутренний адрес хоста с БД.
Данная output передается на вход модулю `app` для указания адреса хоста БД.

Т.к. БД стартует, по-умолчанию, на адресе `127.0.0.1`, пришлось добавить inline
провиженер для модуля `db` в файл [main.tf](./terraform/modules/db/main.tf),
т.к. неправильно на мой взгляд, делать отдельный image для данной задачи
(безопасность).
В провиженере делается смена адреса и рестарт сервиса.
Потом также заморочился с портом БД.

Ну и добавим параметр порта к правилу фаервола (`db_port`)

Решил сделать отдельное модуль для балансировщика. Пришлось добавить 2 параметра:
* `app_instance_count` - кол-во эксземпляров инстанса `app` (по-умолчанию, `1`)
* `create_loadbalancer` - создавать или нет балансировщик (по-умолчанию, `false`)

Если создается балансировщик, то статические ip для инстансов не выделяются.
Если балансировщик не создается, то статические выделенные ip создаются, но этот
кейс я проверил только с `app_instance_count = 1`, т.к. аккаунт GC бесплатный.

В процессе так же выяснил, что забыл указать `session_affinity` для балансировщика
в предыдущем ДЗ, в результате чего постоянно кидало на разные хосты.

Код вынес в отдельную папку `code` в папках `stage` и `prod` сделал симлинки на
нее. Для переопределния перменной `ssh_source_ranges` добавил отдельный файл
`custom.auto.tfvars`, из которого переменная подгружается автоматически.

Добавил модуль для работы с реестром модулей. Создал 2 бакета. При
изменении имен бакетов, старые удаляются, новые создаются.



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
