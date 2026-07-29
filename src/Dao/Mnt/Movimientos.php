<?php

namespace Dao\Mnt;

class Movimientos extends \Dao\Table
{
    /**
     * Obtiene todos los productos activos.
     */
    static public function getProductosActivos()
    {
        $sqlstr = "SELECT 
                        invPrdId,
                        invPrdCodInt,
                        invPrdBrCod,
                        invPrdDsc,
                        invPrdStock,
                        invPrdStockMin,
                        invPrdCosto
                   FROM productos
                   WHERE invPrdEst = 'ACT'
                   ORDER BY invPrdDsc ASC;";

        return self::obtenerRegistros($sqlstr, []);
    }

    /**
     * Obtiene un producto por ID.
     */
    static public function getProducto($invPrdId)
    {
        $sqlstr = "SELECT *
                   FROM productos
                   WHERE invPrdId = :invPrdId;";

        return self::obtenerUnRegistro(
            $sqlstr,
            [
                "invPrdId" => $invPrdId
            ]
        );
    }

    /**
     * Obtiene los batches activos de un producto.
     */
    static public function getBatchesByProducto($invPrdId)
    {
        return Batches::getActiveBatches($invPrdId);
    }

    /**
     * Procesa un movimiento de inventario.
     *
     * ENT = Entrada
     * SAL = Salida
     * MER = Merma
     *
     * RES y CON se manejan desde ProductsStock
     * porque forman parte del flujo de ventas.
     */
    static public function procesarMovimiento(
        $invPrdId,
        $batchId,
        $movementType,
        $quantity,
        $reason,
        $userId
    ) {
        $conn = self::getConn();

        if (!in_array($movementType, ["ENT", "SAL", "MER"])) {
            throw new \Exception(
                "El tipo de movimiento no es válido para este módulo."
            );
        }

        if ($quantity <= 0) {
            throw new \Exception(
                "La cantidad debe ser mayor a cero."
            );
        }

        $product = self::getProducto($invPrdId);

        if (!$product) {
            throw new \Exception(
                "El producto seleccionado no existe."
            );
        }

        $conn->beginTransaction();

        try {

            $batch = null;

            /*
             * ENTRADA
             */
            if ($movementType === "ENT") {

                if (empty($batchId)) {
                    throw new \Exception(
                        "Debe seleccionar un batch para registrar una entrada."
                    );
                }

                $batch = Batches::getBatchById($batchId);

                if (!$batch) {
                    throw new \Exception(
                        "El batch seleccionado no existe."
                    );
                }

                if (intval($batch["invPrdId"]) !== intval($invPrdId)) {
                    throw new \Exception(
                        "El batch seleccionado no pertenece al producto."
                    );
                }

                /*
                 * Incrementar batch
                 */
                Batches::incrementBatch(
                    $batchId,
                    $quantity
                );

                /*
                 * Incrementar stock del producto
                 */
                $sqlupd = "UPDATE productos
                           SET invPrdStock = invPrdStock + ?,
                               invPrdModifiedBy = ?,
                               invPrdModifiedAt = NOW()
                           WHERE invPrdId = ?;";

                $stmt = $conn->prepare($sqlupd);
                $stmt->bindValue(1, intval($quantity), \PDO::PARAM_INT);
                $stmt->bindValue(2, intval($userId), \PDO::PARAM_INT);
                $stmt->bindValue(3, intval($invPrdId), \PDO::PARAM_INT);
                $stmt->execute();
            }

            /*
             * SALIDA / MERMA
             */
            if (
                $movementType === "SAL" ||
                $movementType === "MER"
            ) {

                /*
                 * Validar stock general
                 */
                if (
                    intval($product["invPrdStock"])
                    < $quantity
                ) {
                    throw new \Exception(
                        "No existe suficiente stock disponible para realizar el movimiento."
                    );
                }

                /*
                 * Debe existir un batch
                 */
                if (empty($batchId)) {
                    throw new \Exception(
                        "Debe seleccionar un batch para realizar una salida o merma."
                    );
                }

                $batch = Batches::getBatchById($batchId);

                if (!$batch) {
                    throw new \Exception(
                        "El batch seleccionado no existe."
                    );
                }

                if (
                    intval($batch["invPrdId"])
                    !== intval($invPrdId)
                ) {
                    throw new \Exception(
                        "El batch seleccionado no pertenece al producto."
                    );
                }

                /*
                 * Validar cantidad disponible
                 */
                if (
                    intval($batch["batchQuantityAvailable"])
                    < $quantity
                ) {
                    throw new \Exception(
                        "El batch seleccionado no tiene suficiente stock disponible."
                    );
                }

                /*
                 * Descontar del batch
                 */
                Batches::decrementBatchQuantityAvailable(
                    $batchId,
                    $quantity
                );

                /*
                 * Descontar del producto
                 */
                $sqlupd = "UPDATE productos
                           SET invPrdStock = invPrdStock - ?,
                               invPrdModifiedBy = ?,
                               invPrdModifiedAt = NOW()
                           WHERE invPrdId = ?;";

                $stmt = $conn->prepare($sqlupd);
                $stmt->bindValue(1, intval($quantity), \PDO::PARAM_INT);
                $stmt->bindValue(2, intval($userId), \PDO::PARAM_INT);
                $stmt->bindValue(3, intval($invPrdId), \PDO::PARAM_INT);
                $stmt->execute();
            }

            /*
             * Registrar historial del movimiento
             */
            $movementResult =
                StockMovements::registerMovement(
                    $invPrdId,
                    $batchId,
                    $movementType,
                    $quantity,
                    $reason,
                    "stock_adjustment",
                    null,
                    $userId,
                    $conn
                );

            if (!$movementResult) {
                throw new \Exception(
                    "No se pudo registrar el movimiento de inventario."
                );
            }

            /*
             * Confirmar transacción
             */
            $conn->commit();

            return true;
        } catch (\Exception $ex) {

            /*
             * Revertir todos los cambios
             */
            if ($conn->inTransaction()) {
                $conn->rollBack();
            }

            throw $ex;
        }
    }
}
