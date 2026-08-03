-- =======================================================
-- Módulo POS (Punto de Venta) - Sistema de Inventario
-- =======================================================

-- 1. TABLA DE CLIENTES
CREATE TABLE IF NOT EXISTS `clientes` (
  `clienteId` bigint(10) NOT NULL AUTO_INCREMENT,
  `clienteNombre` varchar(128) NOT NULL,
  `clienteTelefono` varchar(20) DEFAULT NULL,
  `clienteEmail` varchar(80) DEFAULT NULL,
  `clienteDireccion` text DEFAULT NULL,
  `clienteEst` char(3) DEFAULT 'ACT',
  `clienteCreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`clienteId`),
  KEY `idx_cliente_nombre` (`clienteNombre`),
  KEY `idx_cliente_telefono` (`clienteTelefono`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 2. TABLA DE SESIONES DE CAJA
CREATE TABLE IF NOT EXISTS `caja_sesion` (
  `cajaSesionId` bigint(10) NOT NULL AUTO_INCREMENT,
  `usercod` bigint(10) NOT NULL,
  `cajaMontoInicial` decimal(13,2) NOT NULL DEFAULT '0.00',
  `cajaApertura` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cajaCierre` datetime DEFAULT NULL,
  `cajaMontoFinal` decimal(13,2) DEFAULT NULL,
  `cajaTotalVentas` decimal(13,2) DEFAULT '0.00',
  `cajaCantVentas` int(11) DEFAULT '0',
  `cajaEst` char(3) DEFAULT 'ABI' COMMENT 'ABI=Abierta, CER=Cerrada',
  `cajaObservaciones` text DEFAULT NULL,
  PRIMARY KEY (`cajaSesionId`),
  KEY `idx_caja_usuario` (`usercod`),
  KEY `idx_caja_estado` (`cajaEst`),
  CONSTRAINT `fk_caja_usuario` FOREIGN KEY (`usercod`) REFERENCES `usuario` (`usercod`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 3. TABLA DE VENTAS (Encabezado)
CREATE TABLE IF NOT EXISTS `ventas` (
  `ventaId` bigint(15) NOT NULL AUTO_INCREMENT,
  `ventaCod` varchar(20) NOT NULL COMMENT 'Código legible ej. VENTA-00001',
  `clienteId` bigint(10) DEFAULT NULL,
  `usercod` bigint(10) NOT NULL,
  `cajaSesionId` bigint(10) DEFAULT NULL,
  `ventaSubtotal` decimal(13,2) NOT NULL DEFAULT '0.00',
  `ventaDescuento` decimal(13,2) NOT NULL DEFAULT '0.00',
  `ventaTotal` decimal(13,2) NOT NULL DEFAULT '0.00',
  `ventaPagoRecibido` decimal(13,2) NOT NULL DEFAULT '0.00',
  `ventaCambio` decimal(13,2) NOT NULL DEFAULT '0.00',
  `ventaFormaPago` char(3) DEFAULT 'EFE' COMMENT 'EFE=Efectivo, TAR=Tarjeta, MIX=Mixto',
  `ventaEst` char(3) DEFAULT 'ACT' COMMENT 'ACT=Activa, ANU=Anulada',
  `ventaCreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ventaAnuladaAt` datetime DEFAULT NULL,
  `ventaAnuladaBy` bigint(10) DEFAULT NULL,
  `ventaMotivoAnulacion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ventaId`),
  UNIQUE KEY `ventaCod_UNIQUE` (`ventaCod`),
  KEY `idx_venta_cliente` (`clienteId`),
  KEY `idx_venta_usuario` (`usercod`),
  KEY `idx_venta_caja` (`cajaSesionId`),
  KEY `idx_venta_fecha` (`ventaCreatedAt`),
  CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`clienteId`) REFERENCES `clientes` (`clienteId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_venta_usuario` FOREIGN KEY (`usercod`) REFERENCES `usuario` (`usercod`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_venta_caja` FOREIGN KEY (`cajaSesionId`) REFERENCES `caja_sesion` (`cajaSesionId`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 4. TABLA DE DETALLE DE VENTAS (Items)
CREATE TABLE IF NOT EXISTS `ventas_detalle` (
  `ventaDetId` bigint(15) NOT NULL AUTO_INCREMENT,
  `ventaId` bigint(15) NOT NULL,
  `invPrdId` bigint(13) NOT NULL,
  `loteId` bigint(15) DEFAULT NULL,
  `ventaDetCantidad` int(11) NOT NULL,
  `ventaDetPrecioUnitario` decimal(13,2) NOT NULL,
  `ventaDetSubtotal` decimal(13,2) NOT NULL,
  PRIMARY KEY (`ventaDetId`),
  KEY `idx_detalle_venta` (`ventaId`),
  KEY `idx_detalle_producto` (`invPrdId`),
  CONSTRAINT `fk_detalle_venta` FOREIGN KEY (`ventaId`) REFERENCES `ventas` (`ventaId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_detalle_producto` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_detalle_lote` FOREIGN KEY (`loteId`) REFERENCES `lotes_inventario` (`loteId`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 5. FUNCIONES (Permisos) PARA EL MÓDULO POS
INSERT INTO `funciones` (`fncod`, `fndsc`, `fnest`, `fntyp`) VALUES
('Controllers\\POS', 'Módulo Punto de Venta (POS)', 'ACT', 'CTR'),
('Controllers\\POS\\OpenSession', 'Abrir Sesión de Caja', 'ACT', 'CTR'),
('Controllers\\POS\\CloseSession', 'Cerrar Sesión de Caja', 'ACT', 'CTR'),
('Controllers\\POS\\ProcessSale', 'Procesar Venta', 'ACT', 'CTR'),
('Controllers\\POS\\AnulateSale', 'Anular Venta', 'ACT', 'CTR'),
('Controllers\\POS\\History', 'Ver Historial de Ventas', 'ACT', 'CTR');

-- 6. ASIGNACIÓN DE PERMISOS POR ROL
-- Propietario (PRP) - Acceso total automático por bypass en Security.php

-- Administrador / Empleado (ADM)
INSERT INTO `funciones_roles` (`rolescod`, `fncod`, `fnrolest`, `fnexp`) VALUES
('ADM', 'Controllers\\POS', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\POS\\OpenSession', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\POS\\CloseSession', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\POS\\ProcessSale', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\POS\\AnulateSale', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('ADM', 'Controllers\\POS\\History', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR));

-- Auditor (AUD) - Solo lectura
INSERT INTO `funciones_roles` (`rolescod`, `fncod`, `fnrolest`, `fnexp`) VALUES
('AUD', 'Controllers\\POS', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR)),
('AUD', 'Controllers\\POS\\History', 'ACT', DATE_ADD(NOW(), INTERVAL 1 YEAR));

-- 7. CLIENTE POR DEFECTO (Mostrador / Consumidor Final)
INSERT INTO `clientes` (`clienteNombre`, `clienteTelefono`, `clienteEst`) VALUES
('Consumidor Final (Mostrador)', 'N/A', 'ACT');

