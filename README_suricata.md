# Задание 1: 

## Проведите разведку системы и определите, какие сетевые службы запущены на защищаемой системе:

* sudo nmap -sA < ip-адрес >

* sudo nmap -sT < ip-адрес >

* sudo nmap -sS < ip-адрес >

* sudo nmap -sV < ip-адрес >


## Suricata: обнаружила подозрительную сетевую активность и сформировала события безопасности, подтверждая работу системы обнаружения вторжений.

## Fail2Ban: зарегистрировал неудачные попытки входа по SSH. После превышения порога maxretry система автоматически блокирует IP-адрес атакующего, защищая сервер от атак перебора паролей.

![suricata](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/suricana%201.png)
![suricata](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/suricana%202.png)
![suricata](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/suricana%203.png)
![suricata](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/suricana%204.png)
![suricata](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/suricana%205.png)
