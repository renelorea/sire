from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from models.reportes_model import (
    alta_reporte,
    baja_reporte,
    cambio_reporte,
    find_all_reportes,
    find_reporte_by_id,
    find_reportes_filtered
)
import io
import os
import smtplib
from email.message import EmailMessage
import pandas as pd
from dotenv import load_dotenv
import logging

load_dotenv()
logger = logging.getLogger(__name__)

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

@reportes_bp.route('/api/reportes/reporte', methods=['GET'])
@jwt_required()
def reporte_buscar():
    """
    Buscar reportes filtrando por grupo o por nombre/apellido del alumno.
    Query params (opcionales): grupo, nombre, apellido_paterno, apellido_materno
    """
    try:
        # Log inicial de la petición (incluye query params y posible header con error cliente)
        client_error = request.headers.get('X-Client-Error')
        logger.info("GET /api/reportes/reporte params=%s, X-Client-Error=%s", request.args.to_dict(), client_error)

        grupo = request.args.get('grupo')
        nombre = request.args.get('alumno_nombre')
        apellido_paterno = request.args.get('alumno_apellido_paterno')
        apellido_materno = request.args.get('alumno_apellido_materno')
        email_to = request.args.get('email')  # si se proporciona, se enviará el Excel por correo

        # Obtener datos desde el modelo
        resp = find_reportes_filtered(
            grupo=grupo,
            nombre=nombre,
            apellido_paterno=apellido_paterno,
            apellido_materno=apellido_materno
        )

        # Normalizar respuesta del modelo a lista de dicts
        if isinstance(resp, tuple):
            data_list = resp[0].get_json()
        else:
            try:
                data_list = resp.get_json()
            except Exception:
                data_list = resp

        logger.debug("reportes encontrados: %s", getattr(data_list, '__len__', lambda: '?')())

        # Si se pidió envío por correo, generar Excel y enviar
        if email_to:
            rows = []
            try:
                for r in data_list:
                    alumno = r.get('alumno', {}) or {}
                    grupo_obj = alumno.get('grupo', {}) or {}
                    usuario = r.get('usuario', {}) or {}
                    tipo = r.get('tipo_reporte', {}) or {}
                    rows.append({
                        "id_reporte": r.get("id_reporte"),
                        "folio": r.get("folio"),
                        "fecha_incidencia": r.get("fecha_incidencia"),
                        "estatus": r.get("estatus"),
                        "descripcion_hechos": r.get("descripcion_hechos"),
                        "acciones_tomadas": r.get("acciones_tomadas"),
                        "alumno_id": alumno.get("id_alumno"),
                        "alumno_matricula": alumno.get("matricula"),
                        "alumno_nombre": alumno.get("nombre"),
                        "alumno_apellido_paterno": alumno.get("apellido_paterno"),
                        "alumno_apellido_materno": alumno.get("apellido_materno"),
                        "grupo_id": grupo_obj.get("id_grupo"),
                        "grupo_grado": grupo_obj.get("grado"),
                        "grupo_nombre": grupo_obj.get("grupo"),
                        "grupo_ciclo": grupo_obj.get("ciclo_escolar"),
                        "usuario_id": usuario.get("id_usuario"),
                        "usuario_nombre": usuario.get("nombre"),
                        "tipo_reporte": tipo.get("nombre")
                    })
            except Exception as e:
                # Log detallado si ocurre error al iterar/parsear los reportes
                logger.exception("Error al preparar filas para Excel: %s -- params=%s -- X-Client-Error=%s", e, request.args.to_dict(), client_error)
                return jsonify({"msg": f"Error generando datos para Excel: {e}"}), 500

            try:
                df = pd.DataFrame(rows)
                output = io.BytesIO()
                df.to_excel(output, index=False, sheet_name='Reportes')
                output.seek(0)
                excel_bytes = output.read()
            except Exception as e:
                logger.exception("Error generando Excel: %s -- params=%s -- X-Client-Error=%s", e, request.args.to_dict(), client_error)
                return jsonify({"msg": f"Error generando Excel: {e}"}), 500

            # Leer configuración SMTP desde variables de entorno
            smtp_host = os.getenv('SMTP_HOST')
            smtp_port = int(os.getenv('SMTP_PORT', '587'))
            smtp_user = os.getenv('SMTP_USER')
            smtp_pass = os.getenv('SMTP_PASS')
            email_from = os.getenv('EMAIL_FROM', smtp_user)
            if not smtp_host or not smtp_user or not smtp_pass:
                logger.error("Configuración SMTP incompleta -- SMTP_HOST/SMTP_USER/SMTP_PASS faltantes")
                return jsonify({"msg": "Configuración SMTP incompleta"}), 500

            try:
                msg = EmailMessage()
                msg['Subject'] = 'Reporte de incidencias (Excel)'
                msg['From'] = email_from
                msg['To'] = email_to
                msg.set_content('Adjunto se envía el reporte de incidencias en formato Excel.')
                msg.add_attachment(excel_bytes,
                                   maintype='application',
                                   subtype='vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                   filename='reportes_incidencias.xlsx')

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
            except Exception as e:
                logger.exception("Error enviando correo: %s -- params=%s -- X-Client-Error=%s", e, request.args.to_dict(), client_error)
                return jsonify({"msg": f"Error enviando correo: {e}"}), 500

            logger.info("Correo enviado a %s (count=%d)", email_to, len(rows))
            return jsonify({"msg": f"Correo enviado a {email_to}", "count": len(rows)}), 200

        # Si no se solicitó email, devolver los datos normalmente
        return jsonify(data_list), 200

    except Exception as e:
        # Log final y respuesta 500 con detalle
        client_error = request.headers.get('X-Client-Error')
        logger.exception("Error en reporte_buscar: %s -- params=%s -- X-Client-Error=%s", e, request.args.to_dict(), client_error)
        return jsonify({"msg": "Error interno al buscar reportes", "detail": str(e)}), 500
