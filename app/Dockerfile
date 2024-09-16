# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Установка зависимостей системы, необходимых для psycopg2
RUN apt-get update && apt-get install -y build-essential libpq-dev && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

COPY requirements.txt .
RUN pip install -r requirements.txt

# Копируем исходный код приложения
COPY ./backend /app

EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

