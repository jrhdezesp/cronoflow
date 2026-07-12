<?php

namespace Controllers\Mnt;

use Controllers\PrivateController;
use Dao\Mnt\Categorias as DaoCategorias;
use Utilities\Validators;
use Utilities\Site;
use Views\Renderer;

class Categoria extends PrivateController
{
    private $mode = "DSP";
    private $catid = 0;
    private $categoria = [
        "catid" => 0,
        "catnom" => "",
        "catest" => "ACT"
    ];
    private $mode_dscs = [
        "INS" => "Crear Nueva Categoría",
        "UPD" => "Editar Categoría: %s",
        "DSP" => "Detalles de Categoría: %s"
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
        Renderer::render("mnt/categoria", $this->categoria);
    }

    private function _initParams()
    {
        if (isset($_GET["mode"])) {
            $this->mode = $_GET["mode"];
        }
        if (isset($_GET["catid"])) {
            $this->catid = intval($_GET["catid"]);
        }

        if ($this->isPostBack()) {
            if (isset($_POST["mode"])) {
                $this->mode = $_POST["mode"];
            }
            if (isset($_POST["catid"])) {
                $this->catid = intval($_POST["catid"]);
            }
        }

        // Validate mode
        if (!in_array($this->mode, ["INS", "UPD", "DSP"])) {
            Site::redirectToWithMsg("index.php?page=mnt_categorias", "¡Acción no permitida!");
        }

        if ($this->mode === "INS" && !self::isFeatureAutorized("Controllers\\Mnt\\Categoria\\New")) {
            Site::redirectToWithMsg("index.php?page=mnt_categorias", "¡No tiene permisos para realizar esta acción!");
        }
        if ($this->mode === "UPD" && !self::isFeatureAutorized("Controllers\\Mnt\\Categoria\\Upd")) {
            Site::redirectToWithMsg("index.php?page=mnt_categorias", "¡No tiene permisos para realizar esta acción!");
        }
        if ($this->mode === "DSP" && !self::isFeatureAutorized("Controllers\\Mnt\\Categoria\\Dsp")) {
            Site::redirectToWithMsg("index.php?page=mnt_categorias", "¡No tiene permisos para realizar esta acción!");
        }

        if ($this->mode !== "INS") {
            $dbCat = DaoCategorias::getCategoriaById($this->catid);
            if (!$dbCat) {
                Site::redirectToWithMsg("index.php?page=mnt_categorias", "¡Categoría no encontrada!");
            }
            $this->categoria = $dbCat;
        }
    }

    private function _handlePost()
    {
        $this->categoria["catnom"] = isset($_POST["catnom"]) ? trim($_POST["catnom"]) : "";
        $this->categoria["catest"] = isset($_POST["catest"]) ? $_POST["catest"] : "ACT";

        // Validations
        if (Validators::IsEmpty($this->categoria["catnom"])) {
            $this->aErrors[] = "El nombre de la categoría es requerido.";
        }
        if (strlen($this->categoria["catnom"]) > 45) {
            $this->aErrors[] = "El nombre de la categoría no puede exceder los 45 caracteres.";
        }

        // Unique check
        $existing = DaoCategorias::getCategoriaByName($this->categoria["catnom"]);
        if ($existing && ($this->mode === "INS" || $existing["catid"] !== $this->catid)) {
            $this->aErrors[] = "Ya existe una categoría con este nombre.";
            $this->categoria["catnom"] = "";
        }

        if (count($this->aErrors) === 0) {
            if ($this->mode === "INS") {
                $result = DaoCategorias::insertCategoria(
                    $this->categoria["catnom"],
                    $this->categoria["catest"]
                );

                if ($result) {
                    Site::redirectToWithMsg(
                        "index.php?page=mnt_categorias",
                        "¡Categoría creada exitosamente!"
                    );
                } else {
                    $this->aErrors[] = "Hubo un error al crear la categoría en la base de datos.";
                }
            } elseif ($this->mode === "UPD") {
                $result = DaoCategorias::updateCategoria(
                    $this->catid,
                    $this->categoria["catnom"],
                    $this->categoria["catest"]
                );

                if ($result) {
                    Site::redirectToWithMsg(
                        "index.php?page=mnt_categorias",
                        "¡Categoría actualizada exitosamente!"
                    );
                } else {
                    $this->aErrors[] = "Hubo un error al actualizar la categoría en la base de datos.";
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
        $this->categoria["mode"] = $this->mode;
        $this->categoria["catid"] = $this->catid;

        // Map mode descriptions
        if ($this->mode === "INS") {
            $this->categoria["mode_dsc"] = $this->mode_dscs["INS"];
        } else {
            $this->categoria["mode_dsc"] = sprintf($this->mode_dscs[$this->mode], $this->categoria["catnom"]);
        }

        // Configure read-only states
        $this->categoria["readonly"] = ($this->mode === "DSP") ? "readonly" : "";
        $this->categoria["showaction"] = ($this->mode !== "DSP") ? true : false;

        // Map status indicators
        $this->categoria["catest_ACT"] = ($this->categoria["catest"] === "ACT") ? "selected" : "";
        $this->categoria["catest_INA"] = ($this->categoria["catest"] === "INA") ? "selected" : "";
        $this->categoria["catest_PLN"] = ($this->categoria["catest"] === "PLN") ? "selected" : "";

        // Map errors
        $this->categoria["hasErrors"] = (count($this->aErrors) > 0);
        $this->categoria["aErrors"] = $this->aErrors;
    }
}
