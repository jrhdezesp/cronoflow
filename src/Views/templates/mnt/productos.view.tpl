<div style="margin-bottom: 2rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem;">
  <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">Catálogo de Productos</h1>
  <p style="color: #64748b; margin-top: 0.25rem;">Gestión de inventario y artículos por categorías.</p>
</div>

{{if show_categories}}
<section>
  <h2>Selecciona una Categoría</h2>
  <div class="category_grid">
    {{foreach Categorias}}
    <a href="index.php?page=mnt_productos&catid={{catid}}" class="category_card">
      <i class="fas fa-folder category_icon"></i>
      <h3 class="category_title">{{catnom}}</h3>
      <span class="category_btn">Ver Productos</span>
    </a>
    {{endfor Categorias}}
  </div>
</section>
{{endif show_categories}}

{{if show_products}}
<section>
  <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem;">
    <div style="display: flex; align-items: center; gap: 1rem;">
      <a href="index.php?page=mnt_productos" style="display: inline-flex; align-items: center; gap: 0.25rem; text-decoration: none; color: #64748b; font-weight: 600; font-size: 0.9rem;">
        <i class="fas fa-arrow-left"></i> Volver a Categorías
      </a>
      <h2 style="margin: 0; font-size: 1.35rem; color: #0f172a;">Productos en: <span style="color: #3b82f6;">{{catnom}}</span></h2>
    </div>
    
    {{if CanInsert}}
    <a href="index.php?page=mnt_producto&mode=INS&catid={{catid}}" style="display: inline-flex; align-items: center; gap: 0.5rem; background-color: #10b981; color: #fff; padding: 0.6rem 1.25rem; border-radius: 6px; font-weight: 600; text-decoration: none; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2), 0 2px 4px -1px rgba(16, 185, 129, 0.1); transition: all 0.2s ease;">
      <i class="fas fa-plus"></i> Nuevo Producto
    </a>
    {{endif CanInsert}}
  </div>

  <div class="filter_flex_container">
    <div class="search_container">
      <i class="fas fa-search search_icon"></i>
      <input type="text" id="prd-search-input" class="search_input" placeholder="Buscar producto por nombre, barra o código..." />
    </div>

    <div class="filter_group">
      <label for="filter-status" class="filter_label">Estado:</label>
      <select id="filter-status" class="filter_select">
        <option value="all">Todos los Estados</option>
        <option value="disponible">Disponible</option>
        <option value="agotado">Agotado</option>
        <option value="casi agotado">Casi Agotado</option>
        <option value="descontinuado">Descontinuado</option>
      </select>
    </div>
  </div>

  <div class="WWList">
    <table>
      <thead>
        <tr>
          <th style="width: 80px;">ID</th>
          <th style="width: 150px;">Código Barras</th>
          <th>Nombre/Descripción</th>
          <th style="text-align: right; width: 140px;">Precio Venta</th>
          <th style="text-align: right; width: 120px;">Costo</th>
          <th style="text-align: center; width: 100px;">Stock</th>
          <th style="text-align: center; width: 150px;">Estado</th>
          <th style="text-align: right; width: 80px;">Acciones</th>
        </tr>
      </thead>
      <tbody>
        {{foreach Productos}}
        <tr class="product-row" data-status="{{invPrdEst_dsc}}">
          <td>{{invPrdId}}</td>
          <td>{{invPrdBrCod}}</td>
          <td>
            {{if ~CanView}}
            <a href="index.php?page=mnt_producto&mode=DSP&id={{invPrdId}}&catid={{catid}}">{{invPrdDsc}}</a>
            {{endif ~CanView}}
            {{ifnot ~CanView}}
            {{invPrdDsc}}
            {{endifnot ~CanView}}
          </td>
          <td style="text-align: right; font-weight: 600;">L. {{invPrdPrecioVenta}}</td>
          <td style="text-align: right; color: #64748b;">L. {{invPrdCosto}}</td>
          <td style="text-align: center;">{{invPrdStock}}</td>
          <td style="text-align: center;">
            <span class="badge {{invPrdEst_class}}">{{invPrdEst_dsc}}</span>
          </td>
          <td style="text-align: right;">
            <div style="display: inline-flex; gap: 0.35rem; justify-content: flex-end; align-items: center;">
              {{if ~CanView}}
              <a href="index.php?page=mnt_producto&mode=DSP&id={{invPrdId}}&catid={{catid}}" class="btn" title="Ver Detalles">
                <i class="fas fa-eye"></i>
              </a>
              <button type="button" class="btn btn-ver-lotes" data-name="{{invPrdDsc}}" data-lotes='{{lotes_json}}' title="Ver Lotes Activos">
                <i class="fas fa-boxes"></i>
              </button>
              {{endif ~CanView}}
              {{if ~CanUpdate}}
              <button type="button" class="btn btn-ajuste-stock" data-id="{{invPrdId}}" data-name="{{invPrdDsc}}" data-stock="{{invPrdStock}}" data-stockmin="{{invPrdStockMin}}" data-precio="{{invPrdPrecioVenta}}" data-costo="{{invPrdCosto}}" data-lotes='{{lotes_json}}' title="Ajustar Inventario">
                <i class="fas fa-exchange-alt"></i>
              </button>
              <a href="index.php?page=mnt_producto&mode=UPD&id={{invPrdId}}&catid={{catid}}" class="btn" title="Editar">
                <i class="fas fa-edit"></i>
              </a>
              {{endif ~CanUpdate}}
            </div>
          </td>
        </tr>
        {{endfor Productos}}
        {{ifnot Productos}}
        <tr class="no-products-row">
          <td colspan="8" style="padding: 2rem; text-align: center; color: #64748b; font-size: 0.95rem;">No hay productos registrados en esta categoría.</td>
        </tr>
        {{endifnot Productos}}
      </tbody>
    </table>
  </div>

  <div class="pagination_container" style="display: flex; justify-content: space-between; align-items: center; margin-top: 1.5rem; flex-wrap: wrap; gap: 1rem; border-top: 1px solid #cbd5e1; padding-top: 1.25rem;">
    <div class="pagination_info" style="font-size: 0.9rem; color: #64748b; font-weight: 600;">
      Página <span id="pag-current" style="color: #0f172a; font-weight: 700;">1</span> de <span id="pag-total-pages" style="color: #0f172a; font-weight: 700;">1</span>
    </div>

    <div class="pagination_buttons" style="display: flex; gap: 0.5rem; align-items: center;">
      <button id="btn-prev" class="pag_btn">
        <i class="fas fa-chevron-left"></i> Anterior
      </button>
      <div id="pagination-pages" style="display: flex; gap: 0.25rem;">
        <!-- Page numbers will be dynamically generated -->
      </div>
      <button id="btn-next" class="pag_btn">
        Siguiente <i class="fas fa-chevron-right"></i>
      </button>
    </div>
  </div>
</section>

<!-- Modal de Ajuste de Stock -->
<div id="stock-modal" class="modal_overlay" style="display: none;">
  <div class="modal_card">
    <div class="modal_header">
      <h3>Ajustar Inventario</h3>
      <button type="button" class="close_btn" id="modal-close-x">&times;</button>
    </div>
    <form id="stock-adjust-form" action="index.php?page=mnt_productos&catid={{catid}}" method="POST">
      <input type="hidden" name="action" value="ajuste_stock" />
      <input type="hidden" id="modal-prd-id" name="invPrdId" value="" />
      
      <div class="modal_body">
        <div style="margin-bottom: 1.25rem;">
          <label style="font-weight: 600; color: #64748b; font-size: 0.85rem; text-transform: uppercase;">Producto</label>
          <div id="modal-prd-name" style="font-size: 1.1rem; font-weight: 700; color: #0f172a; margin-top: 0.25rem;">-</div>
        </div>
        
        <div style="margin-bottom: 1.25rem; display: flex; gap: 2rem;">
          <div>
            <label style="font-weight: 600; color: #64748b; font-size: 0.85rem; text-transform: uppercase;">Stock Actual</label>
            <div id="modal-prd-stock" style="font-size: 1.25rem; font-weight: 700; color: #0f172a; margin-top: 0.25rem;">0</div>
          </div>
          <div>
            <label style="font-weight: 600; color: #64748b; font-size: 0.85rem; text-transform: uppercase;">Stock Mínimo</label>
            <div id="modal-prd-stockmin" style="font-size: 1.25rem; font-weight: 700; color: #64748b; margin-top: 0.25rem;">10</div>
          </div>
        </div>
        
        <div class="form_field" style="margin-bottom: 1.25rem;">
          <label for="ajuste_tipo" style="font-weight: 600; font-size: 0.9rem; margin-bottom: 0.5rem; display: block; text-align: left;">Tipo de Ajuste *</label>
          <select id="ajuste_tipo" name="ajuste_tipo" required style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.75rem; font-size: 0.95rem;">
            <option value="ENT">Entrada por Compra (Incrementar Stock)</option>
            <option value="SAL">Salida por Venta (Disminuir Stock)</option>
            <option value="MER">Ajuste por Merma / Pérdida (Disminuir Stock)</option>
          </select>
        </div>

        <div id="lote-fields-container" style="margin-bottom: 1.25rem; background-color: #f8fafc; border: 1px dashed #cbd5e1; padding: 1.25rem; border-radius: 8px; display: none; position: relative;">
          <h4 id="lote-fields-header" style="margin-top: 0; margin-bottom: 0.75rem; font-size: 0.9rem; color: #475569; font-weight: 700; text-align: left;">Información del Lote</h4>
          <div class="form_field" style="margin-bottom: 0.75rem; position: relative;">
            <label id="lote-fields-label" for="ajuste_lote_cod" style="font-weight: 600; font-size: 0.85rem; margin-bottom: 0.25rem; display: block; text-align: left;">Código de Lote *</label>
            <input type="text" id="ajuste_lote_cod" name="ajuste_lote_cod" autocomplete="off" style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.5rem; font-size: 0.9rem; box-sizing: border-box;" placeholder="Ej. LOTE-01" />
            <div id="lote-busqueda-resultados" style="border: 1px solid #cbd5e1; border-radius: 6px; max-height: 150px; overflow-y: auto; display: none; background: #ffffff; position: absolute; left: 0; right: 0; z-index: 1000; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); margin-top: 2px;"></div>
          </div>
          <div id="lote-vence-container" class="form_field">
            <label for="ajuste_lote_vence" style="font-weight: 600; font-size: 0.85rem; margin-bottom: 0.25rem; display: block; text-align: left;">Fecha de Vencimiento</label>
            <input type="date" id="ajuste_lote_vence" name="ajuste_lote_vence" style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.5rem; font-size: 0.9rem; box-sizing: border-box;" />
          </div>
        </div>

        <div id="precio-costo-fields-container" style="margin-bottom: 1.25rem; background-color: #f8fafc; border: 1px dashed #cbd5e1; padding: 1.25rem; border-radius: 8px; display: none;">
          <h4 style="margin-top: 0; margin-bottom: 0.75rem; font-size: 0.9rem; color: #475569; font-weight: 700; text-align: left;">Precios de Mercadería</h4>
          
          <div style="display: flex; gap: 1rem;">
            <div class="form_field" style="flex: 1; margin-bottom: 0px; position: relative;">
              <label for="ajuste_precio" style="font-weight: 600; font-size: 0.85rem; margin-bottom: 0.25rem; display: block; text-align: left;">Precio de Venta *</label>
              <input type="number" step="0.01" min="0.01" id="ajuste_precio" name="ajuste_precio" style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.5rem; font-size: 0.9rem; box-sizing: border-box;" placeholder="0.00" />
            </div>
            
            <div class="form_field" style="flex: 1; margin-bottom: 0px; position: relative;">
              <label for="ajuste_costo" style="font-weight: 600; font-size: 0.85rem; margin-bottom: 0.25rem; display: block; text-align: left;">Costo Adquisición *</label>
              <input type="number" step="0.01" min="0.00" id="ajuste_costo" name="ajuste_costo" style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.5rem; font-size: 0.9rem; box-sizing: border-box;" placeholder="0.00" />
            </div>
          </div>
        </div>

        
        <div class="form_field" style="margin-bottom: 1.25rem;">
          <label for="ajuste_cantidad" style="font-weight: 600; font-size: 0.9rem; margin-bottom: 0.5rem; display: block; text-align: left;">Cantidad a Ajustar *</label>
          <input type="number" id="ajuste_cantidad" name="ajuste_cantidad" min="1" required style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.75rem; font-size: 0.95rem; box-sizing: border-box;" placeholder="Ej. 10" />
        </div>
        
        <div class="form_field" style="margin-bottom: 1.5rem;">
          <label for="ajuste_motivo" style="font-weight: 600; font-size: 0.9rem; margin-bottom: 0.5rem; display: block; text-align: left;">Motivo del Ajuste *</label>
          <input type="text" id="ajuste_motivo" name="ajuste_motivo" required style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.75rem; font-size: 0.95rem; box-sizing: border-box;" placeholder="Ej. Compra de mercadería / Ajuste por merma" />
        </div>
      </div>
      
      <div class="modal_footer" style="display: flex; gap: 1rem; justify-content: flex-end; padding-top: 1rem; border-top: 1px solid #cbd5e1;">
        <button type="button" id="modal-btn-cancelar" class="secondary">Cancelar</button>
        <button type="submit" class="primary">Registrar Ajuste</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal para Visualizar Lotes -->
<div id="lotes-modal" class="modal_overlay" style="display: none;">
  <div class="modal_card" style="max-width: 650px; width: 100%;">
    <div class="modal_header">
      <h3>Lotes de Inventario Activos</h3>
      <button type="button" class="close_btn" id="lotes-modal-close-x">&times;</button>
    </div>
    <div class="modal_body">
      <div style="margin-bottom: 1.25rem;">
        <label style="font-weight: 600; color: #64748b; font-size: 0.85rem; text-transform: uppercase;">Producto</label>
        <div id="lotes-prd-name" style="font-size: 1.1rem; font-weight: 700; color: #0f172a; margin-top: 0.25rem;">-</div>
      </div>
      
      <div style="overflow-x: auto; max-height: 300px; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 1rem;">
        <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.9rem;">
          <thead>
            <tr style="background-color: #f8fafc; border-bottom: 1px solid #cbd5e1; color: #475569; font-weight: 600;">
              <th style="padding: 0.75rem 1rem;">Código de Lote</th>
              <th style="padding: 0.75rem 1rem; text-align: center;">Stock Disponible</th>
              <th style="padding: 0.75rem 1rem; text-align: center;">Fecha de Ingreso</th>
              <th style="padding: 0.75rem 1rem; text-align: center;">Fecha de Vencimiento</th>
            </tr>
          </thead>
          <tbody id="lotes-table-body">
            <!-- Filas dinámicas -->
          </tbody>
        </table>
      </div>
      <div id="lotes-no-data" style="text-align: center; padding: 2rem; color: #64748b; display: none;">
        <i class="fas fa-boxes" style="font-size: 2.5rem; margin-bottom: 0.75rem; color: #94a3b8; display: block;"></i>
        Este producto no cuenta con lotes activos registrados.
      </div>
    </div>
    <div class="modal_footer" style="display: flex; justify-content: flex-end; padding-top: 1rem; border-top: 1px solid #cbd5e1;">
      <button type="button" id="lotes-modal-btn-cerrar" class="secondary">Cerrar</button>
    </div>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    console.log("DOMContentLoaded fired.");
    var searchInput = document.getElementById("prd-search-input");
    var statusSelect = document.getElementById("filter-status");

    var venceDateInput = document.getElementById("ajuste_lote_vence");
    if (venceDateInput) {
      var todayStr = new Date().toISOString().split('T')[0];
      venceDateInput.setAttribute('min', todayStr);
    }

    /* Controles del Modal de Ajuste */
    var lotesData = [];
    var currentPrecio = "0.00";
    var currentCosto = "0.00";
    var modal = document.getElementById("stock-modal");
    var modalPrdId = document.getElementById("modal-prd-id");
    var modalPrdName = document.getElementById("modal-prd-name");
    var modalPrdStock = document.getElementById("modal-prd-stock");
    var modalPrdStockMin = document.getElementById("modal-prd-stockmin");
    
    var btnCloseX = document.getElementById("modal-close-x");
    var btnCloseCancel = document.getElementById("modal-btn-cancelar");
    
    console.log("Modal element found:", !!modal);
    var ajusteBtns = document.querySelectorAll(".btn-ajuste-stock");
    console.log("Number of adjustment buttons found:", ajusteBtns.length);
    
    var selectTipo = document.getElementById("ajuste_tipo");
    var loteContainer = document.getElementById("lote-fields-container");
    var inputLoteCod = document.getElementById("ajuste_lote_cod");
    var precioContainer = document.getElementById("precio-costo-fields-container");
    var inputPrecio = document.getElementById("ajuste_precio");
    var inputCosto = document.getElementById("ajuste_costo");

    ajusteBtns.forEach(function(btn) {
      btn.addEventListener("click", function(e) {
        e.preventDefault();
        console.log("Ajustar stock button clicked!");
        var id = btn.getAttribute("data-id");
        var name = btn.getAttribute("data-name");
        var stock = btn.getAttribute("data-stock");
        var stockmin = btn.getAttribute("data-stockmin");
        var precio = btn.getAttribute("data-precio");
        var costo = btn.getAttribute("data-costo");
        var lotesAttr = btn.getAttribute("data-lotes");
        try {
          lotesData = JSON.parse(lotesAttr || "[]");
        } catch(ex) {
          lotesData = [];
        }
        
        currentPrecio = precio || "0.00";
        currentCosto = costo || "0.00";
        
        console.log("Ajuste details - ID:", id, "Name:", name, "Stock:", stock, "Lotes:", lotesData);
        
        if (modalPrdId) modalPrdId.value = id;
        if (modalPrdName) modalPrdName.textContent = name;
        if (modalPrdStock) modalPrdStock.textContent = stock;
        if (modalPrdStockMin) modalPrdStockMin.textContent = stockmin;
        
        var qField = document.getElementById("ajuste_cantidad");
        var mField = document.getElementById("ajuste_motivo");
        if (qField) qField.value = "";
        if (mField) mField.value = "";
        
        if (selectTipo) selectTipo.value = "ENT";
        
        if (modal) {
          modal.style.display = "flex";
          toggleLoteFields();
          document.body.style.overflow = "hidden";
          console.log("Modal style display set to flex");
        } else {
          console.error("Modal element is missing!");
        }
      });
    });
    
    function closeModal() {
      modal.style.display = "none";
      document.body.style.overflow = "";
    }
    
    function toggleLoteFields() {
      var headerText = document.getElementById("lote-fields-header");
      var labelText = document.getElementById("lote-fields-label");
      var venceContainer = document.getElementById("lote-vence-container");
      var inputLoteVence = document.getElementById("ajuste_lote_vence");

      if (selectTipo && selectTipo.value === "ENT") {
        if (loteContainer) loteContainer.style.display = "block";
        if (inputLoteCod) {
          inputLoteCod.required = true;
          inputLoteCod.placeholder = "Ej. LOTE-01";
        }
        if (headerText) headerText.textContent = "Información del Lote";
        if (labelText) labelText.textContent = "Código de Lote *";
        if (venceContainer) venceContainer.style.display = "block";
        
        if (precioContainer) precioContainer.style.display = "block";
        if (inputPrecio) {
          inputPrecio.required = true;
          inputPrecio.value = currentPrecio;
        }
        if (inputCosto) {
          inputCosto.required = true;
          inputCosto.value = currentCosto;
        }
      } else {
        /* Para salidas y mermas: es opcional */
        if (lotesData.length > 0) {
          if (loteContainer) loteContainer.style.display = "block";
          if (inputLoteCod) {
            inputLoteCod.required = false;
            inputLoteCod.placeholder = "Escribe para buscar o deja vacío para usar PEPS";
          }
          if (headerText) headerText.textContent = "Seleccionar Lote Específico (Opcional)";
          if (labelText) labelText.textContent = "Buscar Lote (vacío usa PEPS)";
          if (venceContainer) venceContainer.style.display = "none";
          if (inputLoteVence) inputLoteVence.value = "";
        } else {
          /* Si no hay lotes activos, no hay nada que buscar */
          if (loteContainer) loteContainer.style.display = "none";
          if (inputLoteCod) {
            inputLoteCod.required = false;
            inputLoteCod.value = "";
          }
          if (venceContainer) venceContainer.style.display = "none";
          if (inputLoteVence) inputLoteVence.value = "";
        }
        
        if (precioContainer) precioContainer.style.display = "none";
        if (inputPrecio) {
          inputPrecio.required = false;
          inputPrecio.value = "";
        }
        if (inputCosto) {
          inputCosto.required = false;
          inputCosto.value = "";
        }
      }
    }

    if (selectTipo) {
      selectTipo.addEventListener("change", toggleLoteFields);
    }
    
    /* Autocompletar / Buscar Lotes */
    var loteBusquedaResultados = document.getElementById("lote-busqueda-resultados");

    if (inputLoteCod && loteBusquedaResultados) {
      inputLoteCod.addEventListener("input", function() {
        var query = inputLoteCod.value.trim().toLowerCase();
        loteBusquedaResultados.innerHTML = "";
        
        if (query.length === 0) {
          loteBusquedaResultados.style.display = "none";
          return;
        }

        var matches = lotesData.filter(function(l) {
          return l.loteCod.toLowerCase().indexOf(query) > -1;
        });

        if (matches.length === 0) {
          loteBusquedaResultados.style.display = "none";
          return;
        }

        matches.forEach(function(l) {
          var item = document.createElement("div");
          item.style.padding = "0.75rem";
          item.style.borderBottom = "1px solid #f1f5f9";
          item.style.cursor = "pointer";
          item.style.textAlign = "left";
          item.style.fontSize = "0.9rem";
          item.style.transition = "background 0.15s";
          item.innerHTML = "<strong>" + l.loteCod + "</strong> &rarr; <span style='color: #10b981; font-weight: bold;'>" + l.loteCantActual + " u.</span>";

          item.addEventListener("mouseover", function() {
            item.style.background = "#f8fafc";
          });
          item.addEventListener("mouseout", function() {
            item.style.background = "#ffffff";
          });

          item.addEventListener("click", function() {
            inputLoteCod.value = l.loteCod;
            loteBusquedaResultados.style.display = "none";
          });

          loteBusquedaResultados.appendChild(item);
        });

        loteBusquedaResultados.style.display = "block";
      });

      /* Cerrar sugerencias al hacer clic fuera */
      document.addEventListener("click", function(e) {
        if (e.target !== inputLoteCod && e.target !== loteBusquedaResultados) {
          loteBusquedaResultados.style.display = "none";
        }
      });
    }
    
    if (btnCloseX) btnCloseX.addEventListener("click", closeModal);
    if (btnCloseCancel) btnCloseCancel.addEventListener("click", closeModal);
    
    window.addEventListener("click", function(e) {
      if (e.target === modal) {
        closeModal();
      }
    });

    /* Validar cantidad y stock resultante en el frontend antes de enviar */
    var adjustForm = document.getElementById("stock-adjust-form");
    if (adjustForm) {
      adjustForm.addEventListener("submit", function(e) {
        var cantidadInput = document.getElementById("ajuste_cantidad");
        var cantidad = cantidadInput ? parseInt(cantidadInput.value, 10) : 0;
        var tipoSelect = document.getElementById("ajuste_tipo");
        var tipo = tipoSelect ? tipoSelect.value : "";
        var currentStock = modalPrdStock ? parseInt(modalPrdStock.textContent, 10) : 0;

        if (isNaN(cantidad) || cantidad <= 0) {
          e.preventDefault();
          Swal.fire({
            title: "Atención",
            text: "¡Error: La cantidad a ajustar debe ser mayor a cero!",
            icon: "warning",
            confirmButtonColor: "#10b981",
            confirmButtonText: "Aceptar"
          }).then(function() {
            if (cantidadInput) cantidadInput.focus();
          });
          return false;
        }

        if (tipo === "ENT") {
          var inputPrecio = document.getElementById("ajuste_precio");
          var inputCosto = document.getElementById("ajuste_costo");
          var precioVal = inputPrecio ? parseFloat(inputPrecio.value) : 0;
          var costoVal = inputCosto ? parseFloat(inputCosto.value) : 0;

          if (isNaN(precioVal) || precioVal <= 0) {
            e.preventDefault();
            Swal.fire({
              title: "Atención",
              text: "¡Error: El precio de venta debe ser mayor a cero!",
              icon: "warning",
              confirmButtonColor: "#10b981",
              confirmButtonText: "Aceptar"
            }).then(function() {
              if (inputPrecio) inputPrecio.focus();
            });
            return false;
          }

          if (isNaN(costoVal) || costoVal < 0) {
            e.preventDefault();
            Swal.fire({
              title: "Atención",
              text: "¡Error: El costo de adquisición no puede ser negativo!",
              icon: "warning",
              confirmButtonColor: "#10b981",
              confirmButtonText: "Aceptar"
            }).then(function() {
              if (inputCosto) inputCosto.focus();
            });
            return false;
          }

          if (precioVal <= costoVal) {
            e.preventDefault();
            Swal.fire({
              title: "Atención",
              text: "¡Error: El precio de venta debe ser mayor al costo de adquisición para asegurar un margen de ganancia!",
              icon: "warning",
              confirmButtonColor: "#10b981",
              confirmButtonText: "Aceptar"
            }).then(function() {
              if (inputPrecio) inputPrecio.focus();
            });
            return false;
          }

          var venceInput = document.getElementById("ajuste_lote_vence");
          if (venceInput && venceInput.value) {
            var selectedDate = venceInput.value;
            var today = new Date();
            today.setHours(0,0,0,0);
            var parts = selectedDate.split('-');
            var expDate = new Date(parts[0], parts[1] - 1, parts[2]);
            if (expDate < today) {
              e.preventDefault();
              Swal.fire({
                title: "Fecha de Vencimiento Inválida",
                text: "¡Error: La fecha de vencimiento no puede ser anterior a la fecha de hoy!",
                icon: "warning",
                confirmButtonColor: "#10b981",
                confirmButtonText: "Aceptar"
              }).then(function() {
                venceInput.focus();
              });
              return false;
            }
          }
        }

        if (tipo !== "ENT") {
          var newStock = currentStock - cantidad;
          if (newStock < 0) {
            e.preventDefault();
            Swal.fire({
              title: "Atención",
              text: "¡Error: El stock resultante no puede ser negativo!",
              icon: "warning",
              confirmButtonColor: "#10b981",
              confirmButtonText: "Aceptar"
            }).then(function() {
              if (cantidadInput) cantidadInput.focus();
            });
            return false;
          }
        }
      });
    }

    /* Controles de Visualización de Lotes */
    var lotesModal = document.getElementById("lotes-modal");
    var lotesPrdName = document.getElementById("lotes-prd-name");
    var lotesTableBody = document.getElementById("lotes-table-body");
    var lotesNoData = document.getElementById("lotes-no-data");
    var lotesCloseX = document.getElementById("lotes-modal-close-x");
    var lotesCloseBtn = document.getElementById("lotes-modal-btn-cerrar");

    var verLotesBtns = document.querySelectorAll(".btn-ver-lotes");
    verLotesBtns.forEach(function(btn) {
      btn.addEventListener("click", function() {
        var name = btn.getAttribute("data-name");
        var lotesAttr = btn.getAttribute("data-lotes");
        var lotesList = [];
        try {
          lotesList = JSON.parse(lotesAttr || "[]");
        } catch(ex) {
          lotesList = [];
        }

        if (lotesPrdName) lotesPrdName.textContent = name;
        if (lotesTableBody) lotesTableBody.innerHTML = "";

        if (lotesList.length > 0) {
          if (lotesTableBody) lotesTableBody.parentElement.parentElement.style.display = "block";
          if (lotesNoData) lotesNoData.style.display = "none";

          lotesList.forEach(function(lote) {
            var tr = document.createElement("tr");
            tr.style.borderBottom = "1px solid #cbd5e1";
            tr.style.transition = "background-color 0.2s ease";
            
            tr.addEventListener("mouseover", function() {
              tr.style.backgroundColor = "#f1f5f9";
            });
            tr.addEventListener("mouseout", function() {
              tr.style.backgroundColor = "";
            });

            /* Codigo */
            var tdCod = document.createElement("td");
            tdCod.style.padding = "0.75rem 1rem";
            tdCod.style.fontWeight = "600";
            tdCod.style.color = "#334155";
            tdCod.textContent = lote.loteCod;
            tr.appendChild(tdCod);

            /* Cantidad */
            var tdCant = document.createElement("td");
            tdCant.style.padding = "0.75rem 1rem";
            tdCant.style.textAlign = "center";
            var spanCant = document.createElement("span");
            spanCant.style.display = "inline-block";
            spanCant.style.padding = "0.25rem 0.5rem";
            spanCant.style.borderRadius = "4px";
            spanCant.style.fontSize = "0.8rem";
            spanCant.style.fontWeight = "700";
            spanCant.style.backgroundColor = "#d1fae5";
            spanCant.style.color = "#065f46";
            spanCant.textContent = lote.loteCantActual + " uds";
            tdCant.appendChild(spanCant);
            tr.appendChild(tdCant);

            /* Fecha Ingreso */
            var tdIng = document.createElement("td");
            tdIng.style.padding = "0.75rem 1rem";
            tdIng.style.textAlign = "center";
            tdIng.style.color = "#64748b";
            tdIng.textContent = lote.loteFechaIngreso || "N/A";
            tr.appendChild(tdIng);

            /* Fecha Vencimiento */
            var tdVence = document.createElement("td");
            tdVence.style.padding = "0.75rem 1rem";
            tdVence.style.textAlign = "center";
            var spanVence = document.createElement("span");
            spanVence.style.display = "inline-block";
            spanVence.style.padding = "0.25rem 0.5rem";
            spanVence.style.borderRadius = "4px";
            spanVence.style.fontSize = "0.8rem";
            spanVence.style.fontWeight = "600";
            
            var venceStr = lote.loteFechaVencimiento || "Sin Vencer";
            if (venceStr === "Sin Vencer") {
              spanVence.style.backgroundColor = "#f1f5f9";
              spanVence.style.color = "#475569";
            } else {
              /* Parse date in format DD/MM/YYYY */
              var parts = venceStr.split('/');
              if (parts.length === 3) {
                var expDate = new Date(parts[2], parts[1] - 1, parts[0]);
                var today = new Date();
                today.setHours(0,0,0,0);
                
                var diffTime = expDate - today;
                var diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                
                if (diffDays < 0) {
                  spanVence.style.backgroundColor = "#fee2e2";
                  spanVence.style.color = "#991b1b";
                } else if (diffDays <= 30) {
                  spanVence.style.backgroundColor = "#fef3c7";
                  spanVence.style.color = "#92400e";
                } else {
                  spanVence.style.backgroundColor = "#e0f2fe";
                  spanVence.style.color = "#075985";
                }
              } else {
                spanVence.style.backgroundColor = "#f1f5f9";
                spanVence.style.color = "#475569";
              }
            }
            spanVence.textContent = venceStr;
            tdVence.appendChild(spanVence);
            tr.appendChild(tdVence);

            lotesTableBody.appendChild(tr);
          });
        } else {
          if (lotesTableBody) lotesTableBody.parentElement.parentElement.style.display = "none";
          if (lotesNoData) lotesNoData.style.display = "block";
        }

        if (lotesModal) {
          lotesModal.style.display = "flex";
          document.body.style.overflow = "hidden";
        }
      });
    });

    var closeLotesModal = function() {
      if (lotesModal) {
        lotesModal.style.display = "none";
        document.body.style.overflow = "";
      }
    };

    if (lotesCloseX) lotesCloseX.addEventListener("click", closeLotesModal);
    if (lotesCloseBtn) lotesCloseBtn.addEventListener("click", closeLotesModal);

    if (lotesModal) {
      lotesModal.addEventListener("click", function(e) {
        if (e.target === lotesModal) {
          closeLotesModal();
        }
      });
    }

    var btnPrev = document.getElementById("btn-prev");
    var btnNext = document.getElementById("btn-next");
    var pagesContainer = document.getElementById("pagination-pages");

    var pagCurrent = document.getElementById("pag-current");
    var pagTotalPages = document.getElementById("pag-total-pages");

    var currentPage = 1;
    var itemsPerPage = 8; /* Límite de 8 productos por página */

    function applyFiltersAndPagination() {
      var searchText = searchInput ? searchInput.value.toLowerCase().trim() : "";
      var selectedStatus = statusSelect ? statusSelect.value : "all";

      var allRows = document.querySelectorAll("table tbody tr.product-row");
      var filteredRows = [];

      /* 1. Filtrar filas */
      allRows.forEach(function(row) {
        var rowText = row.textContent.toLowerCase();
        var rowStatus = (row.getAttribute("data-status") || "").toLowerCase().trim();

        var matchesSearch = (rowText.indexOf(searchText) > -1);
        var matchesStatus = (selectedStatus === "all" || rowStatus === selectedStatus);

        if (matchesSearch && matchesStatus) {
          filteredRows.push(row);
        } else {
          row.style.display = "none";
        }
      });

      /* Mostrar fila de "no hay resultados" si corresponde */
      var noProductsRow = document.querySelector("table tbody tr.no-products-row");
      if (noProductsRow) {
        noProductsRow.style.display = filteredRows.length === 0 ? "" : "none";
      }

      /* 2. Paginación sobre filas filtradas */
      var totalItems = filteredRows.length;
      var totalPages = Math.ceil(totalItems / itemsPerPage);

      if (currentPage > totalPages) {
        currentPage = Math.max(1, totalPages);
      }

      var startIndex = (currentPage - 1) * itemsPerPage;
      var endIndex = Math.min(startIndex + itemsPerPage, totalItems);

      filteredRows.forEach(function(row, index) {
        if (index >= startIndex && index < endIndex) {
          row.style.display = "";
        } else {
          row.style.display = "none";
        }
      });

      /* 3. Actualizar información de paginación */
      if (pagCurrent) pagCurrent.textContent = currentPage;
      if (pagTotalPages) pagTotalPages.textContent = totalPages === 0 ? 1 : totalPages;

      /* 4. Actualizar botones Anterior/Siguiente */
      if (btnPrev) btnPrev.disabled = (currentPage === 1);
      if (btnNext) btnNext.disabled = (currentPage === totalPages || totalPages === 0);

      /* 4b. Ocultar contenedor si solo hay 1 página o ninguna */
      var pagContainer = document.querySelector(".pagination_container");
      if (pagContainer) {
        if (totalPages <= 1) {
          pagContainer.style.display = "none";
        } else {
          pagContainer.style.display = "flex";
        }
      }

      /* 5. Generar números de páginas */
      if (pagesContainer) {
        pagesContainer.innerHTML = "";
        for (var i = 1; i <= totalPages; i++) {
          var btn = document.createElement("button");
          btn.textContent = i;
          btn.className = "page_num_btn" + (i === currentPage ? " active" : "");
          btn.setAttribute("data-page", i);
          
          btn.addEventListener("click", function(e) {
            var targetPage = parseInt(e.target.getAttribute("data-page"));
            if (targetPage !== currentPage) {
              currentPage = targetPage;
              applyFiltersAndPagination();
            }
          });
          pagesContainer.appendChild(btn);
        }
      }
    }

    /* Event Listeners */
    if (searchInput) {
      searchInput.addEventListener("input", function() {
        currentPage = 1;
        applyFiltersAndPagination();
      });
    }
    if (statusSelect) {
      statusSelect.addEventListener("change", function() {
        currentPage = 1;
        applyFiltersAndPagination();
      });
    }

    if (btnPrev) {
      btnPrev.addEventListener("click", function() {
        if (currentPage > 1) {
          currentPage--;
          applyFiltersAndPagination();
        }
      });
    }

    if (btnNext) {
      btnNext.addEventListener("click", function() {
        if (!btnNext.disabled) {
          currentPage++;
          applyFiltersAndPagination();
        }
      });
    }

    /* Ejecución inicial */
    applyFiltersAndPagination();
  });
</script>
{{endif show_products}}
