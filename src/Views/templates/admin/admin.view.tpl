<style>
  .dashboard-header {
    margin-bottom: 1.75rem;
    border-bottom: 1px solid #dbe3ef;
    padding-bottom: 1.25rem;
  }

  .dashboard-header h1 {
    margin: 0;
    color: #0f172a;
    font-size: 1.85rem;
    font-weight: 800;
    line-height: 1.2;
  }

  .dashboard-header p {
    margin: 0.35rem 0 0;
    color: #64748b;
    font-size: 0.98rem;
  }

  .dashboard-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
    gap: 1rem;
    margin-bottom: 1.75rem;
  }

  .dashboard-card {
    display: flex;
    align-items: center;
    gap: 1rem;
    min-height: 116px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    background: #ffffff;
    padding: 1.15rem;
    box-shadow: 0 8px 20px rgba(15, 23, 42, 0.06);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }

  .dashboard-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 14px 28px rgba(15, 23, 42, 0.1);
  }

  .dashboard-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 52px;
    height: 52px;
    flex: 0 0 52px;
    border-radius: 8px;
    font-size: 1.35rem;
  }

  .dashboard-label {
    margin: 0;
    color: #64748b;
    font-size: 0.82rem;
    font-weight: 700;
    letter-spacing: 0;
    text-transform: uppercase;
  }

  .dashboard-value {
    margin: 0.25rem 0 0;
    color: #0f172a;
    font-size: 1.75rem;
    font-weight: 800;
    line-height: 1.1;
  }

  .dashboard-card--blue .dashboard-icon {
    background: #dbeafe;
    color: #1d4ed8;
  }

  .dashboard-card--amber .dashboard-icon {
    background: #fef3c7;
    color: #b45309;
  }

  .dashboard-card--green .dashboard-icon {
    background: #dcfce7;
    color: #15803d;
  }

  .dashboard-card--red .dashboard-icon {
    background: #fee2e2;
    color: #b91c1c;
  }

  .dashboard-panel {
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    background: #ffffff;
    box-shadow: 0 8px 20px rgba(15, 23, 42, 0.05);
    overflow: hidden;
  }

  .dashboard-panel__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    padding: 1rem 1.15rem;
    border-bottom: 1px solid #e2e8f0;
  }

  .dashboard-panel__header h2 {
    margin: 0;
    color: #0f172a;
    font-size: 1.1rem;
    font-weight: 800;
  }

  .dashboard-panel__header span {
    color: #64748b;
    font-size: 0.9rem;
    font-weight: 600;
  }

  .dashboard-table-wrap {
    display: block;
    width: 100%;
    max-width: 100%;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  .dashboard-table {
    width: 100%;
    border-collapse: collapse;
  }

  .dashboard-table th,
  .dashboard-table td {
    padding: 0.85rem 1rem;
    border-bottom: 1px solid #edf2f7;
    text-align: left;
    vertical-align: middle;
  }

  .dashboard-table th {
    color: #475569;
    background: #f8fafc;
    font-size: 0.78rem;
    font-weight: 800;
    letter-spacing: 0;
    text-transform: uppercase;
  }

  .dashboard-table td {
    color: #0f172a;
    font-size: 0.92rem;
  }

  .dashboard-table tr:last-child td {
    border-bottom: 0;
  }

  .dash-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 76px;
    border-radius: 999px;
    padding: 0.25rem 0.65rem;
    font-size: 0.78rem;
    font-weight: 800;
  }

  .dash-badge--entry {
    background: #dcfce7;
    color: #166534;
  }

  .dash-badge--exit {
    background: #dbeafe;
    color: #1d4ed8;
  }

  .dash-badge--loss {
    background: #fee2e2;
    color: #991b1b;
  }

  .dash-badge--neutral {
    background: #e2e8f0;
    color: #334155;
  }

  .dashboard-empty {
    padding: 2rem 1rem;
    text-align: center;
    color: #64748b;
    font-weight: 600;
  }

  @media (max-width: 640px) {
    .dashboard-header h1 {
      font-size: 1.45rem;
    }

    .dashboard-panel__header {
      align-items: flex-start;
      flex-direction: column;
      gap: 0.5rem;
    }
  }

  @media (max-width: 576px) {
    body {
      overflow-x: hidden;
    }

    .dashboard-grid {
      grid-template-columns: repeat(2, 1fr);
      gap: 0.65rem;
      margin-bottom: 1.25rem;
    }

    /* La última tarjeta (Mermas) ocupa 2 columnas para balancear el diseño impar */
    .dashboard-grid article:last-child {
      grid-column: span 2;
    }

    .dashboard-card {
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 0.4rem;
      min-height: 125px;
      padding: 0.85rem 0.5rem;
    }

    .dashboard-icon {
      width: 40px;
      height: 40px;
      flex: 0 0 40px;
      font-size: 1.15rem;
      border-radius: 6px;
    }

    .dashboard-label {
      font-size: 0.7rem;
      line-height: 1.2;
    }

    .dashboard-value {
      font-size: 1.15rem;
      margin-top: 0.15rem;
    }

    /* Ajustar tamaño del valor de inventario para que quepa bien en su columna */
    .dashboard-card--green .dashboard-value {
      font-size: 1.05rem;
    }
  }


  /* Modificadores de tarjetas responsivas y colores nuevos */
  .dashboard-card--clickable {
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .dashboard-card--clickable:hover {
    transform: translateY(-4px);
  }

  #card-agotados:hover {
    box-shadow: 0 12px 24px rgba(225, 29, 72, 0.15);
    border-color: #fca5a5;
    background-color: #fffafb;
  }

  #card-lotes-vencer:hover {
    box-shadow: 0 12px 24px rgba(239, 68, 68, 0.15);
    border-color: #fca5a5;
    background-color: #fffbfb;
  }

  #card-stock-critico:hover {
    box-shadow: 0 12px 24px rgba(245, 158, 11, 0.15);
    border-color: #fde68a;
    background-color: #fffdf6;
  }

  #card-mermas:hover {
    box-shadow: 0 12px 24px rgba(249, 115, 22, 0.15);
    border-color: #ffedd5;
    background-color: #fffbf7;
  }

  .dashboard-card--rose .dashboard-icon {
    background: #ffe4e6;
    color: #e11d48;
  }

  .dashboard-card--indigo .dashboard-icon {
    background: #e0e7ff;
    color: #4338ca;
  }

  .dashboard-card--orange .dashboard-icon {
    background: #ffedd5;
    color: #c2410c;
  }

  /* Ajustar tamaño de fuente del valor del inventario para evitar wrapping */
  .dashboard-card--green .dashboard-value {
    font-size: 1.45rem;
    white-space: nowrap;
  }

  .currency-symbol {
    font-size: 1.1rem;
    color: #64748b;
    font-weight: 600;
    margin-right: 0.15rem;
  }
</style>

<div class="dashboard-header">
  <h1>Bienvenido, {{userName}}</h1>
  <p>Resumen general de productos, alertas de stock, valor acumulado y actividad reciente del inventario.</p>
</div>

<section class="dashboard-grid">
  <article class="dashboard-card dashboard-card--blue">
    <div class="dashboard-icon">
      <i class="fas fa-boxes"></i>
    </div>
    <div>
      <p class="dashboard-label">Total de Productos</p>
      <p class="dashboard-value">{{totalProductos}}</p>
    </div>
  </article>

  <article id="card-stock-critico" class="dashboard-card dashboard-card--amber dashboard-card--clickable" data-stockbajo='{{stockBajoJson}}' title="Clic para ver detalle de stock crítico">
    <div class="dashboard-icon">
      <i class="fas fa-exclamation-triangle"></i>
    </div>
    <div>
      <p class="dashboard-label">Stock Crítico</p>
      <p class="dashboard-value">{{totalStockBajo}}</p>
    </div>
  </article>

  <article id="card-agotados" class="dashboard-card dashboard-card--rose dashboard-card--clickable" data-agotados='{{productosAgotadosJson}}' title="Clic para ver detalle de productos agotados">
    <div class="dashboard-icon">
      <i class="fas fa-times-circle"></i>
    </div>
    <div>
      <p class="dashboard-label">Productos Agotados</p>
      <p class="dashboard-value">{{totalProductosAgotados}}</p>
    </div>
  </article>

  <article class="dashboard-card dashboard-card--green">
    <div class="dashboard-icon">
      <i class="fas fa-coins"></i>
    </div>
    <div>
      <p class="dashboard-label">Valor del Inventario</p>
      <p class="dashboard-value"><span class="currency-symbol">L.</span>{{valorInventario}}</p>
    </div>
  </article>

  <article id="card-lotes-vencer" class="dashboard-card dashboard-card--red dashboard-card--clickable" data-lotesvencer='{{lotesVencerJson}}' title="Clic para ver detalle de lotes por vencer">
    <div class="dashboard-icon">
      <i class="fas fa-calendar-times"></i>
    </div>
    <div>
      <p class="dashboard-label">Lotes por Vencer</p>
      <p class="dashboard-value">{{totalLotesPorVencer}}</p>
    </div>
  </article>

  <article class="dashboard-card dashboard-card--indigo">
    <div class="dashboard-icon">
      <i class="fas fa-exchange-alt"></i>
    </div>
    <div>
      <p class="dashboard-label">Movimientos de Hoy</p>
      <p class="dashboard-value">{{totalMovimientosHoy}}</p>
    </div>
  </article>

  <article id="card-mermas" class="dashboard-card dashboard-card--orange dashboard-card--clickable" data-mermas='{{mermasJson}}' title="Clic para ver detalle de mermas del mes">
    <div class="dashboard-icon">
      <i class="fas fa-trash-alt"></i>
    </div>
    <div>
      <p class="dashboard-label">Mermas (Mes Actual)</p>
      <p class="dashboard-value">{{totalMermasMes}}</p>
    </div>
  </article>
</section>

<section class="dashboard-panel">
  <div class="dashboard-panel__header">
    <h2>Actividad Reciente</h2>
    <span>Últimos 5 movimientos registrados</span>
  </div>

  {{if MovimientosRecientes}}
  <div class="dashboard-table-wrap">
    <table class="dashboard-table">
      <thead>
        <tr>
          <th>Fecha/Hora</th>
          <th>Producto</th>
          <th>Tipo</th>
          <th style="text-align: right;">Cantidad</th>
        </tr>
      </thead>
      <tbody>
        {{foreach MovimientosRecientes}}
        <tr>
          <td>{{movFecha}}</td>
          <td>{{invPrdDsc}}</td>
          <td><span class="dash-badge {{movTipoClass}}" title="{{movMotivo}}">{{movTipoDsc}}</span></td>
          <td style="text-align: right; font-weight: 800;">{{movCantidad}}</td>
        </tr>
        {{endfor MovimientosRecientes}}
      </tbody>
    </table>
  </div>
  {{endif MovimientosRecientes}}

  {{ifnot MovimientosRecientes}}
  <div class="dashboard-empty">
    Todavía no hay actividad reciente para mostrar.
  </div>
  {{endifnot MovimientosRecientes}}
</section>

<!-- Modal de Productos Agotados -->
<div id="agotados-modal" class="modal_overlay" style="display: none;">
  <div class="modal_card" style="max-width: 600px;">
    <div class="modal_header">
      <h3>Productos Agotados (Sin Stock)</h3>
      <button type="button" class="close_btn" onclick="closeAgotadosModal()">&times;</button>
    </div>
    <div class="modal_body">
      <div style="overflow: auto; max-height: 300px; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 1rem;">
        <table class="dashboard-table" style="margin: 0; width: 100%;">
          <thead>
            <tr>
              <th style="padding: 0.75rem;">Código Barras</th>
              <th style="padding: 0.75rem;">Producto</th>
              <th style="padding: 0.75rem; text-align: right;">Stock Mínimo</th>
            </tr>
          </thead>
          <tbody id="agotados-modal-body">
          </tbody>
        </table>
      </div>
      <div style="display: flex; justify-content: flex-end; margin-top: 1rem;">
        <button type="button" class="secondary" onclick="closeAgotadosModal()" style="min-width: 100px;">Cerrar</button>
      </div>
    </div>
  </div>
</div>

<!-- Modal de Lotes por Vencer -->
<div id="lotes-vencer-modal" class="modal_overlay" style="display: none;">
  <div class="modal_card" style="max-width: 650px;">
    <div class="modal_header">
      <h3>Lotes por Vencer (Próximos 30 Días)</h3>
      <button type="button" class="close_btn" onclick="closeLotesVencerModal()">&times;</button>
    </div>
    <div class="modal_body">
      <div style="overflow: auto; max-height: 300px; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 1rem;">
        <table class="dashboard-table" style="margin: 0; width: 100%;">
          <thead>
            <tr>
              <th style="padding: 0.75rem;">Código Lote</th>
              <th style="padding: 0.75rem;">Producto</th>
              <th style="padding: 0.75rem; text-align: right;">Cantidad</th>
              <th style="padding: 0.75rem; text-align: right;">Vence</th>
              <th style="padding: 0.75rem; text-align: center;">Estado</th>
            </tr>
          </thead>
          <tbody id="lotes-vencer-modal-body">
          </tbody>
        </table>
      </div>
      <div style="display: flex; justify-content: flex-end; margin-top: 1rem;">
        <button type="button" class="secondary" onclick="closeLotesVencerModal()" style="min-width: 100px;">Cerrar</button>
      </div>
    </div>
  </div>
</div>

<!-- Modal de Stock Crítico -->
<div id="stock-critico-modal" class="modal_overlay" style="display: none;">
  <div class="modal_card" style="max-width: 600px;">
    <div class="modal_header">
      <h3>Productos con Stock Crítico</h3>
      <button type="button" class="close_btn" onclick="closeStockCriticoModal()">&times;</button>
    </div>
    <div class="modal_body">
      <div style="overflow: auto; max-height: 300px; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 1rem;">
        <table class="dashboard-table" style="margin: 0; width: 100%;">
          <thead>
            <tr>
              <th style="padding: 0.75rem;">Código Barras</th>
              <th style="padding: 0.75rem;">Producto</th>
              <th style="padding: 0.75rem; text-align: right;">Stock Actual</th>
              <th style="padding: 0.75rem; text-align: right;">Stock Mínimo</th>
            </tr>
          </thead>
          <tbody id="stock-critico-modal-body">
          </tbody>
        </table>
      </div>
      <div style="display: flex; justify-content: flex-end; margin-top: 1rem;">
        <button type="button" class="secondary" onclick="closeStockCriticoModal()" style="min-width: 100px;">Cerrar</button>
      </div>
    </div>
  </div>
</div>

<!-- Modal de Mermas -->
<div id="mermas-modal" class="modal_overlay" style="display: none;">
  <div class="modal_card" style="max-width: 650px;">
    <div class="modal_header">
      <h3>Detalle de Mermas (Mes Actual)</h3>
      <button type="button" class="close_btn" onclick="closeMermasModal()">&times;</button>
    </div>
    <div class="modal_body">
      <div style="overflow: auto; max-height: 300px; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 1rem;">
        <table class="dashboard-table" style="margin: 0; width: 100%;">
          <thead>
            <tr>
              <th style="padding: 0.75rem;">Fecha/Hora</th>
              <th style="padding: 0.75rem;">Producto</th>
              <th style="padding: 0.75rem; text-align: right;">Cantidad</th>
              <th style="padding: 0.75rem;">Motivo/Detalle</th>
            </tr>
          </thead>
          <tbody id="mermas-modal-body">
          </tbody>
        </table>
      </div>
      <div style="display: flex; justify-content: flex-end; margin-top: 1rem;">
        <button type="button" class="secondary" onclick="closeMermasModal()" style="min-width: 100px;">Cerrar</button>
      </div>
    </div>
  </div>
</div>



<script>
  function openAgotadosModal() {
    var card = document.getElementById("card-agotados");
    if (!card) return;
    
    var dataStr = card.getAttribute("data-agotados");
    var agotados = [];
    try {
      agotados = JSON.parse(dataStr);
    } catch(e) {
      console.error("Error al parsear productos agotados", e);
    }
    
    var tbody = document.getElementById("agotados-modal-body");
    if (tbody) {
      tbody.innerHTML = "";
      if (agotados.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3" style="text-align: center; padding: 2rem; color: #64748b;"><strong>No hay productos agotados en este momento.</strong></td></tr>';
      } else {
        agotados.forEach(function(p) {
          var tr = document.createElement("tr");
          
          var tdCode = document.createElement("td");
          tdCode.style.padding = "0.75rem";
          tdCode.textContent = p.invPrdBrCod || 'N/A';
          
          var tdDsc = document.createElement("td");
          tdDsc.style.padding = "0.75rem";
          tdDsc.innerHTML = '<strong>' + p.invPrdDsc + '</strong>';
          
          var tdMin = document.createElement("td");
          tdMin.style.padding = "0.75rem";
          tdMin.style.textAlign = "right";
          tdMin.style.fontWeight = "bold";
          tdMin.textContent = p.invPrdStockMin;
          
          tr.appendChild(tdCode);
          tr.appendChild(tdDsc);
          tr.appendChild(tdMin);
          
          tbody.appendChild(tr);
        });
      }
    }
    
    var modal = document.getElementById("agotados-modal");
    if (modal) {
      modal.style.display = "flex";
    }
  }

  function closeAgotadosModal() {
    var modal = document.getElementById("agotados-modal");
    if (modal) {
      modal.style.display = "none";
    }
  }

  function openLotesVencerModal() {
    var card = document.getElementById("card-lotes-vencer");
    if (!card) return;
    
    var dataStr = card.getAttribute("data-lotesvencer");
    var lotes = [];
    try {
      lotes = JSON.parse(dataStr);
    } catch(e) {
      console.error("Error al parsear lotes por vencer", e);
    }
    
    var tbody = document.getElementById("lotes-vencer-modal-body");
    if (tbody) {
      tbody.innerHTML = "";
      if (lotes.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 2rem; color: #64748b;"><strong>No hay lotes por vencer en los próximos 30 días.</strong></td></tr>';
      } else {
        lotes.forEach(function(l) {
          var tr = document.createElement("tr");
          
          var tdCode = document.createElement("td");
          tdCode.style.padding = "0.75rem";
          tdCode.textContent = l.loteCod;
          
          var tdDsc = document.createElement("td");
          tdDsc.style.padding = "0.75rem";
          tdDsc.innerHTML = '<strong>' + l.invPrdDsc + '</strong>';
          
          var tdCant = document.createElement("td");
          tdCant.style.padding = "0.75rem";
          tdCant.style.textAlign = "right";
          tdCant.textContent = l.loteCantActual;
          
          var tdVence = document.createElement("td");
          tdVence.style.padding = "0.75rem";
          tdVence.style.textAlign = "right";
          tdVence.style.fontWeight = "bold";
          tdVence.textContent = l.loteFechaVencimiento;
          
          var tdEst = document.createElement("td");
          tdEst.style.padding = "0.75rem";
          tdEst.style.textAlign = "center";
          
          var badge = document.createElement("span");
          badge.className = "dash-badge";
          if (l.diasRestantes < 0) {
            badge.className += " dash-badge--loss";
            badge.textContent = "Vencido";
            badge.title = "Lote ya venció";
          } else if (l.diasRestantes === 0) {
            badge.className += " dash-badge--loss";
            badge.textContent = "Vence Hoy";
            badge.title = "Vence hoy";
          } else {
            badge.className += " dash-badge--neutral";
            badge.textContent = l.diasRestantes + " d";
            badge.title = "Vence en " + l.diasRestantes + " días";
          }
          tdEst.appendChild(badge);
          
          tr.appendChild(tdCode);
          tr.appendChild(tdDsc);
          tr.appendChild(tdCant);
          tr.appendChild(tdVence);
          tr.appendChild(tdEst);
          
          tbody.appendChild(tr);
        });
      }
    }
    
    var modal = document.getElementById("lotes-vencer-modal");
    if (modal) {
      modal.style.display = "flex";
    }
  }

  function closeLotesVencerModal() {
    var modal = document.getElementById("lotes-vencer-modal");
    if (modal) {
      modal.style.display = "none";
    }
  }

  function openStockCriticoModal() {
    var card = document.getElementById("card-stock-critico");
    if (!card) return;
    
    var dataStr = card.getAttribute("data-stockbajo");
    var productos = [];
    try {
      productos = JSON.parse(dataStr);
    } catch(e) {
      console.error("Error al parsear stock crítico", e);
    }
    
    var tbody = document.getElementById("stock-critico-modal-body");
    if (tbody) {
      tbody.innerHTML = "";
      if (productos.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; padding: 2rem; color: #64748b;"><strong>No hay productos con stock crítico en este momento.</strong></td></tr>';
      } else {
        productos.forEach(function(p) {
          var tr = document.createElement("tr");
          
          var tdCode = document.createElement("td");
          tdCode.style.padding = "0.75rem";
          tdCode.textContent = p.invPrdBrCod;
          
          var tdDsc = document.createElement("td");
          tdDsc.style.padding = "0.75rem";
          tdDsc.innerHTML = '<strong>' + p.invPrdDsc + '</strong>';
          
          var tdStock = document.createElement("td");
          tdStock.style.padding = "0.75rem";
          tdStock.style.textAlign = "right";
          tdStock.style.fontWeight = "bold";
          tdStock.style.color = "#b45309";
          tdStock.textContent = p.invPrdStock;
          
          var tdMin = document.createElement("td");
          tdMin.style.padding = "0.75rem";
          tdMin.style.textAlign = "right";
          tdMin.textContent = p.invPrdStockMin;
          
          tr.appendChild(tdCode);
          tr.appendChild(tdDsc);
          tr.appendChild(tdStock);
          tr.appendChild(tdMin);
          
          tbody.appendChild(tr);
        });
      }
    }
    
    var modal = document.getElementById("stock-critico-modal");
    if (modal) {
      modal.style.display = "flex";
    }
  }

  function closeStockCriticoModal() {
    var modal = document.getElementById("stock-critico-modal");
    if (modal) {
      modal.style.display = "none";
    }
  }

  function openMermasModal() {
    var card = document.getElementById("card-mermas");
    if (!card) return;
    
    var dataStr = card.getAttribute("data-mermas");
    var mermas = [];
    try {
      mermas = JSON.parse(dataStr);
    } catch(e) {
      console.error("Error al parsear mermas", e);
    }
    
    var tbody = document.getElementById("mermas-modal-body");
    if (tbody) {
      tbody.innerHTML = "";
      if (mermas.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; padding: 2rem; color: #64748b;"><strong>No hay registros de mermas en este mes.</strong></td></tr>';
      } else {
        mermas.forEach(function(m) {
          var tr = document.createElement("tr");
          
          var tdFecha = document.createElement("td");
          tdFecha.style.padding = "0.75rem";
          tdFecha.textContent = m.movFecha;
          
          var tdDsc = document.createElement("td");
          tdDsc.style.padding = "0.75rem";
          tdDsc.innerHTML = '<strong>' + m.invPrdDsc + '</strong>';
          
          var tdCant = document.createElement("td");
          tdCant.style.padding = "0.75rem";
          tdCant.style.textAlign = "right";
          tdCant.style.fontWeight = "bold";
          tdCant.style.color = "#ea580c";
          tdCant.textContent = m.movCantidad;
          
          var tdMotivo = document.createElement("td");
          tdMotivo.style.padding = "0.75rem";
          tdMotivo.textContent = m.movMotivo;
          
          tr.appendChild(tdFecha);
          tr.appendChild(tdDsc);
          tr.appendChild(tdCant);
          tr.appendChild(tdMotivo);
          
          tbody.appendChild(tr);
        });
      }
    }
    
    var modal = document.getElementById("mermas-modal");
    if (modal) {
      modal.style.display = "flex";
    }
  }

  function closeMermasModal() {
    var modal = document.getElementById("mermas-modal");
    if (modal) {
      modal.style.display = "none";
    }
  }

  document.addEventListener("DOMContentLoaded", function() {
    var card = document.getElementById("card-agotados");
    if (card) {
      card.addEventListener("click", openAgotadosModal);
    }
    
    var cardLotes = document.getElementById("card-lotes-vencer");
    if (cardLotes) {
      cardLotes.addEventListener("click", openLotesVencerModal);
    }

    var cardStock = document.getElementById("card-stock-critico");
    if (cardStock) {
      cardStock.addEventListener("click", openStockCriticoModal);
    }

    var cardMermas = document.getElementById("card-mermas");
    if (cardMermas) {
      cardMermas.addEventListener("click", openMermasModal);
    }
    
    /* Cerrar modal al hacer clic en el fondo translucido */
    var modal = document.getElementById("agotados-modal");
    if (modal) {
      modal.addEventListener("click", function(e) {
        if (e.target === modal) {
          closeAgotadosModal();
        }
      });
    }
    
    var modalLotes = document.getElementById("lotes-vencer-modal");
    if (modalLotes) {
      modalLotes.addEventListener("click", function(e) {
        if (e.target === modalLotes) {
          closeLotesVencerModal();
        }
      });
    }

    var modalStock = document.getElementById("stock-critico-modal");
    if (modalStock) {
      modalStock.addEventListener("click", function(e) {
        if (e.target === modalStock) {
          closeStockCriticoModal();
        }
      });
    }

    var modalMermas = document.getElementById("mermas-modal");
    if (modalMermas) {
      modalMermas.addEventListener("click", function(e) {
        if (e.target === modalMermas) {
          closeMermasModal();
        }
      });
    }
  });
</script>
