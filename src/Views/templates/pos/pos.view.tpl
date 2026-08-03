<style>
  .pos-shell { display: grid; gap: 1.25rem; }
  .pos-card { background: #fff; border-radius: 16px; padding: 1.25rem; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08); }
  .pos-grid { display: grid; grid-template-columns: 1.35fr 0.95fr; gap: 1.25rem; }
  .pos-toolbar { display: flex; flex-wrap: wrap; gap: 0.75rem; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
  .pill { display: inline-flex; align-items: center; gap: 0.35rem; padding: 0.45rem 0.7rem; border-radius: 999px; background: #eff6ff; color: #1d4ed8; font-weight: 600; }
  .search-box { display: flex; gap: 0.5rem; margin-bottom: 0.75rem; }
  .search-box input, .pos-form input, .pos-form select, .pos-form textarea { width: 100%; padding: 0.7rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 10px; font: inherit; }
  .btn { border: none; cursor: pointer; border-radius: 10px; padding: 0.65rem 0.9rem; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 0.35rem; }
  .btn-primary { background: #2563eb; color: #fff; }
  .btn-success { background: #10b981; color: #fff; }
  .btn-secondary { background: #e2e8f0; color: #0f172a; }
  .cart-table { width: 100%; border-collapse: collapse; }
  .cart-table th, .cart-table td { padding: 0.7rem; border-bottom: 1px solid #e2e8f0; text-align: left; }
  .results-list { display: grid; gap: 0.6rem; }
  .result-item { display: flex; justify-content: space-between; align-items: center; padding: 0.7rem 0.8rem; border: 1px solid #e2e8f0; border-radius: 10px; background: #f8fafc; }
  .result-item strong { display: block; }
  .tiny { font-size: 0.85rem; color: #64748b; }
  .error-box { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; border-radius: 12px; padding: 0.85rem 1rem; margin-bottom: 1rem; }
  .success-box { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; border-radius: 12px; padding: 0.85rem 1rem; margin-bottom: 1rem; }
  .two-cols { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 0.75rem; }
  @media (max-width: 900px) { .pos-grid { grid-template-columns: 1fr; } .two-cols { grid-template-columns: 1fr; } }
</style>

<div class="pos-shell">
  <section class="pos-card">
    <div class="pos-toolbar">
      <div>
        <h1 style="margin: 0 0 0.25rem; font-size: 1.7rem;">Punto de Venta</h1>
        <p class="tiny" style="margin: 0;">Búsqueda de productos, apertura de caja y procesamiento de ventas.</p>
      </div>
      <div class="pill"><i class="fas fa-cash-register"></i> {{if tieneSesionActiva}}Caja activa{{else}}Sin caja abierta{{endif tieneSesionActiva}}</div>
    </div>

    {{if hasErrors}}
    <div class="error-box">
      <strong>Se encontraron errores:</strong>
      <ul style="margin: 0.4rem 0 0 1rem;">
        {{foreach aErrors}}<li>{{this}}</li>{{endfor aErrors}}
      </ul>
    </div>
    {{endif hasErrors}}

    {{ifnot hasErrors}}
    {{if sesionActiva}}
    <div class="success-box">
      Sesión abierta por {{sesionActiva.username}} desde {{sesionActiva.cajaApertura}}.
    </div>
    {{endif sesionActiva}}
    {{endifnot hasErrors}}
  </section>

  <div class="pos-grid">
    <section class="pos-card">
      <h2 style="margin-top: 0;">1. Buscar productos</h2>
      <div class="search-box">
        <input id="producto-busqueda" type="text" placeholder="Código, nombre o código interno" />
        <button type="button" class="btn btn-primary" id="btn-buscar-productos"><i class="fas fa-search"></i> Buscar</button>
      </div>
      <div id="resultados-productos" class="results-list"></div>

      <h2 style="margin-bottom: 0.75rem;">2. Clientes</h2>
      <div class="search-box">
        <input id="cliente-busqueda" type="text" placeholder="Nombre o teléfono" />
        <button type="button" class="btn btn-secondary" id="btn-buscar-clientes"><i class="fas fa-user-friends"></i> Buscar</button>
      </div>
      <div id="resultados-clientes" class="results-list"></div>

      <form class="pos-form" id="cliente-rapido-form" method="post">
        <input type="hidden" name="action" value="crear_cliente_rapido" />
        <div class="two-cols" style="margin-top: 0.75rem;">
          <input name="nombre" placeholder="Nombre del cliente" required />
          <input name="telefono" placeholder="Teléfono" />
        </div>
        <input name="email" placeholder="Correo electrónico" style="margin-top: 0.7rem;" />
        <button type="submit" class="btn btn-success" style="margin-top: 0.7rem;"><i class="fas fa-plus"></i> Crear cliente rápido</button>
      </form>
    </section>

    <section class="pos-card">
      <h2 style="margin-top: 0;">3. Sesión de caja</h2>
      {{ifnot tieneSesionActiva}}
      <form class="pos-form" method="post">
        <input type="hidden" name="action" value="abrir_caja" />
        <label>Monto inicial</label>
        <input name="montoInicial" type="number" step="0.01" min="0" value="0" />
        <button type="submit" class="btn btn-success" style="margin-top: 0.75rem;"><i class="fas fa-lock-open"></i> Abrir caja</button>
      </form>
      {{endifnot tieneSesionActiva}}

      {{if tieneSesionActiva}}
      <form class="pos-form" method="post">
        <input type="hidden" name="action" value="cerrar_caja" />
        <label>Monto final</label>
        <input name="montoFinal" type="number" step="0.01" min="0" value="0" />
        <label>Observaciones</label>
        <textarea name="observaciones" rows="3" placeholder="Observaciones de cierre"></textarea>
        <button type="submit" class="btn btn-secondary" style="margin-top: 0.75rem;"><i class="fas fa-lock"></i> Cerrar caja</button>
      </form>
      {{endif tieneSesionActiva}}

      <h2 style="margin-bottom: 0.75rem;">4. Carrito</h2>
      <table class="cart-table">
        <thead>
          <tr><th>Producto</th><th>Cant.</th><th>Precio</th><th>Total</th><th></th></tr>
        </thead>
        <tbody id="carrito-body">
          <tr><td colspan="5" class="tiny">Aún no hay productos agregados.</td></tr>
        </tbody>
      </table>

      <form id="sale-form" class="pos-form" method="post" style="margin-top: 1rem;">
        <input type="hidden" name="action" value="procesar_venta" />
        <input type="hidden" id="items-input" name="items" value="[]" />
        <div class="two-cols">
          <select name="clienteId" id="cliente-select">
            {{foreach clientes}}
            <option value="{{clienteId}}">{{clienteNombre}}</option>
            {{endfor clientes}}
          </select>
          <select name="formaPago">
            <option value="EFE">Efectivo</option>
            <option value="TAR">Tarjeta</option>
            <option value="MIX">Mixto</option>
          </select>
        </div>
        <div class="two-cols" style="margin-top: 0.7rem;">
          <input name="descuento" type="number" step="0.01" min="0" value="0" placeholder="Descuento" />
          <input name="pagoRecibido" type="number" step="0.01" min="0" value="0" placeholder="Monto recibido" />
        </div>
        <div style="display:flex; justify-content:space-between; align-items:center; margin-top:0.85rem; font-weight:700;">
          <span>Total:</span>
          <span id="total-venta">L. 0.00</span>
        </div>
        <button type="submit" class="btn btn-primary" style="margin-top: 0.75rem; width: 100%;"><i class="fas fa-check"></i> Procesar venta</button>
      </form>
    </section>
  </div>

  <section class="pos-card">
    <h2 style="margin-top: 0;">5. Historial del día</h2>
    <table class="cart-table">
      <thead>
        <tr><th>#</th><th>Venta</th><th>Cliente</th><th>Total</th><th>Estado</th></tr>
      </thead>
      <tbody>
        {{foreach ventasDelDia}}
        <tr>
          <td>{{ventaId}}</td>
          <td>{{ventaCod}}</td>
          <td>{{clienteNombre}}</td>
          <td>L. {{ventaTotal}}</td>
          <td>{{ventaEst}}</td>
        </tr>
        {{endfor ventasDelDia}}
        {{ifnot ventasDelDia}}
        <tr><td colspan="5" class="tiny">No hay ventas registradas hoy.</td></tr>
        {{endifnot ventasDelDia}}
      </tbody>
    </table>
  </section>
</div>

<script>
(function () {
  const productoBusqueda = document.getElementById('producto-busqueda');
  const btnBuscarProductos = document.getElementById('btn-buscar-productos');
  const resultadosProductos = document.getElementById('resultados-productos');
  const clienteBusqueda = document.getElementById('cliente-busqueda');
  const btnBuscarClientes = document.getElementById('btn-buscar-clientes');
  const resultadosClientes = document.getElementById('resultados-clientes');
  const carritoBody = document.getElementById('carrito-body');
  const totalVenta = document.getElementById('total-venta');
  const itemsInput = document.getElementById('items-input');
  const saleForm = document.getElementById('sale-form');
  const clienteSelect = document.getElementById('cliente-select');
  const carrito = [];

  function formatCurrency(value) {
    return 'L. ' + Number(value).toFixed(2);
  }

  function renderCart() {
    if (!carrito.length) {
      carritoBody.innerHTML = '<tr><td colspan="5" class="tiny">Aún no hay productos agregados.</td></tr>';
      totalVenta.textContent = formatCurrency(0);
      itemsInput.value = '[]';
      return;
    }

    let total = 0;
    carritoBody.innerHTML = carrito.map((item, index) => {
      const subtotal = item.cantidad * item.precioUnitario;
      total += subtotal;
      return `<tr><td>${item.nombre}</td><td>${item.cantidad}</td><td>${formatCurrency(item.precioUnitario)}</td><td>${formatCurrency(subtotal)}</td><td><button class="btn btn-secondary" type="button" data-index="${index}">Quitar</button></td></tr>`;
    }).join('');
    totalVenta.textContent = formatCurrency(total);
    itemsInput.value = JSON.stringify(carrito.map(({ id, cantidad, precioUnitario }) => ({ invPrdId: id, cantidad, precioUnitario })));
  }

  function addToCart(product) {
    const existing = carrito.find((item) => item.id === product.id);
    if (existing) {
      existing.cantidad += 1;
    } else {
      carrito.push({ id: product.id, nombre: product.nombre, cantidad: 1, precioUnitario: product.precio });
    }
    renderCart();
  }

  function requestJson(action, payload) {
    const formData = new FormData();
    formData.append('action', action);
    Object.entries(payload).forEach(([key, value]) => formData.append(key, value));
    return fetch('index.php?page=pos', { method: 'POST', body: formData }).then((response) => response.json());
  }

  btnBuscarProductos.addEventListener('click', function () {
    const query = productoBusqueda.value.trim();
    if (!query) {
      resultadosProductos.innerHTML = '<div class="tiny">Ingrese un término de búsqueda.</div>';
      return;
    }
    requestJson('buscar_productos', { query }).then((response) => {
      if (!response.success) {
        resultadosProductos.innerHTML = `<div class="tiny">${response.message || 'No se encontraron resultados.'}</div>`;
        return;
      }
      if (!response.data.length) {
        resultadosProductos.innerHTML = '<div class="tiny">No hay productos disponibles.</div>';
        return;
      }
      resultadosProductos.innerHTML = response.data.map((product) => `
        <div class="result-item">
          <div>
            <strong>${product.nombre}</strong>
            <div class="tiny">${product.codigoInterno || product.codigoBarras} · Stock: ${product.stock} · ${product.categoria || 'Sin categoría'}</div>
          </div>
          <div style="text-align:right;">
            <div>${formatCurrency(product.precio)}</div>
            <button class="btn btn-success" type="button" data-id="${product.id}" data-name="${product.nombre}" data-precio="${product.precio}">Agregar</button>
          </div>
        </div>`).join('');
    });
  });

  resultadosProductos.addEventListener('click', function (event) {
    const button = event.target.closest('button[data-id]');
    if (!button) return;
    addToCart({ id: Number(button.dataset.id), nombre: button.dataset.name, precio: Number(button.dataset.precio) });
  });

  btnBuscarClientes.addEventListener('click', function () {
    const query = clienteBusqueda.value.trim();
    if (!query) {
      resultadosClientes.innerHTML = '<div class="tiny">Ingrese un nombre o teléfono.</div>';
      return;
    }
    requestJson('buscar_clientes', { query }).then((response) => {
      if (!response.success) {
        resultadosClientes.innerHTML = `<div class="tiny">${response.message || 'No se encontraron clientes.'}</div>`;
        return;
      }
      if (!response.data.length) {
        resultadosClientes.innerHTML = '<div class="tiny">No hay clientes coincidentes.</div>';
        return;
      }
      resultadosClientes.innerHTML = response.data.map((cliente) => `
        <div class="result-item">
          <div>
            <strong>${cliente.clienteNombre}</strong>
            <div class="tiny">${cliente.clienteTelefono || ''} · ${cliente.clienteEmail || ''}</div>
          </div>
          <button class="btn btn-secondary" type="button" data-id="${cliente.clienteId}" data-name="${cliente.clienteNombre}">Seleccionar</button>
        </div>`).join('');
    });
  });

  resultadosClientes.addEventListener('click', function (event) {
    const button = event.target.closest('button[data-id]');
    if (!button) return;
    clienteSelect.value = button.dataset.id;
    resultadosClientes.innerHTML = '<div class="tiny">Cliente seleccionado.</div>';
  });

  carritoBody.addEventListener('click', function (event) {
    const button = event.target.closest('button[data-index]');
    if (!button) return;
    carrito.splice(Number(button.dataset.index), 1);
    renderCart();
  });

  saleForm.addEventListener('submit', function (event) {
    if (!carrito.length) {
      event.preventDefault();
      alert('Agregue al menos un producto al carrito antes de vender.');
      return;
    }
    if (!clienteSelect.value) {
      event.preventDefault();
      alert('Seleccione un cliente.');
      return;
    }
  });

  document.getElementById('cliente-rapido-form').addEventListener('submit', function (event) {
    event.preventDefault();
    const formData = new FormData(this);
    fetch('index.php?page=pos', { method: 'POST', body: formData }).then((response) => response.json()).then((response) => {
      if (response.success) {
        const option = document.createElement('option');
        option.value = response.clienteId;
        option.textContent = response.clienteNombre;
        clienteSelect.appendChild(option);
        clienteSelect.value = response.clienteId;
        alert(response.message);
        this.reset();
      } else {
        alert(response.message || 'No se pudo crear el cliente.');
      }
    });
  });
})();
</script>
