-- =======================================================
-- Sistema de Control de Inventarios para Microempresas
-- =======================================================

-- 1. ESTRUCTURA DE SEGURIDAD (Usuarios y Roles)
CREATE TABLE IF NOT EXISTS `usuario` (
  `usercod` bigint(10) NOT NULL AUTO_INCREMENT,
  `useremail` varchar(80) NOT NULL,
  `username` varchar(80) DEFAULT NULL,
  `userpswd` varchar(128) DEFAULT NULL,
  `userfching` datetime DEFAULT NULL,
  `userpswdest` char(3) DEFAULT NULL,
  `userpswdexp` datetime DEFAULT NULL,
  `userest` char(3) DEFAULT NULL,
  `useractcod` varchar(128) DEFAULT NULL,
  `userpswdchg` varchar(128) DEFAULT NULL,
  `usertipo` char(3) DEFAULT NULL COMMENT 'Tipo de Usuario, Normal, Consultor o Cliente',
  `userfailedattempts` int(11) DEFAULT 0,
  `userblockedat` datetime DEFAULT NULL,
  PRIMARY KEY (`usercod`),
  UNIQUE KEY `useremail_UNIQUE` (`useremail`),
  KEY `usertipo` (`usertipo`,`useremail`,`usercod`,`userest`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `roles` (
  `rolescod` varchar(15) NOT NULL,
  `rolesdsc` varchar(45) DEFAULT NULL,
  `rolesest` char(3) DEFAULT NULL,
  PRIMARY KEY (`rolescod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `roles_usuarios` (
  `usercod` bigint(10) NOT NULL,
  `rolescod` varchar(15) NOT NULL,
  `roleuserest` char(3) DEFAULT NULL,
  `roleuserfch` datetime DEFAULT NULL,
  `roleuserexp` datetime DEFAULT NULL,
  PRIMARY KEY (`usercod`,`rolescod`),
  KEY `rol_usuario_key_idx` (`rolescod`),
  CONSTRAINT `rol_usuario_key` FOREIGN KEY (`rolescod`) REFERENCES `roles` (`rolescod`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `usuario_rol_key` FOREIGN KEY (`usercod`) REFERENCES `usuario` (`usercod`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `funciones` (
  `fncod` varchar(255) NOT NULL,
  `fndsc` varchar(45) DEFAULT NULL,
  `fnest` char(3) DEFAULT NULL,
  `fntyp` char(3) DEFAULT NULL,
  PRIMARY KEY (`fncod`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `funciones_roles` (
  `rolescod` varchar(15) NOT NULL,
  `fncod` varchar(255) NOT NULL,
  `fnrolest` char(3) DEFAULT NULL,
  `fnexp` datetime DEFAULT NULL,
  PRIMARY KEY (`rolescod`,`fncod`),
  KEY `rol_funcion_key_idx` (`fncod`),
  CONSTRAINT `funcion_rol_key` FOREIGN KEY (`rolescod`) REFERENCES `roles` (`rolescod`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `rol_funcion_key` FOREIGN KEY (`fncod`) REFERENCES `funciones` (`fncod`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 2. ESTRUCTURA DE INVENTARIO, CATEGORÍAS Y PROVEEDORES
CREATE TABLE IF NOT EXISTS `categorias` (
  `catid` BIGINT(8) NOT NULL AUTO_INCREMENT,
  `catnom` VARCHAR(45) NOT NULL,
  `catest` CHAR(3) NULL DEFAULT 'ACT',
  PRIMARY KEY (`catid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `proveedores` (
  `provId` bigint(10) NOT NULL AUTO_INCREMENT,
  `provNombre` varchar(80) NOT NULL COMMENT 'Nombre o Razón Social',
  `provContacto` varchar(80) DEFAULT NULL COMMENT 'Nombre del contacto de ventas',
  `provTelefono` varchar(20) DEFAULT NULL,
  `provEmail` varchar(80) DEFAULT NULL,
  `provDireccion` text DEFAULT NULL,
  `provEst` char(3) DEFAULT 'ACT' COMMENT 'ACT=Activo, INA=Inactivo',
  PRIMARY KEY (`provId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `productos` (
  `invPrdId` bigint(13) NOT NULL AUTO_INCREMENT,
  `invPrdBrCod` varchar(128) DEFAULT NULL COMMENT 'Código de Barras',
  `invPrdCodInt` varchar(128) DEFAULT NULL COMMENT 'Código interno institucional',
  `invPrdDsc` varchar(128) NOT NULL COMMENT 'Descripción o Nombre del Producto',
  `catid` BIGINT(8) DEFAULT NULL COMMENT 'Categoría del Producto',
  `provId` bigint(10) DEFAULT NULL COMMENT 'Proveedor del Producto',
  `invPrdPrecioVenta` decimal(13,2) NOT NULL DEFAULT '0.00' COMMENT 'Precio al público',
  `invPrdCosto` decimal(13,2) NOT NULL DEFAULT '0.00' COMMENT 'Costo de adquisición',
  `invPrdStock` int(11) NOT NULL DEFAULT '0' COMMENT 'Stock Físico Consolidado',
  `invPrdStockMin` int(11) NOT NULL DEFAULT '10' COMMENT 'Umbral para Alerta de Stock Bajo',
  `invPrdTip` char(3) DEFAULT 'PRD' COMMENT 'PRD=Producto, SRV=Servicio',
  `invPrdEst` char(3) DEFAULT 'ACT' COMMENT 'ACT=Activo, INA=Inactivo/Descontinuado',
  `invPrdCreatedBy` bigint(10) DEFAULT NULL,
  `invPrdCreatedAt` datetime DEFAULT NULL,
  `invPrdModifiedBy` bigint(10) DEFAULT NULL,
  `invPrdModifiedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`invPrdId`),
  UNIQUE KEY `invPrdBrCod_UNIQUE` (`invPrdBrCod`),
  UNIQUE KEY `invPrdCodIng_UNIQUE` (`invPrdCodInt`),
  CONSTRAINT `fk_prod_cat` FOREIGN KEY (`catid`) REFERENCES `categorias` (`catid`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_prod_prov` FOREIGN KEY (`provId`) REFERENCES `proveedores` (`provId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_prod_user_crt` FOREIGN KEY (`invPrdCreatedBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL,
  CONSTRAINT `fk_prod_user_mod` FOREIGN KEY (`invPrdModifiedBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 3. TABLA DE LOTES (Soporte PEPS / Caducidad)
CREATE TABLE IF NOT EXISTS `lotes_inventario` (
  `loteId` bigint(15) NOT NULL AUTO_INCREMENT,
  `invPrdId` bigint(13) NOT NULL,
  `loteCod` varchar(50) NOT NULL COMMENT 'Identificador de lote, ej: LOTE-001 o N/A',
  `loteCantOriginal` int(11) NOT NULL,
  `loteCantActual` int(11) NOT NULL,
  `loteFechaIngreso` datetime NOT NULL,
  `loteFechaVencimiento` datetime DEFAULT NULL COMMENT 'NULL si el producto no perece (ej. Celulares)',
  `loteCostoUnitario` decimal(13,2) NOT NULL DEFAULT '0.00',
  `loteEst` char(3) DEFAULT 'ACT' COMMENT 'ACT=Activo con Stock, AGT=Agotado',
  PRIMARY KEY (`loteId`),
  CONSTRAINT `fk_lote_prod` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 4. HISTORIAL DE MOVIMIENTOS (Kardex Contable / Auditoría)
CREATE TABLE IF NOT EXISTS `movimientos_inventario` (
  `movId` bigint(15) NOT NULL AUTO_INCREMENT,
  `invPrdId` bigint(13) NOT NULL,
  `loteId` bigint(15) DEFAULT NULL COMMENT 'Lote afectado si aplica',
  `movTipo` enum('ENT', 'SAL', 'MER') NOT NULL COMMENT 'ENT=Entrada, SAL=Salida, MER=Merma/Pérdida',
  `movCantidad` int(11) NOT NULL,
  `movMotivo` varchar(255) NOT NULL COMMENT 'Razon del movimiento: Venta, Compra, Ajuste, Descomposición, etc.',
  `refTipo` varchar(50) DEFAULT NULL COMMENT 'Para facturación: ej. factura, compra, etc.',
  `refId` bigint(15) DEFAULT NULL COMMENT 'ID del documento de facturación futuro',
  `movCreatedBy` bigint(10) DEFAULT NULL,
  `movCreatedAt` datetime NOT NULL,
  PRIMARY KEY (`movId`),
  CONSTRAINT `fk_mov_prod` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE,
  CONSTRAINT `fk_mov_lote` FOREIGN KEY (`loteId`) REFERENCES `lotes_inventario` (`loteId`) ON DELETE SET NULL,
  CONSTRAINT `fk_mov_user` FOREIGN KEY (`movCreatedBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 5. INSERCIONES DE PRUEBA INICIALES (Semillas / Seeds)
-- Roles
INSERT INTO `roles` (`rolescod`, `rolesdsc`, `rolesest`) VALUES
('PRP', 'Propietario / SuperUser', 'ACT'),
('ADM', 'Administrador / Empleado', 'ACT'),
('AUD', 'Auditor de Solo Lectura', 'ACT');

-- Categorías básicas
INSERT INTO `categorias` (`catnom`, `catest`) VALUES
('Bebidas', 'ACT'),
('Comestibles', 'ACT'),
('Limpieza', 'ACT'),
('Tecnología', 'ACT');

-- Usuarios Iniciales (Contraseña de prueba por defecto: "Test1234$")
-- El hash corresponde al algoritmo bcrypt de PHP
INSERT INTO `usuario` (`useremail`, `username`, `userpswd`, `userfching`, `userpswdest`, `userpswdexp`, `userest`, `usertipo`) VALUES
('propietario@inventario.com', 'Don Cleto (Propietario)', '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS', NOW(), 'ACT', DATE_ADD(NOW(), INTERVAL 90 DAY), 'ACT', 'PRP'),
('empleado@inventario.com', 'Juan Perez (Administrador)', '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS', NOW(), 'ACT', DATE_ADD(NOW(), INTERVAL 90 DAY), 'ACT', 'ADM'),
('auditor@inventario.com', 'Lic. Martinez (Auditor)', '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS', NOW(), 'ACT', DATE_ADD(NOW(), INTERVAL 90 DAY), 'ACT', 'AUD');


-- Asignación de Roles
INSERT INTO `roles_usuarios` (`usercod`, `rolescod`, `roleuserest`, `roleuserfch`, `roleuserexp`) VALUES
(1, 'PRP', 'ACT', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY)),
(2, 'ADM', 'ACT', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY)),
(3, 'AUD', 'ACT', NOW(), DATE_ADD(NOW(), INTERVAL 365 DAY));


-- 6. PERMISOS Y FUNCIONES POR ROL
-- Catálogo de Funciones
INSERT INTO `funciones` (`fncod`, `fndsc`, `fnest`, `fntyp`) VALUES
('Controllers\\Admin\\Admin', 'Dashboard Principal', 'ACT', 'CTR'),
('Controllers\\Mnt\\Productos', 'Listado de Productos', 'ACT', 'CTR'),
('Controllers\\Mnt\\Producto', 'Formulario de Producto', 'ACT', 'CTR'),
('Controllers\\Mnt\\Producto\\New', 'Crear Producto', 'ACT', 'CTR'),
('Controllers\\Mnt\\Producto\\Upd', 'Editar Producto', 'ACT', 'CTR'),
('Controllers\\Mnt\\Producto\\Dsp', 'Ver Producto', 'ACT', 'CTR'),
('Controllers\\Mnt\\Categorias', 'Listado de Categorías', 'ACT', 'CTR'),
('Controllers\\Mnt\\Categoria', 'Formulario de Categoría', 'ACT', 'CTR'),
('Controllers\\Mnt\\Categoria\\New', 'Crear Categoría', 'ACT', 'CTR'),
('Controllers\\Mnt\\Categoria\\Upd', 'Editar Categoría', 'ACT', 'CTR'),
('Controllers\\Mnt\\Categoria\\Dsp', 'Ver Categoría', 'ACT', 'CTR'),
('Controllers\\Mnt\\Kardex', 'Historial Kardex', 'ACT', 'CTR'),
('Controllers\\Sec\\Perfil', 'Perfil de Usuario', 'ACT', 'CTR'),
('Controllers\\Mnt\\Proveedores', 'Listado de Proveedores', 'ACT', 'CTR'),
('Controllers\\Mnt\\Proveedor', 'Formulario de Proveedor', 'ACT', 'CTR'),
('Controllers\\Mnt\\Proveedor\\New', 'Crear Proveedor', 'ACT', 'CTR'),
('Controllers\\Mnt\\Proveedor\\Upd', 'Editar Proveedor', 'ACT', 'CTR'),
('Controllers\\Mnt\\Proveedor\\Dsp', 'Ver Proveedor', 'ACT', 'CTR');

-- Permisos del Administrador / Empleado (ADM)
INSERT INTO `funciones_roles` (`rolescod`, `fncod`, `fnrolest`, `fnexp`) VALUES
('ADM', 'Controllers\\Admin\\Admin', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Productos', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Producto', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Producto\\New', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Producto\\Upd', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Producto\\Dsp', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Categorias', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Categoria', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Categoria\\New', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Categoria\\Upd', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Categoria\\Dsp', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Kardex', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Sec\\Perfil', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Proveedores', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Proveedor', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Proveedor\\New', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Proveedor\\Upd', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\Mnt\\Proveedor\\Dsp', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR));

-- Permisos del Auditor de Solo Lectura (AUD)
INSERT INTO `funciones_roles` (`rolescod`, `fncod`, `fnrolest`, `fnexp`) VALUES
('AUD', 'Controllers\\Admin\\Admin', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Productos', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Producto', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Producto\\Dsp', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Categorias', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Categoria', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Categoria\\Dsp', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Kardex', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Sec\\Perfil', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Proveedores', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Proveedor', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\Mnt\\Proveedor\\Dsp', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR));
