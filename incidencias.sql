-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 01-11-2025 a las 04:57:17
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `incidencias`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumnos`
--

CREATE TABLE `alumnos` (
  `id_alumno` int(11) NOT NULL,
  `matricula` varchar(20) NOT NULL COMMENT 'Identificador único del alumno',
  `nombres` varchar(100) NOT NULL,
  `apellido_paterno` varchar(100) NOT NULL,
  `apellido_materno` varchar(100) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `id_grupo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `alumnos`
--

INSERT INTO `alumnos` (`id_alumno`, `matricula`, `nombres`, `apellido_paterno`, `apellido_materno`, `fecha_nacimiento`, `id_grupo`) VALUES
(1, 'A012345', 'Juan', 'Pérez', 'García', NULL, 1),
(2, 'A012346', 'Sofía1', 'López', 'Mora', '2002-10-01', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupos`
--

CREATE TABLE `grupos` (
  `id_grupo` int(11) NOT NULL,
  `grado` smallint(6) NOT NULL COMMENT 'Ej: 1, 2, 3',
  `ciclo_escolar` varchar(10) NOT NULL COMMENT 'Ej: 2024-2025',
  `id_tutor` int(11) DEFAULT NULL,
  `Descripcion` varchar(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `grupos`
--

INSERT INTO `grupos` (`id_grupo`, `grado`, `ciclo_escolar`, `id_tutor`, `Descripcion`) VALUES
(1, 3, '2024-2025', 1, '201'),
(2, 3, '2024-2025', NULL, '202');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reportes_incidencias`
--

CREATE TABLE `reportes_incidencias` (
  `id_reporte` int(11) NOT NULL,
  `folio` varchar(20) NOT NULL COMMENT 'Folio autogenerado por la aplicación, ej: REP-2025-0001',
  `id_alumno` int(11) NOT NULL COMMENT 'El alumno que protagoniza la incidencia',
  `id_usuario_que_reporta` int(11) NOT NULL COMMENT 'El profesor o administrativo que crea el reporte',
  `id_tipo_reporte` int(11) NOT NULL,
  `descripcion_hechos` text NOT NULL COMMENT 'Narrativa detallada de lo sucedido',
  `acciones_tomadas` text DEFAULT NULL COMMENT 'Qué acciones se realizaron al momento o posteriormente',
  `fecha_incidencia` datetime NOT NULL COMMENT 'Cuándo ocurrió el evento exactamente',
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Cuándo se registró en el sistema (autogenerado)',
  `estatus` enum('Abierto','En Seguimiento','Cerrado') NOT NULL DEFAULT 'Abierto'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `reportes_incidencias`
--

INSERT INTO `reportes_incidencias` (`id_reporte`, `folio`, `id_alumno`, `id_usuario_que_reporta`, `id_tipo_reporte`, `descripcion_hechos`, `acciones_tomadas`, `fecha_incidencia`, `fecha_creacion`, `estatus`) VALUES
(1, 'REP-2025-0001', 1, 1, 1, 'Durante la clase de matemáticas, el alumno Juan Pérez interrumpió constantemente al profesor y a sus compañeros, haciendo ruidos y sin atender a las indicaciones.', 'Se le llamó la atención verbalmente y se le cambió de lugar. Se notificará a sus padres.', '2025-08-21 10:30:00', '2025-08-20 20:42:37', 'En Seguimiento'),
(2, 'REP-2025-0002', 1, 1, 1, 'sdasdsad', 'asdsadsad', '2025-08-20 16:32:00', '2025-08-20 22:33:03', 'Abierto'),
(4, 'REP-2025-0003', 1, 1, 3, 'hhkjhjkhj', 'kljjkjk', '2025-08-20 16:40:00', '2025-08-20 22:40:23', 'Abierto'),
(5, 'REP-2025-0004', 1, 1, 3, 'kjhjhjkhjkhjk', 'khjhjjkhjkhj', '2025-08-20 16:43:00', '2025-08-20 22:43:15', 'Abierto'),
(6, 'REP-2025-0005', 1, 1, 2, 'dasdasdas', 'asdsada', '2025-08-20 17:22:00', '2025-08-20 23:22:39', 'Abierto'),
(7, 'REP-2025-0006', 1, 1, 3, 'bhkjjjkhj', 'jkhkjjkhjkhj', '2025-08-21 17:27:00', '2025-08-20 23:27:49', 'Abierto'),
(8, 'REP-2025-0007', 1, 1, 3, 'jhkjhjkhjkh', 'jhjhkhjhjkh', '2025-08-20 17:33:00', '2025-08-20 23:33:04', 'Abierto'),
(9, 'REP-2025-0008', 2, 1, 4, 'sdasdasd', 'asdadads', '2025-08-13 17:39:00', '2025-08-20 23:39:11', 'Abierto'),
(10, 'REP-2025-0009', 1, 1, 3, 'dasdasd', 'asdasdasd', '2025-08-21 17:48:00', '2025-08-20 23:48:18', 'Abierto'),
(11, 'REP-2025-0010', 1, 1, 4, 'dsfsfdsf', 'sdfsdfsdfsd', '2025-08-21 17:50:00', '2025-08-21 23:50:11', 'Abierto'),
(12, 'REP-2025-0011', 1, 1, 3, 'adasdasdas', 'dasdasasd', '2025-08-22 13:35:00', '2025-08-22 19:35:54', 'Abierto'),
(13, 'REP-2025-0012', 2, 1, 2, 'hjkkhjkh', 'jkhhjkhj', '2025-08-22 13:51:00', '2025-08-22 19:51:03', 'Abierto'),
(14, '', 2, 7, 2, 'ejemplo de falta de material en clase', 'no se toma encuenta la practica', '2025-10-27 00:00:00', '2025-10-26 16:11:11', 'Abierto');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `seguimiento_evidencias`
--

CREATE TABLE `seguimiento_evidencias` (
  `id_seguimiento` int(11) NOT NULL,
  `id_reporte` int(11) NOT NULL COMMENT 'Referencia al reporte original',
  `responsable` varchar(100) NOT NULL COMMENT 'Quien sube la evidencia o da seguimiento',
  `fecha_seguimiento` date NOT NULL COMMENT 'Fecha del registro de seguimiento',
  `descripcion` text NOT NULL COMMENT 'Descripción del avance o evidencia',
  `evidencia_url` varchar(255) DEFAULT NULL COMMENT 'Ruta o enlace al archivo subido',
  `estado` enum('pendiente','en revision','solucionado') DEFAULT 'pendiente',
  `validado` tinyint(1) DEFAULT 0 COMMENT 'Si fue validado por el área correspondiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_reporte`
--

CREATE TABLE `tipos_reporte` (
  `id_tipo_reporte` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `gravedad` enum('Leve','Moderada','Grave') NOT NULL DEFAULT 'Leve'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tipos_reporte`
--

INSERT INTO `tipos_reporte` (`id_tipo_reporte`, `nombre`, `descripcion`, `gravedad`) VALUES
(1, 'Conducta Inapropiada', 'Comportamiento que interrumpe el orden de la clase o falta al reglamento.', 'Moderada'),
(2, 'Falta de Material', 'El alumno no cuenta con los materiales necesarios para la clase de forma reiterada.', 'Leve'),
(3, 'Agresión Física/Verbal', 'Contacto físico o verbal intencional y dañino hacia un compañero o personal.', 'Grave'),
(4, 'Rendimiento Académico Bajo', 'Dificultades notorias en el aprendizaje o entrega de trabajos.', 'Moderada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellido_paterno` varchar(100) NOT NULL,
  `apellido_materno` varchar(100) DEFAULT NULL,
  `email` varchar(255) NOT NULL COMMENT 'Servirá como nombre de usuario para el login',
  `rol` enum('Profesor','Administrativo','Director','Psicologia') NOT NULL COMMENT 'Define los permisos y tipo de usuario',
  `contrasena` varchar(255) NOT NULL COMMENT 'IMPORTANTE: Guardar siempre en formato hash (ej. bcrypt)',
  `activo` tinyint(1) DEFAULT 1 COMMENT 'Para dar de baja a usuarios sin borrarlos (baja lógica)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombres`, `apellido_paterno`, `apellido_materno`, `email`, `rol`, `contrasena`, `activo`) VALUES
(1, 'Usuario', 'Prueba', NULL, 'test@escuela.edu', 'Profesor', '$2b$12$xsch9oS4oLVZ10.ws5CFMuL4g8DBTyFVqzmfDTjFNBTprgFXzOeb.', 1),
(2, 'Carlos', 'Sánchez', 'Ruiz', 'carlos.sanchez@escuela.edu', 'Profesor', '$2y$10$examplehashvalue...', 1),
(3, 'Laura', 'Gómez', 'Paredes', 'laura.gomez@escuela.edu', 'Administrativo', '$2y$10$examplehashvalue...', 0),
(4, 'Ana', 'Martínez', 'Lara', 'ana.martinez@escuela.edu', 'Director', '$2y$10$examplehashvalue...', 0),
(5, 'Rene', 'Lorea', 'Ayala', 'rene.lorea@soycecytem.mx', 'Profesor', '$2b$12$gFWbDi49CSahvxm7crkwrOirNM4.HciujCj1aTRDYCzWQCNfVFITa', 1),
(6, 'Rene1', 'Lorea', 'Ayala', 'rene1.lorea@soycecytem.mx', 'Profesor', '$2b$12$OqDErtE3VjZ2iJkYuVhuI.PvpfqZRNDV4g3qwKN/JT2bO9yUYvJki', 0),
(7, 'rene12', 'lorea', 'ayala', 'rene.lorea1@soycecytem.mx', 'Profesor', '$2b$12$DPzUqCedI38/93GnoZukveb3OOpXZm.tphZiLCckjooykr0KiPhZS', 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alumnos`
--
ALTER TABLE `alumnos`
  ADD PRIMARY KEY (`id_alumno`),
  ADD UNIQUE KEY `matricula` (`matricula`),
  ADD KEY `fk_grupo_alumno` (`id_grupo`);

--
-- Indices de la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD PRIMARY KEY (`id_grupo`),
  ADD KEY `fk_tutor_grupo` (`id_tutor`);

--
-- Indices de la tabla `reportes_incidencias`
--
ALTER TABLE `reportes_incidencias`
  ADD PRIMARY KEY (`id_reporte`),
  ADD UNIQUE KEY `folio` (`folio`),
  ADD KEY `fk_alumno_reporte` (`id_alumno`),
  ADD KEY `fk_usuario_reporte` (`id_usuario_que_reporta`),
  ADD KEY `fk_tipo_reporte` (`id_tipo_reporte`);

--
-- Indices de la tabla `seguimiento_evidencias`
--
ALTER TABLE `seguimiento_evidencias`
  ADD PRIMARY KEY (`id_seguimiento`),
  ADD KEY `fk_reporte_seguimiento` (`id_reporte`);

--
-- Indices de la tabla `tipos_reporte`
--
ALTER TABLE `tipos_reporte`
  ADD PRIMARY KEY (`id_tipo_reporte`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alumnos`
--
ALTER TABLE `alumnos`
  MODIFY `id_alumno` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `grupos`
--
ALTER TABLE `grupos`
  MODIFY `id_grupo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `reportes_incidencias`
--
ALTER TABLE `reportes_incidencias`
  MODIFY `id_reporte` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `seguimiento_evidencias`
--
ALTER TABLE `seguimiento_evidencias`
  MODIFY `id_seguimiento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipos_reporte`
--
ALTER TABLE `tipos_reporte`
  MODIFY `id_tipo_reporte` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `alumnos`
--
ALTER TABLE `alumnos`
  ADD CONSTRAINT `fk_grupo_alumno` FOREIGN KEY (`id_grupo`) REFERENCES `grupos` (`id_grupo`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD CONSTRAINT `fk_tutor_grupo` FOREIGN KEY (`id_tutor`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `reportes_incidencias`
--
ALTER TABLE `reportes_incidencias`
  ADD CONSTRAINT `fk_alumno_reporte` FOREIGN KEY (`id_alumno`) REFERENCES `alumnos` (`id_alumno`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tipo_reporte` FOREIGN KEY (`id_tipo_reporte`) REFERENCES `tipos_reporte` (`id_tipo_reporte`),
  ADD CONSTRAINT `fk_usuario_reporte` FOREIGN KEY (`id_usuario_que_reporta`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `seguimiento_evidencias`
--
ALTER TABLE `seguimiento_evidencias`
  ADD CONSTRAINT `fk_reporte_seguimiento` FOREIGN KEY (`id_reporte`) REFERENCES `reportes_incidencias` (`id_reporte`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
