import psycopg2
from dotenv import load_dotenv
import os

# Загрузка переменных из .env файла
load_dotenv()

POSTGRES_CONN = os.getenv("POSTGRES_CONN")

def get_db_connection():
    if not POSTGRES_CONN:
        raise ValueError("POSTGRES_CONN environment variable is not set")
    return psycopg2.connect(POSTGRES_CONN)
