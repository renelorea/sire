from flask import jsonify
from flask_bcrypt import generate_password_hash
from database.connection import mysql
from MySQLdb.cursors import DictCursor

def alta_usuario(datos):
    # Si no se proporciona contraseña, usar la contraseña por defecto
    contrasena = datos.get('contrasena', 'cecytem@1234')
    
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
        generate_password_hash(contrasena).decode('utf-8')
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

def resetear_contrasena_usuario(id):
    """
    Resetea la contraseña de un usuario a la contraseña por defecto (cecytem@1234)
    """
    contrasena_default = 'cecytem@1234'
    
    try:
        cursor = mysql.connection.cursor(DictCursor)
        
        # Verificar que el usuario existe y está activo
        cursor.execute("SELECT * FROM usuarios WHERE id_usuario = %s AND activo = 1", (id,))
        usuario = cursor.fetchone()
        
        if not usuario:
            cursor.close()
            return jsonify({"msg": "Usuario no encontrado o inactivo"}), 404
        
        # Actualizar la contraseña
        cursor.execute("""
            UPDATE usuarios SET contrasena = %s
            WHERE id_usuario = %s
        """, (
            generate_password_hash(contrasena_default).decode('utf-8'),
            id
        ))
        
        mysql.connection.commit()
        cursor.close()
        
        return jsonify({
            "msg": "Contraseña reseteada exitosamente",
            "nueva_contrasena": contrasena_default,
            "usuario": f"{usuario['nombres']} {usuario['apellido_paterno']}"
        }), 200
        
    except Exception as e:
        if 'cursor' in locals():
            cursor.close()
        return jsonify({"msg": f"Error al resetear contraseña: {str(e)}"}), 500

def cambiar_contrasena_usuario(id, datos):
    """
    Cambia la contraseña de un usuario (requiere contraseña actual y nueva contraseña)
    """
    try:
        cursor = mysql.connection.cursor(DictCursor)
        
        # Verificar que el usuario existe
        cursor.execute("SELECT * FROM usuarios WHERE id_usuario = %s AND activo = 1", (id,))
        usuario = cursor.fetchone()
        
        if not usuario:
            cursor.close()
            return jsonify({"msg": "Usuario no encontrado"}), 404
        
        nueva_contrasena = datos.get('nueva_contrasena')
        
        if not nueva_contrasena:
            cursor.close()
            return jsonify({"msg": "Nueva contraseña es requerida"}), 400
        
        # Actualizar la contraseña
        cursor.execute("""
            UPDATE usuarios SET contrasena = %s
            WHERE id_usuario = %s
        """, (
            generate_password_hash(nueva_contrasena).decode('utf-8'),
            id
        ))
        
        mysql.connection.commit()
        cursor.close()
        
        return jsonify({"msg": "Contraseña actualizada exitosamente"}), 200
        
    except Exception as e:
        if 'cursor' in locals():
            cursor.close()
        return jsonify({"msg": f"Error al cambiar contraseña: {str(e)}"}), 500

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

def cambiar_password_por_correo(correo, password_actual, password_nueva):
    """
    Cambiar contraseña de usuario usando correo electrónico
    Valida que la contraseña actual sea correcta
    """
    try:
        from flask_bcrypt import check_password_hash
        
        cursor = mysql.connection.cursor(DictCursor)
        
        # Buscar usuario por correo
        cursor.execute("SELECT id_usuario, contrasena FROM usuarios WHERE email = %s AND activo = 1", (correo,))
        usuario = cursor.fetchone()
        
        if not usuario:
            cursor.close()
            return {"success": False, "msg": "Usuario no encontrado"}
        
        # Verificar contraseña actual
        if not check_password_hash(usuario['contrasena'], password_actual):
            cursor.close()
            return {"success": False, "msg": "Contraseña actual incorrecta"}
        
        # Actualizar con nueva contraseña
        nueva_contrasena_hash = generate_password_hash(password_nueva).decode('utf-8')
        cursor.execute("""
            UPDATE usuarios SET contrasena = %s
            WHERE id_usuario = %s
        """, (nueva_contrasena_hash, usuario['id_usuario']))
        
        mysql.connection.commit()
        cursor.close()
        
        return {"success": True, "msg": "Contraseña actualizada exitosamente"}
        
    except Exception as e:
        if 'cursor' in locals():
            cursor.close()
        return {"success": False, "msg": f"Error al cambiar contraseña: {str(e)}"}

