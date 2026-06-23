<?php

/**
 * PHP Version 7.2
 *
 * @category Private
 * @package  Controllers
 * @author   Orlando J Betancourth <orlando.betancourth@gmail.com>
 * @license  MIT http://
 * @version  CVS:1.0.0
 * @link     http://
 */
namespace Controllers\Admin;

use Dao\Mnt\Dashboard as DaoDashboard;

/**
 * Página Principal de Administradores
 *
 * @category Public
 * @package  Controllers/Admin
 * @author   Orlando J Betancourth <orlando.betancourth@gmail.com>
 * @license  MIT http://
 * @link     http://
 */
class Admin extends \Controllers\PrivateController
{
    /**
     * Constructor
     */
    public function __construct()
    {
        // $userInRole = \Utilities\Security::isInRol(
        //     \Utilities\Security::getUserId(),
        //     "ADMIN"
        // );
        parent::__construct();
    }
    /** 
     * Ejecuta el controlador
     */
    public function run() :void
    {
        $user = \Utilities\Security::getUser();
        $movimientos = [];

        foreach (DaoDashboard::getMovimientosRecientes() as $movimiento) {
            $movimientos[] = [
                "movFecha" => date("d/m/Y H:i", strtotime($movimiento["movCreatedAt"])),
                "invPrdDsc" => $movimiento["invPrdDsc"],
                "movCantidad" => number_format(floatval($movimiento["movCantidad"]), 0),
                "movMotivo" => $movimiento["movMotivo"],
                "movTipoDsc" => self::getMovimientoTipoDsc($movimiento["movTipo"]),
                "movTipoClass" => self::getMovimientoTipoClass($movimiento["movTipo"])
            ];
        }

        $agotadosList = DaoDashboard::getProductosAgotadosList();
        $productosAgotadosJson = json_encode($agotadosList);

        $lotesVencerList = DaoDashboard::getLotesPorVencerList();
        $lotesVencerFormat = [];
        $today = new \DateTime();
        $today->setTime(0, 0, 0);

        foreach ($lotesVencerList as $lote) {
            $fechaVenc = $lote["loteFechaVencimiento"];
            $diasRestantes = 0;
            if ($fechaVenc) {
                $vencDate = new \DateTime($fechaVenc);
                $vencDate->setTime(0, 0, 0);
                $interval = $today->diff($vencDate);
                $diasRestantes = intval($interval->format("%r%a"));
            }
            $lotesVencerFormat[] = [
                "loteCod" => $lote["loteCod"],
                "loteCantActual" => number_format(floatval($lote["loteCantActual"]), 0),
                "loteFechaVencimiento" => $fechaVenc ? date("d/m/Y", strtotime($fechaVenc)) : "N/A",
                "invPrdDsc" => $lote["invPrdDsc"],
                "diasRestantes" => $diasRestantes
            ];
        }
        $lotesVencerJson = json_encode($lotesVencerFormat);

        $stockBajoList = DaoDashboard::getProductosStockBajoList();
        $stockBajoFormat = [];
        foreach ($stockBajoList as $prod) {
            $stockBajoFormat[] = [
                "invPrdBrCod" => $prod["invPrdBrCod"] ? $prod["invPrdBrCod"] : "N/A",
                "invPrdDsc" => $prod["invPrdDsc"],
                "invPrdStock" => number_format(floatval($prod["invPrdStock"]), 0),
                "invPrdStockMin" => number_format(floatval($prod["invPrdStockMin"]), 0)
            ];
        }
        $stockBajoJson = json_encode($stockBajoFormat);

        $mermasList = DaoDashboard::getMermasMesActualList();
        $mermasFormat = [];
        foreach ($mermasList as $merma) {
            $mermasFormat[] = [
                "movFecha" => date("d/m/Y H:i", strtotime($merma["movCreatedAt"])),
                "invPrdDsc" => $merma["invPrdDsc"],
                "movCantidad" => number_format(floatval($merma["movCantidad"]), 0),
                "movMotivo" => $merma["movMotivo"] ? $merma["movMotivo"] : "Sin motivo registrado"
            ];
        }
        $mermasJson = json_encode($mermasFormat);

        $viewData = [
            "userName" => $user && isset($user["userName"]) ? $user["userName"] : "Usuario",
            "totalProductos" => number_format(DaoDashboard::getTotalProductosActivos(), 0),
            "totalStockBajo" => number_format(DaoDashboard::getTotalProductosStockBajo(), 0),
            "valorInventario" => number_format(DaoDashboard::getValorInventarioActivo(), 2),
            "totalLotesPorVencer" => number_format(DaoDashboard::getTotalLotesPorVencer(), 0),
            "totalMovimientosHoy" => number_format(DaoDashboard::getMovimientosHoy(), 0),
            "totalMermasMes" => number_format(DaoDashboard::getMermasMesActual(), 0),
            "totalProductosAgotados" => number_format(DaoDashboard::getTotalProductosAgotados(), 0),
            "productosAgotadosJson" => $productosAgotadosJson,
            "lotesVencerJson" => $lotesVencerJson,
            "stockBajoJson" => $stockBajoJson,
            "mermasJson" => $mermasJson,
            "MovimientosRecientes" => $movimientos
        ];

        \Views\Renderer::render("admin/admin", $viewData);
    }

    private static function getMovimientoTipoDsc($tipo)
    {
        switch ($tipo) {
            case "ENT":
                return "Entrada";
            case "SAL":
                return "Salida";
            case "MER":
                return "Merma";
            default:
                return "Movimiento";
        }
    }

    private static function getMovimientoTipoClass($tipo)
    {
        switch ($tipo) {
            case "ENT":
                return "dash-badge--entry";
            case "SAL":
                return "dash-badge--exit";
            case "MER":
                return "dash-badge--loss";
            default:
                return "dash-badge--neutral";
        }
    }
}
?>
