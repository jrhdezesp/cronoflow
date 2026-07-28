<?php

namespace Dao\Mnt;

class ProductsStock extends \Dao\Table
{
    static public function getProductStock($invPrdId)
    {
        $sqlstr = "SELECT invPrdStock, invPrdStockMin, invPrdTip FROM productos WHERE invPrdId = :invPrdId;";
        return self::obtenerUnRegistro($sqlstr, ["invPrdId" => $invPrdId]);
    }

    static public function adjustProductStock($invPrdId, $newStock, $userId)
    {
        $sqlupd = "UPDATE productos SET invPrdStock = :newStock, invPrdModifiedBy = :userId, invPrdModifiedAt = NOW() WHERE invPrdId = :invPrdId;";
        return self::executeNonQuery($sqlupd, [
            "newStock" => $newStock,
            "userId" => $userId,
            "invPrdId" => $invPrdId
        ]);
    }

    static public function reserveStock($invPrdId, $batchId, $quantity, $userId)
    {
        $conn = self::getConn();
        $conn->beginTransaction();

        try {
            $batch = Batches::getBatchById($batchId);
            if (!$batch) {
                throw new \Exception("Batch no encontrado para reserva.");
            }

            Batches::reserveBatch($batchId, $quantity);
            StockMovements::registerMovement(
                $invPrdId,
                $batchId,
                'RES',
                $quantity,
                'Reserva de stock para venta',
                'sale',
                null,
                $userId
            );

            $product = self::getProductStock($invPrdId);
            if (!$product) {
                throw new \Exception("Producto no encontrado al reservar stock.");
            }

            $conn->commit();
            return true;
        } catch (\Exception $ex) {
            $conn->rollBack();
            throw $ex;
        }
    }

    static public function consumeStock($invPrdId, $batchId, $quantity, $userId)
    {
        $conn = self::getConn();
        $conn->beginTransaction();

        try {
            Batches::consumeBatch($batchId, $quantity);
            StockMovements::registerMovement(
                $invPrdId,
                $batchId,
                'CON',
                $quantity,
                'Consumo de stock para venta',
                'sale',
                null,
                $userId
            );

            $product = self::getProductStock($invPrdId);
            if (!$product) {
                throw new \Exception("Producto no encontrado al consumir stock.");
            }

            $sqlupd = "UPDATE productos SET
                invPrdStock = invPrdStock - :quantity,
                invPrdModifiedBy = :userId,
                invPrdModifiedAt = NOW()
                WHERE invPrdId = :invPrdId;";

            self::executeNonQuery($sqlupd, [
                "invPrdId" => $invPrdId,
                "quantity" => $quantity,
                "userId" => $userId
            ]);

            $conn->commit();
            return true;
        } catch (\Exception $ex) {
            $conn->rollBack();
            throw $ex;
        }
    }

    static public function deductStock($invPrdId, $batchId, $quantity, $userId)
    {
        return self::consumeStock($invPrdId, $batchId, $quantity, $userId);
    }
}
