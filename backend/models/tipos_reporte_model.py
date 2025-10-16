from flask import jsonify
from database.connection import mysql
from MySQLdb.cursors import DictCursor

def alta_tipo(datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO tipos_reporte (nombre, descripcion, gravedad)
        VALUES (%s, %s, %s)
    """, (
        datos['nombre'],
        datos.get('descripcion'),
        datos['gravedad']
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Tipo de reporte creado"}), 201

def baja_tipo(id):
    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM tipos_reporte WHERE id_tipo_reporte = %s", (id,))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Tipo de reporte eliminado"}), 200

def cambio_tipo(id, datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        UPDATE tipos_reporte SET nombre=%s, descripcion=%s, gravedad=%s
        WHERE id_tipo_reporte = %s
    """, (
        datos['nombre'],
        datos.get('descripcion'),
        datos['gravedad'],
        id
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Tipo de reporte actualizado"}), 200

def find_all_tipos():
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM tipos_reporte")
    tipos = cursor.fetchall()
    cursor.close()
    return jsonify(tipos), 200

def find_tipo_by_id(id):
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM tipos_reporte WHERE id_tipo_reporte = %s", (id,))
    tipo = cursor.fetchone()
    cursor.close()
    if tipo:
        return jsonify(tipo), 200
    else:
        return jsonify({"msg": "Tipo de reporte no encontrado"}), 404

