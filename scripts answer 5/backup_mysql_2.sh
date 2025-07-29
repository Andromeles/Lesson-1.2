#!/bin/bash

# Настройка параметров резервного копирования
BACKUP_DIR="/opt/backup"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql.gz"

# Загрузка параметров подключения из файла
source /opt/mysql_backup.conf

# Проверка существования директории резервного копирования
if [ ! -d "$BACKUP_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "Ошибка: Не удалось создать директорию $BACKUP_DIR"
    exit 1
  fi
fi

# Запуск Docker контейнера для резервного копирования
docker run --rm -d --name sms\
  --network="lesson1_2_backend" \
  -e MYSQL_HOST="$MYSQL_HOST" \
  -e MYSQL_PORT="$MYSQL_PORT" \
  -e MYSQL_USER="$MYSQL_USER" \
  -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
  -e MYSQL_DATABASE="$MYSQL_DATABASE" \
  schnitzler/mysqldump | gzip > "$BACKUP_FILE"

# Проверка успешности резервного копирования
if [ $? -eq 0 ]; then
  echo "Резервная копия успешно создана: $BACKUP_FILE"
else
  echo "Ошибка: Не удалось создать резервную копию."
  exit 1
fi

echo "Резервное копирование завершено."

sleep 1m

docker stop sms