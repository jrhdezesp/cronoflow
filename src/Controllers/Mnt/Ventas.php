<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\POS as DaoPOS;
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
            $rawSales = DaoPOS::getVentas();
            $formattedSales = [];
            foreach ($rawSales as $sale) {
                $formattedSales[] = [
                    "saleId" => $sale["ventaId"],
                    "saleNumber" => $sale["ventaCod"],
                    "saleDate" => date("d/m/Y H:i", strtotime($sale["ventaCreatedAt"])),
                    "customerName" => $sale["clienteNombre"] ?: "Cliente General",
                    "saleTotal" => number_format(floatval($sale["ventaTotal"]), 2),
                    "saleStatus" => $sale["ventaEst"],
                    "saleStatusClass" => $sale["ventaEst"] === "ACT" ? "badge-success" : ($sale["ventaEst"] === "ANU" ? "badge-error" : "badge-warning")
                ];
            }
            $viewData["Sales"] = $formattedSales;
        }

        Renderer::render("mnt/ventas", $viewData);
    }
}
