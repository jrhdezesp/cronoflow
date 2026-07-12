<?php
namespace Controllers\Sec;

use Controllers\PrivateController;
use Views\Renderer;
use Dao\Security\Security as DaoSecurity;

class Perfil extends PrivateController
{
    public function run(): void
    {
        $userId = \Utilities\Security::getUserId();
        $dbUser = DaoSecurity::getUsuarioByCode($userId);
        
        if (!$dbUser) {
            \Utilities\Site::redirectTo("index.php");
        }

        $errors = [];
        $showForm = false;

        if ($this->isPostBack()) {
            $pswdActual = isset($_POST["pswd_actual"]) ? trim($_POST["pswd_actual"]) : "";
            $pswdNueva = isset($_POST["pswd_nueva"]) ? trim($_POST["pswd_nueva"]) : "";
            $pswdConfirmar = isset($_POST["pswd_confirmar"]) ? trim($_POST["pswd_confirmar"]) : "";
            $showForm = true;

            if (\Utilities\Validators::IsEmpty($pswdActual)) {
                $errors[] = "Debe ingresar la contraseña actual.";
            }
            if (\Utilities\Validators::IsEmpty($pswdNueva)) {
                $errors[] = "Debe ingresar la nueva contraseña.";
            }
            if ($pswdNueva !== $pswdConfirmar) {
                $errors[] = "La nueva contraseña y su confirmación no coinciden.";
            }
            if (!\Utilities\Validators::IsValidPassword($pswdNueva)) {
                $errors[] = "La nueva contraseña debe tener al menos 8 caracteres, incluir al menos 1 letra mayúscula, 1 minúscula, 1 número y 1 carácter especial.";
            }

            if (count($errors) === 0) {
                // Verify current password
                if (!DaoSecurity::verifyPassword($pswdActual, $dbUser["userpswd"])) {
                    $errors[] = "La contraseña actual ingresada es incorrecta.";
                } else {
                    // Update password in DB
                    if (DaoSecurity::updatePassword($userId, $pswdNueva)) {
                        \Utilities\Security::logout();
                        \Utilities\Site::redirectToWithMsg("index.php?page=sec_login", "¡Contraseña actualizada exitosamente! Inicie sesión con su nueva contraseña.");
                    } else {
                        $errors[] = "Ocurrió un error al actualizar la contraseña en el servidor.";
                    }
                }
            }
        }
        
        // Fetch user roles
        $rolesList = DaoSecurity::getRolesByUsuario($userId);
        $rolesNames = [];
        foreach ($rolesList as $role) {
            $rolesNames[] = $role["rolesdsc"];
        }
        $roleDisplay = count($rolesNames) > 0 ? implode(", ", $rolesNames) : "Sin Rol Asignado";
        
        // Map status to badge classes
        $statusDsc = "Inactivo";
        $statusClass = "badge-error";
        if ($dbUser["userest"] === "ACT") {
            $statusDsc = "Activo";
            $statusClass = "badge-success";
        } elseif ($dbUser["userest"] === "BLQ") {
            $statusDsc = "Bloqueado";
            $statusClass = "badge-warning";
        }
        
        $viewData = [
            "usercod" => $dbUser["usercod"],
            "username" => $dbUser["username"],
            "useremail" => $dbUser["useremail"],
            "userfching" => date("d/m/Y g:i A", strtotime($dbUser["userfching"])),
            "role_display" => $roleDisplay,
            "status_dsc" => $statusDsc,
            "status_class" => $statusClass,
            "errors" => $errors,
            "hasErrors" => count($errors) > 0,
            "displayForm" => $showForm ? "block" : "none",
            "displayToggle" => $showForm ? "none" : "inline-flex"
        ];
        
        Renderer::render("security/perfil", $viewData);
    }
}
?>
