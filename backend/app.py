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
    import os
    import smtplib
    from email.message import EmailMessage
    from flask import jsonify, request
    
    try:
        # Leer configuración SMTP
        smtp_host = os.getenv('SMTP_HOST')
        smtp_port = int(os.getenv('SMTP_PORT', '587'))
        smtp_user = os.getenv('SMTP_USER')
        smtp_pass = os.getenv('SMTP_PASS')
        email_from = os.getenv('EMAIL_FROM', smtp_user)
        
        # Verificar configuración
        config_info = {
            "smtp_host": smtp_host,
            "smtp_port": smtp_port,
            "smtp_user": smtp_user,
            "email_from": email_from,
            "smtp_pass_configured": bool(smtp_pass)
        }
        
        if not smtp_host or not smtp_user or not smtp_pass:
            return jsonify({
                "success": False,
                "message": "Configuración SMTP incompleta",
                "config": config_info
            }), 400
        
        # Correo de destino (parámetro o el mismo usuario)
        email_to = request.args.get('email', smtp_user)
        
        # Crear mensaje de prueba
        msg = EmailMessage()
        msg['Subject'] = 'Prueba de correo desde Railway'
        msg['From'] = email_from
        msg['To'] = email_to
        msg.set_content('Este es un correo de prueba para verificar la configuración SMTP en Railway.')
        
        # Enviar correo
        if smtp_port == 465:
            smtp = smtplib.SMTP_SSL(smtp_host, smtp_port, timeout=30)
            smtp.login(smtp_user, smtp_pass)
            smtp.send_message(msg)
            smtp.quit()
        else:
            smtp = smtplib.SMTP(smtp_host, smtp_port, timeout=30)
            smtp.starttls()
            smtp.login(smtp_user, smtp_pass)
            smtp.send_message(msg)
            smtp.quit()
        
        return jsonify({
            "success": True,
            "message": f"Correo de prueba enviado exitosamente a {email_to}",
            "config": config_info
        }), 200
        
    except Exception as e:
        return jsonify({
            "success": False,
            "message": f"Error enviando correo: {str(e)}",
            "config": config_info if 'config_info' in locals() else {}
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
