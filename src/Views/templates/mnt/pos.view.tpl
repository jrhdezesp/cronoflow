<?php
// Validate that renderer is being used
if (!isset($this) || !method_exists($this, 'render')) {
    die('Invalid template access');
}
?>

<div class="pos-container">
    <div class="pos-header">
        <h1>🛒 Punto de Venta (POS)</h1>
        <div class="pos-info">
            <span class="user-info"><?php echo htmlspecialchars($userName ?? 'Usuario', ENT_QUOTES); ?></span>
            <span class="datetime" id="current-time"></span>
        </div>
    </div>

    <div class="pos-main">
        <!-- SECCIÓN DE BÚSQUEDA Y PRODUCTOS -->
        <div class="pos-search-panel">
            <div class="search-box">
                <input 
                    type="text" 
                    id="product-search" 
                    class="search-input" 
                    placeholder="🔍 Escribe producto, código, o barcode (mín 2 caracteres)..."
                    autocomplete="off"
                >
                <div id="search-results" class="search-results-dropdown"></div>
            </div>

            <div class="quick-actions">
                <button id="clear-cart-btn" class="btn btn-secondary">🗑️ Limpiar Carrito</button>
                <button id="toggle-view-btn" class="btn btn-info">📊 Cambiar Vista</button>
            </div>
        </div>

        <!-- LAYOUT FLEXIBLE -->
        <div class="pos-flex-layout" id="pos-layout-normal">
            <!-- CARRITO (izquierda) -->
            <div class="pos-cart-section">
                <div class="cart-header">
                    <h2>Carrito de Compras</h2>
                    <span class="cart-count" id="cart-count">0 items</span>
                </div>

                <div class="cart-items" id="cart-items">
                    <div class="cart-empty">
                        <p>El carrito está vacío</p>
                        <p class="hint">👈 Busca productos y agrega items aquí</p>
                    </div>
                </div>

                <div class="cart-summary">
                    <div class="summary-row">
                        <span>Subtotal:</span>
                        <span id="cart-subtotal">$0.00</span>
                    </div>
                    <div class="summary-row">
                        <span>IVA (13%):</span>
                        <span id="cart-tax">$0.00</span>
                    </div>
                    <div class="summary-row total">
                        <span>Total:</span>
                        <span id="cart-total">$0.00</span>
                    </div>
                </div>

                <div class="payment-section">
                    <label for="payment-method">Método de Pago:</label>
                    <select id="payment-method" class="form-control">
                        <option value="CASH">💵 Efectivo</option>
                        <option value="CARD">💳 Tarjeta</option>
                        <option value="CHECK">✓ Cheque</option>
                        <option value="TRANSFER">🏦 Transferencia</option>
                    </select>

                    <button id="process-sale-btn" class="btn btn-primary btn-block" disabled>
                        ✅ Procesar Venta
                    </button>
                </div>
            </div>

            <!-- PRODUCTOS (derecha) -->
            <div class="pos-products-section">
                <div class="products-grid" id="featured-products">
                    <div class="products-placeholder">
                        <p>📦 Busca productos en la barra superior</p>
                        <small>o explora el inventario</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL DE CONFIRMACIÓN -->
<div id="confirm-modal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Confirmación</h2>
            <button class="modal-close">&times;</button>
        </div>
        <div class="modal-body" id="modal-message"></div>
        <div class="modal-footer">
            <button class="btn btn-secondary" id="modal-cancel">Cancelar</button>
            <button class="btn btn-primary" id="modal-confirm">Confirmar</button>
        </div>
    </div>
</div>

<!-- MODAL DE CANTIDAD -->
<div id="quantity-modal" class="modal">
    <div class="modal-content" style="max-width: 300px;">
        <div class="modal-header">
            <h2>Cantidad</h2>
            <button class="modal-close">&times;</button>
        </div>
        <div class="modal-body">
            <label for="quantity-input">¿Cuántos deseas agregar?</label>
            <input type="number" id="quantity-input" class="form-control" min="1" value="1">
            <div style="margin-top: 10px; font-size: 0.9em; color: #666;">
                Stock disponible: <span id="quantity-stock">0</span>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" id="qty-cancel">Cancelar</button>
            <button class="btn btn-primary" id="qty-confirm">Agregar</button>
        </div>
    </div>
</div>

<!-- NOTIFICACIONES -->
<div id="notification" class="notification"></div>

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

.pos-container {
    background: #f5f7fa;
    min-height: 100vh;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.pos-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.pos-header h1 {
    font-size: 28px;
    font-weight: bold;
}

.pos-info {
    display: flex;
    gap: 20px;
    align-items: center;
    font-size: 14px;
}

.pos-main {
    padding: 20px;
    max-width: 1600px;
    margin: 0 auto;
}

.pos-search-panel {
    background: white;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.search-box {
    position: relative;
    margin-bottom: 15px;
}

.search-input {
    width: 100%;
    padding: 12px 15px;
    border: 2px solid #e0e0e0;
    border-radius: 6px;
    font-size: 14px;
    transition: all 0.3s ease;
}

.search-input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.search-results-dropdown {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: white;
    border: 1px solid #e0e0e0;
    border-top: none;
    border-radius: 0 0 6px 6px;
    max-height: 400px;
    overflow-y: auto;
    display: none;
    z-index: 1000;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.search-results-dropdown.active {
    display: block;
}

.search-result-item {
    padding: 12px 15px;
    border-bottom: 1px solid #f0f0f0;
    cursor: pointer;
    transition: background 0.2s;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.search-result-item:hover {
    background: #f5f7fa;
}

.result-name {
    flex: 1;
}

.result-price {
    font-weight: bold;
    color: #667eea;
    margin-right: 10px;
}

.result-stock {
    font-size: 12px;
    color: #999;
}

.quick-actions {
    display: flex;
    gap: 10px;
}

.btn {
    padding: 10px 15px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.btn-primary {
    background: #667eea;
    color: white;
}

.btn-primary:hover:not(:disabled) {
    background: #5568d3;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.btn-primary:disabled {
    background: #ccc;
    cursor: not-allowed;
    opacity: 0.6;
}

.btn-secondary {
    background: #f0f0f0;
    color: #333;
}

.btn-secondary:hover {
    background: #e0e0e0;
}

.btn-info {
    background: #4ecdc4;
    color: white;
}

.btn-info:hover {
    background: #45b8b8;
}

.btn-block {
    width: 100%;
    margin-top: 10px;
}

.pos-flex-layout {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.pos-cart-section {
    background: white;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    display: flex;
    flex-direction: column;
    height: fit-content;
    position: sticky;
    top: 20px;
}

.cart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    border-bottom: 2px solid #f0f0f0;
    padding-bottom: 10px;
}

.cart-header h2 {
    font-size: 18px;
}

.cart-count {
    background: #667eea;
    color: white;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.cart-items {
    flex: 1;
    max-height: 400px;
    overflow-y: auto;
    margin-bottom: 15px;
    padding-right: 10px;
}

.cart-item {
    background: #f9f9f9;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    padding: 12px;
    margin-bottom: 10px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    transition: all 0.2s;
}

.cart-item:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.cart-item-info {
    flex: 1;
}

.cart-item-name {
    font-weight: 500;
    margin-bottom: 5px;
}

.cart-item-price {
    font-size: 12px;
    color: #666;
}

.cart-item-controls {
    display: flex;
    gap: 5px;
    align-items: center;
}

.qty-btn {
    width: 28px;
    height: 28px;
    border: 1px solid #ddd;
    background: white;
    cursor: pointer;
    border-radius: 4px;
    font-weight: bold;
    transition: all 0.2s;
}

.qty-btn:hover {
    background: #667eea;
    color: white;
    border-color: #667eea;
}

.qty-display {
    width: 35px;
    text-align: center;
    font-weight: bold;
}

.remove-btn {
    width: 28px;
    height: 28px;
    background: #ff6b6b;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-weight: bold;
    transition: all 0.2s;
}

.remove-btn:hover {
    background: #ff5252;
}

.cart-empty {
    text-align: center;
    color: #999;
    padding: 30px 20px;
    background: #f9f9f9;
    border-radius: 6px;
    border-dashed: 2px solid #e0e0e0;
}

.cart-empty p {
    margin-bottom: 5px;
}

.hint {
    font-size: 12px;
}

.cart-summary {
    border-top: 2px solid #f0f0f0;
    padding-top: 15px;
    margin-bottom: 15px;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
    font-size: 14px;
}

.summary-row.total {
    font-size: 18px;
    font-weight: bold;
    color: #667eea;
    border-top: 1px solid #e0e0e0;
    padding-top: 10px;
}

.payment-section {
    border-top: 2px solid #f0f0f0;
    padding-top: 15px;
}

.payment-section label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
    font-size: 14px;
}

.form-control {
    width: 100%;
    padding: 10px;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    margin-bottom: 10px;
    font-size: 14px;
}

.form-control:focus {
    outline: none;
    border-color: #667eea;
}

.pos-products-section {
    background: white;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 15px;
}

.products-placeholder {
    grid-column: 1 / -1;
    text-align: center;
    padding: 60px 20px;
    color: #999;
}

.product-card {
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    padding: 15px;
    text-align: center;
    cursor: pointer;
    transition: all 0.3s;
    background: white;
    display: flex;
    flex-direction: column;
}

.product-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    transform: translateY(-4px);
    border-color: #667eea;
}

.product-card.low-stock {
    border-color: #ff9800;
}

.product-name {
    font-weight: 600;
    margin-bottom: 8px;
    font-size: 14px;
    word-break: break-word;
}

.product-barcode {
    font-size: 11px;
    color: #999;
    margin-bottom: 8px;
}

.product-price {
    font-size: 18px;
    font-weight: bold;
    color: #667eea;
    margin-bottom: 5px;
}

.product-stock {
    font-size: 12px;
    color: #666;
    margin-bottom: 10px;
}

.product-stock.low {
    color: #ff9800;
    font-weight: bold;
}

.product-card button {
    margin-top: auto;
}

/* MODAL */
.modal {
    display: none;
    position: fixed;
    z-index: 2000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0,0,0,0.5);
    animation: fadeIn 0.3s ease;
}

.modal.active {
    display: flex;
    justify-content: center;
    align-items: center;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-content {
    background: white;
    border-radius: 8px;
    max-width: 500px;
    width: 90%;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
    animation: slideUp 0.3s ease;
}

@keyframes slideUp {
    from { transform: translateY(50px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

.modal-header {
    padding: 20px;
    border-bottom: 1px solid #e0e0e0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-header h2 {
    margin: 0;
}

.modal-close {
    background: none;
    border: none;
    font-size: 24px;
    cursor: pointer;
    color: #999;
}

.modal-close:hover {
    color: #333;
}

.modal-body {
    padding: 20px;
}

.modal-footer {
    padding: 20px;
    border-top: 1px solid #e0e0e0;
    display: flex;
    gap: 10px;
    justify-content: flex-end;
}

/* NOTIFICACIONES */
.notification {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 3000;
    padding: 15px 20px;
    border-radius: 6px;
    color: white;
    font-weight: 500;
    display: none;
    animation: slideInRight 0.3s ease;
    max-width: 400px;
}

.notification.active {
    display: block;
}

.notification.success {
    background: #4caf50;
}

.notification.error {
    background: #f44336;
}

.notification.info {
    background: #2196f3;
}

@keyframes slideInRight {
    from { transform: translateX(400px); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}

@media (max-width: 1024px) {
    .pos-flex-layout {
        grid-template-columns: 1fr;
    }

    .pos-cart-section {
        position: static;
    }

    .products-grid {
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    }
}

@media (max-width: 768px) {
    .pos-header {
        flex-direction: column;
        gap: 10px;
        text-align: center;
    }

    .pos-header h1 {
        font-size: 20px;
    }

    .quick-actions {
        width: 100%;
        flex-direction: column;
    }

    .quick-actions button {
        width: 100%;
    }

    .cart-items {
        max-height: 300px;
    }

    .products-grid {
        grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
    }
}

</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const posManager = new POSManager();
    posManager.init();
});

class POSManager {
    constructor() {
        this.cart = {};
        this.selectedProduct = null;
        this.debounceTimer = null;
        this.TAX_RATE = 0.13;
    }

    init() {
        this.setupEventListeners();
        this.updateCartDisplay();
        this.updateTime();
        setInterval(() => this.updateTime(), 1000);
        this.loadCart();
    }

    setupEventListeners() {
        // Búsqueda
        document.getElementById('product-search').addEventListener('input', (e) => this.handleSearch(e));
        document.getElementById('search-results').addEventListener('click', (e) => this.handleSearchSelect(e));

        // Carrito
        document.getElementById('clear-cart-btn').addEventListener('click', () => this.clearCart());
        document.getElementById('process-sale-btn').addEventListener('click', () => this.showSaleConfirm());

        // Modales
        document.querySelectorAll('.modal-close').forEach(btn => {
            btn.addEventListener('click', (e) => this.closeModal(e.target.closest('.modal')));
        });

        document.getElementById('modal-cancel').addEventListener('click', () => this.closeModal(document.getElementById('confirm-modal')));
        document.getElementById('modal-confirm').addEventListener('click', () => this.processSale());

        document.getElementById('qty-cancel').addEventListener('click', () => this.closeModal(document.getElementById('quantity-modal')));
        document.getElementById('qty-confirm').addEventListener('click', () => this.confirmQuantity());
    }

    handleSearch(e) {
        clearTimeout(this.debounceTimer);
        const query = e.target.value.trim();
        const resultsDiv = document.getElementById('search-results');

        if (query.length < 2) {
            resultsDiv.classList.remove('active');
            return;
        }

        this.debounceTimer = setTimeout(() => {
            fetch(`index.php?page=mnt_pos&action=search&q=${encodeURIComponent(query)}`)
                .then(r => r.json())
                .then(data => this.displaySearchResults(data.results))
                .catch(err => console.error('Error:', err));
        }, 300);
    }

    displaySearchResults(products) {
        const resultsDiv = document.getElementById('search-results');
        
        if (products.length === 0) {
            resultsDiv.innerHTML = '<div style="padding: 15px; text-align: center; color: #999;">No se encontraron productos</div>';
            resultsDiv.classList.add('active');
            return;
        }

        resultsDiv.innerHTML = products.map(p => `
            <div class="search-result-item" data-product-id="${p.id}" data-product-stock="${p.stock}">
                <div class="result-name">
                    <div style="font-weight: 600; margin-bottom: 4px;">${escapeHtml(p.name)}</div>
                    <div class="result-stock">${p.category} • Barcode: ${p.barcode || 'N/A'}</div>
                </div>
                <div style="text-align: right; white-space: nowrap;">
                    <div class="result-price">$${p.price.toFixed(2)}</div>
                    <div class="result-stock">Stock: ${Math.floor(p.stock)}</div>
                </div>
            </div>
        `).join('');

        resultsDiv.classList.add('active');
    }

    handleSearchSelect(e) {
        const item = e.target.closest('.search-result-item');
        if (!item) return;

        this.selectedProduct = {
            id: item.dataset.productId,
            stock: parseInt(item.dataset.productStock)
        };

        document.getElementById('quantity-input').value = 1;
        document.getElementById('quantity-input').max = this.selectedProduct.stock;
        document.getElementById('quantity-stock').textContent = this.selectedProduct.stock;

        document.getElementById('product-search').value = '';
        document.getElementById('search-results').classList.remove('active');

        this.showQuantityModal();
    }

    showQuantityModal() {
        document.getElementById('quantity-modal').classList.add('active');
        document.getElementById('quantity-input').focus();
    }

    confirmQuantity() {
        if (!this.selectedProduct) return;

        const quantity = parseInt(document.getElementById('quantity-input').value) || 1;
        if (quantity <= 0 || quantity > this.selectedProduct.stock) {
            this.showNotification('Cantidad inválida', 'error');
            return;
        }

        this.addToCart(this.selectedProduct.id, quantity);
        this.closeModal(document.getElementById('quantity-modal'));
        this.selectedProduct = null;
    }

    addToCart(productId, quantity) {
        const formData = new FormData();
        formData.append('product_id', productId);
        formData.append('quantity', quantity);

        fetch(`index.php?page=mnt_pos&action=add_cart`, {
            method: 'POST',
            body: formData
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                this.showNotification('✅ Producto agregado al carrito', 'success');
                this.loadCart();
            } else {
                this.showNotification(data.error || 'Error al agregar producto', 'error');
            }
        })
        .catch(err => this.showNotification('Error de conexión', 'error'));
    }

    loadCart() {
        fetch(`index.php?page=mnt_pos&action=get_cart`)
            .then(r => r.json())
            .then(data => {
                this.cart = data.items;
                this.updateCartDisplay();
            })
            .catch(err => console.error('Error:', err));
    }

    updateCartDisplay() {
        const itemsDiv = document.getElementById('cart-items');
        const countDiv = document.getElementById('cart-count');
        const subtotalDiv = document.getElementById('cart-subtotal');
        const taxDiv = document.getElementById('cart-tax');
        const totalDiv = document.getElementById('cart-total');
        const processBtnDiv = document.getElementById('process-sale-btn');

        if (Object.keys(this.cart).length === 0) {
            itemsDiv.innerHTML = '<div class="cart-empty"><p>El carrito está vacío</p><p class="hint">👈 Busca productos y agrega items aquí</p></div>';
            countDiv.textContent = '0 items';
            subtotalDiv.textContent = '$0.00';
            taxDiv.textContent = '$0.00';
            totalDiv.textContent = '$0.00';
            processBtnDiv.disabled = true;
            return;
        }

        let subtotal = 0;
        itemsDiv.innerHTML = Object.entries(this.cart).map(([id, item]) => {
            subtotal += item.subtotal;
            return `
                <div class="cart-item">
                    <div class="cart-item-info">
                        <div class="cart-item-name">${escapeHtml(item.name)}</div>
                        <div class="cart-item-price">$${item.price.toFixed(2)} x ${item.quantity}</div>
                    </div>
                    <div class="cart-item-controls">
                        <button class="qty-btn" onclick="document.querySelector('[data-pos-manager]')?.decreaseQty('${id}')">−</button>
                        <span class="qty-display">${item.quantity}</span>
                        <button class="qty-btn" onclick="document.querySelector('[data-pos-manager]')?.increaseQty('${id}')">+</button>
                        <button class="remove-btn" onclick="document.querySelector('[data-pos-manager]')?.removeFromCart('${id}')">🗑</button>
                    </div>
                </div>
            `;
        }).join('');

        const tax = subtotal * this.TAX_RATE;
        const total = subtotal + tax;

        countDiv.textContent = `${Object.keys(this.cart).length} items`;
        subtotalDiv.textContent = `$${subtotal.toFixed(2)}`;
        taxDiv.textContent = `$${tax.toFixed(2)}`;
        totalDiv.textContent = `$${total.toFixed(2)}`;
        processBtnDiv.disabled = false;

        // Attach manager reference
        document.documentElement.setAttribute('data-pos-manager', 'true');
        window.posManagerInstance = this;
    }

    increaseQty(productId) {
        if (!this.cart[productId]) return;
        this.updateCartItem(productId, this.cart[productId].quantity + 1);
    }

    decreaseQty(productId) {
        if (!this.cart[productId]) return;
        const newQty = this.cart[productId].quantity - 1;
        if (newQty <= 0) {
            this.removeFromCart(productId);
        } else {
            this.updateCartItem(productId, newQty);
        }
    }

    updateCartItem(productId, quantity) {
        const formData = new FormData();
        formData.append('product_id', productId);
        formData.append('quantity', quantity);

        fetch(`index.php?page=mnt_pos&action=update_cart`, {
            method: 'POST',
            body: formData
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                this.loadCart();
            } else {
                this.showNotification(data.error || 'Error', 'error');
            }
        })
        .catch(err => this.showNotification('Error', 'error'));
    }

    removeFromCart(productId) {
        const formData = new FormData();
        formData.append('product_id', productId);

        fetch(`index.php?page=mnt_pos&action=remove_cart`, {
            method: 'POST',
            body: formData
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                this.showNotification('Producto removido', 'info');
                this.loadCart();
            }
        })
        .catch(err => console.error('Error:', err));
    }

    clearCart() {
        if (confirm('¿Estás seguro de que quieres limpiar el carrito?')) {
            fetch(`index.php?page=mnt_pos&action=get_cart`)
                .then(r => r.json())
                .then(data => {
                    Object.keys(data.items).forEach(id => {
                        const formData = new FormData();
                        formData.append('product_id', id);
                        fetch(`index.php?page=mnt_pos&action=remove_cart`, {
                            method: 'POST',
                            body: formData
                        });
                    });
                    setTimeout(() => this.loadCart(), 500);
                });
        }
    }

    showSaleConfirm() {
        const total = this.calculateTotal();
        const method = document.getElementById('payment-method').value;
        const methodLabel = document.getElementById('payment-method').options[document.getElementById('payment-method').selectedIndex].text;

        document.getElementById('modal-message').innerHTML = `
            <p><strong>Método de Pago:</strong> ${methodLabel}</p>
            <p><strong>Total a cobrar:</strong> <span style="font-size: 24px; color: #667eea; font-weight: bold;">$${total.toFixed(2)}</span></p>
            <p style="margin-top: 20px; font-size: 14px; color: #666;">¿Deseas procesar esta venta?</p>
        `;

        document.getElementById('confirm-modal').classList.add('active');
    }

    processSale() {
        const formData = new FormData();
        formData.append('payment_method', document.getElementById('payment-method').value);

        fetch(`index.php?page=mnt_pos&action=process_sale`, {
            method: 'POST',
            body: formData
        })
        .then(r => r.json())
        .then(data => {
            this.closeModal(document.getElementById('confirm-modal'));
            
            if (data.success) {
                this.showNotification(`✅ Venta ${data.venta_id} registrada por $${data.total.toFixed(2)}`, 'success');
                this.cart = {};
                this.updateCartDisplay();
                
                setTimeout(() => {
                    alert(`VENTA COMPLETADA\n\nID: ${data.venta_id}\nTotal: $${data.total.toFixed(2)}`);
                }, 500);
            } else {
                this.showNotification(data.error || 'Error al procesar venta', 'error');
            }
        })
        .catch(err => this.showNotification('Error de conexión', 'error'));
    }

    calculateTotal() {
        let subtotal = 0;
        Object.values(this.cart).forEach(item => {
            subtotal += item.subtotal;
        });
        return subtotal + (subtotal * this.TAX_RATE);
    }

    closeModal(modal) {
        modal.classList.remove('active');
    }

    showNotification(message, type = 'info') {
        const notif = document.getElementById('notification');
        notif.textContent = message;
        notif.className = `notification active ${type}`;
        setTimeout(() => notif.classList.remove('active'), 4000);
    }

    updateTime() {
        const now = new Date();
        const timeStr = now.toLocaleString('es-SV', {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
        const dateStr = now.toLocaleDateString('es-SV');
        document.getElementById('current-time').textContent = `${dateStr} ${timeStr}`;
    }
}

function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}
</script>
