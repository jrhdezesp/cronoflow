<?php

namespace Utilities;

class Validators {

    static public function IsEmpty($valor)
    {
        return preg_match("/^\s*$/", $valor) === 1;
    }

    static public function IsValidEmail($valor)
    {
        return preg_match("/^[a-z0-9_\.\+\-]+@[a-z0-9\.\-]+\.[a-z\.]{2,}$/i", $valor) === 1;
    }

    static public function IsValidPassword($valor){
        return preg_match("/^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\d\s])([^\s]){8,32}$/", $valor) === 1;
    }

    private function __construct()
    {
        
    }
    private function __clone()
    {
        
    }
}

?>
