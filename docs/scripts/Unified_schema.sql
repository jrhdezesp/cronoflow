-- =======================================================
-- CronoFlow - Script Unificado de Base de Datos
-- Consolidación de los scripts SQL del proyecto
-- =======================================================

CREATE DATABASE IF NOT EXISTS `proyecto_inventario` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

USE `proyecto_inventario`;

-- =======================================================
-- 1. SEGURIDAD (Usuarios, Roles, Permisos, Bitácora)
-- =======================================================

CREATE TABLE IF NOT EXISTS `usuario` (
    `usercod` BIGINT(10) NOT NULL AUTO_INCREMENT,
    `useremail` VARCHAR(80) NOT NULL,
    `username` VARCHAR(80) DEFAULT NULL,
    `userpswd` VARCHAR(128) DEFAULT NULL,
    `userfching` DATETIME DEFAULT NULL,
    `userpswdest` CHAR(3) DEFAULT NULL,
    `userpswdexp` DATETIME DEFAULT NULL,
    `userest` CHAR(3) DEFAULT NULL,
    `useractcod` VARCHAR(128) DEFAULT NULL,
    `userpswdchg` VARCHAR(128) DEFAULT NULL,
    `usertipo` CHAR(3) DEFAULT NULL COMMENT 'PRP=Propietario, ADM=Admin, AUD=Auditor, PBL=Público',
    `userfailedattempts` INT(11) DEFAULT 0,
    `userblockedat` DATETIME DEFAULT NULL,
    PRIMARY KEY (`usercod`),
    UNIQUE KEY `useremail_UNIQUE` (`useremail`),
    KEY `usertipo` (
        `usertipo`,
        `useremail`,
        `usercod`,
        `userest`
    )
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `roles` (
    `rolescod` VARCHAR(15) NOT NULL,
    `rolesdsc` VARCHAR(45) DEFAULT NULL,
    `rolesest` CHAR(3) DEFAULT NULL,
    PRIMARY KEY (`rolescod`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `roles_usuarios` (
    `usercod` BIGINT(10) NOT NULL,
    `rolescod` VARCHAR(15) NOT NULL,
    `roleuserest` CHAR(3) DEFAULT NULL,
    `roleuserfch` DATETIME DEFAULT NULL,
    `roleuserexp` DATETIME DEFAULT NULL,
    PRIMARY KEY (`usercod`, `rolescod`),
    KEY `rol_usuario_key_idx` (`rolescod`),
    CONSTRAINT `rol_usuario_key` FOREIGN KEY (`rolescod`) REFERENCES `roles` (`rolescod`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `usuario_rol_key` FOREIGN KEY (`usercod`) REFERENCES `usuario` (`usercod`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `funciones` (
    `fncod` VARCHAR(255) NOT NULL,
    `fndsc` VARCHAR(45) DEFAULT NULL,
    `fnest` CHAR(3) DEFAULT NULL,
    `fntyp` CHAR(3) DEFAULT NULL,
    PRIMARY KEY (`fncod`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `funciones_roles` (
    `rolescod` VARCHAR(15) NOT NULL,
    `fncod` VARCHAR(255) NOT NULL,
    `fnrolest` CHAR(3) DEFAULT NULL,
    `fnexp` DATETIME DEFAULT NULL,
    PRIMARY KEY (`rolescod`, `fncod`),
    KEY `rol_funcion_key_idx` (`fncod`),
    CONSTRAINT `funcion_rol_key` FOREIGN KEY (`rolescod`) REFERENCES `roles` (`rolescod`) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `rol_funcion_key` FOREIGN KEY (`fncod`) REFERENCES `funciones` (`fncod`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `bitacora` (
    `bitacoracod` INT(11) NOT NULL AUTO_INCREMENT,
    `bitacorafch` DATETIME DEFAULT NULL,
    `bitprograma` VARCHAR(255) DEFAULT NULL,
    `bitdescripcion` VARCHAR(255) DEFAULT NULL,
    `bitobservacion` MEDIUMTEXT DEFAULT NULL,
    `bitTipo` CHAR(3) DEFAULT NULL,
    `bitusuario` BIGINT(18) DEFAULT NULL,
    PRIMARY KEY (`bitacoracod`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

-- =======================================================
-- 2. CATÁLOGOS: Categorías y Proveedores
-- =======================================================

CREATE TABLE IF NOT EXISTS `categorias` (
    `catid` BIGINT(8) NOT NULL AUTO_INCREMENT,
    `catnom` VARCHAR(45) NOT NULL,
    `catest` CHAR(3) DEFAULT 'ACT',
    PRIMARY KEY (`catid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `proveedores` (
    `provId` BIGINT(10) NOT NULL AUTO_INCREMENT,
    `provNombre` VARCHAR(100) NOT NULL COMMENT 'Nombre o Razón Social',
    `provContacto` VARCHAR(100) DEFAULT NULL COMMENT 'Nombre del contacto de ventas',
    `provTelefono` VARCHAR(20) DEFAULT NULL,
    `provEmail` VARCHAR(80) DEFAULT NULL,
    `provDireccion` TEXT DEFAULT NULL,
    `provEst` CHAR(3) DEFAULT 'ACT' COMMENT 'ACT=Activo, INA=Inactivo',
    PRIMARY KEY (`provId`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

-- =======================================================
-- 3. INVENTARIO: Productos, Lotes y Kardex
-- =======================================================

CREATE TABLE IF NOT EXISTS `productos` (
    `invPrdId` BIGINT(13) NOT NULL AUTO_INCREMENT,
    `invPrdBrCod` VARCHAR(128) DEFAULT NULL COMMENT 'Código de Barras',
    `invPrdCodInt` VARCHAR(128) DEFAULT NULL COMMENT 'Código interno institucional',
    `invPrdDsc` VARCHAR(128) NOT NULL COMMENT 'Descripción o Nombre del Producto',
    `catid` BIGINT(8) DEFAULT NULL COMMENT 'Categoría del Producto',
    `provId` BIGINT(10) DEFAULT NULL COMMENT 'Proveedor del Producto',
    `invPrdPrecioVenta` DECIMAL(13, 2) NOT NULL DEFAULT 0.00 COMMENT 'Precio al público',
    `invPrdCosto` DECIMAL(13, 2) NOT NULL DEFAULT 0.00 COMMENT 'Costo de adquisición',
    `invPrdStock` INT(11) NOT NULL DEFAULT 0 COMMENT 'Stock Físico Consolidado',
    `invPrdStockMin` INT(11) NOT NULL DEFAULT 10 COMMENT 'Umbral para Alerta de Stock Bajo',
    `invPrdTip` CHAR(3) DEFAULT 'PRD' COMMENT 'PRD=Producto, SRV=Servicio',
    `invPrdEst` CHAR(3) DEFAULT 'ACT' COMMENT 'ACT=Activo, INA=Inactivo/Descontinuado',
    `invPrdCreatedBy` BIGINT(10) DEFAULT NULL,
    `invPrdCreatedAt` DATETIME DEFAULT NULL,
    `invPrdModifiedBy` BIGINT(10) DEFAULT NULL,
    `invPrdModifiedAt` DATETIME DEFAULT NULL,
    PRIMARY KEY (`invPrdId`),
    UNIQUE KEY `invPrdBrCod_UNIQUE` (`invPrdBrCod`),
    UNIQUE KEY `invPrdCodInt_UNIQUE` (`invPrdCodInt`),
    CONSTRAINT `fk_prod_cat` FOREIGN KEY (`catid`) REFERENCES `categorias` (`catid`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_prod_prov` FOREIGN KEY (`provId`) REFERENCES `proveedores` (`provId`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_prod_user_crt` FOREIGN KEY (`invPrdCreatedBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL,
    CONSTRAINT `fk_prod_user_mod` FOREIGN KEY (`invPrdModifiedBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `lotes_inventario` (
    `loteId` BIGINT(15) NOT NULL AUTO_INCREMENT,
    `invPrdId` BIGINT(13) NOT NULL,
    `loteCod` VARCHAR(50) NOT NULL COMMENT 'Identificador de lote',
    `loteCantOriginal` INT(11) NOT NULL,
    `loteCantActual` INT(11) NOT NULL,
    `loteFechaIngreso` DATETIME NOT NULL,
    `loteFechaVencimiento` DATETIME DEFAULT NULL COMMENT 'NULL si el producto no perece',
    `loteCostoUnitario` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `loteEst` CHAR(3) DEFAULT 'ACT' COMMENT 'ACT=Activo, AGT=Agotado',
    PRIMARY KEY (`loteId`),
    CONSTRAINT `fk_lote_prod` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `movimientos_inventario` (
    `movId` BIGINT(15) NOT NULL AUTO_INCREMENT,
    `invPrdId` BIGINT(13) NOT NULL,
    `loteId` BIGINT(15) DEFAULT NULL COMMENT 'Lote afectado si aplica',
    `movTipo` ENUM('ENT', 'SAL', 'MER') NOT NULL COMMENT 'ENT=Entrada, SAL=Salida, MER=Merma',
    `movCantidad` INT(11) NOT NULL,
    `movMotivo` VARCHAR(255) NOT NULL COMMENT 'Razón del movimiento',
    `refTipo` VARCHAR(50) DEFAULT NULL COMMENT 'Para facturación futura',
    `refId` BIGINT(15) DEFAULT NULL COMMENT 'ID del documento de facturación',
    `movCreatedBy` BIGINT(10) DEFAULT NULL,
    `movCreatedAt` DATETIME NOT NULL,
    PRIMARY KEY (`movId`),
    CONSTRAINT `fk_mov_prod` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE,
    CONSTRAINT `fk_mov_lote` FOREIGN KEY (`loteId`) REFERENCES `lotes_inventario` (`loteId`) ON DELETE SET NULL,
    CONSTRAINT `fk_mov_user` FOREIGN KEY (`movCreatedBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `batches` (
    `batchId` BIGINT(15) NOT NULL AUTO_INCREMENT,
    `invPrdId` BIGINT(13) NOT NULL,
    `batchCode` VARCHAR(50) NOT NULL COMMENT 'Código del lote o batch',
    `batchQuantityOriginal` INT(11) NOT NULL DEFAULT 0 COMMENT 'Cantidad original del lote',
    `batchQuantityAvailable` INT(11) NOT NULL DEFAULT 0 COMMENT 'Cantidad disponible para consumo',
    `batchQuantityReserved` INT(11) NOT NULL DEFAULT 0 COMMENT 'Cantidad reservada para ventas u órdenes',
    `batchFechaIngreso` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `batchFechaVencimiento` DATETIME DEFAULT NULL COMMENT 'NULL si no es perecedero',
    `batchCostoUnitario` DECIMAL(13, 2) NOT NULL DEFAULT 0.00 COMMENT 'Costo de adquisición por unidad',
    `batchStatus` CHAR(3) NOT NULL DEFAULT 'ACT' COMMENT 'ACT=Activo, AGT=Agotado, CAN=Cancelado',
    `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`batchId`),
    UNIQUE KEY `idx_batches_prd_code` (`invPrdId`, `batchCode`),
    CONSTRAINT `fk_batches_product` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (`batchQuantityOriginal` >= 0),
    CHECK (`batchQuantityAvailable` >= 0),
    CHECK (`batchQuantityReserved` >= 0),
    CHECK (
        `batchQuantityAvailable` + `batchQuantityReserved` <= `batchQuantityOriginal`
    )
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `stock_movements` (
    `movementId` BIGINT(15) NOT NULL AUTO_INCREMENT,
    `invPrdId` BIGINT(13) NOT NULL,
    `batchId` BIGINT(15) DEFAULT NULL,
    `movementType` ENUM(
        'ENT',
        'SAL',
        'MER',
        'RES',
        'CON'
    ) NOT NULL COMMENT 'ENT=Entrada, SAL=Salida, MER=Merma, RES=Reserva, CON=Consumo',
    `quantity` INT(11) NOT NULL,
    `reason` VARCHAR(255) NOT NULL,
    `referenceType` VARCHAR(50) DEFAULT NULL,
    `referenceId` BIGINT(15) DEFAULT NULL,
    `createdBy` BIGINT(10) DEFAULT NULL,
    `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`movementId`),
    CONSTRAINT `fk_stock_mov_prod` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE,
    CONSTRAINT `fk_stock_mov_batch` FOREIGN KEY (`batchId`) REFERENCES `batches` (`batchId`) ON DELETE SET NULL,
    CONSTRAINT `fk_stock_mov_user` FOREIGN KEY (`createdBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL,
    CHECK (`quantity` >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

-- =======================================================
-- 4. POS / VENTAS
-- =======================================================

CREATE TABLE IF NOT EXISTS `clientes` (
    `clienteId` BIGINT(10) NOT NULL AUTO_INCREMENT,
    `clienteNombre` VARCHAR(128) NOT NULL,
    `clienteTelefono` VARCHAR(20) DEFAULT NULL,
    `clienteEmail` VARCHAR(80) DEFAULT NULL,
    `clienteDireccion` TEXT DEFAULT NULL,
    `clienteEst` CHAR(3) DEFAULT 'ACT',
    `clienteCreatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`clienteId`),
    KEY `idx_cliente_nombre` (`clienteNombre`),
    KEY `idx_cliente_telefono` (`clienteTelefono`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `caja_sesion` (
    `cajaSesionId` BIGINT(10) NOT NULL AUTO_INCREMENT,
    `usercod` BIGINT(10) NOT NULL,
    `cajaMontoInicial` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `cajaApertura` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `cajaCierre` DATETIME DEFAULT NULL,
    `cajaMontoFinal` DECIMAL(13, 2) DEFAULT NULL,
    `cajaTotalVentas` DECIMAL(13, 2) DEFAULT 0.00,
    `cajaCantVentas` INT(11) DEFAULT 0,
    `cajaEst` CHAR(3) DEFAULT 'ABI' COMMENT 'ABI=Abierta, CER=Cerrada',
    `cajaObservaciones` TEXT DEFAULT NULL,
    PRIMARY KEY (`cajaSesionId`),
    KEY `idx_caja_usuario` (`usercod`),
    KEY `idx_caja_estado` (`cajaEst`),
    CONSTRAINT `fk_caja_usuario` FOREIGN KEY (`usercod`) REFERENCES `usuario` (`usercod`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `ventas` (
    `ventaId` BIGINT(15) NOT NULL AUTO_INCREMENT,
    `ventaCod` VARCHAR(20) NOT NULL COMMENT 'Código legible ej. VENTA-00001',
    `clienteId` BIGINT(10) DEFAULT NULL,
    `usercod` BIGINT(10) NOT NULL,
    `cajaSesionId` BIGINT(10) DEFAULT NULL,
    `ventaSubtotal` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `ventaDescuento` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `ventaTotal` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `ventaPagoRecibido` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `ventaCambio` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `ventaFormaPago` CHAR(3) DEFAULT 'EFE' COMMENT 'EFE=Efectivo, TAR=Tarjeta, MIX=Mixto',
    `ventaEst` CHAR(3) DEFAULT 'ACT' COMMENT 'ACT=Activa, ANU=Anulada',
    `ventaCreatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ventaAnuladaAt` DATETIME DEFAULT NULL,
    `ventaAnuladaBy` BIGINT(10) DEFAULT NULL,
    `ventaMotivoAnulacion` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`ventaId`),
    UNIQUE KEY `ventaCod_UNIQUE` (`ventaCod`),
    KEY `idx_venta_cliente` (`clienteId`),
    KEY `idx_venta_usuario` (`usercod`),
    KEY `idx_venta_caja` (`cajaSesionId`),
    KEY `idx_venta_fecha` (`ventaCreatedAt`),
    CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`clienteId`) REFERENCES `clientes` (`clienteId`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_venta_usuario` FOREIGN KEY (`usercod`) REFERENCES `usuario` (`usercod`) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT `fk_venta_caja` FOREIGN KEY (`cajaSesionId`) REFERENCES `caja_sesion` (`cajaSesionId`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `ventas_detalle` (
    `ventaDetId` BIGINT(15) NOT NULL AUTO_INCREMENT,
    `ventaId` BIGINT(15) NOT NULL,
    `invPrdId` BIGINT(13) NOT NULL,
    `loteId` BIGINT(15) DEFAULT NULL,
    `ventaDetCantidad` INT(11) NOT NULL,
    `ventaDetPrecioUnitario` DECIMAL(13, 2) NOT NULL,
    `ventaDetSubtotal` DECIMAL(13, 2) NOT NULL,
    PRIMARY KEY (`ventaDetId`),
    KEY `idx_detalle_venta` (`ventaId`),
    KEY `idx_detalle_producto` (`invPrdId`),
    CONSTRAINT `fk_detalle_venta` FOREIGN KEY (`ventaId`) REFERENCES `ventas` (`ventaId`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_detalle_producto` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT `fk_detalle_lote` FOREIGN KEY (`loteId`) REFERENCES `lotes_inventario` (`loteId`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

-- =======================================================
-- 5. SEEDS / DATOS INICIALES
-- =======================================================

INSERT INTO
    `roles` (
        `rolescod`,
        `rolesdsc`,
        `rolesest`
    )
VALUES (
        'PRP',
        'Propietario / SuperUser',
        'ACT'
    ),
    (
        'ADM',
        'Administrador / Empleado',
        'ACT'
    ),
    (
        'AUD',
        'Auditor de Solo Lectura',
        'ACT'
    )
ON DUPLICATE KEY UPDATE
    `rolesdsc` = VALUES(`rolesdsc`),
    `rolesest` = VALUES(`rolesest`);

INSERT INTO
    `categorias` (`catnom`, `catest`)
VALUES ('Bebidas', 'ACT'),
    ('Comestibles', 'ACT'),
    ('Limpieza', 'ACT'),
    ('Tecnología', 'ACT')
ON DUPLICATE KEY UPDATE
    `catest` = VALUES(`catest`);

INSERT INTO
    `usuario` (
        `useremail`,
        `username`,
        `userpswd`,
        `userfching`,
        `userpswdest`,
        `userpswdexp`,
        `userest`,
        `usertipo`
    )
VALUES (
        'propietario@inventario.com',
        'Don Cleto (Propietario)',
        '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS',
        NOW(),
        'ACT',
        DATE_ADD(NOW(), INTERVAL 90 DAY),
        'ACT',
        'PRP'
    ),
    (
        'empleado@inventario.com',
        'Juan Perez (Administrador)',
        '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS',
        NOW(),
        'ACT',
        DATE_ADD(NOW(), INTERVAL 90 DAY),
        'ACT',
        'ADM'
    ),
    (
        'auditor@inventario.com',
        'Lic. Martinez (Auditor)',
        '$2y$10$D9zLFYya/6qqHDmlecH5SuSNXUps1YojHLDOtq97Cg8rpjtWmbhIS',
        NOW(),
        'ACT',
        DATE_ADD(NOW(), INTERVAL 90 DAY),
        'ACT',
        'AUD'
    )
ON DUPLICATE KEY UPDATE
    `username` = VALUES(`username`),
    `userpswd` = VALUES(`userpswd`),
    `usertipo` = VALUES(`usertipo`);

INSERT INTO
    `roles_usuarios` (
        `usercod`,
        `rolescod`,
        `roleuserest`,
        `roleuserfch`,
        `roleuserexp`
    )
VALUES (
        1,
        'PRP',
        'ACT',
        NOW(),
        DATE_ADD(NOW(), INTERVAL 365 DAY)
    ),
    (
        2,
        'ADM',
        'ACT',
        NOW(),
        DATE_ADD(NOW(), INTERVAL 365 DAY)
    ),
    (
        3,
        'AUD',
        'ACT',
        NOW(),
        DATE_ADD(NOW(), INTERVAL 365 DAY)
    )
ON DUPLICATE KEY UPDATE
    `roleuserest` = VALUES(`roleuserest`);

INSERT INTO
    `funciones` (
        `fncod`,
        `fndsc`,
        `fnest`,
        `fntyp`
    )
VALUES (
        'Controllers\\Admin\\Admin',
        'Dashboard Principal',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Productos',
        'Listado de Productos',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Producto',
        'Formulario de Producto',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Producto\\New',
        'Crear Producto',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Producto\\Upd',
        'Editar Producto',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Producto\\Dsp',
        'Ver Producto',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Categorias',
        'Listado de Categorías',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Categoria',
        'Formulario de Categoría',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Categoria\\New',
        'Crear Categoría',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Categoria\\Upd',
        'Editar Categoría',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Categoria\\Dsp',
        'Ver Categoría',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Kardex',
        'Historial Kardex',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Sec\\Perfil',
        'Perfil de Usuario',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Clientes',
        'Listado de Clientes',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Ventas',
        'Listado de Ventas',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Proveedores',
        'Listado de Proveedores',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Proveedor',
        'Formulario de Proveedor',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Proveedor\\New',
        'Crear Proveedor',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Proveedor\\Upd',
        'Editar Proveedor',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\Mnt\\Proveedor\\Dsp',
        'Ver Proveedor',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\POS',
        'Módulo Punto de Venta (POS)',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\POS\\OpenSession',
        'Abrir Sesión de Caja',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\POS\\CloseSession',
        'Cerrar Sesión de Caja',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\POS\\ProcessSale',
        'Procesar Venta',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\POS\\AnulateSale',
        'Anular Venta',
        'ACT',
        'CTR'
    ),
    (
        'Controllers\\POS\\History',
        'Ver Historial de Ventas',
        'ACT',
        'CTR'
    )
ON DUPLICATE KEY UPDATE
    `fndsc` = VALUES(`fndsc`),
    `fnest` = VALUES(`fnest`),
    `fntyp` = VALUES(`fntyp`);

INSERT INTO
    `funciones_roles` (
        `rolescod`,
        `fncod`,
        `fnrolest`,
        `fnexp`
    )
VALUES (
        'ADM',
        'Controllers\\Admin\\Admin',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Productos',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Producto',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Producto\\New',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Producto\\Upd',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Producto\\Dsp',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Categorias',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Categoria',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Categoria\\New',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Categoria\\Upd',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Categoria\\Dsp',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Kardex',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Sec\\Perfil',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Clientes',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Ventas',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Proveedores',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Proveedor',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Proveedor\\New',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Proveedor\\Upd',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\Mnt\\Proveedor\\Dsp',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\POS',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\POS\\OpenSession',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\POS\\CloseSession',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\POS\\ProcessSale',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\POS\\AnulateSale',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'ADM',
        'Controllers\\POS\\History',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Admin\\Admin',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Productos',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Producto',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Producto\\Dsp',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Categorias',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Categoria',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Categoria\\Dsp',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Kardex',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Sec\\Perfil',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Proveedores',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Proveedor',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\Mnt\\Proveedor\\Dsp',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\POS',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    ),
    (
        'AUD',
        'Controllers\\POS\\History',
        'ACT',
        DATE_ADD(NOW(), INTERVAL 1 YEAR)
    )
ON DUPLICATE KEY UPDATE
    `fnrolest` = VALUES(`fnrolest`),
    `fnexp` = VALUES(`fnexp`);

INSERT INTO
    `funciones_roles` (
        `rolescod`,
        `fncod`,
        `fnrolest`,
        `fnexp`
    )
SELECT
    'PRP',
    `fncod`,
    'ACT',
    DATE_ADD(NOW(), INTERVAL 1 YEAR)
FROM
    `funciones`
WHERE
    `fnest` = 'ACT'
ON DUPLICATE KEY UPDATE
    `fnrolest` = VALUES(`fnrolest`),
    `fnexp` = VALUES(`fnexp`);

INSERT INTO
    `clientes` (
        `clienteNombre`,
        `clienteTelefono`,
        `clienteEst`
    )
VALUES (
        'Consumidor Final (Mostrador)',
        'N/A',
        'ACT'
    )
ON DUPLICATE KEY UPDATE
    `clienteEst` = VALUES(`clienteEst`);

INSERT INTO
    `proveedores` (
        `provNombre`,
        `provContacto`,
        `provTelefono`,
        `provEmail`,
        `provDireccion`,
        `provEst`
    )
VALUES (
        'Distribuidora El Buen Stock',
        'María González',
        '502-1234-5678',
        'ventas@elbuenstock.com',
        'Avenida Central 123, Ciudad',
        'ACT'
    ),
    (
        'Logística Fresca S.A.',
        'Carlos Méndez',
        '502-2345-6789',
        'contacto@logisticafresca.com',
        'Boulevard Industrial 45, Ciudad',
        'ACT'
    ),
    (
        'Suministros Delta',
        'Ana Ruiz',
        '502-3456-7890',
        'delta@suministros.com',
        'Calle de la Industria 78, Ciudad',
        'ACT'
    )
ON DUPLICATE KEY UPDATE
    `provContacto` = VALUES(`provContacto`),
    `provEst` = VALUES(`provEst`);

INSERT INTO
    `productos` (
        `invPrdBrCod`,
        `invPrdCodInt`,
        `invPrdDsc`,
        `catid`,
        `provId`,
        `invPrdPrecioVenta`,
        `invPrdCosto`,
        `invPrdStock`,
        `invPrdStockMin`,
        `invPrdTip`,
        `invPrdEst`,
        `invPrdCreatedBy`,
        `invPrdCreatedAt`,
        `invPrdModifiedBy`,
        `invPrdModifiedAt`
    )
VALUES (
        '7501000000012',
        'PROD-001',
        'Agua Mineral 600ml',
        1,
        1,
        5.50,
        3.20,
        120,
        20,
        'PRD',
        'ACT',
        1,
        NOW(),
        1,
        NOW()
    ),
    (
        '7501000000029',
        'PROD-002',
        'Gaseosa Cola 2L',
        1,
        1,
        18.00,
        10.50,
        80,
        15,
        'PRD',
        'ACT',
        1,
        NOW(),
        1,
        NOW()
    ),
    (
        '7501000000036',
        'PROD-003',
        'Pan de Caja Integral 680g',
        2,
        2,
        22.00,
        12.00,
        60,
        10,
        'PRD',
        'ACT',
        1,
        NOW(),
        1,
        NOW()
    ),
    (
        '7501000000043',
        'PROD-004',
        'Detergente Líquido 1L',
        3,
        3,
        35.00,
        18.00,
        50,
        10,
        'PRD',
        'ACT',
        1,
        NOW(),
        1,
        NOW()
    ),
    (
        '7501000000050',
        'PROD-005',
        'Shampoo Hidratante 400ml',
        3,
        3,
        48.00,
        28.00,
        40,
        8,
        'PRD',
        'ACT',
        1,
        NOW(),
        1,
        NOW()
    ),
    (
        '7501000000067',
        'PROD-006',
        'Café Molido 250g',
        4,
        2,
        32.00,
        18.00,
        70,
        12,
        'PRD',
        'ACT',
        1,
        NOW(),
        1,
        NOW()
    )
ON DUPLICATE KEY UPDATE
    `invPrdDsc` = VALUES(`invPrdDsc`),
    `invPrdPrecioVenta` = VALUES(`invPrdPrecioVenta`),
    `invPrdCosto` = VALUES(`invPrdCosto`),
    `invPrdStock` = VALUES(`invPrdStock`);

INSERT INTO
    `lotes_inventario` (
        `invPrdId`,
        `loteCod`,
        `loteCantOriginal`,
        `loteCantActual`,
        `loteFechaIngreso`,
        `loteFechaVencimiento`,
        `loteCostoUnitario`,
        `loteEst`
    )
VALUES (
        1,
        'L001-AGUA',
        120,
        120,
        NOW(),
        NULL,
        3.20,
        'ACT'
    ),
    (
        2,
        'L001-COLA',
        80,
        80,
        NOW(),
        NULL,
        10.50,
        'ACT'
    ),
    (
        3,
        'L001-PAN',
        60,
        60,
        NOW(),
        DATE_ADD(NOW(), INTERVAL 15 DAY),
        12.00,
        'ACT'
    ),
    (
        4,
        'L001-DETER',
        50,
        50,
        NOW(),
        NULL,
        18.00,
        'ACT'
    ),
    (
        5,
        'L001-SHAM',
        40,
        40,
        NOW(),
        NULL,
        28.00,
        'ACT'
    ),
    (
        6,
        'L001-CAFE',
        70,
        70,
        NOW(),
        NULL,
        18.00,
        'ACT'
    )
ON DUPLICATE KEY UPDATE
    `loteCantActual` = VALUES(`loteCantActual`),
    `loteEst` = VALUES(`loteEst`);

INSERT INTO
    `batches` (
        `invPrdId`,
        `batchCode`,
        `batchQuantityOriginal`,
        `batchQuantityAvailable`,
        `batchQuantityReserved`,
        `batchFechaIngreso`,
        `batchFechaVencimiento`,
        `batchCostoUnitario`,
        `batchStatus`,
        `createdAt`,
        `updatedAt`
    )
VALUES (
        1,
        'BATCH-AGUA-01',
        120,
        120,
        0,
        NOW(),
        NULL,
        3.20,
        'ACT',
        NOW(),
        NOW()
    ),
    (
        2,
        'BATCH-COLA-01',
        80,
        80,
        0,
        NOW(),
        NULL,
        10.50,
        'ACT',
        NOW(),
        NOW()
    ),
    (
        3,
        'BATCH-PAN-01',
        60,
        60,
        0,
        NOW(),
        DATE_ADD(NOW(), INTERVAL 15 DAY),
        12.00,
        'ACT',
        NOW(),
        NOW()
    ),
    (
        4,
        'BATCH-DETER-01',
        50,
        50,
        0,
        NOW(),
        NULL,
        18.00,
        'ACT',
        NOW(),
        NOW()
    ),
    (
        5,
        'BATCH-SHAM-01',
        40,
        40,
        0,
        NOW(),
        NULL,
        28.00,
        'ACT',
        NOW(),
        NOW()
    ),
    (
        6,
        'BATCH-CAFE-01',
        70,
        70,
        0,
        NOW(),
        NULL,
        18.00,
        'ACT',
        NOW(),
        NOW()
    )
ON DUPLICATE KEY UPDATE
    `batchQuantityAvailable` = VALUES(`batchQuantityAvailable`);

INSERT INTO
    `movimientos_inventario` (
        `invPrdId`,
        `loteId`,
        `movTipo`,
        `movCantidad`,
        `movMotivo`,
        `refTipo`,
        `refId`,
        `movCreatedBy`,
        `movCreatedAt`
    )
VALUES (
        1,
        1,
        'ENT',
        120,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        2,
        2,
        'ENT',
        80,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        3,
        3,
        'ENT',
        60,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        4,
        4,
        'ENT',
        50,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        5,
        5,
        'ENT',
        40,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        6,
        6,
        'ENT',
        70,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    )
ON DUPLICATE KEY UPDATE
    `movCantidad` = VALUES(`movCantidad`);

INSERT INTO
    `stock_movements` (
        `invPrdId`,
        `batchId`,
        `movementType`,
        `quantity`,
        `reason`,
        `referenceType`,
        `referenceId`,
        `createdBy`,
        `createdAt`
    )
VALUES (
        1,
        1,
        'ENT',
        120,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        2,
        2,
        'ENT',
        80,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        3,
        3,
        'ENT',
        60,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        4,
        4,
        'ENT',
        50,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        5,
        5,
        'ENT',
        40,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    ),
    (
        6,
        6,
        'ENT',
        70,
        'Inventario inicial',
        'INIT',
        NULL,
        1,
        NOW()
    )
ON DUPLICATE KEY UPDATE
    `quantity` = VALUES(`quantity`);

-- =======================================================
-- 6. VISTAS DE REPORTES
-- =======================================================

CREATE OR REPLACE VIEW `reporte_ventas_diarias` AS
SELECT
    DATE(v.ventaCreatedAt) AS fecha,
    COUNT(v.ventaId) AS total_ventas,
    SUM(v.ventaTotal) AS monto_total,
    AVG(v.ventaTotal) AS monto_promedio,
    MIN(v.ventaTotal) AS monto_minimo,
    MAX(v.ventaTotal) AS monto_maximo,
    v.ventaFormaPago
FROM `ventas` v
WHERE
    v.ventaEst = 'ACT'
GROUP BY
    DATE(v.ventaCreatedAt),
    v.ventaFormaPago
ORDER BY DATE(v.ventaCreatedAt) DESC;

CREATE OR REPLACE VIEW `reporte_productos_vendidos` AS
SELECT
    p.invPrdId,
    p.invPrdDsc,
    p.invPrdBrCod,
    SUM(vd.ventaDetCantidad) AS total_vendido,
    SUM(vd.ventaDetSubtotal) AS ingresos_totales,
    AVG(vd.ventaDetPrecioUnitario) AS precio_promedio,
    COUNT(DISTINCT vd.ventaId) AS numero_ventas
FROM
    `ventas_detalle` vd
    INNER JOIN `productos` p ON vd.invPrdId = p.invPrdId
    INNER JOIN `ventas` v ON vd.ventaId = v.ventaId
WHERE
    v.ventaEst = 'ACT'
GROUP BY
    p.invPrdId,
    p.invPrdDsc,
    p.invPrdBrCod
ORDER BY total_vendido DESC;