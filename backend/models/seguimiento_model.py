from flask import jsonify
from database.connection import mysql
from MySQLdb.cursors import DictCursor
from datetime import date
import base64
import logging

def crear_seguimiento(data):
    """
    Inserta un seguimiento con archivo en lugar de URL
    Espera keys: id_reporte, responsable, fecha_seguimiento, descripcion, 
    evidencia_archivo (base64), evidencia_nombre, evidencia_tipo, evidencia_tamaño
    """
    try:
        cursor = mysql.connection.cursor(DictCursor)
        fecha = data.get('fecha_seguimiento') or date.today().isoformat()
        
        # Procesar archivo si existe
        evidencia_archivo = None
        evidencia_nombre = None
        evidencia_tipo = None
        evidencia_tamaño = None
        
        if 'evidencia_archivo' in data and data['evidencia_archivo']:
            # Decodificar base64 a bytes
            evidencia_archivo = base64.b64decode(data['evidencia_archivo'])
            evidencia_nombre = data.get('evidencia_nombre', 'archivo')
            evidencia_tipo = data.get('evidencia_tipo', 'application/octet-stream')
            evidencia_tamaño = len(evidencia_archivo)
        
        params = (
            data['id_reporte'],
            data['responsable'],
            fecha,
            data['descripcion'],
            evidencia_archivo,
            evidencia_nombre,
            evidencia_tipo,
            evidencia_tamaño,
            data.get('estado', 'pendiente'),
            int(data.get('validado', 0) or 0)
        )
        
        # Log del query y parámetros para debug
        query = '''
            INSERT INTO seguimiento_evidencias (
                id_reporte, responsable, fecha_seguimiento,
                descripcion, evidencia_archivo, evidencia_nombre,
                evidencia_tipo, evidencia_tamaño, estado, validado
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        '''
        
        # Log de los parámetros (sin incluir el archivo binario por ser muy grande)
        params_log = list(params)
        if params_log[4]:  # evidencia_archivo
            params_log[4] = f"<archivo_binario_{len(params_log[4])}_bytes>"
        
        logging.info(f'[seguimiento_model.crear_seguimiento] Query: {query.strip()}')
        logging.info(f'[seguimiento_model.crear_seguimiento] Params: {params_log}')
        
        cursor.execute(query, params)
        mysql.connection.commit()
        new_id = cursor.lastrowid

        # Obtener el registro sin el archivo para la respuesta
        cursor.execute("""
            SELECT id_seguimiento, id_reporte, responsable, fecha_seguimiento,
                   descripcion, evidencia_nombre, evidencia_tipo, evidencia_tamaño,
                   estado, validado
            FROM seguimiento_evidencias 
            WHERE id_seguimiento = %s
        """, (new_id,))
        row = cursor.fetchone()
        cursor.close()
        return row
    except Exception as e:
        logging.error(f'[seguimiento_model.crear_seguimiento] Error: {e}')
        logging.error(f'[seguimiento_model.crear_seguimiento] Tipo de error: {type(e).__name__}')
        logging.error(f'[seguimiento_model.crear_seguimiento] Data recibida: {[k for k in data.keys()]}')
        print('Error crear_seguimiento:', e)
        try:
            cursor.close()
        except:
            pass
        return None

def listar_seguimientos():
    """Lista seguimientos sin incluir el archivo binario"""
    try:
        cursor = mysql.connection.cursor(DictCursor)
        cursor.execute("""
            SELECT id_seguimiento, id_reporte, responsable, fecha_seguimiento,
                   descripcion, evidencia_nombre, evidencia_tipo, evidencia_tamaño,
                   estado, validado
            FROM seguimiento_evidencias 
            ORDER BY fecha_seguimiento DESC
        """)
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
    """Obtiene seguimiento sin archivo binario"""
    try:
        cursor = mysql.connection.cursor(DictCursor)
        cursor.execute("""
            SELECT id_seguimiento, id_reporte, responsable, fecha_seguimiento,
                   descripcion, evidencia_nombre, evidencia_tipo, evidencia_tamaño,
                   estado, validado
            FROM seguimiento_evidencias 
            WHERE id_seguimiento = %s
        """, (id,))
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

def obtener_archivo_evidencia(id):
    """Obtiene solo el archivo binario y metadatos"""
    try:
        cursor = mysql.connection.cursor(DictCursor)
        cursor.execute("""
            SELECT evidencia_archivo, evidencia_nombre, evidencia_tipo
            FROM seguimiento_evidencias 
            WHERE id_seguimiento = %s
        """, (id,))
        row = cursor.fetchone()
        cursor.close()
        return row
    except Exception as e:
        print('Error obtener_archivo_evidencia:', e)
        try:
            cursor.close()
        except:
            pass
        return None

def actualizar_seguimiento(id, data):
    """
    Actualiza campos permitidos incluyendo archivo
    """
    try:
        allowed = {
            'id_reporte': 'id_reporte',
            'responsable': 'responsable',
            'fecha_seguimiento': 'fecha_seguimiento',
            'descripcion': 'descripcion',
            'estado': 'estado',
            'validado': 'validado'
        }
        fields = []
        params = []
        
        # Campos regulares
        for k, col in allowed.items():
            if k in data:
                fields.append(f"{col} = %s")
                params.append(data[k])
        
        # Manejar archivo si se proporciona
        if 'evidencia_archivo' in data and data['evidencia_archivo']:
            evidencia_archivo = base64.b64decode(data['evidencia_archivo'])
            evidencia_nombre = data.get('evidencia_nombre', 'archivo')
            evidencia_tipo = data.get('evidencia_tipo', 'application/octet-stream')
            evidencia_tamaño = len(evidencia_archivo)
            
            fields.extend([
                'evidencia_archivo = %s',
                'evidencia_nombre = %s', 
                'evidencia_tipo = %s',
                'evidencia_tamaño = %s'
            ])
            params.extend([evidencia_archivo, evidencia_nombre, evidencia_tipo, evidencia_tamaño])
        
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


def actualizar_estatus(id_reporte, nuevo_estatus):
    """
    Actualiza el campo 'estatus' en reportes_incidencias.
    Retorna True si se actualizó (filas afectadas > 0), False en caso contrario.
    """
    try:
        cursor = mysql.connection.cursor()
        sql = "UPDATE reportes_incidencias SET estatus = %s WHERE id_reporte = %s"
        cursor.execute(sql, (nuevo_estatus, id_reporte))
        mysql.connection.commit()
        affected = cursor.rowcount
        cursor.close()
        logging.info(f'[reportes_model.actualizar_estatus] id={id_reporte} affected={affected}')
        return affected > 0
    except Exception as e:
        logging.error(f'[reportes_model.actualizar_estatus] error: {e}')
        try:
            cursor.close()
        except:
            pass
        return False