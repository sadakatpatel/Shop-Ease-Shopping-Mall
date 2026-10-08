import os
import mysql.connector
from mysql.connector import Error
from werkzeug.security import generate_password_hash

DB_CONFIG = {
    'host': os.getenv('DB_HOST','127.0.0.1'),
    'port': int(os.getenv('DB_PORT','3306')),
    'user': os.getenv('DB_USER','root'),
    'password': os.getenv('DB_PASSWORD',''),
    'database': os.getenv('DB_NAME','shopease_db')
}

def get_db():
    return mysql.connector.connect(**DB_CONFIG, use_pure=True)

def init_db():
    # Run schema.sql once from MySQL Workbench before starting Flask.
    try:
        db=get_db(); cur=db.cursor()
        cur.execute("SELECT 1")
        cur.close(); db.close()
    except Error as e:
        print('Database connection error:', e)
