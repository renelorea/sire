from flask import Blueprint, request
from flask_jwt_extended import jwt_required
from models.reportes_model import (
    alta_reporte,
    baja_reporte,
    cambio_reporte,
    find_all_reportes,
    find_reporte_by_id
)

reportes_bp = Blueprint('reportes_bp', __name__)

@reportes_bp.route('/api/reportes', methods=['POST'])
@jwt_required()
def alta():
    """
    Alta de reporte de incidencia
    ---
    tags:
      - Reportes
    security:
      - Bearer: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - folio
              - id_alumno
              - id_usuario_que_reporta
              - id_tipo_reporte
              - descripcion_hechos
              - fecha_incidencia
            properties:
              folio:
                type: string
              id_alumno:
                type: integer
              id_usuario_que_reporta:
                type: integer
              id_tipo_reporte:
                type: integer
              descripcion_hechos:
                type: string
              acciones_tomadas:
                type: string
              fecha_incidencia:
                type: string
                format: date-time
              estatus:
                type: string
                enum: [Abierto, En Seguimiento, Cerrado]
    responses:
      201:
        description: Reporte creado exitosamente
    """
    return alta_reporte(request.json)

@reportes_bp.route('/api/reportes/<int:id>', methods=['DELETE'])
@jwt_required()
def baja(id):
    """
    Eliminar reporte por ID
    ---
    tags:
      - Reportes
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
        description: Reporte eliminado
    """
    return baja_reporte(id)

@reportes_bp.route('/api/reportes/<int:id>', methods=['PUT'])
@jwt_required()
def cambio(id):
    """
    Actualizar reporte de incidencia
    ---
    tags:
      - Reportes
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
              descripcion_hechos:
                type: string
              acciones_tomadas:
                type: string
              estatus:
                type: string
                enum: [Abierto, En Seguimiento, Cerrado]
    responses:
      200:
        description: Reporte actualizado
    """
    return cambio_reporte(id, request.json)

@reportes_bp.route('/api/reportes', methods=['GET'])
@jwt_required()
def listar_todos():
    """
    Listar todos los reportes de incidencia
    ---
    tags:
      - Reportes
    security:
      - Bearer: []
    responses:
      200:
        description: Lista de reportes
    """
    return find_all_reportes()

@reportes_bp.route('/api/reportes/<int:id>', methods=['GET'])
@jwt_required()
def obtener_por_id(id):
    """
    Obtener reporte por ID
    ---
    tags:
      - Reportes
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
        description: Reporte encontrado
      404:
        description: Reporte no encontrado
    """
    return find_reporte_by_id(id)
