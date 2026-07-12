<?php
namespace Controllers\Sec;
class Login extends \Controllers\PublicController
{
    private $txtEmail = "";
    private $txtPswd = "";
    private $errorEmail = "";
    private $errorPswd = "";
    private $generalError = "";
    private $hasError = false;

    public function run() :void
    {
        if (\Utilities\Security::isLogged()) {
            \Utilities\Site::redirectTo("index.php");
        }

        if ($this->isPostBack()) {
            $this->txtEmail = $_POST["txtEmail"];
            $this->txtPswd = $_POST["txtPswd"];

            if (!\Utilities\Validators::IsValidEmail($this->txtEmail)) {
                $this->errorEmail = "¡Correo no tiene el formato adecuado!";
                $this->hasError = true;
            }
            if (\Utilities\Validators::IsEmpty($this->txtPswd)) {
                $this->errorPswd = "¡Debe ingresar una contraseña!";
                $this->hasError = true;
            }
            if (! $this->hasError) {
                if ($dbUser = \Dao\Security\Security::getUsuarioByEmail($this->txtEmail)) {
                    if ($dbUser["userest"] === "BLQ") {
                        $blockedAt = strtotime($dbUser["userblockedat"]);
                        $now = time();
                        $diffSeconds = $now - $blockedAt;
                        if ($diffSeconds >= 300) {
                            \Dao\Security\Security::resetearIntentos($dbUser["usercod"]);
                            $dbUser = \Dao\Security\Security::getUsuarioByEmail($this->txtEmail);
                        } else {
                            $remainingSeconds = 300 - $diffSeconds;
                            $remainingMinutes = ceil($remainingSeconds / 60);
                            $this->generalError = sprintf("Tu cuenta está bloqueada temporalmente por seguridad. Inténtalo de nuevo en %d minuto(s).", $remainingMinutes);
                            $this->hasError = true;
                        }
                    }

                    if (!$this->hasError && $dbUser["userest"] !== "ACT") {
                        $this->generalError = "¡Credenciales son incorrectas!";
                        $this->hasError = true;
                        error_log(
                            sprintf(
                                "ERROR: %d %s tiene cuenta con estado %s",
                                $dbUser["usercod"],
                                $dbUser["useremail"],
                                $dbUser["userest"]
                            )
                        );
                    }

                    if (!$this->hasError) {
                        if (!\Dao\Security\Security::verifyPassword($this->txtPswd, $dbUser["userpswd"])) {
                            \Dao\Security\Security::registrarIntentoFallido($dbUser["usercod"], intval($dbUser["userfailedattempts"]));
                            
                            $attemptsLeft = 2 - intval($dbUser["userfailedattempts"]);
                            if ($attemptsLeft <= 0) {
                                $this->generalError = "Tu cuenta ha sido bloqueada temporalmente por seguridad por 5 minutos.";
                            } else {
                                $this->generalError = sprintf("¡Credenciales son incorrectas! Intentos restantes antes del bloqueo: %d", $attemptsLeft);
                            }
                            $this->hasError = true;
                            error_log(
                                sprintf(
                                    "ERROR: %d %s contraseña incorrecta",
                                    $dbUser["usercod"],
                                    $dbUser["useremail"]
                                )
                            );
                        }
                    }

                    if (! $this->hasError) {
                        \Dao\Security\Security::resetearIntentos($dbUser["usercod"]);
                        \Utilities\Security::login(
                            $dbUser["usercod"],
                            $dbUser["username"],
                            $dbUser["useremail"]
                        );
                        if (\Utilities\Context::getContextByKey("redirto") !== "") {
                            \Utilities\Site::redirectTo(
                                \Utilities\Context::getContextByKey("redirto")
                             );
                        } else {
                            \Utilities\Site::redirectTo("index.php");
                        }
                    }
                } else {
                    error_log(
                        sprintf(
                            "ERROR: %s trato de ingresar",
                            $this->txtEmail
                        )
                    );
                    $this->generalError = "¡Credenciales son incorrectas!";
                }
            }
        }
        $dataView = get_object_vars($this);
        \Views\Renderer::render("security/login", $dataView, "loginlayout.view.tpl");
    }
}
?>
