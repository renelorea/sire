from flask import Flask
from flask_jwt_extended import JWTManager
from flasgger import Swagger
from flask_cors import CORS
from config import Config
from database.connection import mysql
from controllers.usuarios_controller import usuarios_bp
from controllers.alumnos_controller import alumnos_bp
from controllers.grupos_controller import grupos_bp
from controllers.tipos_reporte_controller import tipos_bp
from controllers.reportes_controller import reportes_bp
from auth.routes import auth_bp
import logging

# Configuración básica
logging.basicConfig(
    level=logging.INFO,  # Puedes usar DEBUG para más detalle
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='app.log',  # Guarda en archivo
    filemode='a'         # 'a' para agregar, 'w' para sobrescribir
)

app = Flask(__name__)
app.config.from_object(Config)

CORS(app)
JWTManager(app)
mysql.init_app(app)

app.config['SWAGGER'] = {
    'title': 'API Incidencias Escolares',
    'uiversion': 3,
    'securityDefinitions': {
        'Bearer': {
            'type': 'apiKey',
            'name': 'Authorization',
            'in': 'header',
            'description': 'Agrega el token JWT como: Bearer <token>'
        }
    }
}

swagger = Swagger(app)

# Registrar blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(usuarios_bp)
app.register_blueprint(alumnos_bp)
app.register_blueprint(grupos_bp)
app.register_blueprint(tipos_bp)
app.register_blueprint(reportes_bp)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
