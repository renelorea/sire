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
from controllers.seguimiento_controller import seguimiento_bp
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

# Desarrollo: permitir todas las origins para /api/* (cambiar a dominios específicos en prod)
CORS(app, resources={r"/api/*": {"origins": "*"}},
     supports_credentials=True,
     allow_headers=["Content-Type", "Authorization", "Access-Control-Allow-Origin"])

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
app.register_blueprint(seguimiento_bp)

# Endpoint de prueba para correo
@app.route('/api/test-email', methods=['GET'])
def test_email_endpoint():
    """Endpoint para probar la configuración de correo"""
    from flask import jsonify, request
    from services.email_service import email_service
    
    try:
        # Correo de destino (parámetro o el mismo usuario)
        email_to = request.args.get('email', os.getenv('SMTP_USER', 'perrillo1981@gmail.com'))
        
        # Probar conectividad primero
        connection_results = email_service.test_connection()
        
        # Enviar correo de prueba
        success, provider_used, error_msg = email_service.send_email(
            to_email=email_to,
            subject='Prueba de correo desde Railway',
            content='Este es un correo de prueba para verificar la configuración SMTP en Railway.'
        )
        
        return jsonify({
            "success": success,
            "message": f"Correo enviado a {email_to} usando {provider_used}" if success else f"Error: {error_msg}",
            "provider_used": provider_used,
            "connection_test": connection_results
        }), 200 if success else 500
        
    except Exception as e:
        return jsonify({
            "success": False,
            "message": f"Error inesperado: {str(e)}",
            "connection_test": {}
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
