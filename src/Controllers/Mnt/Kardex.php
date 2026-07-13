<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Kardex as KardexDao;
use Views\Renderer;

class Kardex extends PrivateController
{
    const PAGE_SIZE = 50;

    public function run(): void
    {
        $viewData = [];

        $viewData["search_query"] = $_GET["search_query"] ?? "";
        $viewData["mov_tipo"] = $_GET["mov_tipo"] ?? "";
        $viewData["year"] = $_GET["year"] ?? "";
        $viewData["month"] = $_GET["month"] ?? "";
        $viewData["fecha_inicio"] = $_GET["fecha_inicio"] ?? "";
        $viewData["fecha_fin"] = $_GET["fecha_fin"] ?? "";
        $page = isset($_GET["page_num"]) ? max(1, intval($_GET["page_num"])) : 1;

        $searchDbParam = "";
        if (!empty($viewData["search_query"])) {
            $searchDbParam = "%" . $viewData["search_query"] . "%";
        } else {
            $searchDbParam = "";
        }

        $totalCount = KardexDao::countMovimientosFiltered(
            $searchDbParam,
            $viewData["mov_tipo"],
            $viewData["year"],
            $viewData["month"],
            $viewData["fecha_inicio"],
            $viewData["fecha_fin"]
        );

        $totalPages = max(1, ceil($totalCount / self::PAGE_SIZE));
        $page = min($page, $totalPages);

        $movimientosRaw = KardexDao::getMovimientosFiltered(
            $searchDbParam,
            $viewData["mov_tipo"],
            $viewData["year"],
            $viewData["month"],
            $viewData["fecha_inicio"],
            $viewData["fecha_fin"],
            $page,
            self::PAGE_SIZE
        );

        $movimientosFormateados = [];
        foreach ($movimientosRaw as $mov) {
            switch ($mov["movTipo"]) {
                case 'ENT':
                    $mov["movTipoDsc"] = "Entrada (+)";
                    $mov["badge_class"] = "badge-success";
                    break;
                case 'SAL':
                    $mov["movTipoDsc"] = "Salida (-)";
                    $mov["badge_class"] = "badge-error";
                    break;
                case 'MER':
                    $mov["movTipoDsc"] = "Merma (-)";
                    $mov["badge_class"] = "badge-warning";
                    break;
                default:
                    $mov["movTipoDsc"] = $mov["movTipo"];
                    $mov["badge_class"] = "";
                    break;
            }

            $mov["fecha_formateada"] = date("d/m/Y H:i", strtotime($mov["movCreatedAt"]));
            $movimientosFormateados[] = $mov;
        }

        $viewData["movimientos"] = $movimientosFormateados;
        $viewData["has_movimientos"] = count($movimientosFormateados) > 0;
        $viewData["current_page"] = $page;
        $viewData["total_pages"] = $totalPages;
        $viewData["has_prev"] = $page > 1;
        $viewData["has_next"] = $page < $totalPages;

        $viewData["tipo_" . $viewData["mov_tipo"] . "_selected"] = "selected";
        $viewData["year_" . $viewData["year"] . "_selected"] = "selected";
        $viewData["month_" . $viewData["month"] . "_selected"] = "selected";

        Renderer::render("mnt/kardex", $viewData);
    }
}
