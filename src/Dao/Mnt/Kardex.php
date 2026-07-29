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
                    movId,
                    invPrdId,
                    loteId,
                    movTipo,
                    movCantidad,
                    movMotivo,
                    movCreatedAt,
                    movCreatedBy,
                    invPrdBrCod,
                    invPrdDsc,
                    username,
                    loteCod
                FROM (
                    SELECT
                        sm.movementId AS movId,
                        sm.invPrdId,
                        sm.batchId AS loteId,
                        sm.movementType AS movTipo,
                        sm.quantity AS movCantidad,
                        sm.reason AS movMotivo,
                        sm.createdAt AS movCreatedAt,
                        sm.createdBy AS movCreatedBy,
                        p.invPrdBrCod,
                        p.invPrdDsc,
                        u.username,
                        b.batchCode AS loteCod
                    FROM stock_movements sm
                    INNER JOIN productos p ON sm.invPrdId = p.invPrdId
                    LEFT JOIN usuario u ON sm.createdBy = u.usercod
                    LEFT JOIN batches b ON sm.batchId = b.batchId

                    UNION ALL

                    SELECT
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
                    LEFT JOIN usuario u ON m.movCreatedBy = u.usercod
                    LEFT JOIN lotes_inventario l ON m.loteId = l.loteId
                ) AS combined
                WHERE 1 = 1";

        $params = [];

        if (!empty($searchQuery)) {
            $sql .= " AND (combined.invPrdDsc LIKE :searchQuery OR combined.invPrdBrCod LIKE :searchQuery)";
            $params["searchQuery"] = $searchQuery;
        }

        if (!empty($movTipo)) {
            $sql .= " AND combined.movTipo = :movTipo";
            $params["movTipo"] = $movTipo;
        }

        if (!empty($year)) {
            $sql .= " AND YEAR(combined.movCreatedAt) = :year";
            $params["year"] = $year;
        }

        if (!empty($month)) {
            $sql .= " AND MONTH(combined.movCreatedAt) = :month";
            $params["month"] = $month;
        }

        if (!empty($fechaInicio) && !empty($fechaFin)) {
            $sql .= " AND DATE(combined.movCreatedAt) BETWEEN :fechaInicio AND :fechaFin";
            $params["fechaInicio"] = $fechaInicio;
            $params["fechaFin"] = $fechaFin;
        }

        $sql .= " ORDER BY combined.movCreatedAt DESC";

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
                FROM (
                    SELECT
                        sm.movementId AS movId,
                        sm.invPrdId,
                        sm.batchId AS loteId,
                        sm.movementType AS movTipo,
                        sm.quantity AS movCantidad,
                        sm.reason AS movMotivo,
                        sm.createdAt AS movCreatedAt,
                        sm.createdBy AS movCreatedBy,
                        p.invPrdBrCod,
                        p.invPrdDsc,
                        u.username,
                        b.batchCode AS loteCod
                    FROM stock_movements sm
                    INNER JOIN productos p ON sm.invPrdId = p.invPrdId
                    LEFT JOIN usuario u ON sm.createdBy = u.usercod
                    LEFT JOIN batches b ON sm.batchId = b.batchId

                    UNION ALL

                    SELECT
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
                    LEFT JOIN usuario u ON m.movCreatedBy = u.usercod
                    LEFT JOIN lotes_inventario l ON m.loteId = l.loteId
                ) AS combined
                WHERE 1 = 1";

        $params = [];

        if (!empty($searchQuery)) {
            $sql .= " AND (combined.invPrdDsc LIKE :searchQuery OR combined.invPrdBrCod LIKE :searchQuery)";
            $params["searchQuery"] = $searchQuery;
        }

        if (!empty($movTipo)) {
            $sql .= " AND combined.movTipo = :movTipo";
            $params["movTipo"] = $movTipo;
        }

        if (!empty($year)) {
            $sql .= " AND YEAR(combined.movCreatedAt) = :year";
            $params["year"] = $year;
        }

        if (!empty($month)) {
            $sql .= " AND MONTH(combined.movCreatedAt) = :month";
            $params["month"] = $month;
        }

        if (!empty($fechaInicio) && !empty($fechaFin)) {
            $sql .= " AND DATE(combined.movCreatedAt) BETWEEN :fechaInicio AND :fechaFin";
            $params["fechaInicio"] = $fechaInicio;
            $params["fechaFin"] = $fechaFin;
        }

        $sql .= ";";

        $result = self::obtenerUnRegistro($sql, $params);
        return $result ? intval($result["total"]) : 0;
    }
}