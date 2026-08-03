-- =====================================================
-- SCRIPT: 08_ventas_pos.sql
-- PROPÓSITO: Crear tablas para el módulo POS
-- VERSIÓN: 1.0.0
-- AUTOR: Integrante 5 (María)
-- =====================================================

-- Tabla: ventas
-- Almacena los registros principales de ventas
CREATE TABLE IF NOT EXISTS `ventas` (
    `ventaId` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ventaFecha` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ventaMonto` DECIMAL(12, 2) NOT NULL,
    `ventaMetodo` ENUM('CASH', 'CARD', 'CHECK', 'TRANSFER') NOT NULL DEFAULT 'CASH',
    `ventaEst` ENUM('ACT', 'CAN', 'DEV') NOT NULL DEFAULT 'ACT' COMMENT 'ACT=Activa, CAN=Cancelada, DEV=Devuelta',
    `ventaCreatedBy` INT UNSIGNED NOT NULL,
    `ventaCreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ventaModifiedBy` INT UNSIGNED,
    `ventaModifiedAt` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    
    KEY `idx_ventaFecha` (`ventaFecha`),
    KEY `idx_ventaMetodo` (`ventaMetodo`),
    KEY `idx_ventaEst` (`ventaEst`),
    KEY `fk_ventaCreatedBy` (`ventaCreatedBy`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: venta_items
-- Detalle de productos en cada venta
CREATE TABLE IF NOT EXISTS `venta_items` (
    `viId` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ventaId` INT UNSIGNED NOT NULL,
    `invPrdId` INT UNSIGNED NOT NULL,
    `viCantidad` DECIMAL(10, 2) NOT NULL,
    `viPrecio` DECIMAL(12, 2) NOT NULL,
    `viSubtotal` DECIMAL(12, 2),
    `viCreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`ventaId`) REFERENCES `ventas` (`ventaId`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE RESTRICT ON UPDATE CASCADE,
    KEY `idx_ventaId` (`ventaId`),
    KEY `idx_invPrdId` (`invPrdId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: venta_pagos
-- Útil para registrar detalles adicionales de pagos por cheque/transferencia
CREATE TABLE IF NOT EXISTS `venta_pagos` (
    `pagoId` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ventaId` INT UNSIGNED NOT NULL,
    `pagoMetodo` VARCHAR(50) NOT NULL,
    `pagoReferencia` VARCHAR(255) COMMENT 'Número de cheque, transferencia, etc',
    `pagoMonto` DECIMAL(12, 2) NOT NULL,
    `pagoEstado` ENUM('PENDIENTE', 'CONFIRMADO', 'FALLIDO') DEFAULT 'PENDIENTE',
    `pagoFecha` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`ventaId`) REFERENCES `ventas` (`ventaId`) ON DELETE CASCADE ON UPDATE CASCADE,
    KEY `idx_ventaId` (`ventaId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INDICES Y VISTAS ÚTILES
-- =====================================================

-- Vista: reporte_ventas_diarias
CREATE OR REPLACE VIEW `reporte_ventas_diarias` AS
SELECT
    DATE(v.ventaFecha) as fecha,
    COUNT(v.ventaId) as total_ventas,
    SUM(v.ventaMonto) as monto_total,
    AVG(v.ventaMonto) as monto_promedio,
    MIN(v.ventaMonto) as monto_minimo,
    MAX(v.ventaMonto) as monto_maximo,
    v.ventaMetodo
FROM ventas v
WHERE v.ventaEst = 'ACT'
GROUP BY DATE(v.ventaFecha), v.ventaMetodo
ORDER BY DATE(v.ventaFecha) DESC;

-- Vista: reporte_productos_vendidos
CREATE OR REPLACE VIEW `reporte_productos_vendidos` AS
SELECT
    p.invPrdId,
    p.invPrdDsc,
    p.invPrdBrCod,
    SUM(vi.viCantidad) as total_vendido,
    SUM(vi.viSubtotal) as ingresos_totales,
    AVG(vi.viPrecio) as precio_promedio,
    COUNT(DISTINCT vi.ventaId) as numero_ventas
FROM venta_items vi
INNER JOIN productos p ON vi.invPrdId = p.invPrdId
INNER JOIN ventas v ON vi.ventaId = v.ventaId
WHERE v.ventaEst = 'ACT'
GROUP BY p.invPrdId, p.invPrdDsc, p.invPrdBrCod
ORDER BY total_vendido DESC;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================
