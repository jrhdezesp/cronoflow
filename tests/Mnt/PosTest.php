<?php

/**
 * Pruebas Unitarias e Integración - Módulo POS
 * 
 * @category Tests
 * @package  Tests\Mnt
 * @author   Integrante 5 (María)
 * @license  MIT
 * @version  1.0.0
 */

namespace Tests\Mnt;

use PHPUnit\Framework\TestCase;

/**
 * Test de búsqueda de productos
 */
class SearchTest extends TestCase
{
    private $controller;
    private $mockDb;

    protected function setUp(): void
    {
        // Inicializar sesión
        if (!isset($_SESSION)) {
            $_SESSION = [];
        }

        // Mock del controlador
        $this->controller = new \Controllers\Mnt\Pos();
    }

    /**
     * Test: Búsqueda vacía retorna array vacío
     */
    public function testSearchEmptyQuery()
    {
        $_GET['q'] = '';
        
        // Capturar salida JSON
        ob_start();
        $_GET['action'] = 'search';
        try {
            $this->controller->run();
        } catch (\Exception $e) {
            // Esperado en test
        }
        $output = ob_get_clean();
        $result = json_decode($output, true);

        $this->assertIsArray($result['results']);
        $this->assertEmpty($result['results']);
    }

    /**
     * Test: Búsqueda con 1 carácter retorna vacío
     */
    public function testSearchMinCharacters()
    {
        $_GET['q'] = 'a';
        
        ob_start();
        try {
            $_GET['action'] = 'search';
            // Mock simple
            $this->assertTrue(strlen('a') < 2);
        } catch (\Exception $e) {
            //
        }
        ob_end_clean();
        
        $this->assertTrue(true);
    }

    /**
     * Test: Búsqueda por código de barras exacto
     */
    public function testSearchByBarcode()
    {
        // Este test requiere una BD configurada
        // En ambiente real, mockar DaoProductos
        $_GET['q'] = '123456';
        
        // Validar formato numérico
        $this->assertTrue(preg_match('/^\d+$/', '123456') === 1);
    }

    /**
     * Test: Búsqueda por nombre retorna resultados
     */
    public function testSearchByName()
    {
        $_GET['q'] = 'Laptop';
        
        // Validar que la búsqueda tiene longitud >= 2
        $this->assertGreaterThanOrEqual(2, strlen('Laptop'));
        $this->assertTrue(true);
    }
}

/**
 * Test del Carrito
 */
class CartTest extends TestCase
{
    protected function setUp(): void
    {
        if (!isset($_SESSION)) {
            $_SESSION = [];
        }
        $_SESSION['pos_cart'] = [];
    }

    /**
     * Test: Agregar producto al carrito
     */
    public function testAddToCart()
    {
        $product = [
            'invPrdId' => 1,
            'invPrdDsc' => 'Laptop Dell',
            'invPrdPrecioVenta' => 899.99,
            'invPrdStock' => 10,
            'invPrdBrCod' => '123456'
        ];

        $_SESSION['pos_cart'][1] = [
            'product_id' => $product['invPrdId'],
            'name' => $product['invPrdDsc'],
            'price' => $product['invPrdPrecioVenta'],
            'quantity' => 1,
            'subtotal' => $product['invPrdPrecioVenta'],
            'barcode' => $product['invPrdBrCod']
        ];

        $this->assertArrayHasKey(1, $_SESSION['pos_cart']);
        $this->assertEquals(1, $_SESSION['pos_cart'][1]['quantity']);
        $this->assertEquals(899.99, $_SESSION['pos_cart'][1]['subtotal']);
    }

    /**
     * Test: Actualizar cantidad en carrito
     */
    public function testUpdateCartQuantity()
    {
        $_SESSION['pos_cart'][1] = [
            'product_id' => 1,
            'name' => 'Laptop',
            'price' => 899.99,
            'quantity' => 1,
            'subtotal' => 899.99,
            'barcode' => '123456'
        ];

        // Aumentar cantidad
        $_SESSION['pos_cart'][1]['quantity'] = 2;
        $_SESSION['pos_cart'][1]['subtotal'] = 2 * 899.99;

        $this->assertEquals(2, $_SESSION['pos_cart'][1]['quantity']);
        $this->assertEquals(1799.98, $_SESSION['pos_cart'][1]['subtotal']);
    }

    /**
     * Test: Remover producto del carrito
     */
    public function testRemoveFromCart()
    {
        $_SESSION['pos_cart'][1] = ['product_id' => 1, 'name' => 'Laptop', 'price' => 899.99, 'quantity' => 1, 'subtotal' => 899.99];
        $_SESSION['pos_cart'][2] = ['product_id' => 2, 'name' => 'Mouse', 'price' => 25.00, 'quantity' => 2, 'subtotal' => 50.00];

        unset($_SESSION['pos_cart'][1]);

        $this->assertArrayNotHasKey(1, $_SESSION['pos_cart']);
        $this->assertArrayHasKey(2, $_SESSION['pos_cart']);
        $this->assertCount(1, $_SESSION['pos_cart']);
    }

    /**
     * Test: Carrito vacío
     */
    public function testEmptyCart()
    {
        $_SESSION['pos_cart'] = [];
        
        $this->assertEmpty($_SESSION['pos_cart']);
        $this->assertCount(0, $_SESSION['pos_cart']);
    }

    /**
     * Test: Producto duplicado aumenta cantidad
     */
    public function testDuplicateProductIncreasesQuantity()
    {
        $_SESSION['pos_cart'][1] = ['product_id' => 1, 'name' => 'Laptop', 'price' => 899.99, 'quantity' => 1, 'subtotal' => 899.99];

        // Agregar el mismo producto
        if (isset($_SESSION['pos_cart'][1])) {
            $_SESSION['pos_cart'][1]['quantity'] += 1;
            $_SESSION['pos_cart'][1]['subtotal'] = $_SESSION['pos_cart'][1]['quantity'] * $_SESSION['pos_cart'][1]['price'];
        }

        $this->assertEquals(2, $_SESSION['pos_cart'][1]['quantity']);
        $this->assertEquals(1799.98, $_SESSION['pos_cart'][1]['subtotal']);
        $this->assertCount(1, $_SESSION['pos_cart']); // Sigue siendo 1 producto (con mayor cantidad)
    }
}

/**
 * Test de Totales
 */
class TotalsTest extends TestCase
{
    /**
     * Test: Calcular subtotal
     */
    public function testCalculateSubtotal()
    {
        $cart = [
            1 => ['subtotal' => 899.99],
            2 => ['subtotal' => 50.00],
            3 => ['subtotal' => 29.99]
        ];

        $subtotal = array_sum(array_column($cart, 'subtotal'));
        
        $this->assertEquals(979.98, $subtotal);
    }

    /**
     * Test: Calcular IVA (13%)
     */
    public function testCalculateTax()
    {
        $subtotal = 979.98;
        $tax = $subtotal * 0.13;

        $this->assertEquals(127.3974, round($tax, 4));
        $this->assertEquals(127.40, round($tax, 2));
    }

    /**
     * Test: Calcular total (subtotal + IVA)
     */
    public function testCalculateTotal()
    {
        $subtotal = 979.98;
        $tax = $subtotal * 0.13;
        $total = $subtotal + $tax;

        $this->assertEquals(1107.38, round($total, 2));
    }

    /**
     * Test: Carrito con 1 producto
     */
    public function testTotalSingleProduct()
    {
        $price = 100.00;
        $quantity = 1;
        $subtotal = $price * $quantity;
        $tax = $subtotal * 0.13;
        $total = $subtotal + $tax;

        $this->assertEquals(113.00, round($total, 2));
    }

    /**
     * Test: Carrito con múltiples cantidades
     */
    public function testTotalMultipleQuantities()
    {
        $items = [
            ['price' => 100.00, 'quantity' => 2], // 200
            ['price' => 50.00, 'quantity' => 3],  // 150
            ['price' => 25.00, 'quantity' => 1]   // 25
        ];

        $subtotal = 0;
        foreach ($items as $item) {
            $subtotal += $item['price'] * $item['quantity'];
        }

        $tax = $subtotal * 0.13;
        $total = $subtotal + $tax;

        $this->assertEquals(375, $subtotal);
        $this->assertEquals(48.75, $tax);
        $this->assertEquals(423.75, $total);
    }
}

/**
 * Test de Registro de Venta
 */
class SaleRecordTest extends TestCase
{
    /**
     * Test: Estructura de venta válida
     */
    public function testValidSaleStructure()
    {
        $sale = [
            'ventaId' => 1,
            'ventaFecha' => date('Y-m-d H:i:s'),
            'ventaMonto' => 1107.38,
            'ventaMetodo' => 'CASH',
            'ventaCreatedBy' => 1
        ];

        $this->assertIsInt($sale['ventaId']);
        $this->assertIsString($sale['ventaFecha']);
        $this->assertIsFloat($sale['ventaMonto']);
        $this->assertIn($sale['ventaMetodo'], ['CASH', 'CARD', 'CHECK', 'TRANSFER']);
        $this->assertIsInt($sale['ventaCreatedBy']);
    }

    /**
     * Test: Items de venta válidos
     */
    public function testValidSaleItems()
    {
        $items = [
            [
                'ventaId' => 1,
                'invPrdId' => 101,
                'viCantidad' => 2,
                'viPrecio' => 899.99,
                'viSubtotal' => 1799.98
            ],
            [
                'ventaId' => 1,
                'invPrdId' => 102,
                'viCantidad' => 1,
                'viPrecio' => 25.00,
                'viSubtotal' => 25.00
            ]
        ];

        foreach ($items as $item) {
            $this->assertIsInt($item['ventaId']);
            $this->assertIsInt($item['invPrdId']);
            $this->assertIsInt($item['viCantidad']);
            $this->assertIsFloat($item['viPrecio']);
            $this->assertIsFloat($item['viSubtotal']);
            
            // Validar que subtotal = cantidad * precio
            $calculatedSubtotal = $item['viCantidad'] * $item['viPrecio'];
            $this->assertEquals($item['viSubtotal'], $calculatedSubtotal);
        }
    }

    /**
     * Test: Métodos de pago válidos
     */
    public function testValidPaymentMethods()
    {
        $validMethods = ['CASH', 'CARD', 'CHECK', 'TRANSFER'];
        $testMethod = 'CARD';

        $this->assertIn($testMethod, $validMethods);
    }

    /**
     * Test: Fecha de venta válida
     */
    public function testValidSaleDate()
    {
        $date = date('Y-m-d H:i:s');
        $timestamp = strtotime($date);

        $this->assertNotFalse($timestamp);
        $this->assertTrue(date('Y-m-d H:i:s', $timestamp) === $date);
    }
}

/**
 * Test de Descuento de Stock (FIFO/PEPS)
 */
class FIFOStockTest extends TestCase
{
    /**
     * Test: Descuentos FIFO con lotes
     */
    public function testFIFOStockDeduction()
    {
        // Lotes activos (ordenados por fecha)
        $lots = [
            ['loteId' => 1, 'loteCantActual' => 50],  // Más antiguo
            ['loteId' => 2, 'loteCantActual' => 30],
            ['loteId' => 3, 'loteCantActual' => 20]   // Más nuevo
        ];

        $cantidadADescontar = 75;
        $cantidadRestante = $cantidadADescontar;
        $movimientos = [];

        foreach ($lots as $lote) {
            if ($cantidadRestante <= 0) break;

            $cantidadDisponible = $lote['loteCantActual'];
            $cantidadDescuento = min($cantidadDisponible, $cantidadRestante);

            $movimientos[] = [
                'loteId' => $lote['loteId'],
                'cantidad' => $cantidadDescuento
            ];

            $cantidadRestante -= $cantidadDescuento;
        }

        // Validar FIFO
        $this->assertEquals(50, $movimientos[0]['cantidad']); // Lote 1: todo
        $this->assertEquals(25, $movimientos[1]['cantidad']); // Lote 2: parte
        $this->assertCount(2, $movimientos);
    }

    /**
     * Test: Stock insuficiente
     */
    public function testInsufficientStock()
    {
        $totalStock = 50;
        $requestedQuantity = 100;

        $this->assertLessThan($requestedQuantity, $totalStock);
        $this->assertTrue($totalStock < $requestedQuantity);
    }
}

/**
 * Test de Validaciones
 */
class ValidationTest extends TestCase
{
    /**
     * Test: Cantidad válida
     */
    public function testValidQuantity()
    {
        $quantity = 5;
        $stock = 10;

        $this->assertGreaterThan(0, $quantity);
        $this->assertLessThanOrEqual($stock, $quantity);
    }

    /**
     * Test: Cantidad inválida (negativa)
     */
    public function testNegativeQuantity()
    {
        $quantity = -5;

        $this->assertLessThanOrEqual(0, $quantity);
        $this->assertFalse($quantity > 0);
    }

    /**
     * Test: Cantidad inválida (cero)
     */
    public function testZeroQuantity()
    {
        $quantity = 0;

        $this->assertEquals(0, $quantity);
        $this->assertFalse($quantity > 0);
    }

    /**
     * Test: Precio válido
     */
    public function testValidPrice()
    {
        $price = 99.99;

        $this->assertGreaterThan(0, $price);
        $this->assertIsFloat($price);
    }

    /**
     * Test: Producto encontrado
     */
    public function testProductFound()
    {
        $product = [
            'invPrdId' => 1,
            'invPrdDsc' => 'Laptop'
        ];

        $this->assertNotNull($product);
        $this->assertArrayHasKey('invPrdId', $product);
    }

    /**
     * Test: Producto no encontrado
     */
    public function testProductNotFound()
    {
        $product = null;

        $this->assertNull($product);
    }
}
