<?php

namespace Utilities;

class LoginAttemptLogger
{
    public static function logAttempt($ip, $email, $success = false, $details = "") : void
    {
        $logDir = dirname(__DIR__, 2) . "/data/login_attempts";
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }

        $safeIp = self::sanitizeValue($ip, "unknown");
        $safeEmail = self::sanitizeValue($email, "unknown");
        $safeDetails = self::sanitizeValue($details, "sin-detalle");
        $status = $success ? "SUCCESS" : "FAILED";
        $filePath = $logDir . "/" . $safeIp . ".log";

        $line = sprintf(
            "%s | IP=%s | STATUS=%s | EMAIL=%s | DETAILS=%s\n",
            date("Y-m-d H:i:s"),
            $safeIp,
            $status,
            $safeEmail,
            $safeDetails
        );

        file_put_contents($filePath, $line, FILE_APPEND | LOCK_EX);
    }

    public static function getClientIp() : string
    {
        $serverKeys = ["HTTP_X_FORWARDED_FOR", "HTTP_CLIENT_IP", "REMOTE_ADDR"];
        foreach ($serverKeys as $key) {
            if (!empty($_SERVER[$key])) {
                if (is_array($_SERVER[$key])) {
                    return self::sanitizeValue($_SERVER[$key][0], "unknown");
                }
                return self::sanitizeValue($_SERVER[$key], "unknown");
            }
        }

        return "unknown";
    }

    private static function sanitizeValue($value, $default = "") : string
    {
        $value = trim((string) $value);
        if ($value === "") {
            return $default;
        }

        $value = preg_replace('/[^A-Za-z0-9._:-]/', '_', $value);
        return $value !== "" ? $value : $default;
    }
}
