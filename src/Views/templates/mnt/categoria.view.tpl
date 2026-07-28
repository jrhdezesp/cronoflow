<div style="margin-bottom: 2rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem;">
  <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">{{mode_dsc}}</h1>
  <p style="color: #64748b; margin-top: 0.25rem;">Completa los datos de la categoría.</p>
</div>

{{if hasErrors}}
<div style="background-color: #fef2f2; border-left: 4px solid #ef4444; padding: 1rem; border-radius: 4px; margin-bottom: 1.5rem; max-width: 600px; margin-left: auto; margin-right: auto;">
  <ul style="margin: 0; padding-left: 1.25rem; color: #b91c1c; font-size: 0.9rem;">
    {{foreach aErrors}}
    <li>{{this}}</li>
    {{endfor aErrors}}
  </ul>
</div>
{{endif hasErrors}}

<form action="index.php?page=mnt_categoria&mode={{mode}}&catid={{catid}}" method="POST" class="form_card">
  <input type="hidden" name="mode" value="{{mode}}" />
  <input type="hidden" name="catid" value="{{catid}}" />

  <div class="form_field" style="max-width: 150px;">
    <label for="catiddummy">Código de Categoría</label>
    <input type="text" id="catiddummy" readonly name="catiddummy" value="{{catid}}" style="text-align: center;" />
  </div>

  <div class="form_field">
    <label for="catnom">Nombre de la Categoría *</label>
    <input type="text" id="catnom" name="catnom" value="{{catnom}}" required {{readonly}} placeholder="Ej. Bebidas Calientes" maxlength="45" />
  </div>

  <div class="form_field">
    <label for="catest">Estado *</label>
    <select id="catest" name="catest" required {{if readonly}}disabled{{endif readonly}}>
      <option value="ACT" {{catest_ACT}}>Activo</option>
      <option value="INA" {{catest_INA}}>Inactivo</option>
      <option value="PLN" {{catest_PLN}}>Planificación</option>
    </select>
  </div>

  <div class="form_actions">
    <button type="button" id="btn-cancelar" class="secondary">
      Cancelar
    </button>
    {{if showaction}}
    <button type="submit" class="primary">
      Guardar Categoría
    </button>
    {{endif showaction}}
  </div>
</form>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var btnCancelar = document.getElementById("btn-cancelar");
    if (btnCancelar) {
      btnCancelar.addEventListener("click", function() {
        window.location.assign("index.php?page=mnt_categorias");
      });
    }
  });
</script>
