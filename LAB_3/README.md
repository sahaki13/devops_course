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

Затем сделать полную остановку и старт контейнера с гитлабом и применить конфигурацию:
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

## 2) Развернуть docker-registry
Использовать встроенное registry в gitlab мы не будем, поэтому развернем свое минималистичное.

По умолчанию в репозитории лежит зашифрованный файл `.auth` для `docker-registry`, creds:
```
user: admin
password: pass
```
Файл сгенерирован следующим образом:
```
htpasswd -Bbn <user> <pass> > .auth
```
Утилита требует установки пакета `apache2-utils` (debian based distro).
Логин и пароль можно оставить по умолчанию и не менять.

Это минимальный registry, у него нету интегрированного UI, смотреть содержимое можно через API.<br>
Для нас достаточно смотреть список загруженных образов и их тегов, изначально он будет пустым.<br>После запуска, можно сделать проверку все ли корректно развернулось:
```
curl -s -u <user>:<pass> http://192.168.99.100:5050/v2/_catalog | json_pp
```
Если все ок, то отдаст пустой список реп:
```
{
   "repositories" : []
}
```
Или отправить запрос через адресную строку браузера (ниже примеры запросов к API для моих репозиториев):
```
# get repos
http://192.168.99.100:5050/v2/_catalog

# get repo tags
http://192.168.99.100:5050/v2/root/echo-server/tags/list
http://192.168.99.100:5050/v2/root/hash-generator/tags/list

# get manifest + digest (Docker-Content-Digest header)
http://192.168.99.100:5050/v2/root/echo-server/manifests/3.1.0
```
Затем логинимся в registry, чтобы сгенерировался файл `config.json`:
```
docker login 192.168.99.100:5050
```
Забираем creds:
```
cat ~/.docker/config.json
```
Добавляем их в глобальную переменную для всех проектов `gitlab`, открываем:
```
http://192.168.99.100/admin/application_settings/ci_cd
```
Жмем `Add variable`-> выбираем `Type` -> `file` -><br>
В поле `Key` вводим `DOCKER_CONFIG_JSON` -><br>
В поле `Value` вводим все содержимое из файла `~/.docker/config.json`<br>
Жмем `Add variable`

## 3) Создать и запустить runner.

   * Перейти http://192.168.99.100:80/-/user_settings/personal_access_tokens
   * Нажать на `Add new token`
   * Указать имя, время жизни, права на `api`, `create_runner`
   * Нажать `Create personal access token`
   * Скопировать токен и подставить его в переменную `PERSONAL_ACCESS_TOKEN` в файле `.env`
   * Убедиться, что в `docker-compose.yaml` `IS_REGISTER_RUNNER: true` и запустить `docker compose up runner`
   * После регистрации, остановить контейнер нажатием `ctrl c`
   * Убедиться, что в docker-compose.yaml `IS_REGISTER_RUNNER: false` и запустить в фоне `docker compose up -d runner`
   * Проверить что runner появился в списке http://192.168.99.100:80/admin/runners

## 4) Написать `.gitlab-ci.yml` для своего приложения
Манифест должен включать следующие этапы:
* `Build stage`, этап сборки
* `Test stage`, этап тестов (unit tests, sast, codestyle, ...) можно сделать просто заглушками
* `Dockerize stage`, этап упаковки приложения в образ и загрузки образа в registry

Пример `.gitlab-ci.yml` манифестов в директории `applications/*`

## 5) Запуск пайпа и проверка registry
Запустить пайплайн `ui` -> `your project` -> `build` -> `pipelines` -> `run pipeline` дождаться завершения и sроверить что все этапы завершились без ошибок.

Проверить что образ появился в registry сделав запрос к API.

# Альтернативный вариант (Forgejo, docker regitry/Nexus, Jenkins)

TODO

## При показе выполненного задания
   * Продемонстрировать успешное развертывание **Gitlab** + **runner**
   * Составить **.gitlab-ci.yml** манифест. Собрать приложение несколько раз с разными тегами (нужно внести какие-то изменения в ваше приложение), запустить пайплайн и дождаться окончания сборки
   * Запустить собранные образы на master-0 и продемонстрировать отличия в версиях образов (например отличается лог при запуске/работе сервиса)

