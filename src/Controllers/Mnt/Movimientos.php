<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Movimientos as DaoMovimientos;
use Views\Renderer;

class Movimientos extends PrivateController
{
    private array $viewData = [];

    private function _markSelected(array $items, $selectedValue, string $valueKey): array
    {
        return array_map(function ($item) use ($selectedValue, $valueKey): array {
            $item["selected"] = "";

            if (isset($item[$valueKey]) && strval($item[$valueKey]) === strval($selectedValue)) {
                $item["selected"] = "selected";
            }

            return $item;
        }, $items);
    }

    private function _setMovementTypeSelection(string $movementType): void
    {
        $this->viewData["movementType_ENT"] = "";
        $this->viewData["movementType_SAL"] = "";
        $this->viewData["movementType_MER"] = "";

        if ($movementType === "ENT") {
            $this->viewData["movementType_ENT"] = "selected";
        } elseif ($movementType === "SAL") {
            $this->viewData["movementType_SAL"] = "selected";
        } elseif ($movementType === "MER") {
            $this->viewData["movementType_MER"] = "selected";
        }
    }

    public function run(): void
    {
        $this->viewData = [
            "Productos" => [],
            "Batches" => [],
            "productoSeleccionado" => 0,
            "batchSeleccionado" => 0,
            "movementType" => "",
            "quantity" => "",
            "reason" => "",
            "aErrors" => [],
            "hasErrors" => false,
            "movementType_ENT" => "",
            "movementType_SAL" => "",
            "movementType_MER" => ""
        ];

        $selectedProductId = isset($_GET["invPrdId"])
            ? intval($_GET["invPrdId"])
            : 0;

        /*
         * Cargar productos
         */
        $productos = DaoMovimientos::getProductosActivos();
        $this->viewData["Productos"] =
            $this->_markSelected($productos, $selectedProductId, "invPrdId");

        /*
         * Si se seleccionó un producto,
         * cargar sus batches.
         */
        if ($selectedProductId > 0) {
            $this->viewData["productoSeleccionado"] =
                $selectedProductId;

            $batches = DaoMovimientos::getBatchesByProducto(
                $selectedProductId
            );
            $this->viewData["Batches"] =
                $this->_markSelected($batches, 0, "batchId");
        }

        /*
         * Procesar formulario
         */
        if ($this->isPostBack()) {
            $this->_handlePost();
        }

        Renderer::render(
            "mnt/movimientos",
            $this->viewData
        );
    }

    private function _handlePost(): void
    {
        $invPrdId = isset($_POST["invPrdId"])
            ? intval($_POST["invPrdId"])
            : 0;

        $batchId = isset($_POST["batchId"])
            ? intval($_POST["batchId"])
            : 0;

        $movementType = isset($_POST["movementType"])
            ? trim($_POST["movementType"])
            : "";

        $quantity = isset($_POST["quantity"])
            ? intval($_POST["quantity"])
            : 0;

        $reason = isset($_POST["reason"])
            ? trim($_POST["reason"])
            : "";

        /*
         * Mantener valores del formulario
         */
        $this->viewData["productoSeleccionado"] =
            $invPrdId;

        $this->viewData["batchSeleccionado"] =
            $batchId;

        $this->viewData["movementType"] =
            $movementType;

        $this->viewData["quantity"] =
            $quantity;

        $this->viewData["reason"] =
            $reason;

        $this->_setMovementTypeSelection($movementType);

        $productos = DaoMovimientos::getProductosActivos();
        $this->viewData["Productos"] =
            $this->_markSelected($productos, $invPrdId, "invPrdId");

        /*
         * Cargar batches del producto
         */
        if ($invPrdId > 0) {
            $batches = DaoMovimientos::getBatchesByProducto(
                $invPrdId
            );
            $this->viewData["Batches"] =
                $this->_markSelected($batches, $batchId, "batchId");
        }

        /*
         * Validar producto
         */
        if ($invPrdId <= 0) {

            $this->viewData["aErrors"][] =
                "Debe seleccionar un producto.";
        }

        /*
         * Validar tipo
         */
        if (
            !in_array(
                $movementType,
                ["ENT", "SAL", "MER"]
            )
        ) {

            $this->viewData["aErrors"][] =
                "Debe seleccionar un tipo de movimiento válido.";
        }

        /*
         * Validar cantidad
         */
        if ($quantity <= 0) {

            $this->viewData["aErrors"][] =
                "La cantidad debe ser mayor a cero.";
        }

        /*
         * Validar motivo
         */
        if (empty($reason)) {

            $this->viewData["aErrors"][] =
                "El motivo del movimiento es obligatorio.";
        }

        /*
         * Validar batch
         */
        if ($batchId <= 0) {

            $this->viewData["aErrors"][] =
                "Debe seleccionar un batch.";
        }

        /*
         * Procesar movimiento
         */
        if (
            count(
                $this->viewData["aErrors"]
            ) === 0
        ) {

            try {

                $userId =
                    \Utilities\Security::getUserId();

                $result =
                    DaoMovimientos::procesarMovimiento(
                        $invPrdId,
                        $batchId,
                        $movementType,
                        $quantity,
                        $reason,
                        $userId
                    );

                if ($result) {

                    \Utilities\Site::redirectToWithMsg(
                        "index.php?page=mnt_movimientos",
                        "¡Movimiento registrado exitosamente!"
                    );
                }
            } catch (\Exception $ex) {

                $this->viewData["aErrors"][] =
                    $ex->getMessage();
            }
        }

        $this->viewData["hasErrors"] =
            count(
                $this->viewData["aErrors"]
            ) > 0;
    }
}
