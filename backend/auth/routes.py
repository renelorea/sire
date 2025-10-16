from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from flask_bcrypt import generate_password_hash
from auth.utils import verificar_contraseña
from database.connection import mysql
from MySQLdb.cursors import DictCursor

auth_bp = Blueprint('auth_bp', __name__)

@auth_bp.route('/api/login', methods=['POST'])
def login():
    correo = request.json.get('correo')
    contraseña = request.json.get('contraseña')

    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM usuarios WHERE email = %s", (correo,))
    usuario = cursor.fetchone()
    cursor.close()

    if usuario and verificar_contraseña(contraseña, usuario['contrasena']):
        token = create_access_token(identity=str(usuario['id_usuario']), additional_claims={"rol": usuario['rol']})
        return jsonify(access_token=token, usuario={"id": usuario['id_usuario'], "nombre": usuario['nombres'], "rol": usuario['rol']})
    return jsonify({"msg": "Credenciales inválidas"}), 401



