# ЛАБОРАТОРНАЯ №3. Continuous Integration. Gitlab

## Docs

* [Gitlab docs](https://docs.gitlab.com/)
* [Runner creation](https://docs.gitlab.com/tutorials/automate_runner_creation)

## Возможные ошибки при выполнении задания

Если на этапе `dockerize` при выполнении `docker login` возникает ошибка

```
Error response from daemon: Get "http://192.168.99.100:5050/v2/": Get "http://gitlab:80/jwt/auth?account=gitlab-ci-token&client_id=docker&offline_token=true&service=container_registry": dial tcp: lookup gitlab: no such host
```

тогда добавить строку `registry['token_realm'] = "192.168.99.100:80"` в конец файла ./cfg/gitlab.rb

Затем перезапустить контейнер и применить конфигурацию

```
$ docker compose down gitlab
$ docker compose up -d gitlab

# дождаться запуска gitlab и выполнить reconfigure
$ docker exec gitlab gitlab-ctl reconfigure
```

# Первый вариант (Gitlab)

## 1) Развернуть Gitlab
Подключиться по ssh к ВМ master-0.

Добавить файл `daemon.json` в `/etc/docker/` и перезапустить докер.
```
$ su -
# cp /home/$(id -un 1000)/work/devops_course/LAB_3/gitlab/daemon.json /etc/docker/daemon.json
# systemctl restart docker.service
# exit
```
Перейти в директорию с заданием
```
$ cd ~/work/devops_course/LAB_3/gitlab
```
Создать файл .env с переменной содержащей необходимые переменные
```
$ ./scripts/prepare_env.sh
```

Развернуть Gitlab.
```
$ docker compose up -d gitlab
```
Инициализация займет некоторое время, все последующие запуски будут быстрее.

После инициализации открыть с хоста адрес http://192.168.99.100:80/ и проверить работу Gitlab, данные для входа:
```
login: root
password: GITLAB_ROOT_PASSWORD field from .env
```

* (Опционально) Перейти http://192.168.99.100/admin/users и создать пользователя
* (Опционально) Перейти http://192.168.99.100/-/user_settings/ssh_keys и добавить публичный ssh ключ (удобнее чем http метод).
* Создать репозиторий для вашего приложения http://192.168.99.100/projects/new#blank_project и загрузить приложение в Gitlab

## 2) Создать и запустить runner.

   * Перейти http://192.168.99.100:80/-/user_settings/personal_access_tokens
   * Нажать на `Add new token`
   * Указать имя, время жизни, права на `api`, `create_runner`
   * Нажать `Create personal access token`
   * Скопировать токен и подставить его в переменную `PERSONAL_ACCESS_TOKEN` в файле `.env`
   * Убедиться, что в `docker-compose.yaml` `IS_REGISTER_RUNNER: true` и запустить `docker compose up runner`
   * После регистрации, остановить контейнер нажатием `ctrl c`
   * Убедиться, что в docker-compose.yaml `IS_REGISTER_RUNNER: false` и запустить в фоне `docker compose up -d runner`
   * Проверить что runner появился в списке http://192.168.99.100:80/admin/runners

## 3) Написать `.gitlab-ci.yml` для своего приложения
Манифест должен включать следующие этапы:
* `Build stage`, этап сборки
* `Test stage`, этап тестов (unit tests, sast, codestyle, ...) можно сделать просто заглушками
* `Dockerize stage`, этап упаковки приложения в образ и загрузки образа в registry

## 4) Запуск пайпа и проверка registry
Запустить пайплайн `ui` -> `your project` -> `build` -> `pipelines` -> `run pipeline` дождаться завершения и sроверить что все этапы завершились без ошибок.

Проверить что образ появился в registry `ui` -> `your project` -> `deploy` -> `container registry`

# Альтернативный вариант (Forgejo, docker regitry/Nexus, Jenkins)

TODO

## При показе выполненного задания
   * Продемонстрировать успешное развертывание **Gitlab** + **runner**
   * Составить **.gitlab-ci.yml** манифест. Собрать приложение несколько раз с разными тегами (нужно внести какие-то изменения в ваше приложение), запустить пайплайн и дождаться окончания сборки
   * Запустить собранные образы на master-0 и продемонстрировать отличия в версиях образов (например отличается лог при запуске/работе сервиса)

