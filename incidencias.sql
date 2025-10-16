-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema incidencias
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema incidencias
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `incidencias` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `incidencias` ;

-- -----------------------------------------------------
-- Table `incidencias`.`usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `incidencias`.`usuarios` (
  `id_usuario` INT(11) NOT NULL AUTO_INCREMENT,
  `nombres` VARCHAR(100) NOT NULL,
  `apellido_paterno` VARCHAR(100) NOT NULL,
  `apellido_materno` VARCHAR(100) NULL DEFAULT NULL,
  `email` VARCHAR(255) NOT NULL COMMENT 'Servirá como nombre de usuario para el login',
  `rol` ENUM('Profesor', 'Administrativo', 'Director', 'Psicologia') NOT NULL COMMENT 'Define los permisos y tipo de usuario',
  `contrasena` VARCHAR(255) NOT NULL COMMENT 'IMPORTANTE: Guardar siempre en formato hash (ej. bcrypt)',
  `activo` TINYINT(1) NULL DEFAULT 1 COMMENT 'Para dar de baja a usuarios sin borrarlos (baja lógica)',
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `email` (`email` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 8
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `incidencias`.`grupos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `incidencias`.`grupos` (
  `id_grupo` INT(11) NOT NULL AUTO_INCREMENT,
  `grado` SMALLINT(6) NOT NULL COMMENT 'Ej: 1, 2, 3',
  `ciclo_escolar` VARCHAR(10) NOT NULL COMMENT 'Ej: 2024-2025',
  `id_tutor` INT(11) NULL DEFAULT NULL,
  `Descripcion` VARCHAR(3) NULL DEFAULT NULL,
  PRIMARY KEY (`id_grupo`),
  INDEX `fk_tutor_grupo` (`id_tutor` ASC) VISIBLE,
  CONSTRAINT `fk_tutor_grupo`
    FOREIGN KEY (`id_tutor`)
    REFERENCES `incidencias`.`usuarios` (`id_usuario`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `incidencias`.`alumnos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `incidencias`.`alumnos` (
  `id_alumno` INT(11) NOT NULL AUTO_INCREMENT,
  `matricula` VARCHAR(20) NOT NULL COMMENT 'Identificador único del alumno',
  `nombres` VARCHAR(100) NOT NULL,
  `apellido_paterno` VARCHAR(100) NOT NULL,
  `apellido_materno` VARCHAR(100) NULL DEFAULT NULL,
  `fecha_nacimiento` DATE NULL DEFAULT NULL,
  `id_grupo` INT(11) NOT NULL,
  PRIMARY KEY (`id_alumno`),
  UNIQUE INDEX `matricula` (`matricula` ASC) VISIBLE,
  INDEX `fk_grupo_alumno` (`id_grupo` ASC) VISIBLE,
  CONSTRAINT `fk_grupo_alumno`
    FOREIGN KEY (`id_grupo`)
    REFERENCES `incidencias`.`grupos` (`id_grupo`)
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `incidencias`.`tipos_reporte`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `incidencias`.`tipos_reporte` (
  `id_tipo_reporte` INT(11) NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  `gravedad` ENUM('Leve', 'Moderada', 'Grave') NOT NULL DEFAULT 'Leve',
  PRIMARY KEY (`id_tipo_reporte`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `incidencias`.`reportes_incidencias`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `incidencias`.`reportes_incidencias` (
  `id_reporte` INT(11) NOT NULL AUTO_INCREMENT,
  `folio` VARCHAR(20) NOT NULL COMMENT 'Folio autogenerado por la aplicación, ej: REP-2025-0001',
  `id_alumno` INT(11) NOT NULL COMMENT 'El alumno que protagoniza la incidencia',
  `id_usuario_que_reporta` INT(11) NOT NULL COMMENT 'El profesor o administrativo que crea el reporte',
  `id_tipo_reporte` INT(11) NOT NULL,
  `descripcion_hechos` TEXT NOT NULL COMMENT 'Narrativa detallada de lo sucedido',
  `acciones_tomadas` TEXT NULL DEFAULT NULL COMMENT 'Qué acciones se realizaron al momento o posteriormente',
  `fecha_incidencia` DATETIME NOT NULL COMMENT 'Cuándo ocurrió el evento exactamente',
  `fecha_creacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'Cuándo se registró en el sistema (autogenerado)',
  `estatus` ENUM('Abierto', 'En Seguimiento', 'Cerrado') NOT NULL DEFAULT 'Abierto',
  PRIMARY KEY (`id_reporte`),
  UNIQUE INDEX `folio` (`folio` ASC) VISIBLE,
  INDEX `fk_alumno_reporte` (`id_alumno` ASC) VISIBLE,
  INDEX `fk_usuario_reporte` (`id_usuario_que_reporta` ASC) VISIBLE,
  INDEX `fk_tipo_reporte` (`id_tipo_reporte` ASC) VISIBLE,
  CONSTRAINT `fk_alumno_reporte`
    FOREIGN KEY (`id_alumno`)
    REFERENCES `incidencias`.`alumnos` (`id_alumno`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_tipo_reporte`
    FOREIGN KEY (`id_tipo_reporte`)
    REFERENCES `incidencias`.`tipos_reporte` (`id_tipo_reporte`),
  CONSTRAINT `fk_usuario_reporte`
    FOREIGN KEY (`id_usuario_que_reporta`)
    REFERENCES `incidencias`.`usuarios` (`id_usuario`))
ENGINE = InnoDB
AUTO_INCREMENT = 14
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `incidencias`.`seguimiento_evidencias`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `incidencias`.`seguimiento_evidencias` (
  `id_seguimiento` INT(11) NOT NULL AUTO_INCREMENT,
  `id_reporte` INT(11) NOT NULL COMMENT 'Referencia al reporte original',
  `responsable` VARCHAR(100) NOT NULL COMMENT 'Quien sube la evidencia o da seguimiento',
  `fecha_seguimiento` DATE NOT NULL COMMENT 'Fecha del registro de seguimiento',
  `descripcion` TEXT NOT NULL COMMENT 'Descripción del avance o evidencia',
  `evidencia_url` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Ruta o enlace al archivo subido',
  `estado` ENUM('pendiente', 'en revision', 'solucionado') NULL DEFAULT 'pendiente',
  `validado` TINYINT(1) NULL DEFAULT 0 COMMENT 'Si fue validado por el área correspondiente',
  PRIMARY KEY (`id_seguimiento`),
  INDEX `fk_reporte_seguimiento` (`id_reporte` ASC) VISIBLE,
  CONSTRAINT `fk_reporte_seguimiento`
    FOREIGN KEY (`id_reporte`)
    REFERENCES `incidencias`.`reportes_incidencias` (`id_reporte`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
