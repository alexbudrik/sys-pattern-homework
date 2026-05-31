# Задание 1: 

режимы репликации master-slave, master-master, опишите их различия

В схеме master-slave существует один главный сервер (master) и один или несколько подчинённых серверов (slave). Все операции изменения данных (INSERT, UPDATE, DELETE) выполняются только на master. Затем эти изменения записываются в бинарный журнал и передаются на slave-серверы, которые обновляют свои копии данных. Обычно slave используются для обработки запросов на чтение, что позволяет снизить нагрузку на основной сервер. Такая схема проста в настройке и хорошо подходит для систем, где чтений значительно больше, чем записей. Однако отказ master может привести к остановке операций записи до восстановления сервера или переключения ролей.

В схеме master-master оба сервера являются одновременно и мастерами, и репликами друг для друга. Это означает, что данные можно записывать и читать на любом из серверов, а изменения автоматически распространяются между ними. Такое решение обеспечивает более высокую отказоустойчивость: если один сервер выйдет из строя, второй продолжит работу без потери возможности записи данных. Однако настройка и сопровождение такой схемы сложнее, поскольку необходимо учитывать возможные конфликты при одновременном изменении одних и тех же данных на разных серверах.

Вывод: Таким образом, master-slave обычно выбирают для масштабирования чтения и простоты эксплуатации, а master-master — для повышения отказоустойчивости и возможности выполнять запись на нескольких серверах одновременно.

# Задание 2:

Выполните конфигурацию master-slave репликации, примером можно пользоваться из лекции.

Master container running
![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2-1-master.png)

Slave container running
![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2-1-slave.png)

Master replication status
![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2-2-master.png)

Replica status
![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2-2-slave.png)

Create test database on Master
![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2-3-master.png)

Verify replication on Slave
![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2-3-slave.png)

Replication of new record
![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2-4-master.png)

New record appeared on Slave
![sql](https://github.com/alexbudrik/sys-pattern-homework/blob/main/screenshots/SQL-2-4-slave.png)
