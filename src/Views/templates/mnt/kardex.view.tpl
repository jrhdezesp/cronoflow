<style>
  /* Contenedor del formulario de filtros */
  .kardex_filter_card {
    background-color: #fff;
    padding: 1.25rem;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    margin-bottom: 1.5rem;
  }
  
  .kardex_form {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
    align-items: flex-end;
    width: 100%;
    margin: 0;
    padding: 0;
  }

  .kardex_field {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    width: 100%;
    box-sizing: border-box;
  }

  .kardex_field label {
    font-weight: 600;
    font-size: 0.85rem;
    color: #475569;
  }

  .kardex_field input,
  .kardex_field select {
    width: 100%;
    height: 36px;
    padding: 0.5rem;
    border: 1px solid #cbd5e1;
    border-radius: 4px;
    box-sizing: border-box;
    background-color: #fff;
    font-size: 0.9rem;
    color: #0f172a;
  }

  .kardex_field select {
    padding: 0.25rem 0.5rem;
  }

  .kardex_actions {
    display: flex;
    gap: 0.5rem;
    width: 100%;
    box-sizing: border-box;
  }

  .kardex_actions button,
  .kardex_actions a {
    flex: 1;
    height: 36px;
    font-weight: 600;
    font-size: 0.9rem;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    box-sizing: border-box;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .kardex_actions button {
    background-color: #0f172a;
    color: #ffffff;
    border: none;
  }

  .kardex_actions button:hover {
    background-color: #1e293b;
  }

  .kardex_actions a {
    background-color: #e2e8f0;
    color: #334155;
    border: none;
  }

  .kardex_actions a:hover {
    background-color: #cbd5e1;
  }

  /* Evitar desborde del título en móviles */
  h1 {
    font-size: 1.5rem;
    word-wrap: break-word;
    overflow-wrap: break-word;
    line-height: 1.3;
  }

  /* Responsivo: Pantallas medianas y grandes */
  @media (min-width: 640px) {
    .kardex_field.search_group {
      flex: 2 1 250px;
      width: auto;
    }
    .kardex_field.filter_group_item {
      flex: 1 1 150px;
      width: auto;
    }
    .kardex_field.year_group {
      flex: 1 1 90px;
      width: auto;
    }
    .kardex_field.month_group {
      flex: 1 1 110px;
      width: auto;
    }
    .kardex_field.date_group {
      flex: 1 1 130px;
      width: auto;
    }
    .kardex_actions {
      flex: 1 1 190px;
      width: auto;
    }
    h1 {
      font-size: 2rem;
    }
  }

  /* Ocultar números de página de paginación en pantallas pequeñas para evitar desbordes */
  @media (max-width: 576px) {
    #pagination-pages {
      display: none !important;
    }
    .pagination_container {
      justify-content: center !important;
      flex-direction: column;
      gap: 0.75rem !important;
      text-align: center;
    }
  }
</style>

<h1>Historial de Kardex (Bitácora de Inventario)</h1>
<hr>

<div class="kardex_filter_card">
    <form action="index.php" method="get" class="kardex_form">
        <input type="hidden" name="page" value="mnt_kardex">

        <div class="kardex_field search_group">
            <label for="search_query">Buscar Producto</label>
            <input type="text" id="search_query" name="search_query" value="{{search_query}}" placeholder="Nombre o código de barras...">
        </div>

        <div class="kardex_field filter_group_item">
            <label for="mov_tipo">Tipo Movimiento</label>
            <select name="mov_tipo" id="mov_tipo">
                <option value="" {{tipo__selected}}>Todos</option>
                <option value="ENT" {{tipo_ENT_selected}}>Entradas (Compras)</option>
                <option value="SAL" {{tipo_SAL_selected}}>Salidas (Ventas)</option>
                <option value="MER" {{tipo_MER_selected}}>Mermas (Pérdidas)</option>
            </select>
        </div>

        <div class="kardex_field year_group">
            <label for="year">Año</label>
            <select name="year" id="year">
                <option value="" {{year__selected}}>Todos</option>
                <option value="2026" {{year_2026_selected}}>2026</option>
                <option value="2025" {{year_2025_selected}}>2025</option>
                <option value="2024" {{year_2024_selected}}>2024</option>
            </select>
        </div>

        <div class="kardex_field month_group">
            <label for="month">Mes</label>
            <select name="month" id="month">
                <option value="" {{month__selected}}>Todos</option>
                <option value="1" {{month_1_selected}}>Enero</option>
                <option value="2" {{month_2_selected}}>Febrero</option>
                <option value="3" {{month_3_selected}}>Marzo</option>
                <option value="4" {{month_4_selected}}>Abril</option>
                <option value="5" {{month_5_selected}}>Mayo</option>
                <option value="6" {{month_6_selected}}>Junio</option>
                <option value="7" {{month_7_selected}}>Julio</option>
                <option value="8" {{month_8_selected}}>Agosto</option>
                <option value="9" {{month_9_selected}}>Septiembre</option>
                <option value="10" {{month_10_selected}}>Octubre</option>
                <option value="11" {{month_11_selected}}>Noviembre</option>
                <option value="12" {{month_12_selected}}>Diciembre</option>
            </select>
        </div>

        <div class="kardex_field date_group">
            <label for="fecha_inicio">Desde</label>
            <input type="date" id="fecha_inicio" name="fecha_inicio" value="{{fecha_inicio}}">
        </div>

        <div class="kardex_field date_group">
            <label for="fecha_fin">Hasta</label>
            <input type="date" id="fecha_fin" name="fecha_fin" value="{{fecha_fin}}">
        </div>

        <div class="kardex_actions">
            <button type="submit">Filtrar</button>
            <a href="index.php?page=mnt_kardex">Limpiar</a>
        </div>
    </form>
</div>

<section class="WWList">
    <table>
        <thead>
            <tr>
                <th>ID Mov</th>
                <th>Fecha/Hora</th>
                <th>Código Barras</th>
                <th>Producto</th>
                <th>Tipo</th>
                <th>Cantidad</th>
                <th>Motivo/Detalle</th>
                <th>Lote</th>
                <th>Responsable</th>
            </tr>
        </thead>
        <tbody>
            {{if has_movimientos}}
                {{foreach movimientos}}
                <tr>
                    <td>{{movId}}</td>
                    <td>{{fecha_formateada}}</td>
                    <td>{{invPrdBrCod}}</td>
                    <td><strong>{{invPrdDsc}}</strong></td>
                    <td>
                        <span class="badge {{badge_class}}">{{movTipoDsc}}</span>
                    </td>
                    <td style="text-align: right; font-weight: bold;">{{movCantidad}}</td>
                    <td>{{movMotivo}}</td>
                    <td>{{if loteCod}}{{loteCod}}{{ifnot loteCod}}N/A{{endif loteCod}}</td>
                    <td>{{username}}</td>
                </tr>
                {{endfor movimientos}}
            {{endif has_movimientos}}

            {{ifnot has_movimientos}}
            <tr>
                <td colspan="9" style="text-align: center; padding: 2rem; color: #777;">
                    <strong>No se encontraron movimientos que coincidan con los filtros seleccionados.</strong>
                </td>
            </tr>
            {{endifnot has_movimientos}}
        </tbody>
    </table>
</section>

<div class="pagination_container" style="display: flex; justify-content: space-between; align-items: center; margin-top: 1.5rem; flex-wrap: wrap; gap: 1rem;">
    <div style="font-size: 0.9rem; color: #64748b;">
        Página <span id="pag-current" style="font-weight: 600; color: #0f172a;">1</span> de <span id="pag-total-pages" style="font-weight: 600; color: #0f172a;">1</span>
    </div>
    <div style="display: flex; gap: 0.5rem; align-items: center;">
        <button type="button" id="btn-prev" class="pag_btn" disabled>
            <i class="fas fa-chevron-left"></i> Anterior
        </button>
        <div id="pagination-pages" style="display: flex; gap: 0.35rem;"></div>
        <button type="button" id="btn-next" class="pag_btn" disabled>
            Siguiente <i class="fas fa-chevron-right"></i>
        </button>
    </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var btnPrev = document.getElementById("btn-prev");
    var btnNext = document.getElementById("btn-next");
    var pagesContainer = document.getElementById("pagination-pages");
    var pagCurrent = document.getElementById("pag-current");
    var pagTotalPages = document.getElementById("pag-total-pages");

    var currentPage = 1;
    var itemsPerPage = 5; /* Limite de 5 movimientos por pagina */

    function applyPagination() {
      var allRows = document.querySelectorAll("table tbody tr");
      /* Filtrar solo filas validas */
      var validRows = [];
      allRows.forEach(function(row) {
        if (row.cells.length > 1) {
          validRows.push(row);
        }
      });

      var totalItems = validRows.length;
      var totalPages = Math.ceil(totalItems / itemsPerPage);

      if (currentPage > totalPages) {
        currentPage = Math.max(1, totalPages);
      }

      var startIndex = (currentPage - 1) * itemsPerPage;
      var endIndex = Math.min(startIndex + itemsPerPage, totalItems);

      validRows.forEach(function(row, index) {
        if (index >= startIndex && index < endIndex) {
          row.style.display = "";
        } else {
          row.style.display = "none";
        }
      });

      if (pagCurrent) pagCurrent.textContent = currentPage;
      if (pagTotalPages) pagTotalPages.textContent = totalPages === 0 ? 1 : totalPages;

      if (btnPrev) btnPrev.disabled = (currentPage === 1);
      if (btnNext) btnNext.disabled = (currentPage === totalPages || totalPages === 0);

      var pagContainer = document.querySelector(".pagination_container");
      if (pagContainer) {
        if (totalPages <= 1) {
          pagContainer.style.display = "none";
        } else {
          pagContainer.style.display = "flex";
        }
      }

      if (pagesContainer) {
        pagesContainer.innerHTML = "";
        for (var i = 1; i <= totalPages; i++) {
          var btn = document.createElement("button");
          btn.type = "button";
          btn.className = "page_num_btn" + (i === currentPage ? " active" : "");
          btn.textContent = i;
          
          (function(page) {
            btn.addEventListener("click", function() {
              currentPage = page;
              applyPagination();
            });
          })(i);
          
          pagesContainer.appendChild(btn);
        }
      }
    }

    if (btnPrev) {
      btnPrev.addEventListener("click", function() {
        if (currentPage > 1) {
          currentPage--;
          applyPagination();
        }
      });
    }

    if (btnNext) {
      btnNext.addEventListener("click", function() {
        var allRows = document.querySelectorAll("table tbody tr");
        var validRows = [];
        allRows.forEach(function(row) {
          if (row.cells.length > 1) validRows.push(row);
        });
        var totalItems = validRows.length;
        var totalPages = Math.ceil(totalItems / itemsPerPage);
        
        if (currentPage < totalPages) {
          currentPage++;
          applyPagination();
        }
      });
    }

    /* Ejecucion inicial */
    applyPagination();
  });
</script>