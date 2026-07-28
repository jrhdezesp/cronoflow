<?php

namespace Dao\Mnt;

class Sales extends \Dao\Table
{
    static public function newSale(
        $saleNumber,
        $saleDate,
        $customerName,
        $saleTotal,
        $userId,
        $status = "OPN"
    ) {
        $sqlins = "INSERT INTO sales (
            saleNumber,
            saleDate,
            customerName,
            saleTotal,
            saleStatus,
            createdBy,
            createdAt,
            modifiedAt
        ) VALUES (
            :saleNumber,
            :saleDate,
            :customerName,
            :saleTotal,
            :saleStatus,
            :createdBy,
            NOW(),
            NOW()
        );";

        $result = self::executeNonQuery($sqlins, [
            "saleNumber" => $saleNumber,
            "saleDate" => $saleDate,
            "customerName" => $customerName,
            "saleTotal" => $saleTotal,
            "saleStatus" => $status,
            "createdBy" => $userId
        ]);

        if ($result) {
            return intval(self::getConn()->lastInsertId());
        }
        return false;
    }

    static public function addSaleItem(
        $saleId,
        $invPrdId,
        $batchId,
        $quantity,
        $unitPrice,
        $totalPrice
    ) {
        $sqlins = "INSERT INTO sale_items (
            saleId,
            invPrdId,
            batchId,
            quantity,
            unitPrice,
            totalPrice
        ) VALUES (
            :saleId,
            :invPrdId,
            :batchId,
            :quantity,
            :unitPrice,
            :totalPrice
        );";

        return self::executeNonQuery($sqlins, [
            "saleId" => $saleId,
            "invPrdId" => $invPrdId,
            "batchId" => $batchId,
            "quantity" => $quantity,
            "unitPrice" => $unitPrice,
            "totalPrice" => $totalPrice
        ]);
    }

    static public function getSaleById($saleId)
    {
        $sqlstr = "SELECT * FROM sales WHERE saleId = :saleId;";
        return self::obtenerUnRegistro($sqlstr, ["saleId" => $saleId]);
    }

    static public function getSaleItems($saleId)
    {
        $sqlstr = "SELECT si.*, p.invPrdDsc, p.invPrdBrCod, b.batchCode
                   FROM sale_items si
                   INNER JOIN productos p ON si.invPrdId = p.invPrdId
                   LEFT JOIN batches b ON si.batchId = b.batchId
                   WHERE si.saleId = :saleId;";
        return self::obtenerRegistros($sqlstr, ["saleId" => $saleId]);
    }

    static public function getSales()
    {
        $sqlstr = "SELECT * FROM sales ORDER BY saleDate DESC;";
        return self::obtenerRegistros($sqlstr, []);
    }

    static public function closeSale($saleId)
    {
        $sqlupd = "UPDATE sales SET saleStatus = 'CLS', modifiedAt = NOW() WHERE saleId = :saleId;";
        return self::executeNonQuery($sqlupd, ["saleId" => $saleId]);
    }
}
