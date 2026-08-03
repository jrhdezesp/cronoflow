<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\POS as DaoPOS;
use Views\Renderer;

class Clientes extends PrivateController
{
    public function run(): void
    {
        $viewData = [
            "Clientes" => [],
            "CanInsert" => false,
            "CanUpdate" => false,
            "CanView" => true
        ];

        $viewData["CanView"] = $this->isFeatureAuthorized("Controllers\\Mnt\\Clientes");
        $viewData["Clientes"] = DaoPOS::getClientes();

        Renderer::render("mnt/clientes", $viewData);
    }
}
