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
     * @return array
     */
    public static function getMovimientosFiltered(
        $searchQuery = "",
        $movTipo = "",
        $year = "",
        $month = "",
        $fechaInicio = "",
        $fechaFin = ""
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

        // Filtro de búsqueda por nombre o código de barra
        if (!empty($searchQuery)) {
            $sql .= " AND (p.invPrdDsc LIKE :searchQuery OR p.invPrdBrCod LIKE :searchQuery)";
            $params["searchQuery"] = $searchQuery;
        }

        // Filtro por tipo de movimiento
        if (!empty($movTipo)) {
            $sql .= " AND m.movTipo = :movTipo";
            $params["movTipo"] = $movTipo;
        }

        // Filtro por año
        if (!empty($year)) {
            $sql .= " AND YEAR(m.movCreatedAt) = :year";
            $params["year"] = $year;
        }

        // Filtro por mes
        if (!empty($month)) {
            $sql .= " AND MONTH(m.movCreatedAt) = :month";
            $params["month"] = $month;
        }

        // Filtro por rango de fechas
        if (!empty($fechaInicio) && !empty($fechaFin)) {
            $sql .= " AND DATE(m.movCreatedAt) BETWEEN :fechaInicio AND :fechaFin";
            $params["fechaInicio"] = $fechaInicio;
            $params["fechaFin"] = $fechaFin;
        }

        // Ordenamiento crítico (cronológico descendente)
        $sql .= " ORDER BY m.movCreatedAt DESC;";

        return self::obtenerRegistros($sql, $params);
    }
}