-- =======================================================
-- CronoFlow v2.0 - Tablas de Productos, Lotes y Kardex
-- =======================================================

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
