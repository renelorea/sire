from flask import jsonify
from flask_bcrypt import generate_password_hash
from database.connection import mysql
from MySQLdb.cursors import DictCursor

def alta_usuario(datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO usuarios (nombres, apellido_paterno, apellido_materno, email, rol, contrasena)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        datos['nombres'],
        datos['apellido_paterno'],
        datos.get('apellido_materno'),
        datos['email'],
        datos['rol'],
        generate_password_hash(datos['contrasena']).decode('utf-8')
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Usuario creado"}), 201

def baja_usuario(id):
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE usuarios SET activo = 0 WHERE id_usuario = %s", (id,))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Usuario desactivado"}), 200

def cambio_usuario(id, datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        UPDATE usuarios SET nombres=%s, apellido_paterno=%s, apellido_materno=%s, rol=%s
        WHERE id_usuario = %s
    """, (
        datos['nombres'],
        datos['apellido_paterno'],
        datos.get('apellido_materno'),
        datos['rol'],
        id
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Usuario actualizado"}), 200

def find_all_usuarios():
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM usuarios WHERE activo = 1")
    usuarios = cursor.fetchall()
    cursor.close()
    return jsonify(usuarios), 200

def find_usuario_by_id(id):
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("SELECT * FROM usuarios WHERE id_usuario = %s", (id,))
    usuario = cursor.fetchone()
    cursor.close()
    if usuario:
        return jsonify(usuario), 200
    else:
        return jsonify({"msg": "Usuario no encontrado"}), 404

