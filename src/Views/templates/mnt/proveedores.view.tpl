<div style="margin-bottom: 2rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
  <div>
    <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">Administracion de Proveedores</h1>
    <p style="color: #64748b; margin-top: 0.25rem;">Registra y gestiona las empresas que suministran productos.</p>
  </div>

  {{if CanInsert}}
  <a href="index.php?page=mnt_proveedor&mode=INS" style="display: inline-flex; align-items: center; gap: 0.5rem; background-color: #10b981; color: #fff; padding: 0.6rem 1.25rem; border-radius: 6px; font-weight: 600; text-decoration: none; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2), 0 2px 4px -1px rgba(16, 185, 129, 0.1); transition: all 0.2s ease;">
    <i class="fas fa-plus"></i> Nuevo Proveedor
  </a>
  {{endif CanInsert}}
</div>

<div class="filter_flex_container">
  <div class="search_container">
    <i class="fas fa-search search_icon"></i>
    <input type="text" id="prov-search-input" class="search_input" placeholder="Buscar proveedor por ID, nombre, contacto o telefono..." />
  </div>

  <div class="filter_group">
    <label for="filter-status" class="filter_label">Estado:</label>
    <select id="filter-status" class="filter_select">
      <option value="all">Todos</option>
      <option value="activo">Activo</option>
      <option value="inactivo">Inactivo</option>
    </select>
  </div>
</div>

<div class="WWList">
  <table>
    <thead>
      <tr>
        <th style="width: 90px;">ID</th>
        <th>Empresa</th>
        <th style="width: 180px;">Contacto</th>
        <th style="width: 140px;">Telefono</th>
        <th style="width: 220px;">Correo</th>
        <th style="text-align: center; width: 140px;">Estado</th>
        <th style="text-align: right; width: 110px;">Acciones</th>
      </tr>
    </thead>
    <tbody>
      {{foreach Proveedores}}
      <tr class="provider-row" data-status="{{provEst_dsc}}">
        <td>{{provId}}</td>
        <td>
          {{if ~CanView}}
          <a href="index.php?page=mnt_proveedor&mode=DSP&provId={{provId}}" style="font-weight: 600;">{{provNombre}}</a>
          {{endif ~CanView}}
          {{ifnot ~CanView}}
          {{provNombre}}
          {{endifnot ~CanView}}
        </td>
        <td>{{provContacto}}</td>
        <td>{{provTelefono}}</td>
        <td>{{provEmail}}</td>
        <td style="text-align: center;">
          <span class="badge {{provEst_class}}">{{provEst_dsc}}</span>
        </td>
        <td style="text-align: right;">
          <div style="display: inline-flex; gap: 0.35rem; justify-content: flex-end; align-items: center;">
            {{if ~CanView}}
            <a href="index.php?page=mnt_proveedor&mode=DSP&provId={{provId}}" class="btn" title="Ver Detalles">
              <i class="fas fa-eye"></i>
            </a>
            {{endif ~CanView}}
            {{if ~CanUpdate}}
            <a href="index.php?page=mnt_proveedor&mode=UPD&provId={{provId}}" class="btn" title="Editar">
              <i class="fas fa-edit"></i>
            </a>
            {{endif ~CanUpdate}}
          </div>
        </td>
      </tr>
      {{endfor Proveedores}}
      {{ifnot Proveedores}}
      <tr class="no-providers-row">
        <td colspan="7" style="padding: 2rem; text-align: center; color: #64748b; font-size: 0.95rem;">No hay proveedores registrados en el sistema.</td>
      </tr>
      {{endifnot Proveedores}}
    </tbody>
  </table>
</div>

<div class="pagination_container" style="display: flex; justify-content: space-between; align-items: center; margin-top: 1.5rem; flex-wrap: wrap; gap: 1rem; border-top: 1px solid #cbd5e1; padding-top: 1.25rem;">
  <div class="pagination_info" style="font-size: 0.9rem; color: #64748b; font-weight: 600;">
    Pagina <span id="pag-current" style="color: #0f172a; font-weight: 700;">1</span> de <span id="pag-total-pages" style="color: #0f172a; font-weight: 700;">1</span>
  </div>

  <div class="pagination_buttons" style="display: flex; gap: 0.5rem; align-items: center;">
    <button id="btn-prev" class="pag_btn">
      <i class="fas fa-chevron-left"></i> Anterior
    </button>
    <div id="pagination-pages" style="display: flex; gap: 0.25rem;"></div>
    <button id="btn-next" class="pag_btn">
      Siguiente <i class="fas fa-chevron-right"></i>
    </button>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var searchInput = document.getElementById("prov-search-input");
    var statusSelect = document.getElementById("filter-status");
    var btnPrev = document.getElementById("btn-prev");
    var btnNext = document.getElementById("btn-next");
    var pagesContainer = document.getElementById("pagination-pages");
    var pagCurrent = document.getElementById("pag-current");
    var pagTotalPages = document.getElementById("pag-total-pages");
    var currentPage = 1;
    var itemsPerPage = 8;

    function applyFiltersAndPagination() {
      var searchText = searchInput ? searchInput.value.toLowerCase().trim() : "";
      var selectedStatus = statusSelect ? statusSelect.value : "all";
      var allRows = document.querySelectorAll("table tbody tr.provider-row");
      var filteredRows = [];

      allRows.forEach(function(row) {
        var rowText = row.textContent.toLowerCase();
        var rowStatus = (row.getAttribute("data-status") || "").toLowerCase();
        var matchesSearch = rowText.indexOf(searchText) > -1;
        var matchesStatus = selectedStatus === "all" || rowStatus.indexOf(selectedStatus) > -1;

        if (matchesSearch && matchesStatus) {
          filteredRows.push(row);
        } else {
          row.style.display = "none";
        }
      });

      var noProvidersRow = document.querySelector("table tbody tr.no-providers-row");
      if (noProvidersRow) {
        noProvidersRow.style.display = filteredRows.length === 0 ? "" : "none";
      }

      var totalItems = filteredRows.length;
      var totalPages = Math.ceil(totalItems / itemsPerPage);

      if (currentPage > totalPages) {
        currentPage = Math.max(1, totalPages);
      }

      var startIndex = (currentPage - 1) * itemsPerPage;
      var endIndex = Math.min(startIndex + itemsPerPage, totalItems);

      filteredRows.forEach(function(row, index) {
        row.style.display = index >= startIndex && index < endIndex ? "" : "none";
      });

      if (pagCurrent) pagCurrent.textContent = currentPage;
      if (pagTotalPages) pagTotalPages.textContent = totalPages === 0 ? 1 : totalPages;
      if (btnPrev) btnPrev.disabled = currentPage === 1;
      if (btnNext) btnNext.disabled = currentPage === totalPages || totalPages === 0;

      var pagContainer = document.querySelector(".pagination_container");
      if (pagContainer) {
        pagContainer.style.display = totalPages <= 1 ? "none" : "flex";
      }

      if (pagesContainer) {
        pagesContainer.innerHTML = "";
        for (var i = 1; i <= totalPages; i++) {
          var btn = document.createElement("button");
          btn.textContent = i;
          btn.className = "page_num_btn" + (i === currentPage ? " active" : "");
          btn.setAttribute("data-page", i);
          btn.addEventListener("click", function(e) {
            var targetPage = parseInt(e.target.getAttribute("data-page"), 10);
            if (targetPage !== currentPage) {
              currentPage = targetPage;
              applyFiltersAndPagination();
            }
          });
          pagesContainer.appendChild(btn);
        }
      }
    }

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

    applyFiltersAndPagination();
  });
</script>
