import os

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "P3rr1ll01981")
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "R3n31981")
    MYSQL_HOST = 'localhost'
    MYSQL_USER = 'usercon'
    MYSQL_PASSWORD = 'Admin2025'
    MYSQL_DB = 'incidencias'
    unix_socket="/Applications/XAMPP/xamppfiles/var/mysql/mysql.sock"
