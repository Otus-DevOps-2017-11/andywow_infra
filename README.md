# Homework 06
## 1. install scripts


```
./homework06/runner.sh <command_file.txt> - read and executes commands from file with checks
./homework06/ruby.txt - ruby install commands
./homework06/mongodb.txt - mongodb install commands
./homework06/deploy.txt - deploy app install commands
```

# Homework 05
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
