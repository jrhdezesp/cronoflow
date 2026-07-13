<?php

namespace Controllers;

abstract class PublicController implements IController
{
    protected $name = "";
    const PRIVATE_LAYOUT_KEY = "PRIVATE_LAYOUT";

    public function __construct()
    {
        $this->name = get_class($this);
        if (\Utilities\Security::isLogged()){
            $layoutFile = \Utilities\Context::getContextByKey(self::PRIVATE_LAYOUT_KEY);
            if ($layoutFile !== "") {
                \Utilities\Context::setContext(
                    "layoutFile",
                    $layoutFile
                );
                \Utilities\Nav::setNavContext();
            }
        }
    }

    public function toString() :string
    {
        return $this->name;
    }

    protected function isPostBack()
    {
        return isset($_SERVER["REQUEST_METHOD"]) && $_SERVER["REQUEST_METHOD"] === "POST";
    }

}

?>
