import os
import smtplib
from email.message import EmailMessage
import logging

logger = logging.getLogger(__name__)

class EmailService:
    """Servicio de correo con múltiples proveedores de respaldo"""
    
    def __init__(self):
        self.providers = [
            {
                "name": "SendGrid",
                "host": "smtp.sendgrid.net",
                "port": 587,
                "user": "apikey",
                "password": os.getenv('SENDGRID_API_KEY'),
                "use_tls": True,
                "use_ssl": False
            },
            {
                "name": "Gmail-SSL",
                "host": "smtp.gmail.com",
                "port": 465,
                "user": os.getenv('SMTP_USER'),
                "password": os.getenv('SMTP_PASS'),
                "use_tls": False,
                "use_ssl": True
            },
            {
                "name": "Gmail-TLS",
                "host": "smtp.gmail.com",
                "port": 587,
                "user": os.getenv('SMTP_USER'),
                "password": os.getenv('SMTP_PASS'),
                "use_tls": True,
                "use_ssl": False
            }
        ]
        
        self.email_from = os.getenv('EMAIL_FROM', os.getenv('SMTP_USER'))
    
    def send_email(self, to_email, subject, content, attachment_data=None, attachment_filename=None):
        """
        Envía un correo intentando múltiples proveedores
        
        Args:
            to_email (str): Dirección de destino
            subject (str): Asunto del correo
            content (str): Contenido del correo
            attachment_data (bytes): Datos del archivo adjunto
            attachment_filename (str): Nombre del archivo adjunto
            
        Returns:
            tuple: (success, provider_used, error_message)
        """
        
        errors = []  # Acumular errores de cada proveedor
        
        for provider in self.providers:
            if not provider['password']:
                error_detail = f"{provider['name']}: Sin credenciales configuradas"
                logger.info(error_detail)
                errors.append(error_detail)
                continue
                
            try:
                logger.info(f"Intentando enviar correo con {provider['name']} ({provider['host']}:{provider['port']})")
                
                # Crear mensaje
                msg = EmailMessage()
                msg['Subject'] = subject
                msg['From'] = self.email_from
                msg['To'] = to_email
                msg.set_content(content)
                
                # Agregar archivo adjunto si se proporciona
                if attachment_data and attachment_filename:
                    if attachment_filename.endswith('.xlsx'):
                        msg.add_attachment(attachment_data,
                                         maintype='application',
                                         subtype='vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                         filename=attachment_filename)
                    else:
                        msg.add_attachment(attachment_data, filename=attachment_filename)
                
                # Establecer conexión
                if provider['use_ssl']:
                    logger.info(f"Conectando con SSL a {provider['host']}:{provider['port']}")
                    smtp = smtplib.SMTP_SSL(provider['host'], provider['port'], timeout=30)
                else:
                    logger.info(f"Conectando con SMTP a {provider['host']}:{provider['port']}")
                    smtp = smtplib.SMTP(provider['host'], provider['port'], timeout=30)
                    if provider['use_tls']:
                        logger.info("Iniciando TLS...")
                        smtp.starttls()
                
                # Autenticarse y enviar
                logger.info(f"Autenticando con usuario: {provider['user']}")
                smtp.login(provider['user'], provider['password'])
                logger.info("Enviando mensaje...")
                smtp.send_message(msg)
                smtp.quit()
                
                logger.info(f"✅ Correo enviado exitosamente con {provider['name']} a {to_email}")
                return True, provider['name'], None
                
            except Exception as e:
                error_msg = str(e)
                error_detail = f"{provider['name']}: {error_msg}"
                logger.warning(f"❌ Error con {provider['name']}: {error_msg}")
                errors.append(error_detail)
                
                # Si es error de red, continuar con el siguiente proveedor
                if "Network is unreachable" in error_msg or "errno 101" in error_msg:
                    continue
                # Si es error de autenticación, también continuar
                elif "Authentication failed" in error_msg or "535" in error_msg:
                    continue
                else:
                    # Otros errores también intentar siguiente proveedor
                    continue
        
        # Si ningún proveedor funcionó
        error_msg = f"Todos los proveedores fallaron. Detalles: {'; '.join(errors)}"
        logger.error(error_msg)
        return False, None, error_msg
    
    def test_connection(self):
        """Prueba la conectividad de todos los proveedores"""
        results = {}
        
        for provider in self.providers:
            if not provider['password']:
                results[provider['name']] = "Sin credenciales"
                continue
            
            try:
                logger.info(f"Probando conexión con {provider['name']} ({provider['host']}:{provider['port']})")
                
                if provider['use_ssl']:
                    smtp = smtplib.SMTP_SSL(provider['host'], provider['port'], timeout=10)
                else:
                    smtp = smtplib.SMTP(provider['host'], provider['port'], timeout=10)
                    if provider['use_tls']:
                        smtp.starttls()
                
                smtp.login(provider['user'], provider['password'])
                smtp.quit()
                results[provider['name']] = "✅ Conectado"
                
            except Exception as e:
                error_detail = f"❌ Error: {str(e)}"
                results[provider['name']] = error_detail
                logger.warning(f"Error probando {provider['name']}: {str(e)}")
        
        return results
    
    def get_configuration_info(self):
        """Obtiene información sobre la configuración actual"""
        config_info = {}
        
        for provider in self.providers:
            config_info[provider['name']] = {
                "host": provider['host'],
                "port": provider['port'],
                "user": provider['user'],
                "has_password": bool(provider['password']),
                "use_ssl": provider['use_ssl'],
                "use_tls": provider['use_tls']
            }
        
        return {
            "email_from": self.email_from,
            "providers": config_info
        }

# Instancia global del servicio
email_service = EmailService()