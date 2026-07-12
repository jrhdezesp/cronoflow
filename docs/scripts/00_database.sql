-- =======================================================
-- CronoFlow v2.0 - Esquema Completo de Base de Datos
-- Sistema de Control de Inventarios con Algoritmo PEPS
-- =======================================================

CREATE DATABASE IF NOT EXISTS `proyecto_inventario`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

USE `proyecto_inventario`;

-- =======================================================
-- 1. SEGURIDAD: Usuarios, Roles y Permisos (RBAC)
-- =======================================================

CREATE TABLE IF NOT EXISTS `usuario` (
  `usercod`            BIGINT(10)   NOT NULL AUTO_INCREMENT,
  `useremail`          VARCHAR(80)  NOT NULL,
  `username`           VARCHAR(80)  DEFAULT NULL,
  `userpswd`           VARCHAR(128) DEFAULT NULL,
  `userfching`         DATETIME     DEFAULT NULL,
  `userpswdest`        CHAR(3)      DEFAULT NULL,
  `userpswdexp`        DATETIME     DEFAULT NULL,
  `userest`            CHAR(3)      DEFAULT NULL,
  `useractcod`         VARCHAR(128) DEFAULT NULL,
  `userpswdchg`        VARCHAR(128) DEFAULT NULL,
  `usertipo`           CHAR(3)      DEFAULT NULL COMMENT 'PRP=Propietario, ADM=Admin, AUD=Auditor, PBL=Público',
  `userfailedattempts` INT(11)      DEFAULT 0,
  `userblockedat`      DATETIME     DEFAULT NULL,
  PRIMARY KEY (`usercod`),
  UNIQUE KEY `useremail_UNIQUE` (`useremail`),
  KEY `usertipo` (`usertipo`, `useremail`, `usercod`, `userest`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `roles` (
  `rolescod` VARCHAR(15) NOT NULL,
  `rolesdsc` VARCHAR(45) DEFAULT NULL,
  `rolesest` CHAR(3)     DEFAULT NULL,
  PRIMARY KEY (`rolescod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `roles_usuarios` (
  `usercod`     BIGINT(10) NOT NULL,
  `rolescod`    VARCHAR(15) NOT NULL,
  `roleuserest` CHAR(3)     DEFAULT NULL,
  `roleuserfch` DATETIME    DEFAULT NULL,
  `roleuserexp` DATETIME    DEFAULT NULL,
  PRIMARY KEY (`usercod`, `rolescod`),
  KEY `rol_usuario_key_idx` (`rolescod`),
  CONSTRAINT `rol_usuario_key` FOREIGN KEY (`rolescod`) REFERENCES `roles` (`rolescod`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `usuario_rol_key` FOREIGN KEY (`usercod`) REFERENCES `usuario` (`usercod`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `funciones` (
  `fncod` VARCHAR(255) NOT NULL,
  `fndsc` VARCHAR(45)  DEFAULT NULL,
  `fnest` CHAR(3)      DEFAULT NULL,
  `fntyp` CHAR(3)      DEFAULT NULL,
  PRIMARY KEY (`fncod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `funciones_roles` (
  `rolescod` VARCHAR(15)  NOT NULL,
  `fncod`    VARCHAR(255) NOT NULL,
  `fnrolest` CHAR(3)      DEFAULT NULL,
  `fnexp`    DATETIME     DEFAULT NULL,
  PRIMARY KEY (`rolescod`, `fncod`),
  KEY `rol_funcion_key_idx` (`fncod`),
  CONSTRAINT `funcion_rol_key` FOREIGN KEY (`rolescod`) REFERENCES `roles` (`rolescod`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `rol_funcion_key` FOREIGN KEY (`fncod`) REFERENCES `funciones` (`fncod`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `bitacora` (
  `bitacoracod`  INT(11)      NOT NULL AUTO_INCREMENT,
  `bitacorafch`  DATETIME     DEFAULT NULL,
  `bitprograma`  VARCHAR(255) DEFAULT NULL,
  `bitdescripcion` VARCHAR(255) DEFAULT NULL,
  `bitobservacion` MEDIUMTEXT DEFAULT NULL,
  `bitTipo`      CHAR(3)      DEFAULT NULL,
  `bitusuario`   BIGINT(18)   DEFAULT NULL,
  PRIMARY KEY (`bitacoracod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- =======================================================
-- 2. CATÁLOGO: Categorías, Proveedores y Productos
-- =======================================================

CREATE TABLE IF NOT EXISTS `categorias` (
  `catid`  BIGINT(8) NOT NULL AUTO_INCREMENT,
  `catnom` VARCHAR(45) NOT NULL,
  `catest` CHAR(3)  DEFAULT 'ACT',
  PRIMARY KEY (`catid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `proveedores` (
  `provId`       BIGINT(10)  NOT NULL AUTO_INCREMENT,
  `provNombre`   VARCHAR(100) NOT NULL COMMENT 'Nombre o Razón Social',
  `provContacto` VARCHAR(100) DEFAULT NULL COMMENT 'Nombre del contacto de ventas',
  `provTelefono` VARCHAR(20)  DEFAULT NULL,
  `provEmail`    VARCHAR(80)  DEFAULT NULL,
  `provDireccion` TEXT        DEFAULT NULL,
  `provEst`      CHAR(3)     DEFAULT 'ACT' COMMENT 'ACT=Activo, INA=Inactivo',
  PRIMARY KEY (`provId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `productos` (
  `invPrdId`         BIGINT(13)   NOT NULL AUTO_INCREMENT,
  `invPrdBrCod`      VARCHAR(128) DEFAULT NULL COMMENT 'Código de Barras',
  `invPrdCodInt`     VARCHAR(128) DEFAULT NULL COMMENT 'Código interno institucional',
  `invPrdDsc`        VARCHAR(128) NOT NULL COMMENT 'Descripción o Nombre del Producto',
  `catid`            BIGINT(8)    DEFAULT NULL COMMENT 'Categoría del Producto',
  `provId`           BIGINT(10)   DEFAULT NULL COMMENT 'Proveedor del Producto',
  `invPrdPrecioVenta` DECIMAL(13,2) NOT NULL DEFAULT 0.00 COMMENT 'Precio al público',
  `invPrdCosto`      DECIMAL(13,2) NOT NULL DEFAULT 0.00 COMMENT 'Costo de adquisición',
  `invPrdStock`      INT(11)      NOT NULL DEFAULT 0 COMMENT 'Stock Físico Consolidado',
  `invPrdStockMin`   INT(11)      NOT NULL DEFAULT 10 COMMENT 'Umbral para Alerta de Stock Bajo',
  `invPrdTip`        CHAR(3)     DEFAULT 'PRD' COMMENT 'PRD=Producto, SRV=Servicio',
  `invPrdEst`        CHAR(3)     DEFAULT 'ACT' COMMENT 'ACT=Activo, INA=Inactivo/Descontinuado',
  `invPrdCreatedBy`  BIGINT(10)   DEFAULT NULL,
  `invPrdCreatedAt`  DATETIME     DEFAULT NULL,
  `invPrdModifiedBy` BIGINT(10)   DEFAULT NULL,
  `invPrdModifiedAt` DATETIME     DEFAULT NULL,
  PRIMARY KEY (`invPrdId`),
  UNIQUE KEY `invPrdBrCod_UNIQUE` (`invPrdBrCod`),
  UNIQUE KEY `invPrdCodInt_UNIQUE` (`invPrdCodInt`),
  CONSTRAINT `fk_prod_cat`   FOREIGN KEY (`catid`)  REFERENCES `categorias` (`catid`)   ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_prod_prov`  FOREIGN KEY (`provId`) REFERENCES `proveedores` (`provId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_prod_user_crt` FOREIGN KEY (`invPrdCreatedBy`)  REFERENCES `usuario` (`usercod`) ON DELETE SET NULL,
  CONSTRAINT `fk_prod_user_mod` FOREIGN KEY (`invPrdModifiedBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- =======================================================
-- 3. LOTES (Soporte PEPS / FIFO y Caducidad)
-- =======================================================

CREATE TABLE IF NOT EXISTS `lotes_inventario` (
  `loteId`              BIGINT(15)   NOT NULL AUTO_INCREMENT,
  `invPrdId`            BIGINT(13)   NOT NULL,
  `loteCod`             VARCHAR(50)  NOT NULL COMMENT 'Identificador de lote',
  `loteCantOriginal`    INT(11)      NOT NULL,
  `loteCantActual`      INT(11)      NOT NULL,
  `loteFechaIngreso`    DATETIME     NOT NULL,
  `loteFechaVencimiento` DATETIME    DEFAULT NULL COMMENT 'NULL si el producto no perece',
  `loteCostoUnitario`   DECIMAL(13,2) NOT NULL DEFAULT 0.00,
  `loteEst`             CHAR(3)      DEFAULT 'ACT' COMMENT 'ACT=Activo, AGT=Agotado',
  PRIMARY KEY (`loteId`),
  CONSTRAINT `fk_lote_prod` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- =======================================================
-- 4. KARDEX CONTABLE (Bitácora de Movimientos)
-- =======================================================

CREATE TABLE IF NOT EXISTS `movimientos_inventario` (
  `movId`        BIGINT(15)   NOT NULL AUTO_INCREMENT,
  `invPrdId`     BIGINT(13)   NOT NULL,
  `loteId`       BIGINT(15)   DEFAULT NULL COMMENT 'Lote afectado si aplica',
  `movTipo`      ENUM('ENT','SAL','MER') NOT NULL COMMENT 'ENT=Entrada, SAL=Salida, MER=Merma',
  `movCantidad`  INT(11)      NOT NULL,
  `movMotivo`    VARCHAR(255) NOT NULL COMMENT 'Razón del movimiento',
  `refTipo`      VARCHAR(50)  DEFAULT NULL COMMENT 'Para facturación futura',
  `refId`        BIGINT(15)   DEFAULT NULL COMMENT 'ID del documento de facturación',
  `movCreatedBy` BIGINT(10)   DEFAULT NULL,
  `movCreatedAt` DATETIME     NOT NULL,
  PRIMARY KEY (`movId`),
  CONSTRAINT `fk_mov_prod` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE,
  CONSTRAINT `fk_mov_lote` FOREIGN KEY (`loteId`)   REFERENCES `lotes_inventario` (`loteId`) ON DELETE SET NULL,
  CONSTRAINT `fk_mov_user` FOREIGN KEY (`movCreatedBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- =======================================================
-- 5. DATOS SEMILLA (Seeds)
-- =======================================================

-- Roles del Sistema
INSERT INTO `roles` (`rolescod`, `rolesdsc`, `rolesest`) VALUES
  ('PRP', 'Propietario / SuperUser', 'ACT'),
  ('ADM', 'Administrador / Empleado', 'ACT'),
  ('AUD', 'Auditor de Solo Lectura', 'ACT')
ON DUPLICATE KEY UPDATE `rolesdsc` = VALUES(`rolesdsc`);

-- Categorías por Defecto
INSERT INTO `categorias` (`catnom`, `catest`) VALUES
  ('Bebidas',     'ACT'),
  ('Comestibles', 'ACT'),
  ('Limpieza',    'ACT'),
  ('Tecnología',  'ACT');

-- Usuarios Iniciales (Contraseña: Test1234$)
-- Hash bcrypt: $2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS
INSERT INTO `usuario` (`useremail`, `username`, `userpswd`, `userfching`, `userpswdest`, `userpswdexp`, `userest`, `usertipo`) VALUES
  ('propietario@inventario.com', 'Don Cleto (Propietario)',  '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS', NOW(), 'ACT', DATE_ADD(NOW(), INTERVAL 90 DAY), 'ACT', 'PRP'),
  ('empleado@inventario.com',    'Juan Perez (Administrador)', '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS', NOW(), 'ACT', DATE_ADD(NOW(), INTERVAL 90 DAY), 'ACT', 'ADM'),
  ('auditor@inventario.com',     'Lic. Martinez (Auditor)',   '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS', NOW(), 'ACT', DATE_ADD(NOW(), INTERVAL 90 DAY), 'ACT', 'AUD')
ON DUPLICATE KEY UPDATE `username` = VALUES(`username`);

-- Asignación de Roles a Usuarios
INSERT INTO `roles_usuarios` (`usercod`, `rolescod`, `roleuserest`, `roleuserfch`, `roleuserexp`) VALUES
  (1, 'PRP', 'ACT', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY)),
  (2, 'ADM', 'ACT', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY)),
  (3, 'AUD', 'ACT', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY))
ON DUPLICATE KEY UPDATE `roleuserest` = VALUES(`roleuserest`);

-- =======================================================
-- 6. PERMISOS (Funciones y Asignación por Rol)
-- =======================================================

-- Catálogo de Funciones del Sistema
INSERT INTO `funciones` (`fncod`, `fndsc`, `fnest`, `fntyp`) VALUES
  ('Controllers\\Admin\\Admin',           'Dashboard Principal',     'ACT', 'CTR'),
  ('Controllers\\Mnt\\Productos',          'Listado de Productos',   'ACT', 'CTR'),
  ('Controllers\\Mnt\\Producto',           'Formulario de Producto', 'ACT', 'CTR'),
  ('Controllers\\Mnt\\Producto\\New',      'Crear Producto',         'ACT', 'CTR'),
  ('Controllers\\Mnt\\Producto\\Upd',      'Editar Producto',        'ACT', 'CTR'),
  ('Controllers\\Mnt\\Producto\\Dsp',      'Ver Producto',           'ACT', 'CTR'),
  ('Controllers\\Mnt\\Categorias',         'Listado de Categorías',  'ACT', 'CTR'),
  ('Controllers\\Mnt\\Categoria',          'Formulario de Categoría','ACT', 'CTR'),
  ('Controllers\\Mnt\\Categoria\\New',     'Crear Categoría',        'ACT', 'CTR'),
  ('Controllers\\Mnt\\Categoria\\Upd',     'Editar Categoría',       'ACT', 'CTR'),
  ('Controllers\\Mnt\\Categoria\\Dsp',     'Ver Categoría',          'ACT', 'CTR'),
  ('Controllers\\Mnt\\Kardex',             'Historial Kardex',       'ACT', 'CTR'),
  ('Controllers\\Sec\\Perfil',             'Perfil de Usuario',      'ACT', 'CTR'),
  ('Controllers\\Mnt\\Proveedores',        'Listado de Proveedores', 'ACT', 'CTR'),
  ('Controllers\\Mnt\\Proveedor',          'Formulario de Proveedor','ACT', 'CTR'),
  ('Controllers\\Mnt\\Proveedor\\New',     'Crear Proveedor',        'ACT', 'CTR'),
  ('Controllers\\Mnt\\Proveedor\\Upd',     'Editar Proveedor',       'ACT', 'CTR'),
  ('Controllers\\Mnt\\Proveedor\\Dsp',     'Ver Proveedor',          'ACT', 'CTR'),
  ('Controllers\\Mnt\\Usuarios',            'Listado de Usuarios',    'ACT', 'CTR'),
  ('Controllers\\Mnt\\Usuario',             'Formulario de Usuario',  'ACT', 'CTR'),
  ('Controllers\\Mnt\\Usuario\\New',        'Crear Usuario',          'ACT', 'CTR'),
  ('Controllers\\Mnt\\Usuario\\Upd',        'Editar Usuario',         'ACT', 'CTR'),
  ('Controllers\\Mnt\\Usuario\\Dsp',        'Ver Usuario',            'ACT', 'CTR')
ON DUPLICATE KEY UPDATE `fndsc` = VALUES(`fndsc`), `fnest` = VALUES(`fnest`);

-- Administrador (ADM) — Acceso completo operativo
INSERT INTO `funciones_roles` (`rolescod`, `fncod`, `fnrolest`, `fnexp`)
SELECT 'ADM', f.`fncod`, 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)
FROM `funciones` f
WHERE f.`fncod` NOT LIKE '%Usuario%'
ON DUPLICATE KEY UPDATE `fnrolest` = VALUES(`fnrolest`);

-- Propietario (PRP) — Acceso total (incluye gestión de usuarios)
INSERT INTO `funciones_roles` (`rolescod`, `fncod`, `fnrolest`, `fnexp`)
SELECT 'PRP', f.`fncod`, 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)
FROM `funciones` f
ON DUPLICATE KEY UPDATE `fnrolest` = VALUES(`fnrolest`);

-- Auditor (AUD) — Solo lectura
INSERT INTO `funciones_roles` (`rolescod`, `fncod`, `fnrolest`, `fnexp`)
VALUES
  ('AUD', 'Controllers\\Admin\\Admin',           'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Productos',          'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Producto',           'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Producto\\Dsp',      'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Categorias',         'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Categoria',          'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Categoria\\Dsp',     'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Kardex',             'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Sec\\Perfil',             'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Proveedores',        'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Proveedor',          'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
  ('AUD', 'Controllers\\Mnt\\Proveedor\\Dsp',     'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR))
ON DUPLICATE KEY UPDATE `fnrolest` = VALUES(`fnrolest`);
