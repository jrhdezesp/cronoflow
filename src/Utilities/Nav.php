<?php

namespace Utilities;

class Nav {

    public static function setNavContext(){
        $tmpNAVIGATION = array();
        $userID = \Utilities\Security::getUserId();

        // 1. Catálogo de Productos
        if (\Utilities\Security::isAuthorized($userID, "Controllers\\Mnt\\Productos")) {
            $tmpNAVIGATION[] = array(
                "nav_url" => "index.php?page=mnt_productos",
                "nav_label" => "Catálogo de Productos",
                "nav_icon" => "fas fa-boxes"
            );
        }

        // 2. Categorías
        if (\Utilities\Security::isAuthorized($userID, "Controllers\\Mnt\\Categorias")) {
            $tmpNAVIGATION[] = array(
                "nav_url" => "index.php?page=mnt_categorias",
                "nav_label" => "Categorías",
                "nav_icon" => "fas fa-folder"
            );
        }

        // 3. Proveedores
        if (\Utilities\Security::isAuthorized($userID, "Controllers\\Mnt\\Proveedores")) {
            $tmpNAVIGATION[] = array(
                "nav_url" => "index.php?page=mnt_proveedores",
                "nav_label" => "Proveedores",
                "nav_icon" => "fas fa-truck"
            );
        }

        // 4. Kardex (Movimientos)
        if (\Utilities\Security::isAuthorized($userID, "Controllers\\Mnt\\Kardex")) {
            $tmpNAVIGATION[] = array(
                "nav_url" => "index.php?page=mnt_kardex",
                "nav_label" => "Kardex (Historial)",
                "nav_icon" => "fas fa-exchange-alt"
            );
        }



        // 5. Gestión de Usuarios
        if (\Utilities\Security::isAuthorized($userID, "Controllers\\Mnt\\Usuarios")) {
            $tmpNAVIGATION[] = array(
                "nav_url" => "index.php?page=mnt_usuarios",
                "nav_label" => "Usuarios",
                "nav_icon" => "fas fa-users-cog"
            );
        }

        // 6. Perfil del Usuario (Removido para evitar redundancia, se accede desde la tarjeta de usuario en el pie de página)
       
        \Utilities\Context::setContext("NAVIGATION", $tmpNAVIGATION);
    }



    private function __construct()
    {
        
    }
    private function __clone()
    {
        
    }
}
?>
