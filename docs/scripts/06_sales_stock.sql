-- =======================================================
-- CronoFlow v2.0 - Tablas de ventas, items de venta y movimientos de stock
-- =======================================================

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

CREATE TABLE IF NOT EXISTS `sales` (
    `saleId` BIGINT(15) NOT NULL AUTO_INCREMENT,
    `saleNumber` VARCHAR(50) NOT NULL COMMENT 'Número de venta o comprobante',
    `saleDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `customerName` VARCHAR(128) DEFAULT NULL,
    `saleTotal` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `saleStatus` CHAR(3) NOT NULL DEFAULT 'OPN' COMMENT 'OPN=Abierta, CLS=Cerrada, CAN=Cancelada',
    `createdBy` BIGINT(10) DEFAULT NULL,
    `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `modifiedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`saleId`),
    UNIQUE KEY `idx_sales_number` (`saleNumber`),
    CONSTRAINT `fk_sales_user` FOREIGN KEY (`createdBy`) REFERENCES `usuario` (`usercod`) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

CREATE TABLE IF NOT EXISTS `sale_items` (
    `saleItemId` BIGINT(15) NOT NULL AUTO_INCREMENT,
    `saleId` BIGINT(15) NOT NULL,
    `invPrdId` BIGINT(13) NOT NULL,
    `batchId` BIGINT(15) DEFAULT NULL,
    `quantity` INT(11) NOT NULL,
    `unitPrice` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    `totalPrice` DECIMAL(13, 2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (`saleItemId`),
    CONSTRAINT `fk_sale_items_sale` FOREIGN KEY (`saleId`) REFERENCES `sales` (`saleId`) ON DELETE CASCADE,
    CONSTRAINT `fk_sale_items_product` FOREIGN KEY (`invPrdId`) REFERENCES `productos` (`invPrdId`) ON DELETE CASCADE,
    CONSTRAINT `fk_sale_items_batch` FOREIGN KEY (`batchId`) REFERENCES `batches` (`batchId`) ON DELETE SET NULL,
    CHECK (`quantity` > 0),
    CHECK (`unitPrice` >= 0),
    CHECK (`totalPrice` >= 0)
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