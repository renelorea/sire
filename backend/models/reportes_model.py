from flask import jsonify
from database.connection import mysql
from MySQLdb.cursors import DictCursor

def alta_reporte(datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO reportes_incidencias (
            folio, id_alumno, id_usuario_que_reporta, id_tipo_reporte,
            descripcion_hechos, acciones_tomadas, fecha_incidencia, estatus
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        datos['folio'],
        datos['id_alumno'],
        datos['id_usuario_que_reporta'],
        datos['id_tipo_reporte'],
        datos['descripcion_hechos'],
        datos.get('acciones_tomadas'),
        datos['fecha_incidencia'],
        datos.get('estatus', 'Abierto')
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Reporte creado"}), 201

def baja_reporte(id):
    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM reportes_incidencias WHERE id_reporte = %s", (id,))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Reporte eliminado"}), 200

def cambio_reporte(id, datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        UPDATE reportes_incidencias SET
            descripcion_hechos=%s,
            acciones_tomadas=%s,
            estatus=%s
        WHERE id_reporte = %s
    """, (
        datos['descripcion_hechos'],
        datos.get('acciones_tomadas'),
        datos['estatus'],
        id
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Reporte actualizado"}), 200

def find_all_reportes():
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM reportes_incidencias")
    reportes = cursor.fetchall()
    cursor.close()
    return jsonify(reportes), 200

def find_reporte_by_id(id):
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM reportes_incidencias WHERE id_reporte = %s", (id,))
    reporte = cursor.fetchone()
    cursor.close()
    if reporte:
        return jsonify(reporte), 200
    else:
        return jsonify({"msg": "Reporte no encontrado"}), 404
