<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Views\Renderer;

class Usuarios extends PrivateController
{
    public function __construct()
    {
        parent::__construct();
        if (!\Utilities\Security::isInRol(\Utilities\Security::getUserId(), "PRP")) {
            throw new \Controllers\PrivateNoAuthException();
        }
    }
    public function run(): void
    {
        $viewData = array();
        
        $rawUsers = \Dao\Security\Security::getUsuarios();
        $usersFormatted = [];
        $rolesDsc = [
            "PRP" => "Propietario / SuperUser",
            "ADM" => "Administrador / Empleado",
            "AUD" => "Auditor de Solo Lectura",
            "PUBLICO" => "Público",
            "PBL" => "Público"
        ];
        foreach ($rawUsers as $user) {
            $statusDsc = "Inactivo";
            $statusClass = "badge-error";
            if ($user["userest"] === "ACT") {
                $statusDsc = "Activo";
                $statusClass = "badge-success";
            } elseif ($user["userest"] === "BLQ") {
                $statusDsc = "Bloqueado";
                $statusClass = "badge-warning";
            }

            $user["userest_dsc"] = $statusDsc;
            $user["userest_class"] = $statusClass;
            $user["usertipo_dsc"] = isset($rolesDsc[$user["usertipo"]]) ? $rolesDsc[$user["usertipo"]] : $user["usertipo"];
            $usersFormatted[] = $user;
        }

        $viewData["Usuarios"] = $usersFormatted;
        $viewData["CanInsert"] = self::isFeatureAutorized("Controllers\\Mnt\\Usuario\\New");
        $viewData["CanUpdate"] = self::isFeatureAutorized("Controllers\\Mnt\\Usuario\\Upd");
        $viewData["CanDelete"] = false; // Completely disabled to protect logs/audit trail
        $viewData["CanView"] = self::isFeatureAutorized("Controllers\\Mnt\\Usuario\\Dsp");

        Renderer::render("mnt/usuarios", $viewData);
    }
}

/*
{
    Usuarios: [],
    CanInsert: true,
    CanUpdate: true,
    CanDelete: true,
    CanView: true
}

withContext =
root =
{
    Usuarios: [],
    CanInsert: true,
    CanUpdate: true,
    CanDelete: true,
    CanView: true
}

foreach Usuarios
    withContext = Usuarios
    
    root =
        {
            Usuarios: [],
            CanInsert: true,
            CanUpdate: true,
            CanDelete: true,
            CanView: true
        }
endfor Usuarios
*/

?>
