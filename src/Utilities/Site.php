<?php

namespace Utilities;

class Site
{
    public static function configure()
    {
        $donenv = new \Utilities\DotEnv("parameters.env");
        \Utilities\Context::setArrayToContext($donenv->load());
        $baseDir = \Utilities\Context::getContextByKey("BASE_DIR");
        $basePath = $baseDir ? "/" . trim($baseDir, "/") : "";
        \Utilities\Context::setContext("BASE_PATH", $basePath);
        date_default_timezone_set(\Utilities\Context::getContextByKey("TIMEZONE"));
    }
    public static function getPageRequest()
    {
        $pageRequest = "index";
        if (\Utilities\Security::isLogged()) {
            $pageRequest = "admin\\admin";
        }
        if (isset($_GET["page"])) {
            $pageRequest = str_replace(array("_", "-", "."), "\\", $_GET["page"]);
        }
        
        $resolvedClass = "Controllers\\" . $pageRequest;
        
        $allowedPages = array(
            "controllers\\index",
            "controllers\\noauth",
            "controllers\\error",
            "controllers\\admin\\admin",
            "controllers\\mnt\\categorias",
            "controllers\\mnt\\categoria",
            "controllers\\mnt\\kardex",
            "controllers\\mnt\\productos",
            "controllers\\mnt\\producto",
            "controllers\\mnt\\proveedores",
            "controllers\\mnt\\proveedor",
            "controllers\\mnt\\usuarios",
            "controllers\\mnt\\usuario",
            "controllers\\sec\\login",
            "controllers\\sec\\logout",
            "controllers\\sec\\perfil",
            "controllers\\sec\\register"
        );

        $normalizedClass = strtolower($resolvedClass);
        if (!in_array($normalizedClass, $allowedPages)) {
            $resolvedClass = "Controllers\\Error";
        }

        Context::setArrayToContext($_GET);
        Context::setContext("request_uri", $_SERVER["REQUEST_URI"]);
        return $resolvedClass;
    }
    public static function redirectTo($url)
    {
        if (Context::getContextByKey("USE_URLREWRITE") == "1") {
            header("Location:" . \Views\Renderer::rewriteUrl($url));
        } else { 
            header("Location:" . $url);
        }
        
        die();
    }
    public static function redirectToWithMsg($url, $msg)
    {
        $safeUrl = json_encode($url);
        $safeMsg = json_encode($msg);
        $templatePath = "src/Views/templates/redirect_msg.view.tpl";
        if (file_exists($templatePath)) {
            $html = file_get_contents($templatePath);
            $html = str_replace(["{{url}}", "{{msg}}"], [$safeUrl, $safeMsg], $html);
            echo $html;
        } else {
            echo "Error: No se pudo cargar la plantilla de redirección.";
        }
        die();
    }
    public static function addLink($href)
    {
        $tmpLinks = \Utilities\Context::getContextByKey("SiteLinks");
        if ($tmpLinks === "") {
            $tmpLinks = array($href);
        } else {
            $tmpLinks[] = $href;
        }
        \Utilities\Context::setContext("SiteLinks", $tmpLinks);
    }
    public static function addBeginScript($src)
    {
        $tmpSrcs = \Utilities\Context::getContextByKey("BeginScripts");
        if ($tmpSrcs === "") {
            $tmpSrcs = array($src);
        } else {
            $tmpSrcs[] = $src;
        }
        \Utilities\Context::setContext("BeginScripts", $tmpSrcs);
    }
    public static function addEndScript($src)
    {
        $tmpSrcs = \Utilities\Context::getContextByKey("EndScripts");
        if ($tmpSrcs === "") {
            $tmpSrcs = array($src);
        } else {
            $tmpSrcs[] = $src;
        }
        \Utilities\Context::setContext("EndScripts", $tmpSrcs);
    }
}
?>
