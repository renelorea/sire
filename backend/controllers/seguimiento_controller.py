# controllers/seguimiento_controller.py
from flask import Blueprint, request, jsonify, make_response
from flask_jwt_extended import jwt_required
from models import seguimiento_model

seguimiento_bp = Blueprint('seguimiento_bp', __name__)

@seguimiento_bp.route('/api/seguimientos', methods=['POST'])
@jwt_required()
def crear():
    data = request.get_json()
    if not data:
        return make_response(jsonify({'error': 'Payload vacío'}), 400)

    # crear seguimiento
    creado = seguimiento_model.crear_seguimiento(data)
    if not creado:
        return make_response(jsonify({'error': 'No se pudo crear el seguimiento'}), 500)

    # si el cliente envía nuevo_estatus_reporte, intentar actualizar estatus del reporte
    nuevo_estatus = data.get('nuevo_estatus_reporte')
    if nuevo_estatus:
        id_reporte = data.get('id_reporte') or data.get('idReporte')
        if id_reporte:
            actualizado = seguimiento_model.actualizar_estatus_reporte(id_reporte, nuevo_estatus)
            if not actualizado:
                # Loguear/retornar advertencia, pero seguimiento ya fue creado
                return make_response(jsonify({
                    'warning': 'Seguimiento creado, pero no se pudo actualizar estatus del reporte',
                    'seguimiento': creado
                }), 201)

    return make_response(jsonify(creado), 201)

@seguimiento_bp.route('/api/seguimientos', methods=['GET'])
@jwt_required()
def listar():
    lista = seguimiento_model.listar_seguimientos()
    return make_response(jsonify(lista), 200)

@seguimiento_bp.route('/api/seguimientos/<int:id>', methods=['GET'])
@jwt_required()
def obtener(id):
    seg = seguimiento_model.obtener_seguimiento(id)
    if not seg:
        return make_response(jsonify({'error': 'No encontrado'}), 404)
    return make_response(jsonify(seg), 200)

@seguimiento_bp.route('/api/seguimientos/<int:id>', methods=['PUT'])
@jwt_required()
def actualizar(id):
    data = request.get_json()
    if not data:
        return make_response(jsonify({'error': 'Payload vacío'}), 400)
    actualizado = seguimiento_model.actualizar_seguimiento(id, data)
    if not actualizado:
        return make_response(jsonify({'error': 'No se pudo actualizar'}), 500)
    return make_response(jsonify(actualizado), 200)

@seguimiento_bp.route('/api/seguimientos/<int:id>', methods=['DELETE'])
@jwt_required()
def eliminar(id):
    eliminado = seguimiento_model.eliminar_seguimiento(id)
    if not eliminado:
        return make_response(jsonify({'error': 'No se pudo eliminar'}), 500)
    return make_response(jsonify({'message': 'Eliminado'}), 200)
