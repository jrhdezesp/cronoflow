<?php

namespace Dao\Mnt;

class Dashboard extends \Dao\Table
{
    public static function getMovimientosRecientes()
    {
        $sqlstr = "SELECT m.movCreatedAt, m.movTipo, m.movCantidad, m.movMotivo, p.invPrdDsc
                   FROM movimientos_inventario m
                   INNER JOIN productos p ON m.invPrdId = p.invPrdId
                   ORDER BY m.movCreatedAt DESC
                   LIMIT 5;";
        return self::obtenerRegistros($sqlstr, []);
    }

    public static function getTotalProductosActivos()
    {
        $sqlstr = "SELECT COUNT(*) as total FROM productos WHERE invPrdEst = 'ACT';";
        $result = self::obtenerUnRegistro($sqlstr, []);
        return $result ? intval($result["total"]) : 0;
    }

    public static function getTotalProductosStockBajo()
    {
        $sqlstr = "SELECT COUNT(*) as total FROM productos WHERE invPrdStock <= invPrdStockMin AND invPrdEst = 'ACT';";
        $result = self::obtenerUnRegistro($sqlstr, []);
        return $result ? intval($result["total"]) : 0;
    }

    public static function getValorInventarioActivo()
    {
        $sqlstr = "SELECT SUM(invPrdStock * invPrdCosto) as total_valor FROM productos WHERE invPrdEst = 'ACT';";
        $result = self::obtenerUnRegistro($sqlstr, []);
        return $result && $result["total_valor"] ? floatval($result["total_valor"]) : 0.00;
    }

    public static function getTotalLotesPorVencer()
    {
        $sqlstr = "SELECT COUNT(*) as total FROM lotes_inventario 
                   WHERE loteCantActual > 0 
                     AND loteFechaVencimiento IS NOT NULL 
                     AND loteFechaVencimiento <= DATE_ADD(NOW(), INTERVAL 30 DAY);";
        $result = self::obtenerUnRegistro($sqlstr, []);
        return $result ? intval($result["total"]) : 0;
    }

    public static function getMovimientosHoy()
    {
        $sqlstr = "SELECT COUNT(*) as total FROM movimientos_inventario WHERE DATE(movCreatedAt) = CURDATE();";
        $result = self::obtenerUnRegistro($sqlstr, []);
        return $result ? intval($result["total"]) : 0;
    }

    public static function getMermasMesActual()
    {
        $sqlstr = "SELECT SUM(movCantidad) as total FROM movimientos_inventario 
                   WHERE movTipo = 'MER' 
                     AND YEAR(movCreatedAt) = YEAR(CURDATE()) 
                     AND MONTH(movCreatedAt) = MONTH(CURDATE());";
        $result = self::obtenerUnRegistro($sqlstr, []);
        return $result && $result["total"] ? intval($result["total"]) : 0;
    }

    public static function getTotalProductosAgotados()
    {
        $sqlstr = "SELECT COUNT(*) as total FROM productos WHERE invPrdStock = 0 AND invPrdEst = 'ACT';";
        $result = self::obtenerUnRegistro($sqlstr, []);
        return $result ? intval($result["total"]) : 0;
    }

    public static function getProductosAgotadosList()
    {
        $sqlstr = "SELECT invPrdId, invPrdBrCod, invPrdDsc, invPrdStockMin 
                   FROM productos 
                   WHERE invPrdStock = 0 AND invPrdEst = 'ACT'
                   ORDER BY invPrdDsc ASC;";
        return self::obtenerRegistros($sqlstr, []);
    }

    public static function getLotesPorVencerList()
    {
        $sqlstr = "SELECT l.loteCod, l.loteCantActual, l.loteFechaVencimiento, p.invPrdDsc 
                   FROM lotes_inventario l
                   INNER JOIN productos p ON l.invPrdId = p.invPrdId
                   WHERE l.loteCantActual > 0 
                     AND l.loteFechaVencimiento IS NOT NULL 
                     AND l.loteFechaVencimiento <= DATE_ADD(NOW(), INTERVAL 30 DAY)
                   ORDER BY l.loteFechaVencimiento ASC, p.invPrdDsc ASC;";
        return self::obtenerRegistros($sqlstr, []);
    }

    public static function getProductosStockBajoList()
    {
        $sqlstr = "SELECT invPrdId, invPrdBrCod, invPrdDsc, invPrdStock, invPrdStockMin 
                   FROM productos 
                   WHERE invPrdStock <= invPrdStockMin AND invPrdEst = 'ACT'
                   ORDER BY invPrdDsc ASC;";
        return self::obtenerRegistros($sqlstr, []);
    }

    public static function getMermasMesActualList()
    {
        $sqlstr = "SELECT m.movCreatedAt, m.movCantidad, m.movMotivo, p.invPrdDsc 
                   FROM movimientos_inventario m
                   INNER JOIN productos p ON m.invPrdId = p.invPrdId
                   WHERE m.movTipo = 'MER' 
                     AND YEAR(m.movCreatedAt) = YEAR(CURDATE()) 
                     AND MONTH(m.movCreatedAt) = MONTH(CURDATE())
                   ORDER BY m.movCreatedAt DESC;";
        return self::obtenerRegistros($sqlstr, []);
    }
}


