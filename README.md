# Задание 1: Установка Zabbix Server с веб-интерфейсом

## 1. Установка PostgreSQL

sudo apt update
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo -u postgres psql -c "\du"

## 2. Создание пользователя и базы данных для Zabbix

sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix
sudo -u postgres psql -d zabbix -c "ALTER USER zabbix WITH SUPERUSER;"

## 3.Установка зависимостей

sudo apt install -y \
    build-essential libpcre3-dev libssl-dev libcurl4-openssl-dev libxml2-dev \
    libsnmp-dev libevent-dev libssh2-1-dev libmariadb-dev php-cli php-mbstring \
    php-gd php-bcmath php-xml php-pgsql apache2 wget tar make cmake

## 4.Добавление репозиториев Zabbix и установка Zabbix Server

wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb
sudo dpkg -i zabbix-release_7.0-1+debian12_all.deb
sudo apt update
sudo apt install -y zabbix-server-pgsql zabbix-frontend-php zabbix-apache-conf zabbix-agent zabbix-sql-scripts
5. Настройка конфигурации Zabbix Server
sudo -u postgres psql -d zabbix -f /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz
sudo nano /etc/zabbix/zabbix_server.conf
# Установите правильные параметры:
# DBName=zabbix
# DBUser=zabbix
# DBPassword=<ваш пароль>

## 6.Запуск и проверка Zabbix Server
sudo systemctl daemon-reload
sudo systemctl enable zabbix-server
sudo systemctl restart zabbix-server
sudo systemctl status zabbix-server
sudo systemctl restart apache2

## 7. Настройка веб-интерфейса

браузер: http://10.1.0.1/zabbix/setup.php
Вход в веб-интерфейс:
Логин: Admin
Пароль: zabbix

![runner](https://github.com/alexbudrik/github-homework/blob/main/screenshots/Screenshot%202026-02-28%20212645.png)
