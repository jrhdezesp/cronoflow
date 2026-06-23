<?php

namespace Dao\Mnt;

class Productos extends \Dao\Table
{
    static public function getCategorias()
    {
        $sqlstr = "SELECT * FROM categorias WHERE catest = 'ACT';";
        return self::obtenerRegistros($sqlstr, []);
    }

    static public function getProveedoresActivos()
    {
        $sqlstr = "SELECT provId, provNombre FROM proveedores WHERE provEst = 'ACT' ORDER BY provNombre;";
        return self::obtenerRegistros($sqlstr, []);
    }

    static public function getCategoriaByCode($catid)
    {
        $sqlstr = "SELECT * FROM categorias WHERE catid = :catid;";
        return self::obtenerUnRegistro($sqlstr, ["catid" => $catid]);
    }

    static public function getProductosByCategoria($catid)
    {
        $sqlstr = "SELECT p.*, c.catnom 
                   FROM productos p 
                   LEFT JOIN categorias c ON p.catid = c.catid 
                   WHERE p.catid = :catid;";
        return self::obtenerRegistros($sqlstr, ["catid" => $catid]);
    }

    static public function getProductoByCode($invPrdId)
    {
        $sqlstr = "SELECT * FROM productos WHERE invPrdId = :invPrdId;";
        return self::obtenerUnRegistro($sqlstr, ["invPrdId" => $invPrdId]);
    }

    static public function getProductoByBarcode($barcode)
    {
        $sqlstr = "SELECT * FROM productos WHERE invPrdBrCod = :barcode;";
        return self::obtenerUnRegistro($sqlstr, ["barcode" => $barcode]);
    }

    static public function getProductoByIntcode($intcode)
    {
        $sqlstr = "SELECT * FROM productos WHERE invPrdCodInt = :intcode;";
        return self::obtenerUnRegistro($sqlstr, ["intcode" => $intcode]);
    }

    static public function newProducto($barcode, $intcode, $dsc, $catid, $price, $cost, $stock, $stockmin, $type, $est, $userId, $loteCod = "", $loteFechaVencimiento = "", $provId = 0)
    {
        $conn = self::getConn();
        $conn->beginTransaction();

        try {
            $sqlins = "INSERT INTO productos (
                invPrdId, invPrdBrCod, invPrdCodInt, invPrdDsc, catid, 
                provId, invPrdPrecioVenta, invPrdCosto, invPrdStock, invPrdStockMin, 
                invPrdTip, invPrdEst, invPrdCreatedBy, invPrdCreatedAt, 
                invPrdModifiedBy, invPrdModifiedAt
            ) VALUES (
                NULL, :barcode, :intcode, :dsc, :catid, 
                :provId, :price, :cost, :stock, :stockmin, 
                :type, :est, :userId, NOW(), 
                :userId, NOW()
            );";

            $result = self::executeNonQuery($sqlins, [
                "barcode" => $barcode === "" ? null : $barcode,
                "intcode" => $intcode === "" ? null : $intcode,
                "dsc" => $dsc,
                "catid" => $catid === 0 ? null : $catid,
                "provId" => $provId === 0 ? null : $provId,
                "price" => $price,
                "cost" => $cost,
                "stock" => $stock,
                "stockmin" => $stockmin,
                "type" => $type,
                "est" => $est,
                "userId" => $userId
            ]);

            if ($result) {
                $lastId = self::obtenerUnRegistro("SELECT LAST_INSERT_ID() as id;", []);
                if ($lastId && $stock > 0 && !empty($loteCod)) {
                    $prdId = $lastId["id"];
                    self::registrarLote($prdId, $loteCod, $stock, $loteFechaVencimiento, $cost);
                    $loteResult = self::obtenerUnRegistro("SELECT LAST_INSERT_ID() as id;", []);
                    $loteId = $loteResult ? $loteResult["id"] : null;
                    self::registrarMovimiento($prdId, "ENT", $stock, "Ingreso de stock inicial", $userId, $loteId);
                }
                $conn->commit();
                return $lastId ? $lastId["id"] : true;
            }
            
            $conn->rollBack();
            return false;
        } catch (\Exception $ex) {
            $conn->rollBack();
            error_log("Error en newProducto: " . $ex->getMessage());
            return false;
        }
    }

    static public function updateProducto($invPrdId, $barcode, $intcode, $dsc, $catid, $price, $cost, $stock, $stockmin, $type, $est, $userId, $provId = 0)
    {
        $sqlupd = "UPDATE productos SET 
            invPrdBrCod = :barcode, 
            invPrdCodInt = :intcode, 
            invPrdDsc = :dsc, 
            catid = :catid, 
            provId = :provId, 
            invPrdPrecioVenta = :price, 
            invPrdCosto = :cost, 
            invPrdStock = :stock, 
            invPrdStockMin = :stockmin, 
            invPrdTip = :type, 
            invPrdEst = :est, 
            invPrdModifiedBy = :userId, 
            invPrdModifiedAt = NOW() 
            WHERE invPrdId = :invPrdId;";

        return self::executeNonQuery($sqlupd, [
            "barcode" => $barcode === "" ? null : $barcode,
            "intcode" => $intcode === "" ? null : $intcode,
            "dsc" => $dsc,
            "catid" => $catid === 0 ? null : $catid,
            "provId" => $provId === 0 ? null : $provId,
            "price" => $price,
            "cost" => $cost,
            "stock" => $stock,
            "stockmin" => $stockmin,
            "type" => $type,
            "est" => $est,
            "userId" => $userId,
            "invPrdId" => $invPrdId
        ]);
    }

    static public function registrarLote($invPrdId, $loteCod, $cantidad, $fechaVencimiento, $costoUnitario)
    {
        $sqlins = "INSERT INTO lotes_inventario (
            invPrdId, loteCod, loteCantOriginal, loteCantActual, loteFechaIngreso, loteFechaVencimiento, loteCostoUnitario, loteEst
        ) VALUES (
            :invPrdId, :loteCod, :cantidad, :cantidad, NOW(), :fechaVencimiento, :costoUnitario, 'ACT'
        );";
        return self::executeNonQuery($sqlins, [
            "invPrdId" => $invPrdId,
            "loteCod" => $loteCod,
            "cantidad" => $cantidad,
            "fechaVencimiento" => empty($fechaVencimiento) ? null : $fechaVencimiento,
            "costoUnitario" => $costoUnitario
        ]);
    }

    static public function getLoteByCode($invPrdId, $loteCod)
    {
        $sqlstr = "SELECT * FROM lotes_inventario WHERE invPrdId = :invPrdId AND loteCod = :loteCod;";
        return self::obtenerUnRegistro($sqlstr, ["invPrdId" => $invPrdId, "loteCod" => $loteCod]);
    }

    static public function incrementarLote($loteId, $cantidad, $costo = null)
    {
        if ($costo !== null) {
            $sqlupd = "UPDATE lotes_inventario SET 
                loteCantOriginal = loteCantOriginal + :cantidad, 
                loteCantActual = loteCantActual + :cantidad,
                loteCostoUnitario = :costo,
                loteEst = 'ACT'
                WHERE loteId = :loteId;";
            return self::executeNonQuery($sqlupd, ["loteId" => $loteId, "cantidad" => $cantidad, "costo" => $costo]);
        } else {
            $sqlupd = "UPDATE lotes_inventario SET 
                loteCantOriginal = loteCantOriginal + :cantidad, 
                loteCantActual = loteCantActual + :cantidad,
                loteEst = 'ACT'
                WHERE loteId = :loteId;";
            return self::executeNonQuery($sqlupd, ["loteId" => $loteId, "cantidad" => $cantidad]);
        }
    }

    static public function getLotesActivos($invPrdId)
    {
        $sqlstr = "SELECT * FROM lotes_inventario 
                   WHERE invPrdId = :invPrdId AND loteCantActual > 0 AND loteEst = 'ACT'
                   ORDER BY COALESCE(loteFechaVencimiento, '9999-12-31') ASC, loteFechaIngreso ASC;";
        return self::obtenerRegistros($sqlstr, ["invPrdId" => $invPrdId]);
    }

    static public function actualizarCantidadLote($loteId, $nuevaCantActual)
    {
        $est = $nuevaCantActual <= 0 ? 'AGT' : 'ACT';
        $sqlupd = "UPDATE lotes_inventario SET 
            loteCantActual = :loteCantActual,
            loteEst = :loteEst
            WHERE loteId = :loteId;";
        return self::executeNonQuery($sqlupd, [
            "loteId" => $loteId,
            "loteCantActual" => $nuevaCantActual,
            "loteEst" => $est
        ]);
    }

    static public function registrarMovimiento($invPrdId, $tipo, $cantidad, $motivo, $userId, $loteId = null)
    {
        $sqlins = "INSERT INTO movimientos_inventario (
            invPrdId, loteId, movTipo, movCantidad, movMotivo, movCreatedBy, movCreatedAt
        ) VALUES (
            :invPrdId, :loteId, :movTipo, :movCantidad, :movMotivo, :userId, NOW()
        );";
        return self::executeNonQuery($sqlins, [
            "invPrdId" => $invPrdId,
            "loteId" => $loteId,
            "movTipo" => $tipo,
            "movCantidad" => $cantidad,
            "movMotivo" => $motivo,
            "userId" => $userId
        ]);
    }
}
