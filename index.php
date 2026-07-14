<?php
/**
 * PHP Version 7.2
 *
 * @category Router
 * @package  SimplePHPOOPMvc
 * @author   Orlando J Betancourth <orlando.betancourth@gmail.com>
 * @license  MIT http://
 * @version  CVS:1.0.0
 * @link     http://
 */

use Utilities\Context;
use Utilities\Site;

require __DIR__ . '/vendor/autoload.php';
session_start();

try {
    \Utilities\Site::configure();
} catch (\Exception $ex) {
    error_log("Error en Site::configure: " . $ex);
} catch (\Error $ex) {
    error_log("Error fatal en Site::configure: " . $ex);
}

try {
    $pageRequest = \Utilities\Site::getPageRequest();
} catch (\Exception $ex) {
    error_log("Error en getPageRequest: " . $ex);
    $pageRequest = "Controllers\\Error";
} catch (\Error $ex) {
    error_log("Error fatal en getPageRequest: " . $ex);
    $pageRequest = "Controllers\\Error";
}

try {
    $instance = new $pageRequest();
    $instance->run();
    die();
} catch(\Controllers\PrivateNoAuthException $ex){
    $instance = new \Controllers\NoAuth();
    $instance->run();
    die();
} catch(\Controllers\PrivateNoLoggedException $ex){
    $redirTo = urlencode(\Utilities\Context::getContextByKey("request_uri"));
    \Utilities\Site::redirectTo("index.php?page=sec.login&redirto=".$redirTo);
    die();
} catch(\Exception $ex)
{
    error_log($ex);
    error_log("Ruta solicitada: " . ($pageRequest ?? "N/A"));
    $instance = new \Controllers\Error();
    $instance->run();
    die();
} catch(Error $ex)
{
    error_log($ex);
    error_log("Ruta solicitada: " . ($pageRequest ?? "N/A"));
    $instance = new \Controllers\Error();
    $instance->run();
    die();
}


?>
