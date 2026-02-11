# ЛАБОРАТОРНАЯ №3. Continuous Integration. Gitlab

Требования:

1) Развернуть CI систему

   Подключиться по ssh к ВМ master-0.
   Перед началом задания добавить файл `daemon.json` в `/etc/docker/` и перезапустить докер.
   Добавить запись `192.168.100.2 gitlab` в конец файла /etc/hosts.
   Перейти в директорию с заданием, создать файл .env с переменной содержащей пароль и развернуть Gitlab.
   Инициализация займет некоторое время, все последующие запуски будут быстрее.
```
$ su -
# cp /home/$(id -un 1000)/work/devops_course/LAB_3/gitlab/daemon.json /etc/docker/daemon.json
# systemctl restart docker.service
# echo "192.168.100.2 gitlab" >> /etc/hosts
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

   https://docs.gitlab.com/tutorials/automate_runner_creation

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

## При показе выполненного задания
   * Продемонстрировать успешное развертывание Gitlab + runner, свой .gitlab-ci манифест
   * Выполнить загрузку полученных образов на одну из worker- ВМ (предварительно установив docker)
   * Запустить образы на worker- и продемонстрировать что log отличается
