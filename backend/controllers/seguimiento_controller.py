# controllers/seguimiento_controller.py
from flask import Blueprint, request, jsonify, make_response, send_file, Response
from flask_jwt_extended import jwt_required
from models import seguimiento_model
import logging
import io

seguimiento_bp = Blueprint('seguimiento_bp', __name__)

@seguimiento_bp.route('/api/seguimientos', methods=['POST'])
@jwt_required()
def crear():
    data = request.get_json()
    logging.info(f'[seguimiento.create] payload: {data}')
    if not data:
        logging.warning('[seguimiento.create] payload vacío')
        return make_response(jsonify({'error': 'Payload vacío'}), 400)

    # crear seguimiento
    creado = seguimiento_model.crear_seguimiento(data)
    if not creado:
        logging.error(f'[seguimiento.create] fallo al crear seguimiento, payload={data}')
        return make_response(jsonify({'error': 'No se pudo crear el seguimiento'}), 500)

    logging.info(f'[seguimiento.create] seguimiento creado: {creado}')

    # si el cliente envía nuevo_estatus_reporte, intentar actualizar estatus del reporte
    nuevo_estatus = data.get('nuevo_estatus_reporte')
    if nuevo_estatus:
        id_reporte = data.get('id_reporte') or data.get('idReporte')
        if id_reporte:
            logging.info(f'[seguimiento.create] intentará actualizar estatus del reporte {id_reporte} -> {nuevo_estatus}')
            actualizado = seguimiento_model.actualizar_estatus_reporte(id_reporte, nuevo_estatus)
            if not actualizado:
                logging.warning(f'[seguimiento.create] seguimiento creado pero no se pudo actualizar estatus del reporte id_reporte={id_reporte}')
                # Loguear/retornar advertencia, pero seguimiento ya fue creado
                return make_response(jsonify({
                    'warning': 'Seguimiento creado, pero no se pudo actualizar estatus del reporte',
                    'seguimiento': creado
                }), 201)
            logging.info(f'[seguimiento.create] estatus del reporte {id_reporte} actualizado a "{nuevo_estatus}"')

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

@seguimiento_bp.route('/api/reportes/<int:id_reporte>/estatus', methods=['PUT'])
@jwt_required()
def actualizar_estatus(id_reporte):
    data = request.get_json() or {}
    logging.info(f'[reportes.actualizar_estatus] id={id_reporte} payload={data}')
    nuevo = data.get('estatus')
    if not nuevo:
        logging.warning('[reportes.actualizar_estatus] falta campo "estatus"')
        return make_response(jsonify({'error': 'Campo "estatus" requerido'}), 400)

    ok = seguimiento_model.actualizar_estatus(id_reporte, nuevo)
    if not ok:
        logging.error(f'[reportes.actualizar_estatus] no se pudo actualizar estatus id={id_reporte}')
        return make_response(jsonify({'error': 'No se pudo actualizar estatus'}), 500)

    logging.info(f'[reportes.actualizar_estatus] estatus actualizado id={id_reporte} -> {nuevo}')
    return make_response(jsonify({'message': 'Estatus actualizado', 'id_reporte': id_reporte, 'estatus': nuevo}), 200)

@seguimiento_bp.route('/api/reportes/<int:id_reporte>/seguimientos', methods=['GET'])
@jwt_required()
def obtener_seguimientos_por_reporte(id_reporte):
    """
    Obtener seguimientos de un reporte específico
    """
    try:
        logging.info(f'[seguimiento.por_reporte] Obteniendo seguimientos para reporte ID: {id_reporte}')
        
        # Llamar al modelo para obtener seguimientos
        seguimientos = seguimiento_model.obtener_seguimientos_reporte(id_reporte)
        
        logging.info(f'[seguimiento.por_reporte] Encontrados {len(seguimientos)} seguimientos')
        
        return make_response(jsonify(seguimientos), 200)
        
    except Exception as e:
        logging.exception(f'[seguimiento.por_reporte] Error: {e}')
        return make_response(jsonify({'error': 'Error interno del servidor'}), 500)

@seguimiento_bp.route('/api/seguimientos/<int:id>/evidencia', methods=['GET'])
@jwt_required()
def descargar_evidencia(id):
    """
    Descarga el archivo de evidencia
    """
    try:
        archivo_data = obtener_archivo_evidencia(id)
        
        if not archivo_data or not archivo_data['evidencia_archivo']:
            return {"msg": "Archivo no encontrado"}, 404
        
        # Crear un objeto de archivo en memoria
        archivo_io = io.BytesIO(archivo_data['evidencia_archivo'])
        
        return send_file(
            archivo_io,
            download_name=archivo_data['evidencia_nombre'],
            mimetype=archivo_data['evidencia_tipo'],
            as_attachment=True
        )
    except Exception as e:
        return {"msg": f"Error al descargar archivo: {str(e)}"}, 500