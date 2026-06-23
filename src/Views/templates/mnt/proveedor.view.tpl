<div style="margin-bottom: 2rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem;">
  <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">{{mode_dsc}}</h1>
  <p style="color: #64748b; margin-top: 0.25rem;">Completa los datos de la empresa proveedora.</p>
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

<form action="index.php?page=mnt_proveedor&mode={{mode}}&provId={{provId}}" method="POST" class="form_card">
  <input type="hidden" name="mode" value="{{mode}}" />
  <input type="hidden" name="provId" value="{{provId}}" />

  <div class="form_field" style="max-width: 150px;">
    <label for="provIdDummy">Codigo de Proveedor</label>
    <input type="text" id="provIdDummy" readonly name="provIdDummy" value="{{provId}}" style="text-align: center;" />
  </div>

  <div class="form_field">
    <label for="provNombre">Nombre de la Empresa *</label>
    <input type="text" id="provNombre" name="provNombre" value="{{provNombre}}" required {{readonly}} placeholder="Ej. Distribuidora Central" maxlength="100" />
  </div>

  <div class="form_row">
    <div class="form_field">
      <label for="provContacto">Contacto de Ventas</label>
      <input type="text" id="provContacto" name="provContacto" value="{{provContacto}}" {{readonly}} placeholder="Ej. Maria Lopez" maxlength="100" />
    </div>

    <div class="form_field">
      <label for="provTelefono">Telefono</label>
      <input type="text" id="provTelefono" name="provTelefono" value="{{provTelefono}}" {{readonly}} placeholder="Ej. 9999-9999" maxlength="20" />
    </div>
  </div>

  <div class="form_field">
    <label for="provEmail">Correo Electronico</label>
    <input type="email" id="provEmail" name="provEmail" value="{{provEmail}}" {{readonly}} placeholder="ventas@proveedor.com" maxlength="80" />
  </div>

  <div class="form_field">
    <label for="provDireccion">Direccion</label>
    <textarea id="provDireccion" name="provDireccion" rows="4" {{readonly}} placeholder="Direccion del proveedor">{{provDireccion}}</textarea>
  </div>

  <div class="form_field">
    <label for="provEst">Estado *</label>
    <select id="provEst" name="provEst" required {{if readonly}}disabled{{endif readonly}}>
      <option value="ACT" {{provEst_ACT}}>Activo</option>
      <option value="INA" {{provEst_INA}}>Inactivo</option>
    </select>
  </div>

  <div class="form_actions">
    <button type="button" id="btn-cancelar" class="secondary">
      Cancelar
    </button>
    {{if showaction}}
    <button type="submit" class="primary">
      Guardar Proveedor
    </button>
    {{endif showaction}}
  </div>
</form>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var btnCancelar = document.getElementById("btn-cancelar");
    if (btnCancelar) {
      btnCancelar.addEventListener("click", function() {
        window.location.assign("index.php?page=mnt_proveedores");
      });
    }
  });
</script>
