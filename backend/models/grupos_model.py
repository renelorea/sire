from flask import jsonify
from database.connection import mysql
from MySQLdb.cursors import DictCursor

def alta_grupo(datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO grupos (grado, ciclo_escolar, id_tutor, Descripcion)
        VALUES (%s, %s, %s, %s)
    """, (
        datos['grado'],
        datos['ciclo_escolar'],
        datos.get('id_tutor'),
        datos.get('Descripcion')
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Grupo creado"}), 201

def baja_grupo(id):
    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM grupos WHERE id_grupo = %s", (id,))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Grupo eliminado"}), 200

def cambio_grupo(id, datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        UPDATE grupos SET grado=%s, ciclo_escolar=%s, id_tutor=%s, Descripcion=%s
        WHERE id_grupo = %s
    """, (
        datos['grado'],
        datos['ciclo_escolar'],
        datos.get('id_tutor'),
        datos.get('Descripcion'),
        id
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Grupo actualizado"}), 200

def find_all_grupos():
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM grupos")
    grupos = cursor.fetchall()
    cursor.close()
    return jsonify(grupos), 200

def find_grupo_by_id(id):
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM grupos WHERE id_grupo = %s", (id,))
    grupo = cursor.fetchone()
    cursor.close()
    if grupo:
        return jsonify(grupo), 200
    else:
        return jsonify({"msg": "Grupo no encontrado"}), 404

