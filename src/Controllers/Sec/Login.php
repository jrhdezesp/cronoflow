<?php
namespace Controllers\Sec;

use Utilities\Site;
use Utilities\Validators;
use Utilities\Security as SecurityUtils;
use Utilities\Context;
use Utilities\LoginAttemptLogger;
use Utilities\CSRF;
use Dao\Security\Security;
use Views\Renderer;

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
        if (SecurityUtils::isLogged()) {
            Site::redirectTo("index.php");
        }

        if ($this->isPostBack()) {
            if (!CSRF::validateToken()) {
                $this->generalError = "Solicitud inválida. Intente nuevamente.";
                $this->hasError = true;
            } else {
                $this->txtEmail = $_POST["txtEmail"];
                $this->txtPswd = $_POST["txtPswd"];
                $ip = LoginAttemptLogger::getClientIp();

                if (!Validators::IsValidEmail($this->txtEmail)) {
                    $this->errorEmail = "¡Correo no tiene el formato adecuado!";
                    $this->hasError = true;
                    LoginAttemptLogger::logAttempt($ip, hash("sha256", $this->txtEmail), false, "email-invalido");
                }
                if (Validators::IsEmpty($this->txtPswd)) {
                    $this->errorPswd = "¡Debe ingresar una contraseña!";
                    $this->hasError = true;
                    LoginAttemptLogger::logAttempt($ip, hash("sha256", $this->txtEmail), false, "password-vacio");
                }
            }

            if (! $this->hasError) {
                // Use constant-time comparison to prevent timing attacks
                $dbUser = Security::getUsuarioByEmail($this->txtEmail);
                $userExists = ($dbUser !== false);

                // Always perform a dummy verify to keep timing constant
                $passwordValid = false;
                if ($userExists) {
                    $passwordValid = Security::verifyPassword($this->txtPswd, $dbUser["userpswd"]);
                } else {
                    Security::verifyPassword("dummy_constant_time_check", '$2y$10$dummyhashfordummyhashcheck');
                }

                if (!$userExists) {
                    error_log("ERROR: Intento de login con correo no registrado");
                    LoginAttemptLogger::logAttempt($ip, hash("sha256", $this->txtEmail), false, "usuario-no-encontrado");
                    $this->generalError = "¡Credenciales son incorrectas!";
                    $this->hasError = true;
                } elseif ($dbUser["userest"] === "BLQ") {
                    $blockedAt = strtotime($dbUser["userblockedat"]);
                    $now = time();
                    $diffSeconds = $now - $blockedAt;
                    if ($diffSeconds >= 300) {
                        Security::resetearIntentos($dbUser["usercod"]);
                        $dbUser = Security::getUsuarioByEmail($this->txtEmail);
                    } else {
                        $remainingSeconds = 300 - $diffSeconds;
                        $remainingMinutes = ceil($remainingSeconds / 60);
                        $this->generalError = "Tu cuenta está temporalmente bloqueada por seguridad. Inténtalo más tarde.";
                        $this->hasError = true;
                    }
                }

                if (!$this->hasError && $dbUser["userest"] !== "ACT") {
                    $this->generalError = "¡Credenciales son incorrectas!";
                    $this->hasError = true;
                    error_log("ERROR: Cuenta con estado " . $dbUser["userest"]);
                }

                if (!$this->hasError && !$passwordValid) {
                    Security::registrarIntentoFallido($dbUser["usercod"]);
                    LoginAttemptLogger::logAttempt($ip, hash("sha256", $this->txtEmail), false, "password-incorrecto");

                    $dbUserAfter = Security::getUsuarioByEmail($this->txtEmail);
                    $attemptsUsed = intval($dbUserAfter["userfailedattempts"]);
                    $attemptsLeft = 3 - $attemptsUsed;

                    if ($attemptsLeft <= 0) {
                        $this->generalError = "Tu cuenta ha sido bloqueada temporalmente por seguridad por 5 minutos.";
                    } else {
                        $this->generalError = sprintf("¡Credenciales son incorrectas! Intentos restantes: %d", $attemptsLeft);
                    }
                    $this->hasError = true;
                    error_log("ERROR: Contraseña incorrecta para usuario");
                }

                if (! $this->hasError) {
                    Security::resetearIntentos($dbUser["usercod"]);
                    LoginAttemptLogger::logAttempt($ip, hash("sha256", $this->txtEmail), true, "login-exitoso");
                    SecurityUtils::login(
                        $dbUser["usercod"],
                        $dbUser["username"],
                        $dbUser["useremail"]
                    );
                    if (Context::getContextByKey("redirto") !== "") {
                        Site::redirectTo(Context::getContextByKey("redirto"));
                    } else {
                        Site::redirectTo("index.php");
                    }
                }
            }
        }
        $dataView = get_object_vars($this);
        $dataView["csrf_token"] = CSRF::generateToken();
        Renderer::render("security/login", $dataView, "loginlayout.view.tpl");
    }
}
?>
