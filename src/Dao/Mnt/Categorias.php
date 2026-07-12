<?php

namespace Dao\Mnt;

class Categorias extends \Dao\Table
{
    static public function getCategorias()
    {
        $sqlstr = "SELECT * FROM categorias;";
        return self::obtenerRegistros($sqlstr, []);
    }

    static public function getCategoriasActivas()
    {
        $sqlstr = "SELECT * FROM categorias WHERE catest = 'ACT';";
        return self::obtenerRegistros($sqlstr, []);
    }

    static public function getCategoriaById($catid)
    {
        $sqlstr = "SELECT * FROM categorias WHERE catid = :catid;";
        return self::obtenerUnRegistro($sqlstr, ["catid" => $catid]);
    }

    static public function getCategoriaByName($catnom)
    {
        $sqlstr = "SELECT * FROM categorias WHERE catnom = :catnom;";
        return self::obtenerUnRegistro($sqlstr, ["catnom" => $catnom]);
    }

    static public function insertCategoria($catnom, $catest)
    {
        $sqlins = "INSERT INTO categorias (catnom, catest) VALUES (:catnom, :catest);";
        return self::executeNonQuery($sqlins, [
            "catnom" => $catnom,
            "catest" => $catest
        ]);
    }

    static public function updateCategoria($catid, $catnom, $catest)
    {
        $sqlupd = "UPDATE categorias SET catnom = :catnom, catest = :catest WHERE catid = :catid;";
        return self::executeNonQuery($sqlupd, [
            "catnom" => $catnom,
            "catest" => $catest,
            "catid" => $catid
        ]);
    }

    static public function deleteCategoria($catid)
    {
        $sqlupd = "UPDATE categorias SET catest = 'INA' WHERE catid = :catid;";
        return self::executeNonQuery($sqlupd, ["catid" => $catid]);
    }
}
