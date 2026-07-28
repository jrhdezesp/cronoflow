<?php

/**
 * Controlador POS - Punto de Venta
 * Maneja búsqueda de productos, gestión del carrito y registro de ventas
 * 
 * @category Private
 * @package  Controllers\Mnt
 * @author   Integrante 5 (María)
 * @license  MIT
 * @version  1.0.0
 */

namespace Controllers\Mnt;

use Dao\Mnt\Productos as DaoProductos;

/**
 * Controlador de Punto de Venta (POS)
 */
class Pos extends \Controllers\PrivateController
{
    /**
     * Ejecuta el controlador POS
     */
    public function run(): void
    {
        $viewData = [];
        $action = $_GET['action'] ?? 'view';

        try {
            switch ($action) {
                case 'search':
                    $this->handleSearch($viewData);
                    break;
                case 'add_cart':
                    $this->handleAddCart($viewData);
                    break;
                case 'remove_cart':
                    $this->handleRemoveCart($viewData);
                    break;
                case 'update_cart':
                    $this->handleUpdateCart($viewData);
                    break;
                case 'process_sale':
                    $this->handleProcessSale($viewData);
                    break;
                case 'get_cart':
                    $this->handleGetCart($viewData);
                    break;
                default:
                    $this->handleView($viewData);
                    break;
            }
        } catch (\Exception $ex) {
            $viewData['error'] = $ex->getMessage();
            \Views\Renderer::render("mnt/pos", $viewData);
        }
    }

    /**
     * Maneja la vista principal del POS
     */
    private function handleView(&$viewData)
    {
        $viewData['title'] = 'Punto de Venta (POS)';
        $viewData['cart'] = $_SESSION['pos_cart'] ?? [];
        $viewData['total'] = $this->calculateTotal($_SESSION['pos_cart'] ?? []);
        \Views\Renderer::render("mnt/pos", $viewData);
    }

    /**
     * Busca productos por nombre o código de barras (AJAX)
     */
    private function handleSearch(&$viewData)
    {
        header('Content-Type: application/json');
        $query = $_GET['q'] ?? '';

        if (strlen($query) < 2) {
            echo json_encode(['results' => []]);
            die();
        }

        try {
            // Búsqueda por código de barras exacto
            if (preg_match('/^\d+$/', $query)) {
                $producto = DaoProductos::getProductoByBarcode($query);
                if ($producto && $producto['invPrdStock'] > 0) {
                    echo json_encode(['results' => [$this->formatProducto($producto)]]);
                    die();
                }
            }

            // Búsqueda por nombre (LIKE)
            $sql = "SELECT p.*, c.catnom 
                    FROM productos p 
                    LEFT JOIN categorias c ON p.catid = c.catid 
                    WHERE (p.invPrdDsc LIKE :query OR p.invPrdBrCod LIKE :query) 
                    AND p.invPrdStock > 0 
                    AND p.invPrdEst = 'ACT'
                    LIMIT 10";

            $productos = \Dao\Table::obtenerRegistros($sql, ['query' => "%{$query}%"]);
            $formatted = array_map([$this, 'formatProducto'], $productos);

            echo json_encode(['results' => $formatted]);
        } catch (\Exception $ex) {
            http_response_code(500);
            echo json_encode(['error' => $ex->getMessage()]);
        }
        die();
    }

    /**
     * Agrega producto al carrito (AJAX)
     */
    private function handleAddCart(&$viewData)
    {
        header('Content-Type: application/json');
        $productId = $_POST['product_id'] ?? null;
        $quantity = intval($_POST['quantity'] ?? 1);

        if (!$productId || $quantity <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Producto o cantidad inválida']);
            die();
        }

        try {
            $producto = DaoProductos::getProductoByCode($productId);
            
            if (!$producto) {
                http_response_code(404);
                echo json_encode(['error' => 'Producto no encontrado']);
                die();
            }

            if ($producto['invPrdStock'] < $quantity) {
                http_response_code(400);
                echo json_encode(['error' => 'Stock insuficiente. Disponible: ' . $producto['invPrdStock']]);
                die();
            }

            // Inicializar carrito si no existe
            if (!isset($_SESSION['pos_cart'])) {
                $_SESSION['pos_cart'] = [];
            }

            // Verificar si el producto ya está en el carrito
            $cartKey = $productId;
            if (isset($_SESSION['pos_cart'][$cartKey])) {
                $newQty = $_SESSION['pos_cart'][$cartKey]['quantity'] + $quantity;
                if ($producto['invPrdStock'] < $newQty) {
                    http_response_code(400);
                    echo json_encode(['error' => 'Stock insuficiente para aumentar cantidad']);
                    die();
                }
                $_SESSION['pos_cart'][$cartKey]['quantity'] = $newQty;
                $_SESSION['pos_cart'][$cartKey]['subtotal'] = 
                    $_SESSION['pos_cart'][$cartKey]['quantity'] * $_SESSION['pos_cart'][$cartKey]['price'];
            } else {
                // Agregar nuevo producto
                $_SESSION['pos_cart'][$cartKey] = [
                    'product_id' => $productId,
                    'name' => $producto['invPrdDsc'],
                    'price' => floatval($producto['invPrdPrecioVenta']),
                    'quantity' => $quantity,
                    'subtotal' => $quantity * floatval($producto['invPrdPrecioVenta']),
                    'barcode' => $producto['invPrdBrCod']
                ];
            }

            echo json_encode([
                'success' => true,
                'message' => 'Producto agregado al carrito',
                'cart_count' => count($_SESSION['pos_cart']),
                'total' => $this->calculateTotal($_SESSION['pos_cart'])
            ]);
        } catch (\Exception $ex) {
            http_response_code(500);
            echo json_encode(['error' => $ex->getMessage()]);
        }
        die();
    }

    /**
     * Obtiene el carrito actual (AJAX)
     */
    private function handleGetCart(&$viewData)
    {
        header('Content-Type: application/json');
        $cart = $_SESSION['pos_cart'] ?? [];
        echo json_encode([
            'items' => $cart,
            'count' => count($cart),
            'total' => $this->calculateTotal($cart)
        ]);
        die();
    }

    /**
     * Actualiza cantidad de producto en carrito (AJAX)
     */
    private function handleUpdateCart(&$viewData)
    {
        header('Content-Type: application/json');
        $productId = $_POST['product_id'] ?? null;
        $quantity = intval($_POST['quantity'] ?? 0);

        if (!$productId) {
            http_response_code(400);
            echo json_encode(['error' => 'Producto no especificado']);
            die();
        }

        try {
            if (!isset($_SESSION['pos_cart'][$productId])) {
                http_response_code(404);
                echo json_encode(['error' => 'Producto no está en el carrito']);
                die();
            }

            if ($quantity <= 0) {
                unset($_SESSION['pos_cart'][$productId]);
                echo json_encode([
                    'success' => true,
                    'message' => 'Producto removido del carrito',
                    'cart_count' => count($_SESSION['pos_cart'] ?? []),
                    'total' => $this->calculateTotal($_SESSION['pos_cart'] ?? [])
                ]);
            } else {
                // Validar stock
                $producto = DaoProductos::getProductoByCode($productId);
                if ($producto['invPrdStock'] < $quantity) {
                    http_response_code(400);
                    echo json_encode(['error' => 'Stock insuficiente']);
                    die();
                }

                $_SESSION['pos_cart'][$productId]['quantity'] = $quantity;
                $_SESSION['pos_cart'][$productId]['subtotal'] = 
                    $quantity * $_SESSION['pos_cart'][$productId]['price'];

                echo json_encode([
                    'success' => true,
                    'message' => 'Carrito actualizado',
                    'cart_count' => count($_SESSION['pos_cart']),
                    'total' => $this->calculateTotal($_SESSION['pos_cart'])
                ]);
            }
        } catch (\Exception $ex) {
            http_response_code(500);
            echo json_encode(['error' => $ex->getMessage()]);
        }
        die();
    }

    /**
     * Remueve producto del carrito (AJAX)
     */
    private function handleRemoveCart(&$viewData)
    {
        header('Content-Type: application/json');
        $productId = $_POST['product_id'] ?? null;

        if (!$productId || !isset($_SESSION['pos_cart'][$productId])) {
            http_response_code(400);
            echo json_encode(['error' => 'Producto no encontrado en carrito']);
            die();
        }

        unset($_SESSION['pos_cart'][$productId]);

        echo json_encode([
            'success' => true,
            'message' => 'Producto removido',
            'cart_count' => count($_SESSION['pos_cart']),
            'total' => $this->calculateTotal($_SESSION['pos_cart'])
        ]);
        die();
    }

    /**
     * Procesa la venta (registra en BD)
     */
    private function handleProcessSale(&$viewData)
    {
        header('Content-Type: application/json');
        
        $cart = $_SESSION['pos_cart'] ?? [];
        if (empty($cart)) {
            http_response_code(400);
            echo json_encode(['error' => 'Carrito vacío']);
            die();
        }

        $paymentMethod = $_POST['payment_method'] ?? 'CASH';
        $userId = \Utilities\Security::getUserId();

        try {
            $conn = \Dao\Dao::getConn();
            $conn->beginTransaction();

            // Crear registro de venta
            $sqlVenta = "INSERT INTO ventas (ventaFecha, ventaMonto, ventaMetodo, ventaCreatedBy, ventaCreatedAt)
                        VALUES (NOW(), :monto, :metodo, :userId, NOW())";
            
            $monto = $this->calculateTotal($cart);
            \Dao\Table::executeNonQuery($sqlVenta, [
                'monto' => $monto,
                'metodo' => $paymentMethod,
                'userId' => $userId
            ]);

            $lastVenta = \Dao\Table::obtenerUnRegistro("SELECT LAST_INSERT_ID() as id", []);
            $ventaId = $lastVenta['id'];

            // Registrar items de venta y actualizar stock
            foreach ($cart as $item) {
                // Insertar detalle de venta
                $sqlDetalle = "INSERT INTO venta_items (ventaId, invPrdId, viCantidad, viPrecio, viSubtotal)
                              VALUES (:ventaId, :productId, :cantidad, :precio, :subtotal)";
                
                \Dao\Table::executeNonQuery($sqlDetalle, [
                    'ventaId' => $ventaId,
                    'productId' => $item['product_id'],
                    'cantidad' => $item['quantity'],
                    'precio' => $item['price'],
                    'subtotal' => $item['subtotal']
                ]);

                // Descontar del stock usando FIFO (PEPS)
                $this->descontarStockFIFO($item['product_id'], $item['quantity'], 'SAL', 'Venta POS', $userId);
            }

            $conn->commit();

            // Limpiar carrito
            unset($_SESSION['pos_cart']);

            echo json_encode([
                'success' => true,
                'message' => 'Venta registrada exitosamente',
                'venta_id' => $ventaId,
                'total' => $monto
            ]);
        } catch (\Exception $ex) {
            $conn->rollBack();
            http_response_code(500);
            echo json_encode(['error' => 'Error al procesar venta: ' . $ex->getMessage()]);
        }
        die();
    }

    /**
     * Descuenta stock usando algoritmo FIFO (PEPS)
     */
    private function descontarStockFIFO($productId, $cantidad, $tipoMov = 'SAL', $motivo = '', $userId = null)
    {
        $lotes = DaoProductos::getLotesActivos($productId);
        $cantidadRestante = $cantidad;

        foreach ($lotes as $lote) {
            if ($cantidadRestante <= 0) break;

            $cantidadDisponible = floatval($lote['loteCantActual']);
            $cantidadAdescontar = min($cantidadDisponible, $cantidadRestante);

            // Actualizar cantidad del lote
            $nuevaCantidad = $cantidadDisponible - $cantidadAdescontar;
            DaoProductos::actualizarCantidadLote($lote['loteId'], $nuevaCantidad);

            // Registrar movimiento
            DaoProductos::registrarMovimiento($productId, $tipoMov, $cantidadAdescontar, $motivo, $userId, $lote['loteId']);

            $cantidadRestante -= $cantidadAdescontar;
        }

        // Actualizar stock total del producto
        $producto = DaoProductos::getProductoByCode($productId);
        if ($producto) {
            $nuevoStock = floatval($producto['invPrdStock']) - $cantidad;
            DaoProductos::updateProducto(
                $productId,
                $producto['invPrdBrCod'],
                $producto['invPrdCodInt'],
                $producto['invPrdDsc'],
                $producto['catid'],
                $producto['invPrdPrecioVenta'],
                $producto['invPrdCosto'],
                max(0, $nuevoStock),
                $producto['invPrdStockMin'],
                $producto['invPrdTip'],
                $producto['invPrdEst'],
                $userId,
                $producto['provId']
            );
        }
    }

    /**
     * Calcula el total del carrito
     */
    private function calculateTotal($cart)
    {
        $total = 0;
        foreach ($cart as $item) {
            $total += $item['subtotal'];
        }
        return round($total, 2);
    }

    /**
     * Formatea un producto para la respuesta JSON
     */
    private function formatProducto($producto)
    {
        return [
            'id' => $producto['invPrdId'],
            'name' => $producto['invPrdDsc'],
            'barcode' => $producto['invPrdBrCod'],
            'price' => floatval($producto['invPrdPrecioVenta']),
            'stock' => floatval($producto['invPrdStock']),
            'cost' => floatval($producto['invPrdCosto']),
            'category' => $producto['catnom'] ?? 'Sin categoría'
        ];
    }
}
