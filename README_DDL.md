# Задание 1: 
1.1. Поднимите чистый инстанс MySQL версии 8.0+. Можно использовать локальный сервер или контейнер Docker.

1.2. Создайте учётную запись sys_temp.

1.3. Выполните запрос на получение списка пользователей в базе данных.

![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-1.png)

1.4. Дайте все права для пользователя sys_temp.

1.5. Выполните запрос на получение списка прав для пользователя sys_temp.

![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2.png)

1.6. Переподключитесь к базе данных от имени sys_temp.

Для смены типа аутентификации с sha2 используйте запрос:

ALTER USER 'sys_test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
1.6. По ссылке https://downloads.mysql.com/docs/sakila-db.zip скачайте дамп базы данных.

1.7. Восстановите дамп в базу данных.

1.8. При работе в IDE сформируйте ER-диаграмму получившейся базы данных. При работе в командной строке используйте команду для получения всех таблиц базы данных.

![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-3.png)

```
    # Получить список пользователей
    SELECT user, host
    FROM mysql.user;

    # Получить список прав пользователя sys_temp
    SHOW GRANTS FOR 'sys_temp'@'localhost';

    # Получить список таблиц базы данных
    USE sakila;
    SHOW TABLES;
```

# Задание 2:

