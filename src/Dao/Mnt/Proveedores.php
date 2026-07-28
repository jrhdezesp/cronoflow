<?php

namespace Dao\Mnt;

class Proveedores extends \Dao\Table
{
    static public function getProveedores()
    {
        $sqlstr = "SELECT * FROM proveedores ORDER BY provNombre;";
        return self::obtenerRegistros($sqlstr, []);
    }

    static public function getProveedoresActivos()
    {
        $sqlstr = "SELECT * FROM proveedores WHERE provEst = 'ACT' ORDER BY provNombre;";
        return self::obtenerRegistros($sqlstr, []);
    }

    static public function getProveedorById($provId)
    {
        $sqlstr = "SELECT * FROM proveedores WHERE provId = :provId;";
        return self::obtenerUnRegistro($sqlstr, ["provId" => $provId]);
    }

    static public function getProveedorByName($provNombre)
    {
        $sqlstr = "SELECT * FROM proveedores WHERE provNombre = :provNombre;";
        return self::obtenerUnRegistro($sqlstr, ["provNombre" => $provNombre]);
    }

    static public function newProveedor($provNombre, $provContacto, $provTelefono, $provEmail, $provDireccion, $provEst)
    {
        $sqlins = "INSERT INTO proveedores (
            provNombre, provContacto, provTelefono, provEmail, provDireccion, provEst
        ) VALUES (
            :provNombre, :provContacto, :provTelefono, :provEmail, :provDireccion, :provEst
        );";
        return self::executeNonQuery($sqlins, [
            "provNombre" => $provNombre,
            "provContacto" => $provContacto === "" ? null : $provContacto,
            "provTelefono" => $provTelefono === "" ? null : $provTelefono,
            "provEmail" => $provEmail === "" ? null : $provEmail,
            "provDireccion" => $provDireccion === "" ? null : $provDireccion,
            "provEst" => $provEst
        ]);
    }

    static public function updateProveedor($provId, $provNombre, $provContacto, $provTelefono, $provEmail, $provDireccion, $provEst)
    {
        $sqlupd = "UPDATE proveedores SET
            provNombre = :provNombre,
            provContacto = :provContacto,
            provTelefono = :provTelefono,
            provEmail = :provEmail,
            provDireccion = :provDireccion,
            provEst = :provEst
            WHERE provId = :provId;";
        return self::executeNonQuery($sqlupd, [
            "provNombre" => $provNombre,
            "provContacto" => $provContacto === "" ? null : $provContacto,
            "provTelefono" => $provTelefono === "" ? null : $provTelefono,
            "provEmail" => $provEmail === "" ? null : $provEmail,
            "provDireccion" => $provDireccion === "" ? null : $provDireccion,
            "provEst" => $provEst,
            "provId" => $provId
        ]);
    }

    static public function deleteProveedor($provId)
    {
        $sqlupd = "UPDATE proveedores SET provEst = 'INA' WHERE provId = :provId;";
        return self::executeNonQuery($sqlupd, ["provId" => $provId]);
    }
}
