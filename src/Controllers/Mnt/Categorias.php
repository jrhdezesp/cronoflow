<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Categorias as DaoCategorias;
use Views\Renderer;

class Categorias extends PrivateController
{
    public function run(): void
    {
        $viewData = [
            "Categorias" => [],
            "CanInsert" => false,
            "CanUpdate" => false,
            "CanDelete" => false,
            "CanView" => false
        ];

        // Mapear los permisos de seguridad
        $viewData["CanInsert"] = self::isFeatureAutorized("Controllers\\Mnt\\Categoria\\New");
        $viewData["CanUpdate"] = self::isFeatureAutorized("Controllers\\Mnt\\Categoria\\Upd");
        $viewData["CanView"] = self::isFeatureAutorized("Controllers\\Mnt\\Categoria\\Dsp");

        // Cargar todas las categorías
        $rawCategorias = DaoCategorias::getCategorias();
        $formattedCategorias = [];
        foreach ($rawCategorias as $cat) {
            $est = $cat["catest"];
            if ($est === "ACT") {
                $cat["catest_dsc"] = "Activo";
                $cat["catest_class"] = "badge-success";
            } elseif ($est === "INA") {
                $cat["catest_dsc"] = "Inactivo";
                $cat["catest_class"] = "badge-error";
            } elseif ($est === "PLN") {
                $cat["catest_dsc"] = "Planificación";
                $cat["catest_class"] = "badge-warning";
            } else {
                $cat["catest_dsc"] = $est;
                $cat["catest_class"] = "";
            }
            $formattedCategorias[] = $cat;
        }

        $viewData["Categorias"] = $formattedCategorias;

        Renderer::render("mnt/categorias", $viewData);
    }
}
