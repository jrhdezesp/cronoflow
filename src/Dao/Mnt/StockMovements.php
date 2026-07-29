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
        $userId = null,
        $conn = null
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
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            NOW()
        );";

        $stmt = $conn ? $conn->prepare($sqlins) : self::getConn()->prepare($sqlins);
        $stmt->bindValue(1, intval($invPrdId), \PDO::PARAM_INT);
        $stmt->bindValue(2, $batchId !== null ? intval($batchId) : null, \PDO::PARAM_INT);
        $stmt->bindValue(3, $movementType, \PDO::PARAM_STR);
        $stmt->bindValue(4, intval($quantity), \PDO::PARAM_INT);
        $stmt->bindValue(5, $reason, \PDO::PARAM_STR);
        $stmt->bindValue(6, $referenceType, \PDO::PARAM_STR);
        $stmt->bindValue(7, $referenceId !== null ? intval($referenceId) : null, \PDO::PARAM_INT);
        $stmt->bindValue(8, $userId !== null ? intval($userId) : null, \PDO::PARAM_INT);
        return $stmt->execute();
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
