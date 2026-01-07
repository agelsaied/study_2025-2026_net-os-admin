---
lang: ru-RU
title: Отчёт по лабораторной работе №10
subtitle: Расширенные настройки SMTP-сервера (Postfix + Dovecot)
author:
  - Элсаиед Адел
institute:
  - Российский университет дружбы народов, Москва, Россия
date: 4 января 2026

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
Приобретение практических навыков конфигурирования SMTP-сервера в части настройки аутентификации и защищённой отправки почты.

# Выполнение работы

## LMTP: включение протокола в Dovecot

В файле `/etc/dovecot/dovecot.conf` расширен список протоколов: добавлен LMTP, что позволяет Dovecot принимать почту от Postfix через локальный протокол доставки.

![Добавление LMTP в список протоколов](Screenshot_1.png){ #fig:001 width=70% }

## LMTP: сокет для связи Postfix ↔ Dovecot

В `/etc/dovecot/conf.d/10-master.conf` настроен сервис `lmtp` и UNIX-сокет `/var/spool/postfix/private/dovecot-lmtp` с правами доступа и принадлежностью `postfix:postfix`, чтобы Postfix мог безопасно передавать сообщения Dovecot.

![Настройка сервиса lmtp и UNIX-сокета](Screenshot_2.png){ #fig:002 width=70% }

## Dovecot: формат логина для аутентификации

В `/etc/dovecot/conf.d/10-auth.conf` установлен формат имени пользователя `auth_username_format = %Ln`, чтобы аутентификация выполнялась по логину без доменной части и с приведением к нижнему регистру.

![Настройка auth_username_format](Screenshot_3.png){ #fig:003 width=70% }

## Проверка LMTP: доставка и журналы

При отправке тестового сообщения на стороне сервера в `/var/log/maillog` наблюдаются стадии:
SMTP-сеанс → постановка в очередь → передача в транспорт `lmtp` → приём Dovecot → сохранение в INBOX.

![Фрагмент maillog при доставке через LMTP](Screenshot_4.png){ #fig:004 width=70% }

## Проверка Maildir

На сервере выполнена проверка почтового ящика формата Maildir: тестовое письмо «LMTP test» присутствует во входящих.

![Проверка почтового ящика пользователя](Screenshot_5.png){ #fig:005 width=70% }

## SMTP AUTH: настройка службы auth в Dovecot

В `/etc/dovecot/conf.d/10-master.conf` определена служба `auth`:
- сокет `/var/spool/postfix/private/auth` для Postfix (права `0660`, владелец/группа postfix);
- сокет `auth-userdb` для внутренних операций Dovecot (права `0600`, пользователь dovecot).

![Конфигурация service auth](Screenshot_6.png){ #fig:006 width=70% }

## SMTP AUTH: параметры Postfix

В Postfix включена SASL-аутентификация через Dovecot: задан тип `dovecot` и путь `private/auth`. Дополнительно настроены ограничения получателей для защиты от несанкционированного relay.

![Настройка SASL и ограничений через postconf](Screenshot_7.png){ #fig:007 width=70% }

## SMTP AUTH: временная проверка на 25 порту

Для тестирования авторизации в `/etc/postfix/master.cf` временно включены параметры `smtpd_sasl_auth_enable` и упрощённые ограничения, разрешающие доставку при успешной аутентификации.

![Изменение master.cf для теста SMTP AUTH](Screenshot_8.png){ #fig:008 width=70% }

## SMTP AUTH: тестирование с клиента

На клиенте выполнена проверка: получена base64-строка для `AUTH PLAIN`, выполнено подключение и успешная аутентификация пользователя.

![Проверка AUTH PLAIN с клиента](Screenshot_9.png){ #fig:009 width=70% }

## SMTP over TLS: подготовка сертификата и параметры Postfix

Использован временный сертификат Dovecot: сертификат и ключ перенесены в `/etc/pki/tls/…` для корректной работы с SELinux. В Postfix заданы пути к сертификату/ключу, кэш TLS-сессий и уровень `may`.

![Копирование сертификата и настройка TLS в Postfix](Screenshot_10.png){ #fig:010 width=70% }

## SMTP over TLS: служба submission (587)

В `/etc/postfix/master.cf` настроена служба `submission` на порту 587:
- обязательное шифрование `smtpd_tls_security_level=encrypt`;
- включена SMTP-аутентификация;
- ограничения для получателей как при тестировании AUTH.

![Настройка submission в master.cf](Screenshot_11.png){ #fig:011 width=70% }

## Проверка STARTTLS на 587 порту

С клиента выполнено подключение к 587 порту с STARTTLS, подтверждена поддержка `AUTH PLAIN` и успешная аутентификация по защищённому каналу.

![Проверка STARTTLS и AUTH на 587 порту](Screenshot_12.png){ #fig:012 width=70% }

## Отправка почты через Evolution

Проверка пользовательского сценария выполнена через Evolution:
SMTP-сервер настроен на порт 587, STARTTLS и обычный пароль. Письма успешно отправлены и доставлены.

![Проверка отправки через Evolution](Screenshot_13.png){ #fig:013 width=70% }

## Подтверждение по журналам

В `/var/log/maillog` отражены этапы: подключение клиента → TLS → SASL-аутентификация → передача в LMTP → сохранение в INBOX.

![Журнал доставки при SMTP over TLS](Screenshot_14.png){ #fig:014 width=70% }

## Интеграция в provisioning: перенос конфигов

Актуальные конфигурационные файлы Dovecot и Postfix скопированы в каталог `/vagrant/provision/server/...` для воспроизводимого развёртывания.

![Копирование конфигов в provision-дерево](Screenshot_15.png){ #fig:015 width=70% }

## Интеграция в provisioning: server/mail.sh

В скрипт добавлены шаги установки пакетов, копирования конфигурации, настройки firewall, а также параметры Postfix для LMTP, SMTP AUTH и SMTP over TLS.

![Изменения в /vagrant/provision/server/mail.sh](Screenshot_16.png){ #fig:016 width=70% }

## Интеграция в provisioning: client/mail.sh

В provisioning-скрипт клиента добавлена установка утилиты telnet для диагностики SMTP-сеансов и проверки аутентификации.

![Изменения в /vagrant/provision/client/mail.sh](Screenshot_17.png){ #fig:017 width=70% }

# Выводы

## Вывод

В ходе лабораторной работы настроены расширенные функции почтового сервера: доставка по LMTP, SMTP-аутентификация через Dovecot и защищённая отправка по SMTP over TLS (submission/587, STARTTLS). Работоспособность подтверждена тестами с клиента (AUTH и STARTTLS), а также анализом журналов. Конфигурации и действия интегрированы в provisioning-скрипты Vagrant, что обеспечивает воспроизводимость стенда.
