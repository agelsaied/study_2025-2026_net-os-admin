---
## Front matter
title: "Отчёт по лабораторной работе 6"
subtitle: "Установка и настройка системы управления базами данных MariaDB"
author: "Элсаиед Адел"

## Generic otions
lang: ru-RU
toc-title: "Содержание"

## Bibliography
bibliography: bib/cite.bib
csl: pandoc/csl/gost-r-7-0-5-2008-numeric.csl

## Pdf output format
toc: true # Table of contents
toc-depth: 2
lof: true # List of figures
lot: true # List of tables
fontsize: 12pt
linestretch: 1.5
papersize: a
documentclass: scrreprt
## I18n polyglossia
polyglossia-lang:
  name: russian
  options:
	- spelling=modern
	- babelshorthands=true
polyglossia-otherlangs:
  name: english
## I18n babel
babel-lang: russian
babel-otherlangs: english
## Fonts
mainfont: IBM Plex Serif
romanfont: IBM Plex Serif
sansfont: IBM Plex Sans
monofont: IBM Plex Mono
mathfont: STIX Two Math
mainfontoptions: Ligatures=Common,Ligatures=TeX,Scale=0.94
romanfontoptions: Ligatures=Common,Ligatures=TeX,Scale=0.94
sansfontoptions: Ligatures=Common,Ligatures=TeX,Scale=MatchLowercase,Scale=0.94
monofontoptions: Scale=MatchLowercase,Scale=0.94,FakeStretch=0.9
mathfontoptions:
## Biblatex
biblatex: true
biblio-style: "gost-numeric"
biblatexoptions:
  - parentracker=true
  - backend=biber
  - hyperref=auto
  - language=auto
  - autolang=other*
  - citestyle=gost-numeric
## Pandoc-crossref LaTeX customization
figureTitle: "Рис."
tableTitle: "Таблица"
listingTitle: "Листинг"
lofTitle: "Список иллюстраций"
lotTitle: "Список таблиц"
lolTitle: "Листинги"
## Misc options
indent: true
header-includes:
  - \usepackage{indentfirst}
  - \usepackage{float} # keep figures where there are in the text
  - \floatplacement{figure}{H} # keep figures where there are in the text
---

# Цель работы

Приобретение практических навыков по установке и конфигурированию системы управления базами данных на примере программного обеспечения MariaDB.

# Выполнение

## Установка MariaDB и первичная настройка безопасности

1. На виртуальной машине **server** выполнен переход в режим суперпользователя и установка пакетов MariaDB:

   - `dnf -y install mariadb mariadb-server`

   В результате были установлены сервер MariaDB, клиентские утилиты и сопутствующие компоненты (включая `mariadb-server`, `mariadb-client-utils`, `mariadb-common`, `mariadb-backup` и др.). Установка завершилась успешно со статусом **Complete!**.

   ![Установка пакетов MariaDB и просмотр конфигурации](Screenshot_1.png){ #fig:006 width=80% }

2. Выполнена проверка конфигурационных файлов MariaDB:

   - При попытке просмотра `/etc/my.cnf.d/` командой `cat /etc/my.cnf.d/` получено сообщение *Is a directory*, что подтверждает: `/etc/my.cnf.d` — каталог с дополнительными фрагментами конфигурации.
   - Командой `ls /etc/my.cnf.d/` определён набор конфигурационных файлов:
     - `auth_gssapi.cnf` — параметры аутентификации через GSSAPI (Kerberos).
     - `client.cnf` — настройки клиентских программ.
     - `mysql-clients.cnf` — общие параметры клиентских утилит.
     - `mariadb-server.cnf` — основной файл конфигурации серверной части.
     - `enable-encryption.preset` — предустановки параметров шифрования.
     - `provider_bzip2.cnf`, `provider_lz4.cnf`, `provider_lzo.cnf`, `provider_snappy.cnf` — настройки модулей сжатия.
     - `spider.cnf` — параметры движка Spider.
   - Файл `/etc/my.cnf` является основным конфигурационным файлом и подключает все файлы из каталога `/etc/my.cnf.d`.

   **Построчный комментарий содержимого `/etc/my.cnf`:**
   - `#` — комментарий.
   - `[client-server]` — секция параметров, применяемых и к клиенту, и к серверу.
   - `!includedir /etc/my.cnf.d` — директива подключения всех файлов конфигурации из каталога.

3. Выполнен запуск MariaDB и добавление службы в автозагрузку:

   ```bash
   systemctl start mariadb
   systemctl enable mariadb
```

В результате созданы символические ссылки systemd, подтверждающие включение сервиса при старте ОС.

![Запуск MariaDB и включение автозагрузки](Screenshot_2.png){ #fig:008 width=80% }

4. Проверено, что сервер MariaDB прослушивает порт **3306**:

   ```bash
   ss -tulpen | grep 3306
   ```

   В выводе отображается процесс `mariadbd`, слушающий порт `3306` по IPv4 и IPv6.

   ![Проверка прослушивания порта 3306](Screenshot_2.png){ #fig:009 width=80% }

5. Выполнена настройка безопасности MariaDB:

   ```bash
   mysql_secure_installation
   ```

   В ходе диалога:

   * включена аутентификация через `unix_socket`;
   * установлен пароль пользователя `root` СУБД;
   * применены обновления таблиц привилегий.

   ![Настройка безопасности MariaDB](Screenshot_3.png){ #fig:010 width=80% }

6. Выполнен вход в MariaDB и просмотр доступных команд и баз данных:

   ```sql
   \h
   SHOW DATABASES;
   ```

   В системе присутствуют базы данных:

   * `information_schema`
   * `mysql`
   * `performance_schema`
   * `sys`

   ![Справка и список баз данных](Screenshot_4.png){ #fig:011 width=80% }

## Конфигурация кодировки символов

1. Выполнена проверка статуса MariaDB до изменения кодировки:

   ```sql
   status
   ```

   **Пояснение вывода:**

   * версия клиента и сервера MariaDB;
   * параметры подключения (user, socket, protocol);
   * текущие кодировки сервера, базы данных, клиента и соединения;
   * статистика работы сервера (uptime, queries, threads).

   ![Статус MariaDB до настройки UTF-8](Screenshot_5.png){ #fig:012 width=80% }

2. В каталоге `/etc/my.cnf.d` создан файл `utf8.cnf` со следующим содержимым:

   ```ini
   [client]
   default-character-set = utf8

   [mysqld]
   character-set-server = utf8
   ```

   ![Файл utf8.cnf](Screenshot_6.png){ #fig:013 width=80% }

3. Выполнен перезапуск MariaDB и повторная проверка статуса:

   ```bash
   systemctl restart mariadb
   ```

   ```sql
   status
   ```

   **Результат:**

   * `Server characterset` изменён с `latin1` на `utf8mb3`;
   * `Db characterset` изменён с `latin1` на `utf8mb3`.

   Это подтверждает успешное применение конфигурации кодировки UTF-8.

   ![Статус MariaDB после настройки UTF-8](Screenshot_7.png){ #fig:014 width=80% }

## Создание базы данных и управление доступом

1. Выполнен вход в систему управления базами данных MariaDB с правами администратора:

   ```bash
   mysql -u root -p
```

2. Создана база данных `addressbook` с указанием кодировки `utf8` и правил сортировки `utf8_general_ci`, что обеспечивает корректную работу с кириллическими символами:

   ```sql
   CREATE DATABASE addressbook CHARACTER SET utf8 COLLATE utf8_general_ci;
   ```

   Команда выполнена успешно, что подтверждается сообщением *Query OK, 1 row affected*.

3. Выполнен переход к работе с созданной базой данных:

   ```sql
   USE addressbook;
   ```

4. Проверено наличие таблиц в базе данных `addressbook`:

   ```sql
   SHOW TABLES;
   ```

   Результат — пустой набор, так как таблицы на данном этапе отсутствуют.

5. Создана таблица `city` с двумя полями строкового типа:

   * `name` — имя человека;
   * `city` — название города проживания.

   ```sql
   CREATE TABLE city(name VARCHAR(40), city VARCHAR(40));
   ```

6. Таблица `city` заполнена тестовыми данными:

   ```sql
   INSERT INTO city(name, city) VALUES ('Иванов', 'Москва');
   INSERT INTO city(name, city) VALUES ('Петров', 'Сочи');
   INSERT INTO city(name, city) VALUES ('Сидоров', 'Дубна');
   ```

7. Выполнен запрос на выборку всех данных из таблицы:

   ```sql
   SELECT * FROM city;
   ```

   **Результат выполнения запроса:**
   Отображены все строки таблицы `city`, содержащие три записи. Это подтверждает корректное создание таблицы и успешную вставку данных.

   ![Содержимое таблицы city](Screenshot_8.png){ #fig:015 width=80% }

8. Создан пользователь MariaDB для работы с базой данных `addressbook` с доступом с любых хостов:

   ```sql
   CREATE USER elsaiedadel@'%' IDENTIFIED BY '123456';
   ```

9. Пользователю предоставлены права на основные операции с данными (чтение, добавление, изменение, удаление):

   ```sql
   GRANT SELECT, INSERT, UPDATE, DELETE ON addressbook.* TO elsaiedadel@'%';
   ```

10. Выполнено обновление таблиц привилегий для применения изменений:

    ```sql
    FLUSH PRIVILEGES;
    ```

11. Просмотрена структура таблицы `city`:

    ```sql
    DESCRIBE city;
    ```

    В результате отображены поля таблицы, их типы данных и допустимость значений `NULL`.

    ![Описание структуры таблицы city](Screenshot_9.png){ #fig:016 width=80% }

12. Выполнен выход из интерактивной оболочки MariaDB:

    ```sql
    quit
    ```

13. Проверен список всех баз данных в системе:

    ```bash
    mysqlshow -u root -p
    ```

14. Проверен список таблиц базы данных `addressbook`:

    ```bash
    mysqlshow -u root -p addressbook
    ```

    ![Просмотр баз данных и таблиц](Screenshot_10.png){ #fig:017 width=80% }

## Резервное копирование и восстановление базы данных

1. На виртуальной машине `server` создан каталог для хранения резервных копий:

   ```bash
   mkdir -p /var/backup
   ```

2. Выполнено резервное копирование базы данных `addressbook` в SQL-файл:

   ```bash
   mysqldump -u root -p addressbook > /var/backup/addressbook.sql
   ```

3. Создана сжатая резервная копия базы данных с использованием `gzip`:

   ```bash
   mysqldump -u root -p addressbook | gzip > /var/backup/addressbook.sql.gz
   ```

4. Создана сжатая резервная копия с указанием даты и времени создания в имени файла:

   ```bash
   mysqldump -u root -p addressbook | gzip > $(date +/var/backup/addressbook.%Y%m%d.%H%M%S.sql.gz)
   ```

5. Выполнено восстановление базы данных из обычной резервной копии:

   ```bash
   mysql -u root -p addressbook < /var/backup/addressbook.sql
   ```

6. Выполнено восстановление базы данных из сжатой резервной копии:

   ```bash
   zcat /var/backup/addressbook.sql.gz | mysql -u root -p addressbook
   ```

   ![Резервное копирование и восстановление базы данных](Screenshot_11.png){ #fig:018 width=80% }

## Внесение изменений в настройки внутреннего окружения виртуальной машины

1. В каталоге `/vagrant/provision/server` создана структура для хранения конфигурационных файлов MariaDB и резервных копий базы данных:

   ```bash
   mkdir -p /vagrant/provision/server/mysql/etc/my.cnf.d
   mkdir -p /vagrant/provision/server/mysql/var/backup
   ```

   В созданные каталоги скопированы:

   * файл конфигурации кодировки `utf8.cnf`;
   * резервные копии базы данных `addressbook`.
   
    ![Копирование файлов](Screenshot_12.png){ #fig:019 width=80% }


2. В каталоге `/vagrant/provision/server` создан исполняемый скрипт `mysql.sh`:

   ```bash
   touch mysql.sh
   chmod +x mysql.sh
   ```

   Скрипт автоматизирует:

   * установку MariaDB;
   * копирование конфигурационных файлов;
   * восстановление резервной копии базы данных;
   * выполнение базовой настройки безопасности;
   * создание базы данных `addressbook`.

   ![Скрипт автоматической настройки MariaDB](Screenshot_13.png){ #fig:020 width=80% }

3. Для автоматического выполнения скрипта при запуске виртуальной машины в файл `Vagrantfile` добавлена конфигурация provisioner’а:

# Вывод

В ходе выполнения лабораторной работы была произведена установка и настройка сервера баз данных MariaDB на виртуальной машине. Выполнены действия по первичной конфигурации и усилению безопасности СУБД, настройке кодировки символов для корректной работы с кириллическими данными, созданию пользовательской базы данных и таблиц, а также управлению доступом пользователей. Были отработаны операции резервного копирования и восстановления базы данных, что является важным элементом администрирования. Дополнительно реализована автоматизация установки и настройки MariaDB с помощью provisioning-скрипта Vagrant, что обеспечивает воспроизводимость конфигурации и упрощает развёртывание серверного окружения.

# Контрольные вопросы

**1. Какая команда отвечает за настройки безопасности в MariaDB?**  
За базовую настройку безопасности MariaDB отвечает команда `mysql_secure_installation`. Она запускает интерактивный скрипт, с помощью которого можно задать пароль пользователю root СУБД, отключить удалённый доступ для root, удалить анонимных пользователей и тестовую базу данных, а также обновить таблицы привилегий.

**2. Как настроить MariaDB для доступа через сеть?**  
Для доступа к MariaDB по сети необходимо:
- в конфигурационных файлах (например, `/etc/my.cnf.d/mariadb-server.cnf`) указать параметр `bind-address` (например, `0.0.0.0` для приёма подключений с любых интерфейсов);
- создать пользователя с указанием хоста (`user@'%'` или конкретный IP);
- предоставить этому пользователю необходимые привилегии;
- убедиться, что порт 3306 открыт в настройках брандмауэра.

**3. Какая команда позволяет получить обзор доступных баз данных после входа в среду оболочки MariaDB?**  
Для просмотра списка доступных баз данных используется SQL-команда:
```sql
SHOW DATABASES;
````

**4. Какая команда позволяет узнать, какие таблицы доступны в базе данных?**
После выбора базы данных командой `USE имя_базы;` список таблиц выводится командой:

```sql
SHOW TABLES;
```

**5. Какая команда позволяет узнать, какие поля доступны в таблице?**
Для просмотра структуры таблицы и списка её полей используется команда:

```sql
DESCRIBE имя_таблицы;
```

или

```sql
SHOW COLUMNS FROM имя_таблицы;
```

**6. Какая команда позволяет узнать, какие записи доступны в таблице?**
Для просмотра содержимого таблицы применяется SQL-запрос:

```sql
SELECT * FROM имя_таблицы;
```

Он выводит все строки и все столбцы указанной таблицы.

**7. Как удалить запись из таблицы?**
Удаление записи выполняется командой `DELETE` с указанием условия:

```sql
DELETE FROM имя_таблицы WHERE условие;
```

Например, удаление записи по значению поля:

```sql
DELETE FROM city WHERE name = 'Иванов';
```

**8. Где расположены файлы конфигурации MariaDB? Что можно настроить с их помощью?**
Основные файлы конфигурации MariaDB располагаются в:

* `/etc/my.cnf`;
* `/etc/my.cnf.d/`.

С их помощью можно настраивать параметры сервера и клиента: сетевые настройки, кодировки символов, параметры хранения данных, пути к файлам, настройки безопасности, журналирование, производительность и поведение сервиса при запуске.

**9. Где располагаются файлы с базами данных MariaDB?**
Файлы баз данных MariaDB по умолчанию хранятся в каталоге:

```
/var/lib/mysql/
```

Внутри этого каталога для каждой базы данных создаётся отдельный подкаталог с файлами таблиц и служебной информацией.

**10. Как сделать резервную копию базы данных и затем её восстановить?**
Резервное копирование выполняется с помощью утилиты `mysqldump`, например:

```bash
mysqldump -u root -p имя_базы > backup.sql
```

Восстановление базы данных из резервной копии выполняется командой:

```bash
mysql -u root -p имя_базы < backup.sql
```

Для сжатых резервных копий можно использовать `gzip` и `zcat`:

```bash
mysqldump -u root -p имя_базы | gzip > backup.sql.gz
zcat backup.sql.gz | mysql -u root -p имя_базы
```

