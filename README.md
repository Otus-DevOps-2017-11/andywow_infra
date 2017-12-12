1. page 36 task
подключение к someinternalhost (1 команда):
ssh -i ~/.ssh/appuser -A -o ProxyCommand="ssh -W %h:%p %r@35.205.18.133" appuser@someinternalhost
либо, если версия ssh новее (проверял на bash for win ;)
ssh -i ~/.ssh/appuser -J appuser@35.205.18.133 appuser@someinternalhost
доп. задание:
В каталоге ~/.ssh создать файл config с правами 600 и следующим содержимым
## ssh config start
Host someinternalhost
        HostName someinternalhost
        IdentityFile ~/.ssh/appuser
        User appuser
	# old version
        ProxyCommand ssh -A -W %h:%p %r@35.205.18.133
	# new version
	# ProxyJump %r@35.205.18.133
## ssh config end

3. Network configuration
Host bastion, EXTERNAL IP: 35.205.18.133, INTERNAL IP: 10.132.0.2
Host someinternalhost, INTERNAL IP: 10.132.0.3
 
