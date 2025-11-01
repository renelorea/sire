from flask import jsonify
from database.connection import mysql
from MySQLdb.cursors import DictCursor
from datetime import date

def crear_seguimiento(data):
    """
    Inserta un seguimiento en la tabla y devuelve el registro insertado (dict) o None en error.
    Espera keys: id_reporte, responsable, fecha_seguimiento, descripcion, evidencia_url (opt), estado (opt), validado (opt)
    """
    try:
        cursor = mysql.connection.cursor(DictCursor)
        fecha = data.get('fecha_seguimiento') or date.today().isoformat()
        params = (
            data['id_reporte'],
            data['responsable'],
            fecha,
            data['descripcion'],
            data.get('evidencia_url'),
            data.get('estado', 'pendiente'),
            int(data.get('validado', 0) or 0)
        )
        cursor.execute('''
            INSERT INTO seguimiento_evidencias (
                id_reporte, responsable, fecha_seguimiento,
                descripcion, evidencia_url, estado, validado
            ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        ''', params)
        mysql.connection.commit()
        new_id = cursor.lastrowid

        cursor.execute("SELECT * FROM seguimiento_evidencias WHERE id_seguimiento = %s", (new_id,))
        row = cursor.fetchone()
        cursor.close()
        return row
    except Exception as e:
        print('Error crear_seguimiento:', e)
        try:
            cursor.close()
        except:
            pass
        return None

def listar_seguimientos():
    try:
        cursor = mysql.connection.cursor(DictCursor)
        cursor.execute("SELECT * FROM seguimiento_evidencias ORDER BY fecha_seguimiento DESC")
        rows = cursor.fetchall()
        cursor.close()
        return rows
    except Exception as e:
        print('Error listar_seguimientos:', e)
        try:
            cursor.close()
        except:
            pass
        return []

def obtener_seguimiento(id):
    try:
        cursor = mysql.connection.cursor(DictCursor)
        cursor.execute("SELECT * FROM seguimiento_evidencias WHERE id_seguimiento = %s", (id,))
        row = cursor.fetchone()
        cursor.close()
        return row
    except Exception as e:
        print('Error obtener_seguimiento:', e)
        try:
            cursor.close()
        except:
            pass
        return None

def actualizar_seguimiento(id, data):
    """
    Actualiza campos permitidos y devuelve el registro actualizado o None en error.
    """
    try:
        allowed = {
            'id_reporte': 'id_reporte',
            'responsable': 'responsable',
            'fecha_seguimiento': 'fecha_seguimiento',
            'descripcion': 'descripcion',
            'evidencia_url': 'evidencia_url',
            'estado': 'estado',
            'validado': 'validado'
        }
        fields = []
        params = []
        for k, col in allowed.items():
            if k in data:
                fields.append(f"{col} = %s")
                params.append(data[k])
        if not fields:
            return None
        params.append(id)
        sql = "UPDATE seguimiento_evidencias SET " + ", ".join(fields) + " WHERE id_seguimiento = %s"
        cursor = mysql.connection.cursor()
        cursor.execute(sql, tuple(params))
        mysql.connection.commit()
        cursor.close()
        return obtener_seguimiento(id)
    except Exception as e:
        print('Error actualizar_seguimiento:', e)
        try:
            cursor.close()
        except:
            pass
        return None

def eliminar_seguimiento(id):
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("DELETE FROM seguimiento_evidencias WHERE id_seguimiento = %s", (id,))
        mysql.connection.commit()
        affected = cursor.rowcount
        cursor.close()
        return affected > 0
    except Exception as e:
        print('Error eliminar_seguimiento:', e)
        try:
            cursor.close()
        except:
            pass
        return False

def actualizar_estatus_reporte(id_reporte, nuevo_estatus):
    """
    Actualiza el estatus en reportes_incidencias. Devuelve True si se actualizó.
    """
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("UPDATE reportes_incidencias SET estatus = %s WHERE id_reporte = %s", (nuevo_estatus, id_reporte))
        mysql.connection.commit()
        affected = cursor.rowcount
        cursor.close()
        return affected > 0
    except Exception as e:
        print('Error actualizar_estatus_reporte:', e)
        try:
            cursor.close()
        except:
            pass
        return False
