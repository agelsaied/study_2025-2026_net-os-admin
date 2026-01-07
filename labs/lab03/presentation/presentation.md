---
lang: ru-RU
title: Отчёт по лабораторной работе №3
subtitle: Настройка DHCP-сервера Kea и DDNS-интеграции с Bind
author:
  - Элсаиед Адел
institute:
  - Российский университет дружбы народов, Москва, Россия
date: 2 января 2026

toc: false
slide_level: 2
aspectratio: 169
section-titles: true
theme: metropolis
header-includes:
 - \metroset{progressbar=frametitle,sectionpage=progressbar,numbering=fraction}
---

# Цели и задачи работы

## Цель

Приобретение практических навыков установки и конфигурирования DHCP-сервера.

# Выполнение работы

## Установка Kea DHCP

- переход в режим суперпользователя (`sudo -i`)
- установка пакета `kea` через `dnf`
- зависимости установлены автоматически, ошибок не выявлено

![Установка DHCP-сервера Kea](Screenshot_1.png){ #fig:001 width=75% }

## Настройка DHCP: параметры DNS

- DNS-сервер для клиентов: `192.168.1.1`
- доменное имя: `elsaiedadel.net`
- домен поиска: `elsaiedadel.net`

![Настройка параметров DNS в kea-dhcp4.conf](Screenshot_2.png){ #fig:002 width=75% }

## Настройка DHCP: подсеть и пул адресов

- подсеть: `192.168.1.0/24`
- пул: `192.168.1.30 - 192.168.1.199`
- шлюз (routers): `192.168.1.1`

![Конфигурация DHCP-подсети](Screenshot_3.png){ #fig:003 width=75% }

## DNS: добавление записей DHCP-сервера

- прямая зона: `dhcp A 192.168.1.1`

![Настройка прямой DNS-зоны](Screenshot_4.png){ #fig:004 width=70% }

## DNS: добавление записей DHCP-сервера

- обратная зона: `1 PTR dhcp.elsaiedadel.net.`

![Настройка обратной DNS-зоны](Screenshot_5.png){ #fig:005 width=70% }

## Проверка разрешения имени DHCP

- перезапуск Bind: `systemctl restart named`
- проверка: `ping dhcp.elsaiedadel.net`
- имя разрешается, потерь пакетов нет

![Проверка разрешения имени DHCP-сервера](Screenshot_6.png){ #fig:006 width=75% }

## Firewall и SELinux, запуск DHCP

![Запуск DHCP-сервера Kea](Screenshot_7.png){ #fig:007 width=75% }

## Provisioning маршрутизации на client

- шлюз по умолчанию назначается через `eth1`
- для `eth0` отключается default-route (IPv4/IPv6)
- переподнимаются соединения NetworkManager

![Provisioning-скрипт настройки маршрутизации client](Screenshot_8.png){ #fig:008 width=75% }

## Получение адреса и ifconfig на client

- `eth1`: получен адрес `192.168.1.30/24`, broadcast `192.168.1.255`
- `eth0`: активен, но не является дефолтным маршрутом
- `lo`: локальная петля `127.0.0.1`

![Сетевые интерфейсы виртуальной машины client](Screenshot_9.png){ #fig:009 width=75% }

## Файл аренд Kea: kea-leases4.csv

- `address` — выданный IP (`192.168.1.30`)
- `hwaddr` — MAC-адрес клиента
- `client_id` — идентификатор клиента (если используется)
- `valid_lifetime` — длительность аренды
- `expire` — время истечения аренды (epoch)
- `subnet_id` — ID подсети (в конфигурации `id: 1`)
- `state` — состояние записи аренды

![Файл аренды DHCP kea-leases4.csv](Screenshot_10.png){ #fig:010 width=75% }

## TSIG-ключ для динамических обновлений

- сгенерирован ключ:
  - `tsig-keygen -a HMAC-SHA512 DHCP_UPDATER > /etc/named/keys/dhcp_updater.key`

![Генерация TSIG-ключа DHCP_UPDATER](Screenshot_11.png){ #fig:011 width=75% }

## Bind: разрешение обновлений зон (update-policy)

В конфигурации зон включены правила:

- прямая зона `elsaiedadel.net`: разрешить `A` по ключу `DHCP_UPDATER`
- обратная зона `1.168.192.in-addr.arpa`: разрешить `PTR` по ключу `DHCP_UPDATER`

![Настройка update-policy для DNS-зон](Screenshot_12.png){ #fig:012 width=75% }

## Kea: ключ в JSON и конфигурация DHCP-DDNS

1) Создан файл `/etc/kea/tsig-keys.json` (TSIG в формате JSON)  
2) Настроен `/etc/kea/kea-dhcp-ddns.conf`:

![TSIG-ключ в формате JSON для Kea](Screenshot_13.png){ #fig:013 width=70% }

## Kea: ключ в JSON и конфигурация DHCP-DDNS

![Конфигурация DHCP-DDNS в Kea](Screenshot_14.png){ #fig:014 width=70% }

## Запуск kea-dhcp-ddns и включение обновлений в DHCPv4

![Состояние службы kea-dhcp-ddns](Screenshot_15.png){ #fig:015 width=75% }

## Запуск kea-dhcp-ddns и включение обновлений в DHCPv4

![Настройка DDNS в kea-dhcp4.conf](Screenshot_16.png){ #fig:016 width=75% }

## Запуск kea-dhcp-ddns и включение обновлений в DHCPv4

- перезапуск DHCP

![Состояние службы kea-dhcp4](Screenshot_17.png){ #fig:017 width=75% }

## Проверка: запись клиента появилась в DNS (dig)

Ключевые признаки корректной работы:

- `status: NOERROR` — запись найдена
- `aa` — ответ авторитетный
- в ANSWER: `A 192.168.1.30` — имя сопоставлено выданному адресу

![Проверка DNS-записи клиента с помощью dig](Screenshot_18.png){ #fig:018 width=80% }

## Сохранение конфигураций и скрипт dhcp.sh

![Копирование конфигурации DNS и DHCP](Screenshot_19.png){ #fig:019 width=75% }

## Сохранение конфигураций и скрипт dhcp.sh

![Provisioning-скрипт dhcp.sh](Screenshot_20.png){ #fig:020 width=75% }


# Выводы

## Итог

- Настроен Kea DHCPv4: выдача адресов и сетевых параметров
- Проанализирована работа DHCP на клиенте (маршрутизация, ifconfig, leases)
- Реализована интеграция DHCP и Bind через DDNS (TSIG + update-policy)
- Подтверждено автоматическое создание DNS-записи клиента (dig)
- Выполнена автоматизация действий через provisioning-скрипты Vagrant
