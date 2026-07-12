<?php

namespace Utilities;

class Nav {

    public static function setNavContext(){
        $tmpNAVIGATION = array();
        $userID = \Utilities\Security::getUserId();

        $configPath = "nav.config.json";
        if (!file_exists($configPath)) {
            \Utilities\Context::setContext("NAVIGATION", $tmpNAVIGATION);
            return;
        }

        $json = file_get_contents($configPath);
        $items = json_decode($json, true);

        if (!is_array($items)) {
            \Utilities\Context::setContext("NAVIGATION", $tmpNAVIGATION);
            return;
        }

        foreach ($items as $item) {
            if (isset($item["feature"]) && \Utilities\Security::isAuthorized($userID, $item["feature"])) {
                $tmpNAVIGATION[] = array(
                    "nav_url" => $item["url"],
                    "nav_label" => $item["label"],
                    "nav_icon" => $item["icon"]
                );
            }
        }

        \Utilities\Context::setContext("NAVIGATION", $tmpNAVIGATION);
    }

    private function __construct()
    {
        
    }
    private function __clone()
    {
        
    }
}
