<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Proveedores as DaoProveedores;
use Utilities\Validators;
use Utilities\Site;
use Views\Renderer;

class Proveedor extends PrivateController
{
    private $mode = "DSP";
    private $provId = 0;
    private $proveedor = [
        "provId" => 0,
        "provNombre" => "",
        "provContacto" => "",
        "provTelefono" => "",
        "provEmail" => "",
        "provDireccion" => "",
        "provEst" => "ACT"
    ];
    private $mode_dscs = [
        "INS" => "Crear Nuevo Proveedor",
        "UPD" => "Editar Proveedor: %s",
        "DSP" => "Detalles de Proveedor: %s"
    ];
    private $aErrors = [];

    public function run(): void
    {
        $this->_initParams();

        if ($this->isPostBack()) {
            $this->_handlePost();
        }

        $this->_prepareViewData();
        Renderer::render("mnt/proveedor", $this->proveedor);
    }

    private function _initParams()
    {
        if (isset($_GET["mode"])) {
            $this->mode = $_GET["mode"];
        }
        if (isset($_GET["provId"])) {
            $this->provId = intval($_GET["provId"]);
        }

        if ($this->isPostBack()) {
            if (isset($_POST["mode"])) {
                $this->mode = $_POST["mode"];
            }
            if (isset($_POST["provId"])) {
                $this->provId = intval($_POST["provId"]);
            }
        }

        if (!in_array($this->mode, ["INS", "UPD", "DSP"])) {
            Site::redirectToWithMsg("index.php?page=mnt_proveedores", "Accion no permitida.");
        }

        if ($this->mode === "INS" && !self::isFeatureAutorized("Controllers\\Mnt\\Proveedor\\New")) {
            Site::redirectToWithMsg("index.php?page=mnt_proveedores", "¡No tiene permisos para realizar esta acción!");
        }
        if ($this->mode === "UPD" && !self::isFeatureAutorized("Controllers\\Mnt\\Proveedor\\Upd")) {
            Site::redirectToWithMsg("index.php?page=mnt_proveedores", "¡No tiene permisos para realizar esta acción!");
        }
        if ($this->mode === "DSP" && !self::isFeatureAutorized("Controllers\\Mnt\\Proveedor\\Dsp")) {
            Site::redirectToWithMsg("index.php?page=mnt_proveedores", "¡No tiene permisos para realizar esta acción!");
        }

        if ($this->mode !== "INS") {
            $dbProveedor = DaoProveedores::getProveedorById($this->provId);
            if (!$dbProveedor) {
                Site::redirectToWithMsg("index.php?page=mnt_proveedores", "Proveedor no encontrado.");
            }
            $this->proveedor = $dbProveedor;
        }
    }

    private function _handlePost()
    {
        $this->proveedor["provNombre"] = isset($_POST["provNombre"]) ? trim($_POST["provNombre"]) : "";
        $this->proveedor["provContacto"] = isset($_POST["provContacto"]) ? trim($_POST["provContacto"]) : "";
        $this->proveedor["provTelefono"] = isset($_POST["provTelefono"]) ? trim($_POST["provTelefono"]) : "";
        $this->proveedor["provEmail"] = isset($_POST["provEmail"]) ? trim($_POST["provEmail"]) : "";
        $this->proveedor["provDireccion"] = isset($_POST["provDireccion"]) ? trim($_POST["provDireccion"]) : "";
        $this->proveedor["provEst"] = isset($_POST["provEst"]) ? $_POST["provEst"] : "ACT";

        if (Validators::IsEmpty($this->proveedor["provNombre"])) {
            $this->aErrors[] = "El nombre de la empresa proveedora es requerido.";
        }
        if (strlen($this->proveedor["provNombre"]) > 100) {
            $this->aErrors[] = "El nombre del proveedor no puede exceder los 100 caracteres.";
        }
        if (!empty($this->proveedor["provContacto"]) && strlen($this->proveedor["provContacto"]) > 100) {
            $this->aErrors[] = "El contacto no puede exceder los 100 caracteres.";
        }
        if (!empty($this->proveedor["provEmail"]) && !filter_var($this->proveedor["provEmail"], FILTER_VALIDATE_EMAIL)) {
            $this->aErrors[] = "El correo del proveedor no tiene un formato valido.";
        }
        if (!in_array($this->proveedor["provEst"], ["ACT", "INA"])) {
            $this->aErrors[] = "Estado no valido seleccionado.";
        }

        $existing = DaoProveedores::getProveedorByName($this->proveedor["provNombre"]);
        if ($existing && ($this->mode === "INS" || intval($existing["provId"]) !== $this->provId)) {
            $this->aErrors[] = "Ya existe un proveedor con este nombre.";
            $this->proveedor["provNombre"] = "";
        }

        if (count($this->aErrors) === 0) {
            if ($this->mode === "INS") {
                $result = DaoProveedores::newProveedor(
                    $this->proveedor["provNombre"],
                    $this->proveedor["provContacto"],
                    $this->proveedor["provTelefono"],
                    $this->proveedor["provEmail"],
                    $this->proveedor["provDireccion"],
                    $this->proveedor["provEst"]
                );

                if ($result) {
                    Site::redirectToWithMsg("index.php?page=mnt_proveedores", "Proveedor creado exitosamente.");
                } else {
                    $this->aErrors[] = "Hubo un error al crear el proveedor en la base de datos.";
                }
            } elseif ($this->mode === "UPD") {
                $result = DaoProveedores::updateProveedor(
                    $this->provId,
                    $this->proveedor["provNombre"],
                    $this->proveedor["provContacto"],
                    $this->proveedor["provTelefono"],
                    $this->proveedor["provEmail"],
                    $this->proveedor["provDireccion"],
                    $this->proveedor["provEst"]
                );

                if ($result) {
                    Site::redirectToWithMsg("index.php?page=mnt_proveedores", "Proveedor actualizado exitosamente.");
                } else {
                    $this->aErrors[] = "Hubo un error al actualizar el proveedor en la base de datos.";
                }
            }
        }
    }

    private function _prepareViewData()
    {
        $this->proveedor["mode"] = $this->mode;
        $this->proveedor["provId"] = $this->provId;

        if ($this->mode === "INS") {
            $this->proveedor["mode_dsc"] = $this->mode_dscs["INS"];
        } else {
            $this->proveedor["mode_dsc"] = sprintf($this->mode_dscs[$this->mode], $this->proveedor["provNombre"]);
        }

        $this->proveedor["readonly"] = ($this->mode === "DSP") ? "readonly" : "";
        $this->proveedor["showaction"] = ($this->mode !== "DSP");
        $this->proveedor["provEst_ACT"] = ($this->proveedor["provEst"] === "ACT") ? "selected" : "";
        $this->proveedor["provEst_INA"] = ($this->proveedor["provEst"] === "INA") ? "selected" : "";
        $this->proveedor["hasErrors"] = (count($this->aErrors) > 0);
        $this->proveedor["aErrors"] = $this->aErrors;
    }
}
