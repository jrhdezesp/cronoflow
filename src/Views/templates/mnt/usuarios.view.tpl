<style>
  .filter_flex_container {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
    flex-wrap: wrap;
    align-items: center;
  }
  .search_container {
    position: relative;
    flex: 1;
    min-width: 280px;
  }
  .search_input {
    width: 100%;
    padding: 0.65rem 1rem 0.65rem 2.6rem;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    font-size: 0.95rem;
    color: #0f172a;
    outline: none;
    transition: all 0.2s ease;
    background-color: #f8fafc;
    box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05);
  }
  .search_input:focus {
    border-color: #3b82f6 !important;
    background-color: #fff !important;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15), inset 0 1px 2px rgba(0, 0, 0, 0.05) !important;
  }
  .search_icon {
    position: absolute;
    left: 1rem;
    top: 50%;
    transform: translateY(-50%);
    color: #64748b;
    font-size: 0.95rem;
    pointer-events: none;
  }
  .filter_group {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }
  .filter_label {
    font-size: 0.85rem;
    font-weight: 600;
    color: #64748b;
  }
  .filter_select {
    padding: 0.65rem 2.25rem 0.65rem 1rem;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    font-size: 0.95rem;
    color: #0f172a;
    outline: none;
    background-color: #f8fafc;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05);
    appearance: none;
    background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3E%3Cpath stroke='%2364748b' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='m6 8 4 4 4-4'/%3E%3C/svg%3E");
    background-position: right 0.75rem center;
    background-repeat: no-repeat;
    background-size: 1.25rem;
  }
  .filter_select:focus {
    border-color: #3b82f6 !important;
    background-color: #fff !important;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15), inset 0 1px 2px rgba(0, 0, 0, 0.05) !important;
  }
  .pag_btn {
    height: 38px;
    padding: 0 1rem;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    background-color: #fff;
    color: #334155;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    user-select: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.35rem;
    font-size: 0.875rem;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  }
  .pag_btn:hover:not(:disabled) {
    background-color: #f8fafc;
    border-color: #94a3b8;
    color: #0f172a;
  }
  .pag_btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    box-shadow: none;
  }
  .page_num_btn {
    height: 38px;
    width: 38px;
    padding: 0;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    background-color: #fff;
    color: #334155;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    user-select: none;
    font-size: 0.875rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  }
  .page_num_btn:hover:not(.active) {
    background-color: #f8fafc;
    border-color: #94a3b8;
    color: #0f172a;
  }
  .page_num_btn.active {
    background-color: #eff6ff;
    color: #2563eb;
    border-color: #bfdbfe;
    cursor: default;
    box-shadow: none;
  }
</style>

<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem;">
  <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">Trabajar con Usuarios</h1>
  {{if CanInsert}}
  <a href="index.php?page=mnt_usuario&mode=INS&id=0" style="display: inline-flex; align-items: center; gap: 0.5rem; background-color: #10b981; color: #fff; padding: 0.6rem 1.25rem; border-radius: 6px; font-weight: 600; text-decoration: none; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2), 0 2px 4px -1px rgba(16, 185, 129, 0.1); transition: all 0.2s ease;">
    <i class="fas fa-plus"></i> Nuevo Usuario
  </a>
  {{endif CanInsert}}
</div>

<div class="filter_flex_container">
  <div class="search_container">
    <i class="fas fa-search search_icon"></i>
    <input type="text" id="user-search-input" class="search_input" placeholder="Buscar usuario por nombre, correo o código..." />
  </div>
  
  <div class="filter_group">
    <label for="filter-role" class="filter_label">Rol:</label>
    <select id="filter-role" class="filter_select">
      <option value="all">Todos los Roles</option>
      <option value="propietario">Propietario / SuperUser</option>
      <option value="administrador">Administrador / Empleado</option>
      <option value="auditor">Auditor de Solo Lectura</option>
    </select>
  </div>

  <div class="filter_group">
    <label for="filter-status" class="filter_label">Estado:</label>
    <select id="filter-status" class="filter_select">
      <option value="all">Todos los Estados</option>
      <option value="activo">Activo</option>
      <option value="inactivo">Inactivo</option>
      <option value="bloqueado">Bloqueado</option>
    </select>
  </div>
</div>

<section class="WWList">
  <table>
    <thead>
      <tr>
        <th style="width: 80px;">Código</th>
        <th>Nombre Completo</th>
        <th>Correo Electrónico</th>
        <th>Rol</th>
        <th style="width: 150px;">Estado</th>
        <th style="width: 100px; text-align: right;">Acciones</th>
      </tr>
    </thead>
    <tbody>
      {{foreach Usuarios}}
      <tr class="user-row" data-role="{{usertipo_dsc}}" data-status="{{userest_dsc}}">
        <td>{{usercod}}</td>
        <td>{{username}}</td>
        <td>
          {{if ~CanView}}
          <a href="index.php?page=mnt_usuario&mode=DSO&id={{usercod}}">{{useremail}}</a>
          {{endif ~CanView}}

          {{ifnot ~CanView}}
          {{useremail}}
          {{endifnot ~CanView}}
        </td>
        <td>{{usertipo_dsc}}</td>
        <td>
          <span class="badge {{userest_class}}">{{userest_dsc}}</span>
        </td>
        <td style="text-align: right;">
          {{if ~CanUpdate}}
          <a href="index.php?page=mnt_usuario&mode=UPD&id={{usercod}}" class="btn" title="Editar">
            <i class="fas fa-edit"></i>
          </a>
          {{endif ~CanUpdate}}
        </td>
      </tr>
      {{endfor Usuarios}}
    </tbody>
  </table>

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

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var searchInput = document.getElementById("user-search-input");
    var roleSelect = document.getElementById("filter-role");
    var statusSelect = document.getElementById("filter-status");

    var btnPrev = document.getElementById("btn-prev");
    var btnNext = document.getElementById("btn-next");
    var pagesContainer = document.getElementById("pagination-pages");

    var pagStart = document.getElementById("pag-start");
    var pagEnd = document.getElementById("pag-end");
    var pagTotal = document.getElementById("pag-total");

    var currentPage = 1;
    var itemsPerPage = 3; /* Ajustado a 3 para pruebas con tus 4 usuarios actuales */

    function applyFiltersAndPagination() {
      var searchText = searchInput ? searchInput.value.toLowerCase().trim() : "";
      var selectedRole = roleSelect ? roleSelect.value : "all";
      var selectedStatus = statusSelect ? statusSelect.value : "all";

      var allRows = document.querySelectorAll("table tbody tr.user-row");
      var filteredRows = [];

      /* 1. Filtrar filas */
      allRows.forEach(function(row) {
        var rowText = row.textContent.toLowerCase();
        var rowRole = (row.getAttribute("data-role") || "").toLowerCase();
        var rowStatus = (row.getAttribute("data-status") || "").toLowerCase();

        var matchesSearch = (rowText.indexOf(searchText) > -1);
        var matchesRole = (selectedRole === "all" || rowRole.indexOf(selectedRole) > -1);
        var matchesStatus = (selectedStatus === "all" || rowStatus.indexOf(selectedStatus) > -1);

        if (matchesSearch && matchesRole && matchesStatus) {
          filteredRows.push(row);
        } else {
          row.style.display = "none";
        }
      });

      /* 2. Paginacion sobre filas filtradas */
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

      /* 3. Actualizar informacion de paginacion */
      var pagCurrent = document.getElementById("pag-current");
      var pagTotalPages = document.getElementById("pag-total-pages");
      if (pagCurrent) pagCurrent.textContent = currentPage;
      if (pagTotalPages) pagTotalPages.textContent = totalPages === 0 ? 1 : totalPages;

      /* 4. Actualizar botones Anterior/Siguiente */
      if (btnPrev) btnPrev.disabled = (currentPage === 1);
      if (btnNext) btnNext.disabled = (currentPage === totalPages || totalPages === 0);

      /* 4b. Ocultar contenedor si solo hay 1 pagina o ninguna */
      var pagContainer = document.querySelector(".pagination_container");
      if (pagContainer) {
        if (totalPages <= 1) {
          pagContainer.style.display = "none";
        } else {
          pagContainer.style.display = "flex";
        }
      }

      /* 5. Generar numeros de paginas */
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
    if (roleSelect) {
      roleSelect.addEventListener("change", function() {
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

    /* Ejecucion inicial */
    applyFiltersAndPagination();
  });
</script>
