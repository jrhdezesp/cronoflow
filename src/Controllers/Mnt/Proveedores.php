<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Proveedores as DaoProveedores;
use Views\Renderer;

class Proveedores extends PrivateController
{
    public function run(): void
    {
        $viewData = [
            "Proveedores" => [],
            "CanInsert" => false,
            "CanUpdate" => false,
            "CanView" => false
        ];

        $viewData["CanInsert"] = self::isFeatureAutorized("Controllers\\Mnt\\Proveedor\\New");
        $viewData["CanUpdate"] = self::isFeatureAutorized("Controllers\\Mnt\\Proveedor\\Upd");
        $viewData["CanView"] = self::isFeatureAutorized("Controllers\\Mnt\\Proveedor\\Dsp");

        $rawProveedores = DaoProveedores::getProveedores();
        $formattedProveedores = [];
        foreach ($rawProveedores as $prov) {
            if ($prov["provEst"] === "ACT") {
                $prov["provEst_dsc"] = "Activo";
                $prov["provEst_class"] = "badge-success";
            } elseif ($prov["provEst"] === "INA") {
                $prov["provEst_dsc"] = "Inactivo";
                $prov["provEst_class"] = "badge-error";
            } else {
                $prov["provEst_dsc"] = $prov["provEst"];
                $prov["provEst_class"] = "";
            }
            $formattedProveedores[] = $prov;
        }

        $viewData["Proveedores"] = $formattedProveedores;
        Renderer::render("mnt/proveedores", $viewData);
    }
}
