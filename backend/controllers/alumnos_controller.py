from flask import Blueprint, request
from flask_jwt_extended import jwt_required
from models.alumnos_model import alta_alumno, baja_alumno, cambio_alumno, find_all_alumnos, find_alumno_by_id

alumnos_bp = Blueprint('alumnos_bp', __name__)

@alumnos_bp.route('/api/alumnos', methods=['POST'])
@jwt_required()
def alta():
    """
    Alta de alumno
    ---
    tags:
      - Alumnos
    security:
      - Bearer: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - matricula
              - nombres
              - apellido_paterno
              - id_grupo
            properties:
              matricula:
                type: string
              nombres:
                type: string
              apellido_paterno:
                type: string
              apellido_materno:
                type: string
              fecha_nacimiento:
                type: string
                format: date
              id_grupo:
                type: integer
    responses:
      201:
        description: Alumno creado exitosamente
    """
    return alta_alumno(request.json)

@alumnos_bp.route('/api/alumnos/<int:id>', methods=['DELETE'])
@jwt_required()
def baja(id):
    """
    Eliminar alumno por ID
    ---
    tags:
      - Alumnos
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
        description: Alumno eliminado
    """
    return baja_alumno(id)

@alumnos_bp.route('/api/alumnos/<int:id>', methods=['PUT'])
@jwt_required()
def cambio(id):
    """
    Actualizar alumno
    ---
    tags:
      - Alumnos
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
              fecha_nacimiento:
                type: string
                format: date
              id_grupo:
                type: integer
    responses:
      200:
        description: Alumno actualizado
    """
    return cambio_alumno(id, request.json)

@alumnos_bp.route('/api/alumnos', methods=['GET'])
@jwt_required()
def listar_todos():
    """
    Listar todos los alumnos
    ---
    tags:
      - Alumnos
    security:
      - Bearer: []
    responses:
      200:
        description: Lista de alumnos
    """
    return find_all_alumnos()

@alumnos_bp.route('/api/alumnos/<int:id>', methods=['GET'])
@jwt_required()
def obtener_por_id(id):
    """
    Obtener alumno por ID
    ---
    tags:
      - Alumnos
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
        description: Alumno encontrado
      404:
        description: Alumno no encontrado
    """
    return find_alumno_by_id(id)
