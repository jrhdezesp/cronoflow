<?php

namespace Dao\Mnt;

class StockMovements extends \Dao\Table
{
    static public function registerMovement(
        $invPrdId,
        $batchId,
        $movementType,
        $quantity,
        $reason,
        $referenceType = null,
        $referenceId = null,
        $userId = null
    ) {
        $sqlins = "INSERT INTO stock_movements (
            invPrdId,
            batchId,
            movementType,
            quantity,
            reason,
            referenceType,
            referenceId,
            createdBy,
            createdAt
        ) VALUES (
            :invPrdId,
            :batchId,
            :movementType,
            :quantity,
            :reason,
            :referenceType,
            :referenceId,
            :createdBy,
            NOW()
        );";

        return self::executeNonQuery($sqlins, [
            "invPrdId" => $invPrdId,
            "batchId" => $batchId,
            "movementType" => $movementType,
            "quantity" => $quantity,
            "reason" => $reason,
            "referenceType" => $referenceType,
            "referenceId" => $referenceId,
            "createdBy" => $userId
        ]);
    }

    static public function getMovementsByProduct($invPrdId, $limit = 100)
    {
        $sqlstr = "SELECT sm.*, p.invPrdDsc, b.batchCode, u.username
                   FROM stock_movements sm
                   INNER JOIN productos p ON sm.invPrdId = p.invPrdId
                   LEFT JOIN batches b ON sm.batchId = b.batchId
                   LEFT JOIN usuario u ON sm.createdBy = u.usercod
                   WHERE sm.invPrdId = :invPrdId
                   ORDER BY sm.createdAt DESC
                   LIMIT :limit;";
        return self::obtenerRegistros($sqlstr, ["invPrdId" => $invPrdId, "limit" => intval($limit)]);
    }
}
