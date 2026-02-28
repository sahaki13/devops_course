# ЛАБОРАТОРНАЯ №3. Continuous Integration. Gitlab

## Docs

* [Gitlab docs](https://docs.gitlab.com/)
* [Runner creation](https://docs.gitlab.com/tutorials/automate_runner_creation)


Требования:

1) Развернуть CI систему

   Подключиться по ssh к ВМ master-0.
   Перед началом задания добавить файл `daemon.json` в `/etc/docker/` и перезапустить докер.
   Перейти в директорию с заданием, создать файл .env с переменной содержащей пароль и развернуть Gitlab.
   Инициализация займет некоторое время, все последующие запуски будут быстрее.
```
$ su -
# cp /home/$(id -un 1000)/work/devops_course/LAB_3/gitlab/daemon.json /etc/docker/daemon.json
# systemctl restart docker.service
# exit
$ cd ~/work/devops_course/LAB_3/gitlab
$ ./scripts/prepare_env.sh
# Открыть файл .env и указать свой пароль в переменную GITLAB_ROOT_PASSWORD
$ docker compose up -d gitlab
```
   После инициализации открыть с хоста адрес http://192.168.99.100:80/ и проверить работу Gitlab.
   * (Опционально) Перейти http://192.168.99.100/admin/users и создать пользователя
   * (Опционально) Перейти http://192.168.99.100/-/user_settings/ssh_keys и добавить публичный ssh ключ
   * Создать репозиторий для вашего приложения http://192.168.99.100/projects/new#blank_project и загрузить приложение в Gitlab

2) Создать и запустить runner.

   * Перейти http://192.168.99.100:80/-/user_settings/personal_access_tokens
   * Нажать на `Add new token`
   * Указать имя, время жизни, права на `api`, `create_runner`
   * Скопировать токен и указать его в переменную PERSONAL_ACCESS_TOKEN в файле .env
   * Убедиться, что в docker-compose.yaml `IS_REGISTER_RUNNER: true` и запустить `docker compose up runner`
   * После регистрации, остановить контейнер нажатием `ctrl c`
   * Убедиться, что в docker-compose.yaml `IS_REGISTER_RUNNER: false` и запустить в фоне `docker compose up -d runner`
   * Проверить что runner появился в списке http://192.168.99.100:80/admin/runners

3) Написать `.gitlab-ci.yml` для своего приложения со следующими этапами:
   * Этап сборки приложения
   * Этап тестирования с подэтапами (например модульное тестирование и статический анализ кода), можно сделать просто заглушками
   * Этап упаковки приложения в образ и загрузки образа в registry

4) Запустить pipeline в Gitlab, проверить что все этапы завершились без ошибок и образ появился в registry.

## Ошибки

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

## При показе выполненного задания
   * Продемонстрировать успешное развертывание **Gitlab** + **runner**
   * Составить **.gitlab-ci.yml** манифест. Собрать приложение несколько раз с разными тегами (нужно внести какие-то изменения в ваше приложение), запустить пайплайн и дождаться окончания сборки
   * Запустить собранные образы на master-0 и продемонстрировать отличия в версиях образов (например отличается лог при запуске/работе сервиса)
