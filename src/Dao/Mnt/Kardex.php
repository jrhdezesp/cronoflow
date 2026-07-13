<?php

namespace Dao\Mnt;

class Kardex extends \Dao\Table
{
    /**
     * Obtiene los movimientos de inventario filtrados dinámicamente.
     *
     * @param string $searchQuery
     * @param string $movTipo
     * @param string $year
     * @param string $month
     * @param string $fechaInicio
     * @param string $fechaFin
     * @param int $page
     * @param int $pageSize
     * @return array
     */
    public static function getMovimientosFiltered(
        $searchQuery = "",
        $movTipo = "",
        $year = "",
        $month = "",
        $fechaInicio = "",
        $fechaFin = "",
        $page = 1,
        $pageSize = 50
    ) {
        $sql = "SELECT 
                    m.movId, 
                    m.invPrdId, 
                    m.loteId, 
                    m.movTipo, 
                    m.movCantidad, 
                    m.movMotivo, 
                    m.movCreatedAt, 
                    m.movCreatedBy,
                    p.invPrdBrCod, 
                    p.invPrdDsc,
                    u.username,
                    l.loteCod
                FROM movimientos_inventario m
                INNER JOIN productos p ON m.invPrdId = p.invPrdId
                INNER JOIN usuario u ON m.movCreatedBy = u.usercod
                LEFT JOIN lotes_inventario l ON m.loteId = l.loteId
                WHERE 1 = 1";

        $params = [];

        if (!empty($searchQuery)) {
            $sql .= " AND (p.invPrdDsc LIKE :searchQuery OR p.invPrdBrCod LIKE :searchQuery)";
            $params["searchQuery"] = $searchQuery;
        }

        if (!empty($movTipo)) {
            $sql .= " AND m.movTipo = :movTipo";
            $params["movTipo"] = $movTipo;
        }

        if (!empty($year)) {
            $sql .= " AND YEAR(m.movCreatedAt) = :year";
            $params["year"] = $year;
        }

        if (!empty($month)) {
            $sql .= " AND MONTH(m.movCreatedAt) = :month";
            $params["month"] = $month;
        }

        if (!empty($fechaInicio) && !empty($fechaFin)) {
            $sql .= " AND DATE(m.movCreatedAt) BETWEEN :fechaInicio AND :fechaFin";
            $params["fechaInicio"] = $fechaInicio;
            $params["fechaFin"] = $fechaFin;
        }

        $sql .= " ORDER BY m.movCreatedAt DESC";

        if ($pageSize > 0) {
            $offset = ($page - 1) * $pageSize;
            $sql .= " LIMIT :limit OFFSET :offset";
            $params["limit"] = intval($pageSize);
            $params["offset"] = intval($offset);
        }

        $sql .= ";";

        return self::obtenerRegistros($sql, $params);
    }

    /**
     * Cuenta los movimientos filtrados (para paginación).
     */
    public static function countMovimientosFiltered(
        $searchQuery = "",
        $movTipo = "",
        $year = "",
        $month = "",
        $fechaInicio = "",
        $fechaFin = ""
    ) {
        $sql = "SELECT COUNT(*) as total
                FROM movimientos_inventario m
                INNER JOIN productos p ON m.invPrdId = p.invPrdId
                INNER JOIN usuario u ON m.movCreatedBy = u.usercod
                LEFT JOIN lotes_inventario l ON m.loteId = l.loteId
                WHERE 1 = 1";

        $params = [];

        if (!empty($searchQuery)) {
            $sql .= " AND (p.invPrdDsc LIKE :searchQuery OR p.invPrdBrCod LIKE :searchQuery)";
            $params["searchQuery"] = $searchQuery;
        }

        if (!empty($movTipo)) {
            $sql .= " AND m.movTipo = :movTipo";
            $params["movTipo"] = $movTipo;
        }

        if (!empty($year)) {
            $sql .= " AND YEAR(m.movCreatedAt) = :year";
            $params["year"] = $year;
        }

        if (!empty($month)) {
            $sql .= " AND MONTH(m.movCreatedAt) = :month";
            $params["month"] = $month;
        }

        if (!empty($fechaInicio) && !empty($fechaFin)) {
            $sql .= " AND DATE(m.movCreatedAt) BETWEEN :fechaInicio AND :fechaFin";
            $params["fechaInicio"] = $fechaInicio;
            $params["fechaFin"] = $fechaFin;
        }

        $sql .= ";";

        $result = self::obtenerUnRegistro($sql, $params);
        return $result ? intval($result["total"]) : 0;
    }
}