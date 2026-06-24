-- =======================================================
-- CronoFlow v2.0 - Tabla de Proveedores
-- =======================================================

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
