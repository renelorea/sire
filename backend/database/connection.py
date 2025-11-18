from flask_mysqldb import MySQL

mysql = MySQL()

def init_app(app):
    # Usa host/port (TCP) en vez de unix socket
    app.config['MYSQL_HOST'] = app.config.get('MYSQL_HOST', 'srv734.hstgr.io')
    app.config['MYSQL_PORT'] = int(app.config.get('MYSQL_PORT', 3306))
    app.config['MYSQL_USER'] = app.config.get('MYSQL_USER')
    app.config['MYSQL_PASSWORD'] = app.config.get('MYSQL_PASSWORD')
    app.config['MYSQL_DB'] = app.config.get('MYSQL_DB')
    app.config['MYSQL_CHARSET'] = app.config.get('MYSQL_CHARSET', 'utf8mb4')
    mysql.init_app(app)
    return mysql
