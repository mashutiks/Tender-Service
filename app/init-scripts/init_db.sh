#!/bin/bash
set -e

# Преобразуем дамп из UTF-16 в UTF-8, если это необходимо
iconv -f UTF-16 -t UTF-8 /docker-entrypoint-initdb.d/dump.sql > /docker-entrypoint-initdb.d/dump_utf8.sql

# Выполняем преобразованный дамп в базе данных
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/dump_utf8.sql
