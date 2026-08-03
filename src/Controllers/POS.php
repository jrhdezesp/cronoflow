<?php

namespace Controllers;

use Controllers\PrivateController;
use Dao\Mnt\POS as DaoPOS;
use Views\Renderer;

/**
 * Controlador del Módulo POS (Punto de Venta)
 *
 * Gestiona:
 * - Interfaz de venta (carrito, búsqueda de productos, cobro)
 * - Sesiones de caja (apertura/cierre)
 * - Clientes rápidos
 * - Procesamiento de ventas con validaciones
 * - Historial de ventas
 */
class POS extends PrivateController
{
    public function run(): void
    {
        $viewData = [
            "mode" => "pos",
            "sesionActiva" => null,
            "tieneSesionActiva" => false,
            "clienteDefecto" => 1, // Consumidor Final
            "clientes" => [],
            "ventasDelDia" => [],
            "totalVentasDia" => 0,
            "cantVentasDia" => 0,
            "productos" => [],
            "mostrarHistorial" => false,
            "canProcessSale" => false,
            "canOpenSession" => false,
            "canCloseSession" => false,
            "canAnulateSale" => false,
            "canViewHistory" => false,
            "hasErrors" => false,
            "aErrors" => []
        ];

        // Permisos
        $viewData["canProcessSale"] = self::isFeatureAutorized("Controllers\\POS\\ProcessSale");
        $viewData["canOpenSession"] = self::isFeatureAutorized("Controllers\\POS\\OpenSession");
        $viewData["canCloseSession"] = self::isFeatureAutorized("Controllers\\POS\\CloseSession");
        $viewData["canAnulateSale"] = self::isFeatureAutorized("Controllers\\POS\\AnulateSale");
        $viewData["canViewHistory"] = self::isFeatureAutorized("Controllers\\POS\\History");

        $userId = \Utilities\Security::getUserId();

        // Verificar sesión de caja activa
        $sesionActiva = DaoPOS::getSesionActiva($userId);
        if ($sesionActiva) {
            $viewData["sesionActiva"] = $sesionActiva;
            $viewData["tieneSesionActiva"] = true;
        }

        // Cargar clientes
        $viewData["clientes"] = DaoPOS::getClientes();

        // Cargar ventas del día
        $ventasDelDia = DaoPOS::getVentasDelDia();
        $viewData["ventasDelDia"] = $ventasDelDia;
        $totalDia = 0;
        $cantDia = 0;
        foreach ($ventasDelDia as $v) {
            if ($v["ventaEst"] === "ACT") {
                $totalDia += floatval($v["ventaTotal"]);
                $cantDia++;
            }
        }
        $viewData["totalVentasDia"] = $totalDia;
        $viewData["cantVentasDia"] = $cantDia;

        // Manejar POST según acción
        if ($this->isPostBack()) {
            $action = isset($_POST["action"]) ? $_POST["action"] : "";

            switch ($action) {
                case "buscar_productos":
                    $this->_handleBuscarProductos();
                    return;

                case "buscar_clientes":
                    $this->_handleBuscarClientes();
                    return;

                case "crear_cliente_rapido":
                    $this->_handleCrearClienteRapido();
                    return;

                case "abrir_caja":
                    $this->_handleAbrirCaja($userId, $viewData);
                    break;

                case "cerrar_caja":
                    $this->_handleCerrarCaja($userId, $viewData);
                    break;

                case "procesar_venta":
                    $this->_handleProcesarVenta($userId, $viewData);
                    break;

                case "anular_venta":
                    $this->_handleAnularVenta($userId, $viewData);
                    break;

                case "ver_detalle_venta":
                    $this->_handleVerDetalleVenta();
                    return;

                default:
                    $viewData["hasErrors"] = true;
                    $viewData["aErrors"][] = "Acción no reconocida.";
                    break;
            }
        }

        Renderer::render("pos/pos", $viewData);
    }

    /**
     * Maneja la búsqueda AJAX de productos
     */
    private function _handleBuscarProductos()
    {
        $query = isset($_POST["query"]) ? trim($_POST["query"]) : "";

        if (empty($query)) {
            echo json_encode(["success" => false, "message" => "Ingrese un término de búsqueda."]);
            die();
        }

        $productos = DaoPOS::buscarProductosPOS($query);
        $resultados = [];

        foreach ($productos as $prod) {
            $stock = intval($prod["invPrdStock"]);
            if ($stock <= 0) continue; // No mostrar agotados

            $resultados[] = [
                "id" => $prod["invPrdId"],
                "codigoBarras" => $prod["invPrdBrCod"] ?: "",
                "codigoInterno" => $prod["invPrdCodInt"] ?: "",
                "nombre" => $prod["invPrdDsc"],
                "categoria" => $prod["catnom"] ?: "",
                "precio" => floatval($prod["invPrdPrecioVenta"]),
                "costo" => floatval($prod["invPrdCosto"]),
                "stock" => $stock,
                "stockMin" => intval($prod["invPrdStockMin"]),
                "tipo" => $prod["invPrdTip"]
            ];
        }

        echo json_encode(["success" => true, "data" => $resultados]);
        die();
    }

    /**
     * Maneja la búsqueda AJAX de clientes
     */
    private function _handleBuscarClientes()
    {
        $query = isset($_POST["query"]) ? trim($_POST["query"]) : "";

        if (empty($query)) {
            echo json_encode(["success" => false, "message" => "Ingrese un término de búsqueda."]);
            die();
        }

        $clientes = DaoPOS::buscarClientes($query);
        echo json_encode(["success" => true, "data" => $clientes]);
        die();
    }

    /**
     * Maneja la creación rápida de clientes (AJAX)
     */
    private function _handleCrearClienteRapido()
    {
        $nombre = isset($_POST["nombre"]) ? trim($_POST["nombre"]) : "";
        $telefono = isset($_POST["telefono"]) ? trim($_POST["telefono"]) : "";
        $email = isset($_POST["email"]) ? trim($_POST["email"]) : "";

        if (empty($nombre)) {
            echo json_encode(["success" => false, "message" => "El nombre del cliente es obligatorio."]);
            die();
        }

        $clienteId = DaoPOS::crearClienteRapido($nombre, $telefono, $email);

        if ($clienteId > 0) {
            echo json_encode([
                "success" => true,
                "message" => "Cliente creado exitosamente.",
                "clienteId" => $clienteId,
                "clienteNombre" => $nombre
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Error al crear el cliente."]);
        }
        die();
    }

    /**
     * Maneja la apertura de sesión de caja
     */
    private function _handleAbrirCaja($userId, &$viewData)
    {
        if (!$viewData["canOpenSession"]) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "No tiene permisos para abrir caja.";
            return;
        }

        // Verificar si ya hay una sesión activa
        $sesionActual = DaoPOS::getSesionActiva($userId);
        if ($sesionActual) {
            $viewData["sesionActiva"] = $sesionActual;
            $viewData["tieneSesionActiva"] = true;
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "Ya tiene una sesión de caja abierta.";
            return;
        }

        $montoInicial = isset($_POST["montoInicial"]) ? floatval(str_replace([",", " "], [".", ""], trim((string)$_POST["montoInicial"]))) : 0;

        if ($montoInicial < 0) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "El monto inicial no puede ser negativo.";
            return;
        }

        $sesionId = DaoPOS::abrirSesionCaja($userId, $montoInicial);

        if ($sesionId > 0) {
            $viewData["sesionActiva"] = DaoPOS::getSesionActiva($userId);
            $viewData["tieneSesionActiva"] = true;
            \Utilities\Site::redirectToWithMsg(
                "index.php?page=pos",
                "¡Sesión de caja abierta exitosamente!"
            );
        } else {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "Error al abrir la sesión de caja.";
        }
    }

    /**
     * Maneja el cierre de sesión de caja
     */
    private function _handleCerrarCaja($userId, &$viewData)
    {
        if (!$viewData["canCloseSession"]) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "No tiene permisos para cerrar caja.";
            return;
        }

        $sesionActiva = DaoPOS::getSesionActiva($userId);
        if (!$sesionActiva) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "No hay una sesión de caja activa.";
            return;
        }

        $cajaSesionId = intval($sesionActiva["cajaSesionId"]);
        $montoFinal = isset($_POST["montoFinal"]) ? floatval(str_replace([",", " "], [".", ""], trim((string)$_POST["montoFinal"]))) : 0;
        $observaciones = isset($_POST["observaciones"]) ? trim((string)$_POST["observaciones"]) : "";

        if ($montoFinal < 0) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "El monto final no puede ser negativo.";
            return;
        }

        $resumen = DaoPOS::getResumenSesion($cajaSesionId);
        $totalVentas = floatval($resumen["monto_total"]);
        $cantVentas = intval($resumen["total_ventas"]);

        $result = DaoPOS::cerrarSesionCaja($cajaSesionId, $montoFinal, $totalVentas, $cantVentas, $observaciones);

        if ($result) {
            $viewData["tieneSesionActiva"] = false;
            $viewData["sesionActiva"] = null;
            \Utilities\Site::redirectToWithMsg(
                "index.php?page=pos",
                "¡Sesión de caja cerrada exitosamente! Total ventas: L. " . number_format($totalVentas, 2)
            );
        } else {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "Error al cerrar la sesión de caja.";
        }
    }

    /**
     * Maneja el procesamiento de una venta
     */
    private function _handleProcesarVenta($userId, &$viewData)
    {
        if (!$viewData["canProcessSale"]) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "No tiene permisos para procesar ventas.";
            return;
        }

        // Validar sesión de caja activa
        $sesionActiva = DaoPOS::getSesionActiva($userId);
        if (!$sesionActiva) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "Debe abrir una sesión de caja antes de vender.";
            return;
        }
        $cajaSesionId = intval($sesionActiva["cajaSesionId"]);

        // Obtener datos del formulario
        $clienteId = isset($_POST["clienteId"]) ? intval($_POST["clienteId"]) : 1; // Default: Consumidor Final
        $descuento = isset($_POST["descuento"]) ? floatval(str_replace([",", " "], [".", ""], trim((string)$_POST["descuento"]))) : 0;
        $pagoRecibido = isset($_POST["pagoRecibido"]) ? floatval(str_replace([",", " "], [".", ""], trim((string)$_POST["pagoRecibido"]))) : 0;
        $formaPago = isset($_POST["formaPago"]) ? strtoupper(trim((string)$_POST["formaPago"])) : "EFE";
        $itemsJSON = isset($_POST["items"]) ? trim((string)$_POST["items"]) : "[]";
        if ($itemsJSON === "") {
            $itemsJSON = "[]";
        }

        // Validar forma de pago
        if (!in_array($formaPago, ["EFE", "TAR", "MIX"], true)) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "Forma de pago no válida.";
            return;
        }

        // Decodificar items del carrito
        $items = json_decode($itemsJSON, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "El carrito no tiene un formato válido.";
            return;
        }

        if (!is_array($items) || empty($items)) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "El carrito está vacío. Agregue productos antes de procesar la venta.";
            return;
        }

        // Validar descuento
        if ($descuento < 0) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "El descuento no puede ser negativo.";
            return;
        }

        // Validar cliente
        if ($clienteId <= 0) {
            $clienteId = 1; // Consumidor Final
        }

        // Validar pago
        if ($pagoRecibido <= 0) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "El monto recibido debe ser mayor a cero.";
            return;
        }

        // Validar items individualmente (stock, precio)
        foreach ($items as $index => $item) {
            if (!is_array($item)) {
                $viewData["hasErrors"] = true;
                $viewData["aErrors"][] = "Hay un producto inválido en el carrito.";
                return;
            }

            $prdId = isset($item["invPrdId"]) ? intval($item["invPrdId"]) : 0;
            $cantidad = isset($item["cantidad"]) ? intval($item["cantidad"]) : 0;
            $precioUnitario = isset($item["precioUnitario"]) ? floatval(str_replace([",", " "], [".", ""], trim((string)$item["precioUnitario"]))) : 0;

            if ($prdId <= 0) {
                $viewData["hasErrors"] = true;
                $viewData["aErrors"][] = "El producto en la posición {$index} no es válido.";
                return;
            }

            if ($cantidad <= 0) {
                $viewData["hasErrors"] = true;
                $viewData["aErrors"][] = "La cantidad del producto debe ser mayor a cero.";
                return;
            }

            if ($precioUnitario <= 0) {
                $viewData["hasErrors"] = true;
                $viewData["aErrors"][] = "El precio unitario del producto debe ser mayor a cero.";
                return;
            }

            $items[$index]["invPrdId"] = $prdId;
            $items[$index]["cantidad"] = $cantidad;
            $items[$index]["precioUnitario"] = $precioUnitario;

            // Validar que el producto existe y tiene stock
            $producto = DaoPOS::getProductoPOSById($prdId);
            if (!$producto) {
                $viewData["hasErrors"] = true;
                $viewData["aErrors"][] = "Producto ID $prdId no encontrado.";
                return;
            }

            if (intval($producto["invPrdStock"]) < $cantidad) {
                $viewData["hasErrors"] = true;
                $viewData["aErrors"][] = "Stock insuficiente para '{$producto['invPrdDsc']}'. Disponible: {$producto['invPrdStock']}";
                return;
            }
        }

        // Procesar la venta
        $result = DaoPOS::procesarVenta(
            $userId,
            $clienteId,
            $cajaSesionId,
            $items,
            $descuento,
            $pagoRecibido,
            $formaPago
        );

        if ($result["success"]) {
            \Utilities\Site::redirectToWithMsg(
                "index.php?page=pos",
                "¡Venta #{$result['ventaCod']} procesada exitosamente! Total: L. " . number_format($result["total"], 2) . " | Cambio: L. " . number_format($result["cambio"], 2)
            );
        } else {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = $result["message"];
        }
    }

    /**
     * Maneja la anulación de una venta
     */
    private function _handleAnularVenta($userId, &$viewData)
    {
        if (!$viewData["canAnulateSale"]) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "No tiene permisos para anular ventas.";
            return;
        }

        $ventaId = isset($_POST["ventaId"]) ? intval($_POST["ventaId"]) : 0;
        $motivo = isset($_POST["motivoAnulacion"]) ? trim($_POST["motivoAnulacion"]) : "";

        if ($ventaId <= 0) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "ID de venta no válido.";
            return;
        }

        if (empty($motivo)) {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = "Debe especificar el motivo de la anulación.";
            return;
        }

        $result = DaoPOS::anularVenta($ventaId, $userId, $motivo);

        if ($result["success"]) {
            \Utilities\Site::redirectToWithMsg(
                "index.php?page=pos",
                $result["message"]
            );
        } else {
            $viewData["hasErrors"] = true;
            $viewData["aErrors"][] = $result["message"];
        }
    }

    /**
     * Maneja la visualización de detalle de venta (AJAX)
     */
    private function _handleVerDetalleVenta()
    {
        $ventaId = isset($_POST["ventaId"]) ? intval($_POST["ventaId"]) : 0;

        if ($ventaId <= 0) {
            echo json_encode(["success" => false, "message" => "ID de venta no válido."]);
            die();
        }

        $venta = DaoPOS::getVentaById($ventaId);

        if (!$venta) {
            echo json_encode(["success" => false, "message" => "Venta no encontrada."]);
            die();
        }

        echo json_encode(["success" => true, "data" => $venta]);
        die();
    }
}

