<?php

namespace Utilities;

class CSRF
{
    private function __construct()
    {
    }
    private function __clone()
    {
    }

    public static function generateToken(): string
    {
        if (!isset($_SESSION["csrf_tokens"])) {
            $_SESSION["csrf_tokens"] = [];
        }
        $token = bin2hex(random_bytes(32));
        $_SESSION["csrf_tokens"][$token] = time() + 3600;
        return $token;
    }

    public static function validateToken(string $token = null): bool
    {
        if ($token === null) {
            $token = $_POST["csrf_token"] ?? "";
        }
        if (empty($token)) {
            return false;
        }
        if (!isset($_SESSION["csrf_tokens"][$token])) {
            return false;
        }
        $expiry = $_SESSION["csrf_tokens"][$token];
        if (time() > $expiry) {
            unset($_SESSION["csrf_tokens"][$token]);
            return false;
        }
        unset($_SESSION["csrf_tokens"][$token]);
        return true;
    }
}
