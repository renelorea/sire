from flask import Blueprint, request
from flask_jwt_extended import jwt_required
from models.grupos_model import alta_grupo, baja_grupo, cambio_grupo, find_all_grupos, find_grupo_by_id

grupos_bp = Blueprint('grupos_bp', __name__)

@grupos_bp.route('/api/grupos', methods=['POST'])
@jwt_required()
def alta():
    """
    Alta de grupo
    ---
    tags:
      - Grupos
    security:
      - Bearer: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - grado
              - ciclo_escolar
            properties:
              grado:
                type: integer
              ciclo_escolar:
                type: string
              id_tutor:
                type: integer
              Descripcion:
                type: string
    responses:
      201:
        description: Grupo creado exitosamente
    """
    return alta_grupo(request.json)

@grupos_bp.route('/api/grupos/<int:id>', methods=['DELETE'])
@jwt_required()
def baja(id):
    """
    Eliminar grupo por ID
    ---
    tags:
      - Grupos
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
        description: Grupo eliminado
    """
    return baja_grupo(id)

@grupos_bp.route('/api/grupos/<int:id>', methods=['PUT'])
@jwt_required()
def cambio(id):
    """
    Actualizar grupo
    ---
    tags:
      - Grupos
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
              grado:
                type: integer
              ciclo_escolar:
                type: string
              id_tutor:
                type: integer
              Descripcion:
                type: string
    responses:
      200:
        description: Grupo actualizado
    """
    return cambio_grupo(id, request.json)

@grupos_bp.route('/api/grupos', methods=['GET'])
@jwt_required()
def listar_todos():
    """
    Listar todos los grupos
    ---
    tags:
      - Grupos
    security:
      - Bearer: []
    responses:
      200:
        description: Lista de grupos
    """
    return find_all_grupos()

@grupos_bp.route('/api/grupos/<int:id>', methods=['GET'])
@jwt_required()
def obtener_por_id(id):
    """
    Obtener grupo por ID
    ---
    tags:
      - Grupos
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
        description: Grupo encontrado
      404:
        description: Grupo no encontrado
    """
    return find_grupo_by_id(id)
