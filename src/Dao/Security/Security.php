<?php
namespace Dao\Security;

if (version_compare(phpversion(), '7.4.0', '<')) {
        define('PASSWORD_ALGORITHM', 1);  //BCRYPT
} else {
    define('PASSWORD_ALGORITHM', '2y');  //BCRYPT
}
/*
usercod     bigint(10) AI PK
useremail   varchar(80)
username    varchar(80)
userpswd    varchar(128)
userfching  datetime
userpswdest char(3)
userpswdexp datetime
userest     char(3)
useractcod  varchar(128)
userpswdchg varchar(128)
usertipo    char(3)

 */

use Exception;

class Security extends \Dao\Table
{
    static public function getUsuarios($filter = "", $params = [], $page = -1, $items = 0)
    {
        $sqlstr = "SELECT * FROM usuario";
        if (!empty($filter)) {
            $sqlstr .= " WHERE " . $filter;
        }
        if ($page !== -1 && $items > 0) {
            $offset = ($page - 1) * $items;
            $sqlstr .= sprintf(" LIMIT %d, %d", intval($offset), intval($items));
        }
        $sqlstr .= ";";
        return self::obtenerRegistros($sqlstr, $params);
    }

    static public function newUsuario($email, $password, $username = "John Doe", $userest = 'ACT', $usertipo = 'PUBLICO')
    {
        if (!\Utilities\Validators::IsValidEmail($email)) {
            throw new Exception("Correo no es válido");
        }
        if (!\Utilities\Validators::IsValidPassword($password)) {
            throw new Exception("Contraseña debe ser almenos 8 caracteres, 1 número, 1 mayúscula, 1 símbolo especial");
        }

        $newUser = self::_usuarioStruct();
        //Tratamiento de la Contraseña
        $hashedPassword = self::_hashPassword($password);

        unset($newUser["usercod"]);
        unset($newUser["userfching"]);
        unset($newUser["userpswdchg"]);

        $newUser["useremail"] = $email;
        $newUser["username"] = $username;
        $newUser["userpswd"] = $hashedPassword;
        $newUser["userpswdest"] = 'ACT';
        $newUser["userpswdexp"] = date('Y-m-d', time() + 7776000);  //(3*30*24*60*60) (m d h mi s)
        $newUser["userest"] = $userest;
        $newUser["useractcod"] = hash("sha256", $email.time());
        $newUser["usertipo"] = $usertipo;

        $sqlIns = "INSERT INTO `usuario` (`useremail`, `username`, `userpswd`,
            `userfching`, `userpswdest`, `userpswdexp`, `userest`, `useractcod`,
            `userpswdchg`, `usertipo`)
            VALUES
            ( :useremail, :username, :userpswd,
            now(), :userpswdest, :userpswdexp, :userest, :useractcod,
            now(), :usertipo);";

        return self::executeNonQuery($sqlIns, $newUser);
    }

    static public function getUsuarioByEmail($email)
    {
        $sqlstr = "SELECT * from `usuario` where `useremail` = :useremail ;";
        $params = array("useremail"=>$email);

        return self::obtenerUnRegistro($sqlstr, $params);
    }

    static private function _saltPassword($password)
    {
        return hash_hmac(
            "sha256",
            $password,
            \Utilities\Context::getContextByKey("PWD_HASH")
        );
    }

    static private function _hashPassword($password)
    {
        return password_hash(self::_saltPassword($password), PASSWORD_ALGORITHM);
    }

    static public function verifyPassword($raw_password, $hash_password)
    {
        return password_verify(
            self::_saltPassword($raw_password),
            $hash_password
        );
    }


    static private function _usuarioStruct()
    {
        return array(
            "usercod"      => "",
            "useremail"    => "",
            "username"     => "",
            "userpswd"     => "",
            "userfching"   => "",
            "userpswdest"  => "",
            "userpswdexp"  => "",
            "userest"      => "",
            "useractcod"   => "",
            "userpswdchg"  => "",
            "usertipo"     => "",
        );
    }

    static public function getFeature($fncod)
    {
        $sqlstr = "SELECT * from funciones where fncod=:fncod;";
        $featuresList = self::obtenerRegistros($sqlstr, array("fncod"=>$fncod));
        return count($featuresList) > 0;
    }

    static public function addNewFeature($fncod, $fndsc, $fnest, $fntyp )
    {
        $sqlins = "INSERT INTO `funciones` (`fncod`, `fndsc`, `fnest`, `fntyp`)
            VALUES (:fncod , :fndsc , :fnest , :fntyp );";

        return self::executeNonQuery(
            $sqlins,
            array(
                "fncod" => $fncod,
                "fndsc" => $fndsc,
                "fnest" => $fnest,
                "fntyp" => $fntyp
            )
        );
    }

    static public function getFeatureByUsuario($userCod, $fncod)
    {
        $sqlstr = "select * from
        funciones_roles a inner join roles_usuarios b on a.rolescod = b.rolescod
        where a.fnrolest = 'ACT' and b.roleuserest='ACT' and b.usercod=:usercod
        and a.fncod=:fncod limit 1;";
        $resultados = self::obtenerRegistros(
            $sqlstr,
            array(
                "usercod"=> $userCod,
                "fncod" => $fncod
            )
        );
        return count($resultados) > 0;
    }

    static public function getRol($rolescod)
    {
        $sqlstr = "SELECT * from roles where rolescod=:rolescod;";
        $featuresList = self::obtenerRegistros($sqlstr, array("rolescod" => $rolescod));
        return count($featuresList) > 0;
    }

    static public function addNewRol($rolescod, $rolesdsc, $rolesest)
    {
        $sqlins = "INSERT INTO `roles` (`rolescod`, `rolesdsc`, `rolesest`)
        VALUES (:rolescod, :rolesdsc, :rolesest);";

        return self::executeNonQuery(
            $sqlins,
            array(
                "rolescod" => $rolescod,
                "rolesdsc" => $rolesdsc,
                "rolesest" => $rolesest
            )
        );
    }

    static public function isUsuarioInRol($userCod, $rolescod)
    {
        $sqlstr = "select * from roles a inner join
        roles_usuarios b on a.rolescod = b.rolescod where a.rolesest = 'ACT'
        and b.roleuserest = 'ACT'
        and b.usercod=:usercod and a.rolescod=:rolescod limit 1;";
        $resultados = self::obtenerRegistros(
            $sqlstr,
            array(
                "usercod" => $userCod,
                "rolescod" => $rolescod
            )
        );
        return count($resultados) > 0;
    }

    static public function getRolesByUsuario($userCod)
    {
        $sqlstr = "select * from roles a inner join
        roles_usuarios b on a.rolescod = b.rolescod where a.rolesest = 'ACT'
        and b.roleuserest = 'ACT'
        and b.usercod=:usercod;";
        $resultados = self::obtenerRegistros(
            $sqlstr,
            array(
                "usercod" => $userCod
            )
        );
        return $resultados;
    }

    static public function removeRolFromUser($userCod, $rolescod)
    {
        $sqldel = "UPDATE roles_usuarios set roleuserest='INA' 
        where rolescod=:rolescod and usercod=:usercod;";
        return self::executeNonQuery(
            $sqldel,
            array("rolescod"=>$rolescod, "usercod"=>$userCod)
        );
    }

    static public function removeFeatureFromRol($fncod, $rolescod)
    {
        $sqldel = "UPDATE funciones_roles set roleuserest='INA'
        where fncod=:fncod and rolescod=:rolescod;";
        return self::executeNonQuery(
            $sqldel,
            array("fncod" => $fncod, "rolescod" => $rolescod)
        );
    }
    static public function getUsuarioByCode($usercod)
    {
        $sqlstr = "SELECT * FROM `usuario` WHERE `usercod` = :usercod;";
        return self::obtenerUnRegistro($sqlstr, array("usercod" => $usercod));
    }

    static public function updateUsuario($usercod, $email, $username, $userest, $usertipo)
    {
        $sqlupd = "UPDATE `usuario` SET `useremail` = :useremail, `username` = :username, `userest` = :userest, `usertipo` = :usertipo WHERE `usercod` = :usercod;";
        return self::executeNonQuery(
            $sqlupd,
            array(
                "useremail" => $email,
                "username" => $username,
                "userest" => $userest,
                "usertipo" => $usertipo,
                "usercod" => $usercod
            )
        );
    }

    static public function updatePassword($usercod, $newPassword)
    {
        $hashedPassword = self::_hashPassword($newPassword);
        $sqlstr = "UPDATE `usuario` SET `userpswd` = :userpswd, `userpswdchg` = NOW() WHERE `usercod` = :usercod;";
        return self::executeNonQuery($sqlstr, [
            "userpswd" => $hashedPassword,
            "usercod" => $usercod
        ]);
    }

    static public function addRolToUser($userCod, $rolescod)
    {
        $sqlstr = "SELECT * FROM roles_usuarios WHERE usercod = :usercod AND rolescod = :rolescod;";
        $exists = self::obtenerUnRegistro($sqlstr, array("usercod" => $userCod, "rolescod" => $rolescod));
        if ($exists) {
            $sqlupd = "UPDATE roles_usuarios SET roleuserest = 'ACT', roleuserfch = NOW() WHERE usercod = :usercod AND rolescod = :rolescod;";
            return self::executeNonQuery($sqlupd, array("usercod" => $userCod, "rolescod" => $rolescod));
        } else {
            $sqlins = "INSERT INTO roles_usuarios (usercod, rolescod, roleuserest, roleuserfch, roleuserexp) 
                       VALUES (:usercod, :rolescod, 'ACT', NOW(), DATE_ADD(NOW(), INTERVAL 1 YEAR));";
            return self::executeNonQuery($sqlins, array("usercod" => $userCod, "rolescod" => $rolescod));
        }
    }

    static public function clearRolesFromUser($userCod)
    {
        $sqlupd = "UPDATE roles_usuarios SET roleuserest = 'INA' WHERE usercod = :usercod;";
        return self::executeNonQuery($sqlupd, array("usercod" => $userCod));
    }

    static public function getRoles()
    {
        $sqlstr = "SELECT * FROM roles WHERE rolesest = 'ACT';";
        return self::obtenerRegistros($sqlstr, array());
    }

    static public function resetearIntentos($usercod)
    {
        $sqlstr = "UPDATE `usuario` SET `userfailedattempts` = 0, `userblockedat` = NULL, `userest` = 'ACT' WHERE `usercod` = :usercod;";
        return self::executeNonQuery($sqlstr, ["usercod" => $usercod]);
    }

    static public function registrarIntentoFallido($usercod, $currentAttempts)
    {
        $newAttempts = $currentAttempts + 1;
        if ($newAttempts >= 3) {
            $sqlstr = "UPDATE `usuario` SET `userfailedattempts` = :attempts, `userest` = 'BLQ', `userblockedat` = NOW() WHERE `usercod` = :usercod;";
            return self::executeNonQuery($sqlstr, ["attempts" => $newAttempts, "usercod" => $usercod]);
        } else {
            $sqlstr = "UPDATE `usuario` SET `userfailedattempts` = :attempts WHERE `usercod` = :usercod;";
            return self::executeNonQuery($sqlstr, ["attempts" => $newAttempts, "usercod" => $usercod]);
        }
    }

    private function __construct()
    {
    }
    private function __clone()
    {
    }
}


?>
