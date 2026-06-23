<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Productos as DaoProductos;
use Utilities\Validators;
use Utilities\Site;
use Views\Renderer;

class Producto extends PrivateController
{
    private $mode = "DSP";
    private $id = 0;
    private $catid = 0;
    private $selectedEst = "";
    private $product = [
        "invPrdId" => 0,
        "invPrdBrCod" => "",
        "invPrdCodInt" => "",
        "invPrdDsc" => "",
        "catid" => 0,
        "provId" => 0,
        "invPrdPrecioVenta" => 0.00,
        "invPrdCosto" => 0.00,
        "invPrdStock" => 0,
        "invPrdStockMin" => 10,
        "invPrdTip" => "PRD",
        "invPrdEst" => "ACT"
    ];
    private $mode_dscs = [
        "INS" => "Crear Nuevo Producto",
        "UPD" => "Editar Producto: %s",
        "DSP" => "Detalles del Producto: %s"
    ];
    private $aErrors = [];

    public function run(): void
    {
        $this->_initParams();

        if ($this->isPostBack()) {
            $this->_handlePost();
        } else {
            $this->_handleGet();
        }

        $this->_prepareViewData();
        Renderer::render("mnt/producto", $this->product);
    }

    private function _initParams()
    {
        if (isset($_GET["mode"])) {
            $this->mode = $_GET["mode"];
        }
        if (isset($_GET["id"])) {
            $this->id = intval($_GET["id"]);
        }
        if (isset($_GET["catid"])) {
            $this->catid = intval($_GET["catid"]);
        }

        if ($this->isPostBack()) {
            if (isset($_POST["mode"])) {
                $this->mode = $_POST["mode"];
            }
            if (isset($_POST["id"])) {
                $this->id = intval($_POST["id"]);
            }
            if (isset($_POST["catid"])) {
                $this->catid = intval($_POST["catid"]);
            }
        }

        // Validate mode
        if (!in_array($this->mode, ["INS", "UPD", "DSP"])) {
            Site::redirectToWithMsg("index.php?page=mnt_productos", "¡Acción no permitida!");
        }

        if ($this->mode === "INS" && !self::isFeatureAutorized("Controllers\\Mnt\\Producto\\New")) {
            Site::redirectToWithMsg("index.php?page=mnt_productos", "¡No tiene permisos para realizar esta acción!");
        }
        if ($this->mode === "UPD" && !self::isFeatureAutorized("Controllers\\Mnt\\Producto\\Upd")) {
            Site::redirectToWithMsg("index.php?page=mnt_productos", "¡No tiene permisos para realizar esta acción!");
        }
        if ($this->mode === "DSP" && !self::isFeatureAutorized("Controllers\\Mnt\\Producto\\Dsp")) {
            Site::redirectToWithMsg("index.php?page=mnt_productos", "¡No tiene permisos para realizar esta acción!");
        }

        if ($this->mode !== "INS") {
            $dbProduct = DaoProductos::getProductoByCode($this->id);
            if (!$dbProduct) {
                Site::redirectToWithMsg("index.php?page=mnt_productos", "¡Producto no encontrado!");
            }
            $this->product = $dbProduct;
            $this->catid = $this->product["catid"];
        } else {
            $this->product["catid"] = $this->catid;
        }
    }

    private function _handlePost()
    {
        // Collect general fields
        $this->product["invPrdBrCod"] = isset($_POST["invPrdBrCod"]) ? trim($_POST["invPrdBrCod"]) : "";
        $this->product["invPrdCodInt"] = isset($_POST["invPrdCodInt"]) ? trim($_POST["invPrdCodInt"]) : "";
        $this->product["invPrdDsc"] = isset($_POST["invPrdDsc"]) ? trim($_POST["invPrdDsc"]) : "";
        $this->product["catid"] = isset($_POST["catid"]) ? intval($_POST["catid"]) : 0;
        $this->product["provId"] = isset($_POST["provId"]) ? intval($_POST["provId"]) : 0;
        
        if ($this->mode === "INS") {
            $this->product["invPrdPrecioVenta"] = isset($_POST["invPrdPrecioVenta"]) ? floatval($_POST["invPrdPrecioVenta"]) : 0.00;
            $this->product["invPrdCosto"] = isset($_POST["invPrdCosto"]) ? floatval($_POST["invPrdCosto"]) : 0.00;
        } else {
            $dbProduct = DaoProductos::getProductoByCode($this->id);
            if ($dbProduct) {
                $this->product["invPrdPrecioVenta"] = floatval($dbProduct["invPrdPrecioVenta"]);
                $this->product["invPrdCosto"] = floatval($dbProduct["invPrdCosto"]);
            }
        }
        
        $this->product["invPrdStockMin"] = isset($_POST["invPrdStockMin"]) ? intval($_POST["invPrdStockMin"]) : 10;
        $this->product["invPrdTip"] = isset($_POST["invPrdTip"]) ? $_POST["invPrdTip"] : "PRD";
        
        $this->selectedEst = isset($_POST["invPrdEst"]) ? $_POST["invPrdEst"] : "DIS";

        $loteCod = isset($_POST["loteCod"]) ? trim($_POST["loteCod"]) : "";
        $loteFechaVencimiento = isset($_POST["loteFechaVencimiento"]) ? trim($_POST["loteFechaVencimiento"]) : "";
        $this->product["loteCod"] = $loteCod;
        $this->product["loteFechaVencimiento"] = $loteFechaVencimiento;

        // Collect stock (can only change stock in INS mode directly, otherwise keep database stock)
        if ($this->mode === "INS") {
            $newStock = isset($_POST["invPrdStock"]) ? intval($_POST["invPrdStock"]) : 0;
        } else {
            $newStock = intval($this->product["invPrdStock"]);
        }
        $this->product["invPrdStock"] = $newStock;

        // Validations
        if (Validators::IsEmpty($this->product["invPrdDsc"])) {
            $this->aErrors[] = "El nombre o descripción del producto es requerido.";
        }

        if ($this->product["invPrdPrecioVenta"] <= 0) {
            $this->aErrors[] = "El precio de venta debe ser mayor a cero.";
        }

        if ($this->product["invPrdCosto"] < 0) {
            $this->aErrors[] = "El costo de adquisición no puede ser negativo.";
        }

        if ($this->product["invPrdPrecioVenta"] <= $this->product["invPrdCosto"]) {
            $this->aErrors[] = "El precio de venta debe ser mayor al costo de adquisición para asegurar un margen de ganancia.";
        }

        if ($newStock < 0) {
            $this->aErrors[] = "El stock del producto no puede ser negativo.";
        }

        if ($this->product["invPrdStockMin"] < 0) {
            $this->aErrors[] = "El stock mínimo no puede ser negativo.";
        }

        if ($this->mode === "INS" && $newStock > 0 && empty($loteCod)) {
            $this->aErrors[] = "Debe proporcionar un código de lote si el stock inicial es mayor a cero.";
        }

        if ($this->mode === "INS" && !empty($loteFechaVencimiento)) {
            $today = date("Y-m-d");
            if ($loteFechaVencimiento < $today) {
                $this->aErrors[] = "La fecha de vencimiento del lote no puede ser anterior a la fecha actual (" . date("d/m/Y") . ").";
                $this->product["loteFechaVencimiento"] = "";
            }
        }

        // Validaciones de consistencia de estado y stock físico
        if ($this->selectedEst === "DIS") {
            if ($newStock <= $this->product["invPrdStockMin"]) {
                $this->aErrors[] = "Para establecer el estado 'Disponible', el stock físico (" . $newStock . ") debe ser mayor al stock mínimo (" . $this->product["invPrdStockMin"] . ").";
            }
            $this->product["invPrdEst"] = "ACT";
        } elseif ($this->selectedEst === "AGO") {
            if ($newStock !== 0) {
                $this->aErrors[] = "Para establecer el estado 'Agotado', el stock físico debe ser exactamente 0.";
            }
            $this->product["invPrdEst"] = "ACT";
        } elseif ($this->selectedEst === "CAS") {
            if ($newStock <= 0 || $newStock > $this->product["invPrdStockMin"]) {
                $this->aErrors[] = "Para establecer el estado 'Casi Agotado', el stock físico (" . $newStock . ") debe ser mayor a 0 y menor o igual al stock mínimo (" . $this->product["invPrdStockMin"] . ").";
            }
            $this->product["invPrdEst"] = "ACT";
        } elseif ($this->selectedEst === "INA") {
            $this->product["invPrdEst"] = "INA";
        } else {
            $this->aErrors[] = "Estado no válido seleccionado.";
        }

        // Barcode unique check
        if (!empty($this->product["invPrdBrCod"])) {
            $existingBarcode = DaoProductos::getProductoByBarcode($this->product["invPrdBrCod"]);
            if ($existingBarcode && ($this->mode === "INS" || $existingBarcode["invPrdId"] !== $this->id)) {
                $this->aErrors[] = "El código de barras ya está registrado por otro producto.";
                $this->product["invPrdBrCod"] = "";
            }
        }

        // Internal code unique check
        if (!empty($this->product["invPrdCodInt"])) {
            $existingIntcode = DaoProductos::getProductoByIntcode($this->product["invPrdCodInt"]);
            if ($existingIntcode && ($this->mode === "INS" || $existingIntcode["invPrdId"] !== $this->id)) {
                $this->aErrors[] = "El código interno institucional ya está registrado por otro producto.";
                $this->product["invPrdCodInt"] = "";
            }
        }

        if (count($this->aErrors) === 0) {
            $userId = \Utilities\Security::getUserId();

            if ($this->mode === "INS") {
                $result = DaoProductos::newProducto(
                    $this->product["invPrdBrCod"],
                    $this->product["invPrdCodInt"],
                    $this->product["invPrdDsc"],
                    $this->product["catid"],
                    $this->product["invPrdPrecioVenta"],
                    $this->product["invPrdCosto"],
                    $newStock,
                    $this->product["invPrdStockMin"],
                    $this->product["invPrdTip"],
                    $this->product["invPrdEst"],
                    $userId,
                    $loteCod,
                    $loteFechaVencimiento,
                    $this->product["provId"]
                );

                if ($result) {
                    Site::redirectToWithMsg(
                        "index.php?page=mnt_productos&catid=" . $this->product["catid"],
                        "¡Producto creado exitosamente!"
                    );
                } else {
                    $this->aErrors[] = "Hubo un error al crear el producto en la base de datos.";
                }
            } elseif ($this->mode === "UPD") {
                $oldProduct = DaoProductos::getProductoByCode($this->id);
                $oldStock = $oldProduct ? intval($oldProduct["invPrdStock"]) : 0;

                $result = DaoProductos::updateProducto(
                    $this->id,
                    $this->product["invPrdBrCod"],
                    $this->product["invPrdCodInt"],
                    $this->product["invPrdDsc"],
                    $this->product["catid"],
                    $this->product["invPrdPrecioVenta"],
                    $this->product["invPrdCosto"],
                    $newStock,
                    $this->product["invPrdStockMin"],
                    $this->product["invPrdTip"],
                    $this->product["invPrdEst"],
                    $userId,
                    $this->product["provId"]
                );

                if ($result) {
                    // Kardex Log: Check stock difference
                    if ($newStock !== $oldStock) {
                        $diff = $newStock - $oldStock;
                        if ($diff > 0) {
                            DaoProductos::registrarMovimiento(
                                $this->id,
                                "ENT",
                                $diff,
                                "Ajuste manual de inventario (Incremento)",
                                $userId
                            );
                        } else {
                            DaoProductos::registrarMovimiento(
                                $this->id,
                                "MER",
                                abs($diff),
                                "Ajuste manual de inventario (Disminución / Merma)",
                                $userId
                            );
                        }
                    }

                    Site::redirectToWithMsg(
                        "index.php?page=mnt_productos&catid=" . $this->product["catid"],
                        "¡Producto actualizado exitosamente!"
                    );
                } else {
                    $this->aErrors[] = "Hubo un error al actualizar el producto en la base de datos.";
                }
            }
        }
    }

    private function _handleGet()
    {
        // Handled by _initParams loader
    }

    private function _prepareViewData()
    {
        $this->product["mode"] = $this->mode;
        $this->product["id"] = $this->id;
        $this->product["catid_url"] = $this->catid;

        // Map mode descriptions
        if ($this->mode === "INS") {
            $this->product["mode_dsc"] = $this->mode_dscs["INS"];
        } else {
            $this->product["mode_dsc"] = sprintf($this->mode_dscs[$this->mode], $this->product["invPrdDsc"]);
        }

        // Configure read-only states
        $this->product["readonly"] = ($this->mode === "DSP") ? "readonly" : "";
        $this->product["stock_readonly"] = ($this->mode === "INS") ? "" : "readonly";
        $this->product["showaction"] = ($this->mode !== "DSP") ? true : false;
        $this->product["show_lote_fields"] = ($this->mode === "INS");
        $this->product["show_price_cost_fields"] = ($this->mode === "INS" || $this->mode === "DSP");
        $this->product["provId"] = isset($this->product["provId"]) ? intval($this->product["provId"]) : 0;

        // Map type indicators
        $this->product["invPrdTip_PRD"] = ($this->product["invPrdTip"] === "PRD") ? "selected" : "";
        $this->product["invPrdTip_SRV"] = ($this->product["invPrdTip"] === "SRV") ? "selected" : "";

        // Map status indicators based on computed or pre-selected business status
        $selectedEst = $this->selectedEst;
        if (empty($selectedEst)) {
            $stock = intval($this->product["invPrdStock"]);
            $stockMin = intval($this->product["invPrdStockMin"]);
            $est = $this->product["invPrdEst"];
            if ($est === "INA") {
                $selectedEst = "INA";
            } elseif ($stock === 0) {
                $selectedEst = "AGO";
            } elseif ($stock <= $stockMin) {
                $selectedEst = "CAS";
            } else {
                $selectedEst = "DIS";
            }
        }

        $this->product["invPrdEst_DIS"] = ($selectedEst === "DIS") ? "selected" : "";
        $this->product["invPrdEst_AGO"] = ($selectedEst === "AGO") ? "selected" : "";
        $this->product["invPrdEst_CAS"] = ($selectedEst === "CAS") ? "selected" : "";
        $this->product["invPrdEst_INA"] = ($selectedEst === "INA") ? "selected" : "";

        // Map errors
        $this->product["hasErrors"] = (count($this->aErrors) > 0);
        $this->product["aErrors"] = $this->aErrors;

        // Load categories list and mark selected category
        $categoriesList = DaoProductos::getCategorias();
        $categoriesFormatted = [];
        foreach ($categoriesList as $cat) {
            $categoriesFormatted[] = [
                "catid" => $cat["catid"],
                "catnom" => $cat["catnom"],
                "selected" => ($cat["catid"] == $this->product["catid"]) ? "selected" : ""
            ];
        }
        $this->product["Categorias"] = $categoriesFormatted;

        $proveedoresList = DaoProductos::getProveedoresActivos();
        $proveedoresFormatted = [];
        $selectedProveedorNombre = "";
        foreach ($proveedoresList as $prov) {
            $provId = intval($prov["provId"]);
            $proveedoresFormatted[] = [
                "provId" => $provId,
                "provNombre" => $prov["provNombre"]
            ];
            if ($provId === intval($this->product["provId"])) {
                $selectedProveedorNombre = $prov["provNombre"];
            }
        }
        $this->product["proveedores_json"] = json_encode($proveedoresFormatted);
        $this->product["provNombre"] = $selectedProveedorNombre;
    }
}
