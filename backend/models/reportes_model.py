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
    cursor.execute("""
        SELECT r.*, 
               -- Alumno y grupo
               a.id_alumno, a.matricula, a.nombres AS alumno_nombre, a.apellido_paterno AS alumno_apaterno, a.apellido_materno AS alumno_amaterno,
               a.fecha_nacimiento, g.id_grupo, g.grado AS grupo_grado, g.Descripcion AS grupo_nombre, g.ciclo_escolar,
               
               -- Usuario que reporta
               u.id_usuario, u.nombres AS usuario_nombre, u.apellido_paterno AS usuario_apaterno, u.apellido_materno AS usuario_amaterno,
               u.email AS email, u.rol AS usuario_rol, u.activo AS usuario_activo,
               
               -- Tipo de reporte
               t.id_tipo_reporte, t.nombre AS tipo_nombre, t.descripcion AS tipo_descripcion, t.gravedad AS tipo_gravedad
        FROM reportes_incidencias r
        JOIN alumnos a ON r.id_alumno = a.id_alumno
        JOIN grupos g ON a.id_grupo = g.id_grupo
        JOIN usuarios u ON r.id_usuario_que_reporta = u.id_usuario
        JOIN tipos_reporte t ON r.id_tipo_reporte = t.id_tipo_reporte
    """)
    rows = cursor.fetchall()
    cursor.close()

    reportes = []
    for r in rows:
        reporte = {
            "id_reporte": r["id_reporte"],
            "folio": r["folio"],
            "descripcion_hechos": r["descripcion_hechos"],
            "acciones_tomadas": r["acciones_tomadas"],
            "fecha_incidencia": r["fecha_incidencia"],
            "fecha_creacion": r["fecha_creacion"],
            "estatus": r["estatus"],
            "alumno": {
                "id_alumno": r["id_alumno"],
                "matricula": r["matricula"],
                "nombre": r["alumno_nombre"],
                "apellido_paterno": r["alumno_apaterno"],
                "apellido_materno": r["alumno_amaterno"],
                "fecha_nacimiento": r["fecha_nacimiento"],
                "grupo": {
                    "id_grupo": r["id_grupo"],
                    "grado": r["grupo_grado"],
                    "grupo": r["grupo_nombre"],
                    "ciclo_escolar": r["ciclo_escolar"]
                }
            },
            "usuario": {
                "id_usuario": r["id_usuario"],
                "nombre": r["usuario_nombre"],
                "apellido_paterno": r["usuario_apaterno"],
                "apellido_materno": r["usuario_amaterno"],
                "email": r["email"],
                "rol": r["usuario_rol"],
                "activo": r["usuario_activo"]
            },
            "tipo_reporte": {
                "id_tipo_reporte": r["id_tipo_reporte"],
                "nombre": r["tipo_nombre"],
                "descripcion": r["tipo_descripcion"],
                "gravedad": r["tipo_gravedad"]
            }
        }
        reportes.append(reporte)

    return jsonify(reportes), 200


def find_reporte_by_id(id):
    cursor = mysql.connection.cursor(DictCursor)
    cursor.execute("""
        SELECT r.*, 
               -- Alumno y grupo
               a.id_alumno, a.matricula, a.nombres AS alumno_nombre, a.apellido_paterno AS alumno_apaterno, a.apellido_materno AS alumno_amaterno,
               a.fecha_nacimiento, g.id_grupo, g.grado AS grupo_grado, g.Descripcion AS grupo_nombre, g.ciclo_escolar,
               
               -- Usuario que reporta
               u.id_usuario, u.nombres AS usuario_nombre, u.apellido_paterno AS usuario_apaterno, u.apellido_materno AS usuario_amaterno,
               u.email AS email, u.rol AS usuario_rol, u.activo AS usuario_activo,
               
               -- Tipo de reporte
               t.id_tipo_reporte, t.nombre AS tipo_nombre, t.descripcion AS tipo_descripcion, t.gravedad AS tipo_gravedad
        FROM reportes_incidencias r
        JOIN alumnos a ON r.id_alumno = a.id_alumno
        JOIN grupos g ON a.id_grupo = g.id_grupo
        JOIN usuarios u ON r.id_usuario_que_reporta = u.id_usuario
        JOIN tipos_reporte t ON r.id_tipo_reporte = t.id_tipo_reporte
        WHERE r.id_reporte = %s
    """, (id,))
    r = cursor.fetchone()
    cursor.close()

    if not r:
        return jsonify({"msg": "Reporte no encontrado"}), 404

    reporte = {
        "id_reporte": r["id_reporte"],
        "folio": r["folio"],
        "descripcion_hechos": r["descripcion_hechos"],
        "acciones_tomadas": r["acciones_tomadas"],
        "fecha_incidencia": r["fecha_incidencia"],
        "fecha_creacion": r["fecha_creacion"],
        "estatus": r["estatus"],
        "alumno": {
            "id_alumno": r["id_alumno"],
            "matricula": r["matricula"],
            "nombre": r["alumno_nombre"],
            "apellido_paterno": r["alumno_apaterno"],
            "apellido_materno": r["alumno_amaterno"],
            "fecha_nacimiento": r["fecha_nacimiento"],
            "grupo": {
                "id_grupo": r["id_grupo"],
                "grado": r["grupo_grado"],
                "grupo": r["grupo_nombre"],
                "ciclo_escolar": r["ciclo_escolar"]
            }
        },
        "usuario": {
            "id_usuario": r["id_usuario"],
            "nombre": r["usuario_nombre"],
            "apellido_paterno": r["usuario_apaterno"],
            "apellido_materno": r["usuario_amaterno"],
            "email": r["email"],
            "rol": r["usuario_rol"],
            "activo": r["usuario_activo"]
        },
        "tipo_reporte": {
            "id_tipo_reporte": r["id_tipo_reporte"],
            "nombre": r["tipo_nombre"],
            "descripcion": r["tipo_descripcion"],
            "gravedad": r["tipo_gravedad"]
        }
    }

    return jsonify(reporte), 200
