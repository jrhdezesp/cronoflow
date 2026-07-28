USE `proyecto_inventario`;

-- =======================================================
-- Seed de datos de ejemplo para proveedores, productos, lotes y ventas
-- =======================================================

INSERT INTO `proveedores` (`provNombre`, `provContacto`, `provTelefono`, `provEmail`, `provDireccion`, `provEst`)
VALUES
    ('Distribuidora El Buen Stock', 'María González', '502-1234-5678', 'ventas@elbuenstock.com', 'Avenida Central 123, Ciudad', 'ACT'),
    ('Logística Fresca S.A.', 'Carlos Méndez', '502-2345-6789', 'contacto@logisticafresca.com', 'Boulevard Industrial 45, Ciudad', 'ACT'),
    ('Suministros Delta', 'Ana Ruiz', '502-3456-7890', 'delta@suministros.com', 'Calle de la Industria 78, Ciudad', 'ACT');

INSERT INTO `productos` (`invPrdBrCod`, `invPrdCodInt`, `invPrdDsc`, `catid`, `provId`, `invPrdPrecioVenta`, `invPrdCosto`, `invPrdStock`, `invPrdStockMin`, `invPrdTip`, `invPrdEst`, `invPrdCreatedBy`, `invPrdCreatedAt`, `invPrdModifiedBy`, `invPrdModifiedAt`)
VALUES
    ('7501000000012', 'PROD-001', 'Agua Mineral 600ml', 1, 1, 5.50, 3.20, 120, 20, 'PRD', 'ACT', 1, NOW(), 1, NOW()),
    ('7501000000029', 'PROD-002', 'Gaseosa Cola 2L', 1, 1, 18.00, 10.50, 80, 15, 'PRD', 'ACT', 1, NOW(), 1, NOW()),
    ('7501000000036', 'PROD-003', 'Pan de Caja Integral 680g', 2, 2, 22.00, 12.00, 60, 10, 'PRD', 'ACT', 1, NOW(), 1, NOW()),
    ('7501000000043', 'PROD-004', 'Detergente Líquido 1L', 3, 3, 35.00, 18.00, 50, 10, 'PRD', 'ACT', 1, NOW(), 1, NOW()),
    ('7501000000050', 'PROD-005', 'Shampoo Hidratante 400ml', 3, 3, 48.00, 28.00, 40, 8, 'PRD', 'ACT', 1, NOW(), 1, NOW()),
    ('7501000000067', 'PROD-006', 'Café Molido 250g', 4, 2, 32.00, 18.00, 70, 12, 'PRD', 'ACT', 1, NOW(), 1, NOW());

INSERT INTO `lotes_inventario` (`invPrdId`, `loteCod`, `loteCantOriginal`, `loteCantActual`, `loteFechaIngreso`, `loteFechaVencimiento`, `loteCostoUnitario`, `loteEst`)
VALUES
    (1, 'L001-AGUA', 120, 120, NOW(), NULL, 3.20, 'ACT'),
    (2, 'L001-COLA', 80, 80, NOW(), NULL, 10.50, 'ACT'),
    (3, 'L001-PAN', 60, 60, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), 12.00, 'ACT'),
    (4, 'L001-DETER', 50, 50, NOW(), NULL, 18.00, 'ACT'),
    (5, 'L001-SHAM', 40, 40, NOW(), NULL, 28.00, 'ACT'),
    (6, 'L001-CAFE', 70, 70, NOW(), NULL, 18.00, 'ACT');

INSERT INTO `batches` (`invPrdId`, `batchCode`, `batchQuantityOriginal`, `batchQuantityAvailable`, `batchQuantityReserved`, `batchFechaIngreso`, `batchFechaVencimiento`, `batchCostoUnitario`, `batchStatus`, `createdAt`, `updatedAt`)
VALUES
    (1, 'BATCH-AGUA-01', 120, 120, 0, NOW(), NULL, 3.20, 'ACT', NOW(), NOW()),
    (2, 'BATCH-COLA-01', 80, 80, 0, NOW(), NULL, 10.50, 'ACT', NOW(), NOW()),
    (3, 'BATCH-PAN-01', 60, 60, 0, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), 12.00, 'ACT', NOW(), NOW()),
    (4, 'BATCH-DETER-01', 50, 50, 0, NOW(), NULL, 18.00, 'ACT', NOW(), NOW()),
    (5, 'BATCH-SHAM-01', 40, 40, 0, NOW(), NULL, 28.00, 'ACT', NOW(), NOW()),
    (6, 'BATCH-CAFE-01', 70, 70, 0, NOW(), NULL, 18.00, 'ACT', NOW(), NOW());

INSERT INTO `movimientos_inventario` (`invPrdId`, `loteId`, `movTipo`, `movCantidad`, `movMotivo`, `refTipo`, `refId`, `movCreatedBy`, `movCreatedAt`)
VALUES
    (1, 1, 'ENT', 120, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (2, 2, 'ENT', 80, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (3, 3, 'ENT', 60, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (4, 4, 'ENT', 50, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (5, 5, 'ENT', 40, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (6, 6, 'ENT', 70, 'Inventario inicial', 'INIT', NULL, 1, NOW());

INSERT INTO `stock_movements` (`invPrdId`, `batchId`, `movementType`, `quantity`, `reason`, `referenceType`, `referenceId`, `createdBy`, `createdAt`)
VALUES
    (1, 1, 'ENT', 120, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (2, 2, 'ENT', 80, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (3, 3, 'ENT', 60, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (4, 4, 'ENT', 50, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (5, 5, 'ENT', 40, 'Inventario inicial', 'INIT', NULL, 1, NOW()),
    (6, 6, 'ENT', 70, 'Inventario inicial', 'INIT', NULL, 1, NOW());

INSERT INTO `sales` (`saleNumber`, `saleDate`, `customerName`, `saleTotal`, `saleStatus`, `createdBy`, `createdAt`, `modifiedAt`)
VALUES
    ('VENTA-0001', NOW(), 'Cliente Comercial A', 78.00, 'CLS', 1, NOW(), NOW());

INSERT INTO `sale_items` (`saleId`, `invPrdId`, `batchId`, `quantity`, `unitPrice`, `totalPrice`)
VALUES
    (1, 1, 1, 10, 5.50, 55.00),
    (1, 3, 3, 1, 22.00, 22.00);
