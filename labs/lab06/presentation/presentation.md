---
lang: ru-RU
title: Отчёт по лабораторной работе №6
subtitle: Установка и настройка СУБД MariaDB
author:
  - Элсаиед Адел
institute:
  - Российский университет дружбы народов, Москва, Россия
date: 3 января 2026

toc: false
slide_level: 2
aspectratio: 169
section-titles: true
theme: metropolis
header-includes:
 - \metroset{progressbar=frametitle,sectionpage=progressbar,numbering=fraction}
---

# Цели и задачи работы

## Цель лабораторной работы

Приобретение практических навыков по установке и конфигурированию системы управления базами данных на примере MariaDB.

# Выполнение работы

## Установка пакетов MariaDB

На виртуальной машине `server` выполнена установка серверной и клиентской части MariaDB.

![Установка пакетов MariaDB](Screenshot_1.png){ #fig:001 width=70% }

## Запуск и автозагрузка службы

Служба MariaDB запущена и включена в автозагрузку:

- `systemctl start mariadb`
- `systemctl enable mariadb`

![Запуск и enable mariadb](Screenshot_2.png){ #fig:003 width=70% }

## Проверка прослушивания порта 3306

Проверено, что процесс `mariadbd` слушает порт `3306`:

- `ss -tulpen | grep 3306`

![Проверка порта 3306](Screenshot_2.png){ #fig:004 width=70% }

## mysql_secure_installation

Выполнено:
- настройка root-доступа (в т.ч. unix_socket)
- установка пароля root MariaDB
- применение обновлений таблиц привилегий

![mysql_secure_installation](Screenshot_3.png){ #fig:005 width=70% }

## Проверка окружения MariaDB

В интерактивной оболочке проверены:
- справка: `\h`
- системные базы: `SHOW DATABASES;`

![Справка и SHOW DATABASES](Screenshot_4.png){ #fig:006 width=70% }

## Статус до изменения кодировки

Команда `status` показала, что серверная кодировка по умолчанию была `latin1`.

![status до настройки UTF-8](Screenshot_5.png){ #fig:007 width=70% }

## Настройка UTF-8 через utf8.cnf

Создан файл `/etc/my.cnf.d/utf8.cnf`:

![Файл utf8.cnf](Screenshot_6.png){ #fig:008 width=70% }

## Статус после перезапуска MariaDB

Изменения:
- `Server characterset`: `latin1` → `utf8mb3`
- `Db characterset`: `latin1` → `utf8mb3`

![status после настройки UTF-8](Screenshot_7.png){ #fig:009 width=70% }

## Создание базы и таблицы

![SELECT * FROM city](Screenshot_8.png){ #fig:010 width=70% }

## Создание пользователя и выдача прав

![Пользователь, GRANT, DESCRIBE](Screenshot_9.png){ #fig:011 width=70% }

## Проверка структуры таблицы и объектов

![mysqlshow: базы и таблицы](Screenshot_10.png){ #fig:012 width=70% }

## Резервные копии mysqldump

![Backup/Restore addressbook](Screenshot_11.png){ #fig:013 width=70% }

## Подготовка файлов для provisioning

Созданы каталоги в `/vagrant/provision/server`:
- `mysql/etc/my.cnf.d`
- `mysql/var/backup`

![Копирование конфигурации и резервных копий](Screenshot_12.png){ #fig:014 width=70% }

## Скрипт mysql.sh

Создан исполняемый скрипт `mysql.sh`, который повторяет выполненные шаги:

![mysql.sh (provisioning)](Screenshot_13.png){ #fig:015 width=70% }

# Выводы

## Вывод

В ходе лабораторной работы выполнена установка и настройка MariaDB на виртуальной машине: применены базовые меры безопасности, настроена кодировка UTF-8, создана пользовательская база `addressbook`, реализовано управление доступом и проверены операции резервного копирования/восстановления. Дополнительно подготовлен provisioning-скрипт, автоматизирующий установку и конфигурацию, что повышает воспроизводимость и упрощает развёртывание серверного окружения.
