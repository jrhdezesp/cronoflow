CREATE TABLE IF NOT EXISTS `proveedores` (
  `provId` bigint(10) NOT NULL AUTO_INCREMENT,
  `provNombre` varchar(100) NOT NULL COMMENT 'Nombre de la empresa',
  `provContacto` varchar(100) DEFAULT NULL COMMENT 'Contacto de ventas',
  `provTelefono` varchar(20) DEFAULT NULL,
  `provEmail` varchar(80) DEFAULT NULL,
  `provDireccion` text DEFAULT NULL,
  `provEst` char(3) DEFAULT 'ACT' COMMENT 'ACT=Activo, INA=Inactivo/Eliminado Logico',
  PRIMARY KEY (`provId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET @has_provId := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'productos'
    AND COLUMN_NAME = 'provId'
);

SET @sql_add_col := IF(
  @has_provId = 0,
  'ALTER TABLE productos ADD COLUMN provId bigint(10) NULL DEFAULT NULL',
  'SELECT 1'
);
PREPARE stmt_add_col FROM @sql_add_col;
EXECUTE stmt_add_col;
DEALLOCATE PREPARE stmt_add_col;

SET @has_fk_prod_prov := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'productos'
    AND CONSTRAINT_NAME = 'fk_prod_prov'
);

SET @sql_add_fk := IF(
  @has_fk_prod_prov = 0,
  'ALTER TABLE productos ADD CONSTRAINT fk_prod_prov FOREIGN KEY (provId) REFERENCES proveedores (provId) ON DELETE SET NULL ON UPDATE CASCADE',
  'SELECT 1'
);
PREPARE stmt_add_fk FROM @sql_add_fk;
EXECUTE stmt_add_fk;
DEALLOCATE PREPARE stmt_add_fk;

INSERT INTO funciones (fncod, fndsc, fnest, fntyp) VALUES
('Controllers\\Mnt\\Proveedores', 'Proveedores', 'ACT', 'CTR'),
('Controllers\\Mnt\\Proveedor', 'Proveedor', 'ACT', 'CTR'),
('Controllers\\Mnt\\Proveedor\\New', 'Nuevo Proveedor', 'ACT', 'FNC'),
('Controllers\\Mnt\\Proveedor\\Upd', 'Editar Proveedor', 'ACT', 'FNC'),
('Controllers\\Mnt\\Proveedor\\Dsp', 'Ver Proveedor', 'ACT', 'FNC')
ON DUPLICATE KEY UPDATE fnest = VALUES(fnest), fndsc = VALUES(fndsc), fntyp = VALUES(fntyp);

INSERT IGNORE INTO funciones_roles (rolescod, fncod, fnrolest, fnexp)
SELECT r.rolescod, f.fncod, 'ACT', DATE_ADD(NOW(), INTERVAL 365 DAY)
FROM roles r
JOIN funciones f
WHERE r.rolescod IN ('PRP', 'ADM')
  AND f.fncod IN (
    'Controllers\\Mnt\\Proveedores',
    'Controllers\\Mnt\\Proveedor',
    'Controllers\\Mnt\\Proveedor\\New',
    'Controllers\\Mnt\\Proveedor\\Upd',
    'Controllers\\Mnt\\Proveedor\\Dsp'
  );

INSERT IGNORE INTO funciones_roles (rolescod, fncod, fnrolest, fnexp)
SELECT r.rolescod, f.fncod, 'ACT', DATE_ADD(NOW(), INTERVAL 365 DAY)
FROM roles r
JOIN funciones f
WHERE r.rolescod = 'AUD'
  AND f.fncod IN (
    'Controllers\\Mnt\\Proveedores',
    'Controllers\\Mnt\\Proveedor',
    'Controllers\\Mnt\\Proveedor\\Dsp'
  );

