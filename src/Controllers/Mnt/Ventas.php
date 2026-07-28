<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Sales as DaoSales;
use Views\Renderer;

class Ventas extends PrivateController
{
    public function run(): void
    {
        $viewData = [
            "Sales" => [],
            "CanView" => false
        ];

        $viewData["CanView"] = $this->isFeatureAuthorized("Controllers\\Mnt\\Ventas");

        if ($viewData["CanView"]) {
            $rawSales = DaoSales::getSales();
            $formattedSales = [];
            foreach ($rawSales as $sale) {
                $formattedSales[] = [
                    "saleId" => $sale["saleId"],
                    "saleNumber" => $sale["saleNumber"],
                    "saleDate" => date("d/m/Y H:i", strtotime($sale["saleDate"])),
                    "customerName" => $sale["customerName"] ?: "Cliente General",
                    "saleTotal" => number_format(floatval($sale["saleTotal"]), 2),
                    "saleStatus" => $sale["saleStatus"],
                    "saleStatusClass" => $sale["saleStatus"] === "CLS" ? "badge-success" : ($sale["saleStatus"] === "CAN" ? "badge-error" : "badge-warning")
                ];
            }
            $viewData["Sales"] = $formattedSales;
        }

        Renderer::render("mnt/ventas", $viewData);
    }
}
