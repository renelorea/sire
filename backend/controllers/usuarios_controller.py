from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.usuarios_model import alta_usuario, baja_usuario, cambio_usuario, find_all_usuarios, find_usuario_by_id
import logging

usuarios_bp = Blueprint('usuarios_bp', __name__)

@usuarios_bp.route('/api/usuarios', methods=['POST'])
@jwt_required()
def alta():
    """
    Alta de usuario
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - nombres
              - apellido_paterno
              - email
              - rol
              - contrasena
            properties:
              nombres:
                type: string
              apellido_paterno:
                type: string
              apellido_materno:
                type: string
              email:
                type: string
              rol:
                type: string
                enum:
                  - Profesor
                  - Administrativo
                  - Director
                  - Psicologia
              contrasena:
                type: string
    responses:
      201:
        description: Usuario creado exitosamente
      409:
        description: El correo ya está registrado
    """
    datos = request.json
    logging.info(f'Datos recibidos en POST /usuarios: {datos}')
    return alta_usuario(datos)

@usuarios_bp.route('/api/usuarios/<int:id>', methods=['DELETE'])
@jwt_required()
def baja(id):
    """
    Eliminar usuario por ID
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
    responses:
      200:
        description: Usuario desactivado
    """
    return baja_usuario(id)

@usuarios_bp.route('/api/usuarios/<int:id>', methods=['PUT'])
@jwt_required()
def cambio(id):
    """
    Actualizar usuario por ID
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              nombres:
                type: string
              apellido_paterno:
                type: string
              apellido_materno:
                type: string
              rol:
                type: string
    responses:
      200:
        description: Usuario actualizado
    """
    datos = request.json
    return cambio_usuario(id, datos)

@usuarios_bp.route('/api/usuarios', methods=['GET'])
@jwt_required()
def listar_todos():
    """
    Listar todos los usuarios activos
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    responses:
      200:
        description: Lista de usuarios
    """
    return find_all_usuarios()

@usuarios_bp.route('/api/usuarios/<int:id>', methods=['GET'])
@jwt_required()
def obtener_por_id(id):
    """
    Obtener usuario por ID
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
    responses:
      200:
        description: Usuario encontrado
      404:
        description: Usuario no encontrado
    """
    return find_usuario_by_id(id)
