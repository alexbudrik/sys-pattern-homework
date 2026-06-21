# Задание 1: 

Скачайте и установите виртуальную машину Metasploitable: https://sourceforge.net/projects/metasploitable/.
Это типовая ОС для экспериментов в области информационной безопасности, с которой следует начать при анализе уязвимостей.
Просканируйте эту виртуальную машину, используя nmap.
Попробуйте найти уязвимости, которым подвержена эта виртуальная машина.
Сами уязвимости можно поискать на сайте https://www.exploit-db.com/.
Для этого нужно в поиске ввести название сетевой службы, обнаруженной на атакуемой машине, и выбрать подходящие по версии уязвимости.
Ответьте на следующие вопросы:
Какие сетевые службы в ней разрешены?
Какие уязвимости были вами обнаружены? (список со ссылками: достаточно трёх уязвимостей)


![exploit](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/metasploitable-1.png)

Уязвимость №1 – VSFTPD 2.3.4 Backdoor
Сервис: FTP (vsftpd 2.3.4)
Данная версия содержит встроенный бэкдор. При специальном имени пользователя сервер открывает удалённую оболочку с правами системы.
Ссылка:https://www.exploit-db.com/exploits/17491
Уровень риска: Критический

Уязвимость №2 – Samba 3.0.20 "username map script"
Сервис: Samba 3.0.20
Уязвимость позволяет удалённо выполнить произвольный код без аутентификации через специально сформированный запрос.
Ссылка:https://www.exploit-db.com/exploits/16320
Уровень риска: Критический

Уязвимость №3 – UnrealIRCd 3.2.8.1 Backdoor
Сервис: UnrealIRCd
Версия содержит вредоносный бэкдор, позволяющий злоумышленнику выполнять команды на сервере удалённо.
Ссылка:https://www.exploit-db.com/exploits/13853
Уровень риска: Критический




# Задание 2: Установите и запустите memcached.

![cash](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/cash%20-%201.png)


# Задание 3: Удаление по TTL в Memcached.

![cash](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/cash%20-%202.png)

# Задание 4: Запись данных в Redis.

![cash](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/cash%20-%203.png)
