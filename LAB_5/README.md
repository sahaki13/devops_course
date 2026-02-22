# ЛАБОРАТОРНАЯ №5. Container orchestration system. Kubernetes + Helm + HashiCorp Vault

## Docs

* [Helm](https://helm.sh/docs)
* [Kubernetes](https://kubernetes.io/docs/home/)
* [Kubernetes cluster architecture](https://kubernetes.io/docs/concepts/architecture/)
* [Vault cli](https://developer.hashicorp.com/vault/docs/commands)

# Требования

Написать k8s манифесты и развернуть в kubernetes приложения с помощью `kubectl`.
Написать простой `helm chart` для шаблонизации манифестов и повторно развернуть, но уже с помощью `helm`.
Использовать `vault` для получения секретов в pod.

Обычно управление k8s происходит через `kubectl` с отдельной машины, изолированой от окружения где развернут кластер, но в нашем случае будет запускаться с master-0. С утилитой `helm` ситуация такая же.

Утилита `kubectl` и `helm` уже должна быть установлена и настроена в лаб. №4. Чтобы не писать команду целиком `kubectl`, можно использовать alias `k`.

1) В директории `examples` есть примеры манифестов для развертывания сервисов.
   В них используются самые основные и необходимые абстракции/контрóллеры k8s.
   Поэтому вам нужно проанализировать и разобраться с их синтаксисом, затем изменить под свое окружение и приложение.

* namespace
* service
* pod
* replicaset
* deployment

   После этого зайти на master-0, и развернуть манифесты, самый простой способ с помощью команд:

```
$ k apply -f <path_to_manifest> # применить конфигурацию
$ k delete -f <path_to_manifest> # удалить созданные ресурсы
```

   Достаточно сделать all-in-one deployment содержащий service, pod, ns, rs

   После развертывания сделать запросы к своему сервису.

2) Развернуть систему хранения секретов `vault` и разобраться с этим инструментом.
   Hастроить, добавить секреты, получить секреты и продемонстрировать что они получены
   (например зайти в pod и посмотреть содержимое .env файла)


```
$ cd ~/work/LAB_5

# Добавить к себе на хост запись в /etc/hosts
192.168.99.200 vault.test.local

# Создать директорию для хранения данных vault на диске и pv
$ k apply -f ./examples/vault/setup-vault.yaml

# Установить chart и дождаться инициализации (проверить по логам или ui)
$ helm install vault -n vault ./helm/vault

# Запустить сценарии (предварительно поменять значения на свои ./helm/templates/configmap.yaml)
$ k exec -it -n vault vault-0 -- /vault/scripts/create_users.sh
$ k exec -it -n vault vault-0 -- /vault/scripts/create_secrets.sh
```

```
# Проверка все ли успешно прошло (лог пода можно смотреть в другом окне пока работает тест)
$ helm test -n vault vault
$ k logs -n dev pods/vault-test dev-jq-curl-1 --follow
```
![test_success](./docs/test_success.png "test_success")
![test_success_log](./docs/test_success_log.png "test_success_log")

```
# Для отладки токена, если нужно
echo $(cat /var/run/secrets/kubernetes.io/serviceaccount/token) | cut -d '.' -f 2 | base64 -d 2>/dev/null | jq .

# Удалить chart можно с помощью команды
$ helm uninstall -n vault vault

# Удалить pv, pvc, ns и все постоянные данные
$ k delete -f ./examples/vault/setup-vault.yaml
$ k apply -f ./examples/vault/remove-vault-srotage.yaml

# Если pv зависло в статусе terminating при удалении (обычно если осталось pvc), тогда
$ k patch pv vault-pv-0 -p '{"metadata":{"finalizers":null}}'
```

3) Использовать helm для запуска сервиса (пример чарта расположен в ./helm/ms).
   Отредактировать values для своего сервиса и запустить или сделать свой чарт с нуля.

```
# Поправить values в чарте ./helm/ms/values.yaml

# Добавить к себе на хост запись в /etc/hosts (<service_name> поменять на свое имя сервиса)
192.168.99.200 <service_name>.test.local

# Создание структуры шаблона
$ helm create echo-server

# Проверка шаблона с подставленными values (для отладки шаблонизатора)
$ helm template -n dev echo-server ./helm/ms/

# Установка чарта
$ helm install -n dev echo-server ./helm/ms

# Обновление версии чарта (например изменить версию образа), правим values и обновляем
$ helm upgrade -n dev echo-server ./helm/ms

# Можно через --set-string указать нужные values для замены (через запятую без пробелов)
$ helm upgrade -n dev echo-server ./helm/ms --set-string ms.tag=2.3.0,ms.rs=5

# Удалить чарт
$ helm uninstall -n dev echo-server
```

## Полезные команды k8s
```
# Показать манифест без запуска
k apply -k <path_to_manifest> --dry-run=client -o yaml

# Проброс порта
k port-forward svc/<service_name> -n <ns_name> <external_port>:<internal_port>

# Следить за событиями во всех ns кластера
k get events -A --sort-by='.lastTimestamp' -w

# Вывести потребляемые ресурсы
k top pod -n <ns_name> --sort-by=memory

# Посмотреть ресурсы
k get all,cm,secret,ing,pvc -n <ns_name>

# Показать все уникальные образы, которые запущены на данный момент
k get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n' | sort | uniq

# Сравнить локальный ресурс (например чтобы проверить изменения) с тем который запущен в кластере
k diff -n <ns_name> -f ./<resource_file>

# Сохранить измененный манифест в файл, чтобы можно было сравнить с оригинальным
k kustomize ./<path_to_kustomize> > install.yaml

# Зайти в init-container
k exec -it -n <ns_name> pods/<pod_name> -c <init_container_name> -- /bin/sh

# Посмотреть логи init-container
k logs -f -n <ns_name> pods/<pod_name> -c <init_container_name>

# Запуск pod для отладки
k run dbg-pod --rm -it --restart=Never --image=docker.io/pnnlmiscscripts/curl-jq:1.6-10 -- /bin/bash
```

## При показе выполненного задания
   * Запустить deployment и сделать запросы к сервису
   * Продемонстрировать успешную настройку и доступ к vault
   * Запустить helm чарт для сервиса, продемонстрировать что секреты были
     получены из vault и были прочитаны сервисом.
     (например прочесть .env и вывести содержимое при запросе к отдельному endpoint сервиса)
