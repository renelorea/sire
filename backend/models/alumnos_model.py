from flask import jsonify
from database.connection import mysql
from MySQLdb.cursors import DictCursor

def alta_alumno(datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO alumnos (matricula, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, id_grupo)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        datos['matricula'],
        datos['nombres'],
        datos['apellido_paterno'],
        datos.get('apellido_materno'),
        datos.get('fecha_nacimiento'),
        datos['id_grupo']
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Alumno creado"}), 201

def baja_alumno(id):
    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM alumnos WHERE id_alumno = %s", (id,))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Alumno eliminado"}), 200

def cambio_alumno(id, datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        UPDATE alumnos SET nombres=%s, apellido_paterno=%s, apellido_materno=%s, fecha_nacimiento=%s, id_grupo=%s
        WHERE id_alumno = %s
    """, (
        datos['nombres'],
        datos['apellido_paterno'],
        datos.get('apellido_materno'),
        datos.get('fecha_nacimiento'),
        datos['id_grupo'],
        id
    ))
    mysql.connection.commit()
    cursor.close()
    return jsonify({"msg": "Alumno actualizado"}), 200

def find_all_alumnos():
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("""
        SELECT 
             a.id_alumno, a.matricula, a.nombres, a.apellido_paterno, a.apellido_materno, a.fecha_nacimiento,
            g.id_grupo, g.grado, g.ciclo_escolar, g.id_tutor,g.Descripcion
        FROM alumnos a
        JOIN grupos g ON a.id_grupo = g.id_grupo
    """)
    rows = cursor.fetchall()
    cursor.close()

    alumnos = []
    for row in rows:
        alumno = {
            "id_alumno": row["id_alumno"],
            "matricula": row["matricula"],
            "nombres": row["nombres"],
            "apellido_paterno": row["apellido_paterno"],
            "apellido_materno": row["apellido_materno"],
            "fecha_nacimiento": row["fecha_nacimiento"],
            "grupo": {
                "id_grupo": row["id_grupo"],
                "grado": row["grado"],
                "ciclo": row["ciclo_escolar"],
                "idtutor": row["id_tutor"],
                "descripcion": row["Descripcion"]
            }
        }
        alumnos.append(alumno)

    return jsonify(alumnos), 200


def find_alumno_by_id(id):
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("""
        SELECT 
            a.id_alumno, a.matricula, a.nombres, a.apellido_paterno, a.apellido_materno, a.fecha_nacimiento,
            g.id_grupo, g.grado, g.ciclo_escolar, g.id_tutor,g.Descripcion
        FROM alumnos a
        JOIN grupos g ON a.id_grupo = g.id_grupo
        WHERE a.id_alumno = %s
    """, (id,))
    row = cursor.fetchone()
    cursor.close()

    if row:
        alumno = {
            "id_alumno": row["id_alumno"],
            "matricula": row["matricula"],
            "nombres": row["nombres"],
            "apellido_paterno": row["apellido_paterno"],
            "apellido_materno": row["apellido_materno"],
            "fecha_nacimiento": row["fecha_nacimiento"],
            "grupo": {
                "id_grupo": row["id_grupo"],
                "grado": row["grado"],
                "ciclo": row["ciclo_escolar"],
                "idtutor": row["id_tutor"],
                "descripcion": row["Descripcion"]
            }
        }
        return jsonify(alumno), 200
    else:
        return jsonify({"msg": "Alumno no encontrado"}), 404


