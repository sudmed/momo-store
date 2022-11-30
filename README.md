# Momo Store aka Пельменная №2

<img width="900" alt="image" src="https://user-images.githubusercontent.com/9394918/167876466-2c530828-d658-4efe-9064-825626cc6db5.png">

## Frontend локальная сборка

```bash
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve
```

## Backend локальная сборка

```bash
go run ./cmd/api
go test -v ./... 
```

---


Ссылка на развернутое приложение: [momo-store.hopto.org](http://momo-store.hopto.org).  
IP: 84.201.129.209  


## Реализован полный цикл сборки-поставки приложения, используя практики CI/CD
1. Код хранится в [GitLab](https://gitlab.praktikum-services.ru/d.pashkov/momo-store) с использованием модели ветвления github flow.
2. В проекте присутствует модульный [.gitlab-ci.yml](https://gitlab.praktikum-services.ru/d.pashkov/momo-store/-/blob/master/.gitlab-ci.yml), в котором описаны шаги сборки. Изменения в папках frontend и backend запускаются дочерние пайплайны, который лежат в соответствующих папках.
3. Артефакты сборки публикуются в систему хранения Nexus ([архивы фронтенда](https://nexus.praktikum-services.ru/service/rest/repository/browse/06-momostore-pashkov-frontend/), [бинарные файлы бэкенда](https://nexus.praktikum-services.ru/service/rest/repository/browse/06-momostore-pashkov-backend/), docker-образы хранятся в [Gitlab Container Registry](https://gitlab.praktikum-services.ru/d.pashkov/momo-store/container_registry).
4. Артефакты сборки версионируются по правилам SemVer2.
5. Написаны Dockerfile'ы для сборки Docker-образов [бэкенда](https://gitlab.praktikum-services.ru/d.pashkov/momo-store/-/blob/master/backend/Dockerfile) и [фронтенда](https://gitlab.praktikum-services.ru/d.pashkov/momo-store/-/blob/master/frontend/Dockerfile).
    - Бэкенд: бинарный файл Go в Docker-образе.
    - Фронтенд: HTML-страница раздаётся с Nginx.
6. В GitLab CI описаны шаги сборки и публикации артефактов.
7. В GitLab CI описаны шаги тестирования (тесты [Sonarqube для фронтенда](https://sonarqube.praktikum-services.ru/dashboard?id=06_DMITRIYPASHKOV_MOMO_FRONTEND): eslint-sast, gosec-sast, nodejs-scan-sast, semgrep-sast, sonarqube-frontend; 
тесты unit и [Sonarqube для бэкенда](https://sonarqube.praktikum-services.ru/dashboard?id=06_DMITRIYPASHKOV_MOMO_BACKEND): semgrep-sast, sonarqube-backend).
8. В GitLab CI описан шаг деплоя в кластер Docker Swarm из трех нод (manager и 2 worker).
9. Кластер Docker Swarm развернут в облаке Yandex.Cloud.
10. Кластер Docker Swarm описан в виде кода Terraform, код хранится в [GitLab](https://gitlab.praktikum-services.ru/d.pashkov/momo-store/-/blob/master/infrastructure).
11. Конфигурация всех необходимых ресурсов описана согласно IaC.
12. Состояние Terraform'а хранится в [S3](https://storage.yandexcloud.net/momo-store-terraform-state/dev/terraform.tfstate).
13. Картинки, которые использует сайт, хранятся в [S3](https://storage.yandexcloud.net/momo-pics/).
14. Секреты не хранятся в открытом виде.
15. Для удобства визуального контроля за кластером установлен Portainer (http://84.201.129.209:9000/, гостевые парамерты входа: guest:DF2cUq5pxphgEBude68w).
16. Дашборд мониторинга Grafana (http://84.201.129.209:3000, гостевые парамерты входа: guest:DF2cUq5pxphgEBude68w).


---


## Развертываение инфраструктуры
Развертываение инфраструктуры проводить Terraform'ом с установленным провайдером Yandex.Cloud, ключи запуска:  
```bash
terraform init -backend-config "access_key=$YC_STORAGE_ACCESS_KEY" -backend-config "secret_key=$YC_STORAGE_SECRET_KEY" -reconfigure
terraform apply --auto-approve -var=s3_access_key=$YC_STORAGE_ACCESS_KEY -var=s3_secret_key=$YC_STORAGE_SECRET_KEY -var=IAM_token=$IAM_token
terraform destroy --auto-approve -var=s3_access_key=$YC_STORAGE_ACCESS_KEY -var=s3_secret_key=$YC_STORAGE_SECRET_KEY -var=IAM_token=$IAM_token
```

Terraform поднимает в облаке указанное в переменных `variables.tf` количество виртуальных машин для управляющих и рабочих нод кластера (по-умолчанию 1 и 2 соответственно), параметры RAM, CPU, disk и т.д. задаются в том же файле.  
Также Terraform:  
- устанавливает на все виртуальные машины пакеты, необходимые для работы docker, 
- на мастер-ноде запускает команду инициализации кластера на дефолтном сетевом интерфейсе `docker swarm init --advertise-addr eth0` и устанавливает Portainer,
- рабочие ноды добавляются в кластер с полученным на предыдущем шаге токеном командой `docker swarm join {ip_master_node}:2377 --token $TOKEN`

После завершения работы Terraform получаем полностью работоспособный и готовый к работе кластер из 3 нод. Внешний IP-адрес управляющей ноды следует через веб-интерфейс [console.cloud.yandex.ru](https://console.cloud.yandex.ru) назначить статическим и добавить в переменную Gitlab как `SWARM_HOST`. Последний шаг - скопировать картинки сайта в s3 бакет и облачная инфраструктура готова к деплою приложения.  


---


## Развертываение приложения
В переменные Gitlab `SSH_PRIVATE_KEY_SWARM` и `SSH_PUBLIC_KEY_SWARM` положить предварительно сгенерированные SSH ключи для авторизации раннеров на нодах кластера.  
При запуске `Run pipeline` или изменении файлов проекта в директориях frontend или backend, после выполнения всех этапов и шагов, произойдет автоматический деплой в подготовленную облачную инфраструктуру.  
