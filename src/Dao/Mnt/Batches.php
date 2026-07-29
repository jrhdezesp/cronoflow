<?php

namespace Dao\Mnt;

class Batches extends \Dao\Table
{
    static public function getBatchById($batchId)
    {
        $sqlstr = "SELECT * FROM batches WHERE batchId = :batchId;";
        return self::obtenerUnRegistro($sqlstr, ["batchId" => $batchId]);
    }

    static public function getBatchByCode($invPrdId, $batchCode)
    {
        $sqlstr = "SELECT * FROM batches WHERE invPrdId = :invPrdId AND batchCode = :batchCode;";
        return self::obtenerUnRegistro($sqlstr, ["invPrdId" => $invPrdId, "batchCode" => $batchCode]);
    }

    static public function getActiveBatches($invPrdId)
    {
        $sqlstr = "SELECT * FROM batches
                   WHERE invPrdId = :invPrdId
                     AND batchStatus = 'ACT'
                     AND (batchQuantityAvailable + batchQuantityReserved) > 0
                   ORDER BY COALESCE(batchFechaVencimiento, '9999-12-31') ASC, batchFechaIngreso ASC;";
        return self::obtenerRegistros($sqlstr, ["invPrdId" => $invPrdId]);
    }

    static public function createBatch($invPrdId, $batchCode, $cantidad, $fechaVencimiento, $costoUnitario)
    {
        $existing = self::getBatchByCode($invPrdId, $batchCode);
        if ($existing) {
            throw new \Exception("El código de batch '$batchCode' ya existe para este producto.");
        }

        $sqlins = "INSERT INTO batches (
            invPrdId,
            batchCode,
            batchQuantityOriginal,
            batchQuantityAvailable,
            batchQuantityReserved,
            batchFechaIngreso,
            batchFechaVencimiento,
            batchCostoUnitario,
            batchStatus,
            createdAt,
            updatedAt
        ) VALUES (
            :invPrdId,
            :batchCode,
            :cantidad,
            :cantidad,
            0,
            NOW(),
            :fechaVencimiento,
            :costoUnitario,
            'ACT',
            NOW(),
            NOW()
        );";

        return self::executeNonQuery($sqlins, [
            "invPrdId" => $invPrdId,
            "batchCode" => $batchCode,
            "cantidad" => $cantidad,
            "fechaVencimiento" => empty($fechaVencimiento) ? null : $fechaVencimiento,
            "costoUnitario" => $costoUnitario
        ]);
    }

    static public function incrementBatch($batchId, $cantidad, $costoUnitario = null)
    {
        $batch = self::getBatchById($batchId);
        if (!$batch) {
            throw new \Exception("Batch no encontrado para incrementar.");
        }

        $conn = self::getConn();

        $sqlupd = "UPDATE batches SET
            batchQuantityOriginal = batchQuantityOriginal + ?,
            batchQuantityAvailable = batchQuantityAvailable + ?,
            batchStatus = 'ACT',
            updatedAt = NOW()
            WHERE batchId = ?;";

        $stmt = $conn->prepare($sqlupd);
        $stmt->bindValue(1, intval($cantidad), \PDO::PARAM_INT);
        $stmt->bindValue(2, intval($cantidad), \PDO::PARAM_INT);
        $stmt->bindValue(3, intval($batchId), \PDO::PARAM_INT);
        $result = $stmt->execute();

        if ($result && $costoUnitario !== null) {
            $sqlupdCost = "UPDATE batches SET batchCostoUnitario = ? WHERE batchId = ?;";
            $stmtCost = $conn->prepare($sqlupdCost);
            $stmtCost->bindValue(1, $costoUnitario, \PDO::PARAM_STR);
            $stmtCost->bindValue(2, intval($batchId), \PDO::PARAM_INT);
            $stmtCost->execute();
        }

        return $result;
    }

    static public function reserveBatch($batchId, $quantity)
    {
        $batch = self::getBatchById($batchId);
        if (!$batch) {
            throw new \Exception("Batch no encontrado para reserva.");
        }
        if ($batch["batchQuantityAvailable"] < $quantity) {
            throw new \Exception("No hay suficiente stock disponible en el batch para reservar.");
        }

        $sqlupd = "UPDATE batches SET
            batchQuantityAvailable = batchQuantityAvailable - :quantity,
            batchQuantityReserved = batchQuantityReserved + :quantity,
            batchStatus = CASE WHEN (batchQuantityAvailable - :quantity + batchQuantityReserved + :quantity) = 0 THEN 'AGT' ELSE 'ACT' END,
            updatedAt = NOW()
            WHERE batchId = :batchId;";
        return self::executeNonQuery($sqlupd, [
            "batchId" => $batchId,
            "quantity" => $quantity
        ]);
    }

    static public function releaseBatchReservation($batchId, $quantity)
    {
        $batch = self::getBatchById($batchId);
        if (!$batch) {
            throw new \Exception("Batch no encontrado para liberar reserva.");
        }
        if ($batch["batchQuantityReserved"] < $quantity) {
            throw new \Exception("La cantidad de reserva a liberar excede lo reservado.");
        }

        $sqlupd = "UPDATE batches SET
            batchQuantityAvailable = batchQuantityAvailable + :quantity,
            batchQuantityReserved = batchQuantityReserved - :quantity,
            batchStatus = 'ACT',
            updatedAt = NOW()
            WHERE batchId = :batchId;";
        return self::executeNonQuery($sqlupd, [
            "batchId" => $batchId,
            "quantity" => $quantity
        ]);
    }

    static public function consumeBatch($batchId, $quantity)
    {
        $batch = self::getBatchById($batchId);
        if (!$batch) {
            throw new \Exception("Batch no encontrado para consumo.");
        }

        $available = intval($batch["batchQuantityAvailable"]);
        $reserved = intval($batch["batchQuantityReserved"]);
        $consumeFromReserved = min($reserved, $quantity);
        $consumeFromAvailable = $quantity - $consumeFromReserved;

        if ($consumeFromAvailable > $available) {
            throw new \Exception("No hay suficiente stock en el batch para consumir la cantidad solicitada.");
        }

        $sqlupd = "UPDATE batches SET
            batchQuantityAvailable = batchQuantityAvailable - :consumeFromAvailable,
            batchQuantityReserved = batchQuantityReserved - :consumeFromReserved,
            batchStatus = CASE WHEN (batchQuantityAvailable - :consumeFromAvailable + batchQuantityReserved - :consumeFromReserved) = 0 THEN 'AGT' ELSE 'ACT' END,
            updatedAt = NOW()
            WHERE batchId = :batchId;";

        return self::executeNonQuery($sqlupd, [
            "batchId" => $batchId,
            "consumeFromAvailable" => $consumeFromAvailable,
            "consumeFromReserved" => $consumeFromReserved
        ]);
    }

    static public function decrementBatchQuantityAvailable($batchId, $quantity)
    {
        $batch = self::getBatchById($batchId);
        if (!$batch) {
            throw new \Exception("Batch no encontrado para decremento.");
        }
        if ($batch["batchQuantityAvailable"] < $quantity) {
            throw new \Exception("No hay suficiente stock disponible para descontar del batch.");
        }

        $sqlupd = "UPDATE batches SET
            batchQuantityAvailable = batchQuantityAvailable - ?,
            batchStatus = CASE WHEN (batchQuantityAvailable - ? + batchQuantityReserved) = 0 THEN 'AGT' ELSE 'ACT' END,
            updatedAt = NOW()
            WHERE batchId = ?;";

        $conn = self::getConn();
        $stmt = $conn->prepare($sqlupd);
        $stmt->bindValue(1, intval($quantity), \PDO::PARAM_INT);
        $stmt->bindValue(2, intval($quantity), \PDO::PARAM_INT);
        $stmt->bindValue(3, intval($batchId), \PDO::PARAM_INT);
        return $stmt->execute();
    }
}
