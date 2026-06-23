<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Security\Security as DaoSecurity;
use Utilities\Validators;
use Utilities\Site;
use Views\Renderer;

class Usuario extends PrivateController
{
    public function __construct()
    {
        parent::__construct();
        if (!\Utilities\Security::isInRol(\Utilities\Security::getUserId(), "PRP")) {
            throw new \Controllers\PrivateNoAuthException();
        }
    }
    private $mode = "DSP";
    private $id = 0;
    private $user = [
        "usercod" => 0,
        "useremail" => "",
        "username" => "",
        "userest" => "ACT",
        "usertipo" => "PUBLICO"
    ];
    private $rolescod = "AUD"; // Default role to assign
    private $mode_dscs = [
        "INS" => "Crear Nuevo Usuario",
        "UPD" => "Editar Usuario: %s",
        "DSP" => "Detalles del Usuario: %s"
    ];
    private $aErrors = [];

    public function run(): void
    {
        $this->_initParams();
        
        if ($this->isPostBack()) {
            $this->_handlePost();
        } else {
            $this->_handleGet();
        }

        $this->_prepareViewData();
        Renderer::render("mnt/usuario", $this->user);
    }

    private function _initParams()
    {
        if (isset($_GET["mode"])) {
            $this->mode = $_GET["mode"];
        }
        if (isset($_GET["id"])) {
            $this->id = intval($_GET["id"]);
        }

        if ($this->isPostBack()) {
            if (isset($_POST["mode"])) {
                $this->mode = $_POST["mode"];
            }
            if (isset($_POST["id"])) {
                $this->id = intval($_POST["id"]);
            }
        }

        // Validate mode
        if (!in_array($this->mode, ["INS", "UPD", "DSP"])) {
            Site::redirectToWithMsg("index.php?page=mnt_usuarios", "¡Acción no permitida!");
        }

        // If UPD or DSP, load user from DB
        if ($this->mode !== "INS") {
            $dbUser = DaoSecurity::getUsuarioByCode($this->id);
            if (!$dbUser) {
                Site::redirectToWithMsg("index.php?page=mnt_usuarios", "¡Usuario no encontrado!");
            }
            $this->user = $dbUser;

            // Load user's current active role
            $userRoles = DaoSecurity::getRolesByUsuario($this->id);
            if (count($userRoles) > 0) {
                // Find the first role in their active mapping
                foreach ($userRoles as $r) {
                    if ($r["roleuserest"] === "ACT") {
                        $this->rolescod = $r["rolescod"];
                        break;
                    }
                }
            }
        }
    }

    private function _handlePost()
    {
        // Collect inputs
        $this->user["username"] = isset($_POST["username"]) ? trim($_POST["username"]) : "";
        $rolesPost = isset($_POST["rolescod"]) ? $_POST["rolescod"] : "AUD";
        $statusPost = isset($_POST["userest"]) ? $_POST["userest"] : "ACT";

        if ($this->mode === "INS") {
            $this->user["useremail"] = isset($_POST["useremail"]) ? trim($_POST["useremail"]) : "";
            $password = isset($_POST["userpswd"]) ? $_POST["userpswd"] : "";
            $passwordConfirm = isset($_POST["userpswd_confirm"]) ? $_POST["userpswd_confirm"] : "";

            // INS validations
            if (Validators::IsEmpty($this->user["useremail"])) {
                $this->aErrors[] = "El correo electrónico es requerido.";
            } elseif (!Validators::IsValidEmail($this->user["useremail"])) {
                $this->aErrors[] = "El correo electrónico ingresado no tiene un formato válido.";
            } else {
                // Check if email already exists
                $existing = DaoSecurity::getUsuarioByEmail($this->user["useremail"]);
                if ($existing) {
                    $this->aErrors[] = "Este correo electrónico ya está registrado.";
                    $this->user["useremail"] = "";
                }
            }

            if (Validators::IsEmpty($password)) {
                $this->aErrors[] = "La contraseña es requerida.";
            } elseif (!Validators::IsValidPassword($password)) {
                $this->aErrors[] = "La contraseña no cumple con los requisitos mínimos de seguridad.";
            }

            if ($password !== $passwordConfirm) {
                $this->aErrors[] = "Las contraseñas ingresadas no coinciden.";
            }
        }

        if (Validators::IsEmpty($this->user["username"])) {
            $this->aErrors[] = "El nombre completo es requerido.";
        }

        // Self-deactivation and self-role change protection checks
        $currentLoggedUserId = \Utilities\Security::getUserId();
        $isSelfEdit = ($this->id === $currentLoggedUserId);
        if ($isSelfEdit) {
            if ($statusPost !== "ACT") {
                $this->aErrors[] = "Por motivos de seguridad, no puedes desactivar ni bloquear tu propio usuario administrador.";
                $statusPost = "ACT"; // force active
            }
            if ($rolesPost !== $this->rolescod) {
                $this->aErrors[] = "Por motivos de seguridad, no puedes cambiar tu propio rol de administrador.";
                $rolesPost = $this->rolescod; // force current role
            }
        }

        // If no errors, process database modifications
        if (count($this->aErrors) === 0) {
            if ($this->mode === "INS") {
                // Create user (usertipo matches the role selection)
                $result = DaoSecurity::newUsuario(
                    $this->user["useremail"],
                    $password,
                    $this->user["username"],
                    $statusPost,
                    $rolesPost
                );
                
                if ($result) {
                    // Fetch newly created usercod to map role
                    $newDbUser = DaoSecurity::getUsuarioByEmail($this->user["useremail"]);
                    if ($newDbUser) {
                        DaoSecurity::addRolToUser($newDbUser["usercod"], $rolesPost);
                    }
                    Site::redirectToWithMsg("index.php?page=mnt_usuarios", "¡Usuario creado exitosamente!");
                } else {
                    $this->aErrors[] = "Hubo un error al crear el usuario en la base de datos.";
                }
            } elseif ($this->mode === "UPD") {
                // Update general fields (usertipo matches the role selection)
                $result = DaoSecurity::updateUsuario(
                    $this->id,
                    $this->user["useremail"],
                    $this->user["username"],
                    $statusPost,
                    $rolesPost
                );

                if ($result) {
                    // Clear and assign new role
                    DaoSecurity::clearRolesFromUser($this->id);
                    DaoSecurity::addRolToUser($this->id, $rolesPost);
                    Site::redirectToWithMsg("index.php?page=mnt_usuarios", "¡Usuario actualizado exitosamente!");
                } else {
                    $this->aErrors[] = "Hubo un error al actualizar el usuario en la base de datos.";
                }
            }
        }
    }

    private function _handleGet()
    {
        // Standard GET load is already handled by _initParams
    }

    private function _prepareViewData()
    {
        $this->user["mode"] = $this->mode;
        $this->user["id"] = $this->id;

        $currentLoggedUserId = \Utilities\Security::getUserId();
        $this->user["is_self_edit"] = ($this->id === $currentLoggedUserId);

        // Map mode descriptions
        if ($this->mode === "INS") {
            $this->user["mode_dsc"] = $this->mode_dscs["INS"];
        } else {
            $this->user["mode_dsc"] = sprintf($this->mode_dscs[$this->mode], $this->user["username"]);
        }

        // Configure read-only states
        $this->user["readonly"] = ($this->mode === "DSP") ? "readonly" : "";
        $this->user["readonly_email"] = ($this->mode !== "INS") ? "readonly" : "";
        $this->user["select_disabled"] = ($this->mode === "DSP" || $this->user["is_self_edit"]) ? true : false;
        $this->user["select_role_disabled"] = ($this->mode === "DSP" || $this->user["is_self_edit"]) ? true : false;
        $this->user["showaction"] = ($this->mode !== "DSP") ? true : false;
        $this->user["show_password"] = ($this->mode === "INS") ? true : false;

        // Map status indicators
        $this->user["userest_ACT"] = ($this->user["userest"] === "ACT") ? "selected" : "";
        $this->user["userest_INA"] = ($this->user["userest"] === "INA") ? "selected" : "";
        $this->user["userest_BLQ"] = ($this->user["userest"] === "BLQ") ? "selected" : "";
        $this->user["show_blocked_option"] = ($this->user["userest"] === "BLQ");

        // Map errors
        $this->user["hasErrors"] = (count($this->aErrors) > 0);
        $this->user["aErrors"] = $this->aErrors;

        // Load roles list and mark selected role
        $rolesList = DaoSecurity::getRoles();
        $rolesFormatted = [];
        foreach ($rolesList as $role) {
            $rolesFormatted[] = [
                "rolescod" => $role["rolescod"],
                "rolesdsc" => $role["rolesdsc"],
                "selected" => ($role["rolescod"] === $this->rolescod) ? "selected" : ""
            ];
        }
        $this->user["Roles"] = $rolesFormatted;
        $this->user["rolescod_selected"] = $this->rolescod;
    }
}
