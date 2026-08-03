<?php

namespace Dao\Mnt;

class POS extends \Dao\Table
{
    // ============================================================
    // CLIENTES
    // ============================================================

    /**
     * Obtiene todos los clientes activos
     */
    public static function getClientes()
    {
        $sqlstr = "SELECT * FROM clientes WHERE clienteEst = 'ACT' ORDER BY clienteNombre ASC;";
        return self::obtenerRegistros($sqlstr, []);
    }

    /**
     * Obtiene un cliente por ID
     */
    public static function getClienteById($clienteId)
    {
        $sqlstr = "SELECT * FROM clientes WHERE clienteId = :clienteId;";
        return self::obtenerUnRegistro($sqlstr, ["clienteId" => $clienteId]);
    }

    /**
     * Busca clientes por nombre o teléfono
     */
    public static function buscarClientes($query)
    {
        $sqlstr = "SELECT * FROM clientes 
                   WHERE clienteEst = 'ACT' 
                   AND (clienteNombre LIKE :query OR clienteTelefono LIKE :query)
                   ORDER BY clienteNombre ASC 
                   LIMIT 10;";
        return self::obtenerRegistros($sqlstr, ["query" => "%" . $query . "%"]);
    }

    /**
     * Crea un cliente rápido (para POS)
     */
    public static function crearClienteRapido($nombre, $telefono = "", $email = "")
    {
        $sqlins = "INSERT INTO clientes (clienteNombre, clienteTelefono, clienteEmail, clienteEst, clienteCreatedAt)
                   VALUES (:nombre, :telefono, :email, 'ACT', NOW());";
        $result = self::executeNonQuery($sqlins, [
            "nombre" => $nombre,
            "telefono" => $telefono === "" ? null : $telefono,
            "email" => $email === "" ? null : $email
        ]);

        if ($result) {
            $lastId = self::obtenerUnRegistro("SELECT LAST_INSERT_ID() as id;", []);
            return $lastId ? $lastId["id"] : 0;
        }
        return 0;
    }

    // ============================================================
    // PRODUCTOS (Búsqueda POS)
    // ============================================================

    /**
     * Busca productos activos por código de barras, nombre o código interno
     */
    public static function buscarProductosPOS($query)
    {
        $sqlstr = "SELECT p.*, c.catnom 
                   FROM productos p 
                   LEFT JOIN categorias c ON p.catid = c.catid 
                   WHERE p.invPrdEst = 'ACT' 
                   AND (p.invPrdDsc LIKE :query 
                        OR p.invPrdBrCod LIKE :query 
                        OR p.invPrdCodInt LIKE :query)
                   ORDER BY p.invPrdDsc ASC 
                   LIMIT 20;";
        return self::obtenerRegistros($sqlstr, ["query" => "%" . $query . "%"]);
    }

    /**
     * Obtiene producto completo con lotes activos
     */
    public static function getProductoPOSById($invPrdId)
    {
        $sqlstr = "SELECT p.*, c.catnom 
                   FROM productos p 
                   LEFT JOIN categorias c ON p.catid = c.catid 
                   WHERE p.invPrdId = :invPrdId;";
        $producto = self::obtenerUnRegistro($sqlstr, ["invPrdId" => $invPrdId]);

        if ($producto) {
            $producto["lotes"] = self::getLotesActivos($invPrdId);
            $producto["stock_total"] = intval($producto["invPrdStock"]);
        }

        return $producto;
    }

    /**
     * Obtiene lotes activos ordenados por vencimiento PEPS
     */
    public static function getLotesActivos($invPrdId)
    {
        $sqlstr = "SELECT * FROM lotes_inventario 
                   WHERE invPrdId = :invPrdId AND loteCantActual > 0 AND loteEst = 'ACT'
                   ORDER BY COALESCE(loteFechaVencimiento, '9999-12-31') ASC, loteFechaIngreso ASC;";
        return self::obtenerRegistros($sqlstr, ["invPrdId" => $invPrdId]);
    }

    // ============================================================
    // SESIÓN DE CAJA
    // ============================================================

    /**
     * Obtiene la sesión de caja activa para un usuario
     */
    public static function getSesionActiva($usercod)
    {
        $sqlstr = "SELECT * FROM caja_sesion 
                   WHERE usercod = :usercod AND cajaEst = 'ABI'
                   ORDER BY cajaApertura DESC 
                   LIMIT 1;";
        return self::obtenerUnRegistro($sqlstr, ["usercod" => $usercod]);
    }

    /**
     * Obtiene cualquier sesión activa (para verificar si hay alguna abierta)
     */
    public static function getAnySesionActiva()
    {
        $sqlstr = "SELECT cs.*, u.username 
                   FROM caja_sesion cs 
                   INNER JOIN usuario u ON cs.usercod = u.usercod
                   WHERE cs.cajaEst = 'ABI'
                   ORDER BY cs.cajaApertura DESC 
                   LIMIT 1;";
        return self::obtenerUnRegistro($sqlstr, []);
    }

    /**
     * Abre una nueva sesión de caja
     */
    public static function abrirSesionCaja($usercod, $montoInicial)
    {
        $sqlins = "INSERT INTO caja_sesion (usercod, cajaMontoInicial, cajaApertura, cajaEst)
                   VALUES (:usercod, :montoInicial, NOW(), 'ABI');";
        $result = self::executeNonQuery($sqlins, [
            "usercod" => $usercod,
            "montoInicial" => $montoInicial
        ]);
        if ($result) {
            $lastId = self::obtenerUnRegistro("SELECT LAST_INSERT_ID() as id;", []);
            return $lastId ? $lastId["id"] : 0;
        }
        return 0;
    }

    /**
     * Cierra una sesión de caja
     */
    public static function cerrarSesionCaja($cajaSesionId, $montoFinal, $totalVentas, $cantVentas, $observaciones = "")
    {
        $sqlupd = "UPDATE caja_sesion SET 
            cajaCierre = NOW(),
            cajaMontoFinal = :montoFinal,
            cajaTotalVentas = :totalVentas,
            cajaCantVentas = :cantVentas,
            cajaEst = 'CER',
            cajaObservaciones = :observaciones
            WHERE cajaSesionId = :cajaSesionId AND cajaEst = 'ABI';";
        return self::executeNonQuery($sqlupd, [
            "cajaSesionId" => $cajaSesionId,
            "montoFinal" => $montoFinal,
            "totalVentas" => $totalVentas,
            "cantVentas" => $cantVentas,
            "observaciones" => $observaciones
        ]);
    }

    /**
     * Obtiene el resumen de ventas de una sesión de caja
     */
    public static function getResumenSesion($cajaSesionId)
    {
        $sqlstr = "SELECT 
                    COUNT(*) as total_ventas,
                    COALESCE(SUM(ventaTotal), 0) as monto_total,
                    COALESCE(SUM(ventaPagoRecibido), 0) as total_recibido
                   FROM ventas 
                   WHERE cajaSesionId = :cajaSesionId AND ventaEst = 'ACT';";
        return self::obtenerUnRegistro($sqlstr, ["cajaSesionId" => $cajaSesionId]);
    }

    // ============================================================
    // PROCESAR VENTA (Transacción completa)
    // ============================================================

    /**
     * Procesa una venta completa con transacción
     *
     * @param int $usercod
     * @param int $clienteId
     * @param int $cajaSesionId
     * @param array $items Array de [invPrdId, cantidad, precioUnitario]
     * @param float $descuento
     * @param float $pagoRecibido
     * @param string $formaPago
     * @return array ['success' => bool, 'message' => string, 'ventaId' => int|null, 'ventaCod' => string|null]
     */
    public static function procesarVenta($usercod, $clienteId, $cajaSesionId, $items, $descuento = 0.00, $pagoRecibido = 0.00, $formaPago = 'EFE')
    {
        $conn = self::getConn();
        $conn->beginTransaction();

        try {
            // 1. Validar items
            if (empty($items)) {
                throw new \Exception("El carrito está vacío.");
            }

            // 2. Calcular totales y validar stock
            $subtotal = 0;
            $detallesVenta = [];
            $productosActualizar = [];

            foreach ($items as $item) {
                $invPrdId = intval($item["invPrdId"]);
                $cantidad = intval($item["cantidad"]);
                $precioUnitario = floatval($item["precioUnitario"]);

                if ($cantidad <= 0) {
                    throw new \Exception("La cantidad del producto debe ser mayor a cero.");
                }
                if ($precioUnitario <= 0) {
                    throw new \Exception("El precio unitario debe ser mayor a cero.");
                }

                // Obtener producto actual
                $producto = self::obtenerUnRegistro(
                    "SELECT * FROM productos WHERE invPrdId = :invPrdId AND invPrdEst = 'ACT';",
                    ["invPrdId" => $invPrdId]
                );

                if (!$producto) {
                    throw new \Exception("Producto ID $invPrdId no encontrado o inactivo.");
                }

                $stockActual = intval($producto["invPrdStock"]);
                if ($stockActual < $cantidad) {
                    throw new \Exception("Stock insuficiente para '{$producto['invPrdDsc']}'. Disponible: $stockActual, Solicitado: $cantidad.");
                }

                // Obtener lotes activos para descontar (PEPS)
                $lotes = self::getLotesActivos($invPrdId);
                $cantRestante = $cantidad;
                $lotesADescontar = [];

                foreach ($lotes as $lote) {
                    if ($cantRestante <= 0) break;
                    $loteId = intval($lote["loteId"]);
                    $cantActual = intval($lote["loteCantActual"]);

                    if ($cantActual >= $cantRestante) {
                        $lotesADescontar[] = [
                            "loteId" => $loteId,
                            "cantidad" => $cantRestante,
                            "loteCantActual" => $cantActual,
                            "loteCod" => $lote["loteCod"]
                        ];
                        $cantRestante = 0;
                    } else {
                        $lotesADescontar[] = [
                            "loteId" => $loteId,
                            "cantidad" => $cantActual,
                            "loteCantActual" => $cantActual,
                            "loteCod" => $lote["loteCod"]
                        ];
                        $cantRestante -= $cantActual;
                    }
                }

                if ($cantRestante > 0) {
                    throw new \Exception("No hay suficiente stock en lotes para '{$producto['invPrdDsc']}'.");
                }

                $itemSubtotal = $cantidad * $precioUnitario;
                $subtotal += $itemSubtotal;

                $detallesVenta[] = [
                    "invPrdId" => $invPrdId,
                    "cantidad" => $cantidad,
                    "precioUnitario" => $precioUnitario,
                    "subtotal" => $itemSubtotal,
                    "lotesADescontar" => $lotesADescontar
                ];

                $productosActualizar[] = [
                    "invPrdId" => $invPrdId,
                    "nuevoStock" => $stockActual - $cantidad
                ];
            }

            $total = $subtotal - $descuento;
            if ($total < 0) $total = 0;

            if ($pagoRecibido < $total) {
                throw new \Exception("El monto recibido ($pagoRecibido) es menor al total de la venta ($total).");
            }

            $cambio = $pagoRecibido - $total;

            // 3. Generar código de venta
            $fecha = date("Ymd");
            $ultimoCod = self::obtenerUnRegistro(
                "SELECT ventaCod FROM ventas WHERE ventaCod LIKE :prefijo ORDER BY ventaId DESC LIMIT 1;",
                ["prefijo" => "VENTA-$fecha-%"]
            );

            if ($ultimoCod) {
                $ultimoNum = intval(explode("-", $ultimoCod["ventaCod"])[2]);
                $nuevoNum = $ultimoNum + 1;
            } else {
                $nuevoNum = 1;
            }
            $ventaCod = "VENTA-$fecha-" . str_pad($nuevoNum, 4, "0", STR_PAD_LEFT);

            // 4. Insertar encabezado de venta
            $sqlVenta = "INSERT INTO ventas (
                ventaCod, clienteId, usercod, cajaSesionId,
                ventaSubtotal, ventaDescuento, ventaTotal,
                ventaPagoRecibido, ventaCambio, ventaFormaPago, ventaEst, ventaCreatedAt
            ) VALUES (
                :ventaCod, :clienteId, :usercod, :cajaSesionId,
                :subtotal, :descuento, :total,
                :pagoRecibido, :cambio, :formaPago, 'ACT', NOW()
            );";

            $resultVenta = self::executeNonQuery($sqlVenta, [
                "ventaCod" => $ventaCod,
                "clienteId" => $clienteId,
                "usercod" => $usercod,
                "cajaSesionId" => $cajaSesionId,
                "subtotal" => $subtotal,
                "descuento" => $descuento,
                "total" => $total,
                "pagoRecibido" => $pagoRecibido,
                "cambio" => $cambio,
                "formaPago" => $formaPago
            ]);

            if (!$resultVenta) {
                throw new \Exception("Error al registrar la venta.");
            }

            $ventaId = self::obtenerUnRegistro("SELECT LAST_INSERT_ID() as id;", []);
            if (!$ventaId) {
                throw new \Exception("Error al obtener ID de la venta.");
            }
            $ventaId = $ventaId["id"];

            // 5. Insertar detalles y descontar lotes
            foreach ($detallesVenta as $detalle) {
                foreach ($detalle["lotesADescontar"] as $loteOp) {
                    // Insertar detalle por lote
                    $sqlDet = "INSERT INTO ventas_detalle (ventaId, invPrdId, loteId, ventaDetCantidad, ventaDetPrecioUnitario, ventaDetSubtotal)
                               VALUES (:ventaId, :invPrdId, :loteId, :cantidad, :precioUnitario, :subtotal);";
                    $detSubtotal = $loteOp["cantidad"] * $detalle["precioUnitario"];
                    self::executeNonQuery($sqlDet, [
                        "ventaId" => $ventaId,
                        "invPrdId" => $detalle["invPrdId"],
                        "loteId" => $loteOp["loteId"],
                        "cantidad" => $loteOp["cantidad"],
                        "precioUnitario" => $detalle["precioUnitario"],
                        "subtotal" => $detSubtotal
                    ]);

                    // Descontar lote
                    $nuevaCantLote = $loteOp["loteCantActual"] - $loteOp["cantidad"];
                    $estLote = $nuevaCantLote <= 0 ? 'AGT' : 'ACT';
                    self::executeNonQuery(
                        "UPDATE lotes_inventario SET loteCantActual = :nuevaCant, loteEst = :est WHERE loteId = :loteId;",
                        ["nuevaCant" => $nuevaCantLote, "est" => $estLote, "loteId" => $loteOp["loteId"]]
                    );
                }
            }

            // 6. Actualizar stock de productos
            foreach ($productosActualizar as $prodUpd) {
                self::executeNonQuery(
                    "UPDATE productos SET invPrdStock = :nuevoStock, invPrdModifiedAt = NOW(), invPrdModifiedBy = :usercod WHERE invPrdId = :invPrdId;",
                    [
                        "nuevoStock" => $prodUpd["nuevoStock"],
                        "usercod" => $usercod,
                        "invPrdId" => $prodUpd["invPrdId"]
                    ]
                );
            }

            // 7. Registrar movimientos de inventario (SAL)
            foreach ($detallesVenta as $detalle) {
                foreach ($detalle["lotesADescontar"] as $loteOp) {
                    self::executeNonQuery(
                        "INSERT INTO movimientos_inventario (invPrdId, loteId, movTipo, movCantidad, movMotivo, refTipo, refId, movCreatedBy, movCreatedAt)
                         VALUES (:invPrdId, :loteId, 'SAL', :cantidad, :motivo, 'VENTA', :refId, :usercod, NOW());",
                        [
                            "invPrdId" => $detalle["invPrdId"],
                            "loteId" => $loteOp["loteId"],
                            "cantidad" => $loteOp["cantidad"],
                            "motivo" => "Venta #$ventaCod",
                            "refId" => $ventaId,
                            "usercod" => $usercod
                        ]
                    );
                }
            }

            // 8. Actualizar sesión de caja (sumar venta)
            $sesionActual = self::obtenerUnRegistro(
                "SELECT cajaTotalVentas, cajaCantVentas FROM caja_sesion WHERE cajaSesionId = :cajaSesionId;",
                ["cajaSesionId" => $cajaSesionId]
            );

            $nuevoTotalVentas = floatval($sesionActual["cajaTotalVentas"]) + $total;
            $nuevaCantVentas = intval($sesionActual["cajaCantVentas"]) + 1;

            self::executeNonQuery(
                "UPDATE caja_sesion SET cajaTotalVentas = :totalVentas, cajaCantVentas = :cantVentas WHERE cajaSesionId = :cajaSesionId;",
                [
                    "totalVentas" => $nuevoTotalVentas,
                    "cantVentas" => $nuevaCantVentas,
                    "cajaSesionId" => $cajaSesionId
                ]
            );

            $conn->commit();
            return [
                "success" => true,
                "message" => "¡Venta procesada exitosamente!",
                "ventaId" => $ventaId,
                "ventaCod" => $ventaCod,
                "total" => $total,
                "cambio" => $cambio
            ];
        } catch (\Exception $ex) {
            $conn->rollBack();
            return [
                "success" => false,
                "message" => $ex->getMessage(),
                "ventaId" => null,
                "ventaCod" => null,
                "total" => 0,
                "cambio" => 0
            ];
        }
    }

    // ============================================================
    // HISTORIAL DE VENTAS
    // ============================================================

    /**
     * Obtiene ventas con filtros
     */
    public static function getVentas($fechaInicio = "", $fechaFin = "", $clienteId = 0, $estado = "", $cajaSesionId = 0)
    {
        $sql = "SELECT v.*, c.clienteNombre, u.username 
                FROM ventas v 
                LEFT JOIN clientes c ON v.clienteId = c.clienteId 
                INNER JOIN usuario u ON v.usercod = u.usercod 
                WHERE 1 = 1";
        $params = [];

        if (!empty($fechaInicio)) {
            $sql .= " AND DATE(v.ventaCreatedAt) >= :fechaInicio";
            $params["fechaInicio"] = $fechaInicio;
        }
        if (!empty($fechaFin)) {
            $sql .= " AND DATE(v.ventaCreatedAt) <= :fechaFin";
            $params["fechaFin"] = $fechaFin;
        }
        if ($clienteId > 0) {
            $sql .= " AND v.clienteId = :clienteId";
            $params["clienteId"] = $clienteId;
        }
        if (!empty($estado)) {
            $sql .= " AND v.ventaEst = :estado";
            $params["estado"] = $estado;
        }
        if ($cajaSesionId > 0) {
            $sql .= " AND v.cajaSesionId = :cajaSesionId";
            $params["cajaSesionId"] = $cajaSesionId;
        }

        $sql .= " ORDER BY v.ventaCreatedAt DESC LIMIT 100;";

        return self::obtenerRegistros($sql, $params);
    }

    /**
     * Obtiene una venta por ID con detalles
     */
    public static function getVentaById($ventaId)
    {
        $venta = self::obtenerUnRegistro(
            "SELECT v.*, c.clienteNombre, c.clienteTelefono, u.username 
             FROM ventas v 
             LEFT JOIN clientes c ON v.clienteId = c.clienteId 
             INNER JOIN usuario u ON v.usercod = u.usercod 
             WHERE v.ventaId = :ventaId;",
            ["ventaId" => $ventaId]
        );

        if ($venta) {
            $detalles = self::obtenerRegistros(
                "SELECT vd.*, p.invPrdBrCod, p.invPrdDsc, l.loteCod
                 FROM ventas_detalle vd 
                 INNER JOIN productos p ON vd.invPrdId = p.invPrdId 
                 LEFT JOIN lotes_inventario l ON vd.loteId = l.loteId 
                 WHERE vd.ventaId = :ventaId;",
                ["ventaId" => $ventaId]
            );
            $venta["detalles"] = $detalles;
        }

        return $venta;
    }

    /**
     * Anula una venta (restaura stock)
     */
    public static function anularVenta($ventaId, $usercod, $motivo)
    {
        $conn = self::getConn();
        $conn->beginTransaction();

        try {
            $venta = self::obtenerUnRegistro(
                "SELECT * FROM ventas WHERE ventaId = :ventaId AND ventaEst = 'ACT';",
                ["ventaId" => $ventaId]
            );

            if (!$venta) {
                throw new \Exception("Venta no encontrada o ya anulada.");
            }

            $detalles = self::obtenerRegistros(
                "SELECT vd.*, l.loteCantActual FROM ventas_detalle vd 
                 LEFT JOIN lotes_inventario l ON vd.loteId = l.loteId 
                 WHERE vd.ventaId = :ventaId;",
                ["ventaId" => $ventaId]
            );

            // Restaurar stock de lotes
            foreach ($detalles as $det) {
                $loteId = intval($det["loteId"]);
                $cantidad = intval($det["ventaDetCantidad"]);
                $cantActual = intval($det["loteCantActual"]);

                self::executeNonQuery(
                    "UPDATE lotes_inventario SET loteCantActual = loteCantActual + :cantidad, loteEst = 'ACT' WHERE loteId = :loteId;",
                    ["cantidad" => $cantidad, "loteId" => $loteId]
                );

                // Restaurar stock del producto
                self::executeNonQuery(
                    "UPDATE productos SET invPrdStock = invPrdStock + :cantidad, invPrdModifiedAt = NOW(), invPrdModifiedBy = :usercod WHERE invPrdId = :invPrdId;",
                    ["cantidad" => $cantidad, "usercod" => $usercod, "invPrdId" => $det["invPrdId"]]
                );

                // Registrar movimiento de reversión
                self::executeNonQuery(
                    "INSERT INTO movimientos_inventario (invPrdId, loteId, movTipo, movCantidad, movMotivo, refTipo, refId, movCreatedBy, movCreatedAt)
                     VALUES (:invPrdId, :loteId, 'ENT', :cantidad, :motivo, 'ANULACION', :refId, :usercod, NOW());",
                    [
                        "invPrdId" => $det["invPrdId"],
                        "loteId" => $loteId,
                        "cantidad" => $cantidad,
                        "motivo" => "Anulación de venta #{$venta['ventaCod']}: $motivo",
                        "refId" => $ventaId,
                        "usercod" => $usercod
                    ]
                );
            }

            // Marcar venta como anulada
            self::executeNonQuery(
                "UPDATE ventas SET ventaEst = 'ANU', ventaAnuladaAt = NOW(), ventaAnuladaBy = :usercod, ventaMotivoAnulacion = :motivo WHERE ventaId = :ventaId;",
                ["usercod" => $usercod, "motivo" => $motivo, "ventaId" => $ventaId]
            );

            $conn->commit();
            return ["success" => true, "message" => "Venta anulada exitosamente. Stock restaurado."];
        } catch (\Exception $ex) {
            $conn->rollBack();
            return ["success" => false, "message" => $ex->getMessage()];
        }
    }

    /**
     * Obtiene las ventas del día
     */
    public static function getVentasDelDia()
    {
        $sql = "SELECT v.*, c.clienteNombre, u.username 
                FROM ventas v 
                LEFT JOIN clientes c ON v.clienteId = c.clienteId 
                INNER JOIN usuario u ON v.usercod = u.usercod 
                WHERE DATE(v.ventaCreatedAt) = CURDATE()
                ORDER BY v.ventaCreatedAt DESC;";
        return self::obtenerRegistros($sql, []);
    }
}

