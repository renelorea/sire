from flask import jsonify
from database.connection import mysql
from MySQLdb.cursors import DictCursor

import logging

def alta_alumno(datos):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO alumnos (matricula, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, id_grupo, sexo)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (
        datos['matricula'],
        datos['nombres'],
        datos['apellido_paterno'],
        datos.get('apellido_materno'),
        datos.get('fecha_nacimiento'),
        datos['id_grupo'],
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
    # Log para inspeccionar qué llega en 'datos'
    logging.info(f'[alumnos_model.cambio_alumno] id={id} datos={datos}')

    cursor = mysql.connection.cursor()
    cursor.execute("""
        UPDATE alumnos SET nombres=%s, apellido_paterno=%s, apellido_materno=%s, fecha_nacimiento=%s, sexo=%s, id_grupo=%s
        WHERE id_alumno = %s
    """, (
        datos['nombres'],
        datos['apellido_paterno'],
        datos.get('apellido_materno'),
        datos.get('fecha_nacimiento'),
        datos.get('sexo'),     # corregido: sexo antes de id_grupo
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
            g.id_grupo, g.grado, g.ciclo_escolar, g.id_tutor,g.Descripcion, a.sexo
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
            "sexo": row["sexo"],
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
            g.id_grupo, g.grado, g.ciclo_escolar, g.id_tutor,g.Descripcion, a.sexo
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
            "sexo": row["sexo"],
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
    
def importar_alumnos(records):
    """
    Espera una lista de dicts con claves (ej): nombre, apaterno, amaterno, matricula, grupo_id, correo, sexo
    Retorna número de filas insertadas (int).
    """
    if not records:
        return 0
    try:
        cursor = mysql.connection.cursor()
        sql = """
            INSERT INTO alumnos (nombres, apellido_paterno, apellido_materno, matricula, id_grupo, fecha_nacimiento, sexo)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        params = []
        for r in records:
            params.append((
                r.get('nombre') or r.get('Nombre') or '',
                r.get('apaterno') or r.get('Apaterno') or '',
                r.get('amaterno') or r.get('Amaterno') or '',
                r.get('matricula') or r.get('Matricula') or None,
                r.get('grupo_id') or r.get('Grupo') or None,
                r.get('fecha_nacimiento') or r.get('fecha_nacimiento') or None,
                (r.get('sexo') or r.get('Sexo') or r.get('gender') or 'O')[:1],  # M/F/O
            ))
        cursor.executemany(sql, params)
        mysql.connection.commit()
        affected = cursor.rowcount
        cursor.close()
        logging.info(f'[alumnos_model.importar_alumnos] affected={affected}')
        return affected
    except Exception as e:
        logging.exception('[alumnos_model.importar_alumnos] error')
        try:
            cursor.close()
        except:
            pass
        return 0

def find_alumnos_by_grupo(grupo_id):
    """
    Retorna lista JSON de alumnos que pertenezcan al grupo `grupo_id`.
    Implementar según el acceso a BD que ya uses (ej. SQLAlchemy, pymysql, etc.).
    Ejemplo con cursor raw:
    """
    cursor = mysql.connection.cursor()
    sql = "SELECT id_alumno, nombres, apellido_paterno, apellido_materno, matricula, fecha_nacimiento, sexo FROM alumnos WHERE id_grupo=%s"
    cursor.execute(sql, (grupo_id,))
    rows = cursor.fetchall()
    cols = [desc[0] for desc in cursor.description]
    data = [dict(zip(cols, row)) for row in rows]
    cursor.close()
    return jsonify(data), 200



