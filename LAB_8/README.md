# ЛАБОРАТОРНАЯ №8. Collect, storage and search logs. (OpenSearch, Vector)

## Docs
* [OpenSearch](https://docs.opensearch.org/latest/)
* [Vector](https://vector.dev/docs/)

Цель задания настроить инструменты:
* сбора
* хранения
* поиска

Разворачивать инструменты будем в нашем кластере kubernetes.<br>
Подготовлен чарт который развернет стек.<br>
Основные интрументы для работы с метриками:
* log collectors
* storage + search engine
* visualisation tools

В качестве хранилища и движка поиска будем использовать:
* `OpenSearch`

Для визуализации:
* `OpenSearch Dashboards`

Для сбора логов:
* `vector`

Собирать логи будем с запущенных подов k8s

## Предварительные действия
Добавить записи в `/etc/hosts`:
```
192.168.99.200 opensearch.test.local
```

## 1) TODO

