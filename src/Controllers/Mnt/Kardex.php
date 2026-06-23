<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Kardex as KardexDao;
use Views\Renderer;

class Kardex extends PrivateController
{
    public function run(): void
    {
        $viewData = [];

       
        $viewData["search_query"] = $_GET["search_query"] ?? "";
        $viewData["mov_tipo"] = $_GET["mov_tipo"] ?? "";
        $viewData["year"] = $_GET["year"] ?? "";
        $viewData["month"] = $_GET["month"] ?? "";
        $viewData["fecha_inicio"] = $_GET["fecha_inicio"] ?? "";
        $viewData["fecha_fin"] = $_GET["fecha_fin"] ?? "";

        // preparar el parámetro de búsqueda con comodines si no está vacío
        $searchDbParam = "";
        if (!empty($viewData["search_query"])) {
            $searchDbParam = "%" . $viewData["search_query"] . "%";
        } else {
            $searchDbParam = "";
        }

        // Consultar a la base de datos 
        $movimientosRaw = KardexDao::getMovimientosFiltered(
            $searchDbParam,
            $viewData["mov_tipo"],
            $viewData["year"],
            $viewData["month"],
            $viewData["fecha_inicio"],
            $viewData["fecha_fin"]
        );

        // Formatear datos para la interfaz de usuario 
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
                    $mov["badge_class"] = "badge-warning"; // O badge-error según tu CSS estándar
                    break;
                default:
                    $mov["movTipoDsc"] = $mov["movTipo"];
                    $mov["badge_class"] = "";
                    break;
            }
            
            // Opcional: Si deseas limpiar aún más el formato de fecha 
            $mov["fecha_formateada"] = date("d/m/Y H:i", strtotime($mov["movCreatedAt"]));
            
            $movimientosFormateados[] = $mov;
        }

        $viewData["movimientos"] = $movimientosFormateados;
        $viewData["has_movimientos"] = count($movimientosFormateados) > 0;

        // Mantener los estados de "selected" en los inputs del formulario
        $viewData["tipo_" . $viewData["mov_tipo"] . "_selected"] = "selected";
        $viewData["year_" . $viewData["year"] . "_selected"] = "selected";
        $viewData["month_" . $viewData["month"] . "_selected"] = "selected";

        //  Renderizar la plantilla
        Renderer::render("mnt/kardex", $viewData);
    }
}
