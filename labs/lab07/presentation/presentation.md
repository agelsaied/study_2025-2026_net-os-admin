---
lang: ru-RU
title: "Лабораторная работа №7"
subtitle: "Расширенные настройки межсетевого экрана (FirewallD)"
author:
  - "Элсаиед Адел"
date: 3 января 2026

toc: false
slide_level: 2
aspectratio: 169
section-titles: true
theme: metropolis
header-includes:
 - \metroset{progressbar=frametitle,sectionpage=progressbar,numbering=fraction}
---

# Цели и ожидаемый результат

## Цель работы

Получить навыки настройки межсетевого экрана в Linux:
- переадресация (port forwarding);
- маскарадинг (masquerading / NAT).

# Выполнение работы

## Создание пользовательской службы FirewallD (ssh-custom)

- скопирован файл `/usr/lib/firewalld/services/ssh.xml`;
- создан пользовательский файл `/etc/firewalld/services/ssh-custom.xml`;
- изучена структура XML-описания службы.

![Просмотр содержимого ssh-custom.xml](Screenshot_1.png){ width=75% }

## Редактирование ssh-custom: порт и описание

Изменения в `/etc/firewalld/services/ssh-custom.xml`:
- порт SSH изменён со стандартного `22` на `2022`;
- описание уточнено как пользовательская модификация.

![Редактирование порта и описания службы](Screenshot_2.png){ width=75% }

## Активация службы ssh-custom

Служба добавлена в правила FirewallD:

![Добавление ssh-custom и перезагрузка FirewallD](Screenshot_3.png){ width=75% }

## Перенаправление портов 2022 → 22 на сервере

Настройка позволяет:
- принимать подключения на внешнем порту `2022`,
- при этом обслуживать их локальной SSH-службой на `22`.

![Настройка port forward 2022 -> 22](Screenshot_4.png){ width=75% }

## Проверка SSH-подключения с клиента

На `client` выполнено подключение по SSH к `server` через порт `2022`.

![Проверка SSH-подключения через порт 2022](Screenshot_5.png){ width=75% }

## Включение IPv4 forwarding + masquerading (NAT)

- создан `/etc/sysctl.d/90-forward.conf` с `net.ipv4.ip_forward = 1`;
- применены sysctl-настройки;
- включён masquerading (NAT) для зоны `public`;
- перезагружен FirewallD для применения конфигурации.

![Включение ip_forward и masquerading](Screenshot_6.png){ width=75% }

## Проверка выхода клиента в Интернет

На `client` проверен доступ во внешнюю сеть.

![Проверка выхода в Интернет на клиенте](Screenshot_7.png){ width=75% }

## Подготовка файлов в provision-структуре

Для воспроизводимости окружения подготовлены файлы в `/vagrant/provision/server/`:
- `ssh-custom.xml` (служба FirewallD);
- `90-forward.conf` (sysctl-настройка forwarding).

![Подготовка каталогов и копирование конфигураций](Screenshot_8.png){ width=75% }

## Скрипт firewall.sh для автоматической настройки

![Содержимое скрипта firewall.sh](Screenshot_9.png){ width=75% }

# Итоги

## Выводы по работе

В ходе лабораторной работы:
- создана пользовательская служба FirewallD для SSH с портом `2022`;
- настроено перенаправление `2022 → 22` и подтверждено успешным SSH-подключением;
- включены IPv4 forwarding и masquerading для маршрутизации трафика клиента;
- подготовлена автоматизация через provisioning для повторяемого развёртывания.