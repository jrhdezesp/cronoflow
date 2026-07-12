<div style="margin-bottom: 2rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem; display: flex; align-items: center; gap: 0.75rem;">
  <div>
    <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">Mi Perfil de Usuario</h1>
    <p style="color: #64748b; margin-top: 0.25rem;">Visualiza los detalles y el rol activo de tu cuenta o actualiza tu contraseña.</p>
  </div>
</div>

<div class="form_card" style="max-width: 550px; margin: 2rem auto; padding: 2.5rem 2rem; border-radius: 12px; border: 1px solid #cbd5e1; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05), 0 4px 6px -2px rgba(0, 0, 0, 0.02);">
  <!-- Profile Header Card -->
  <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-bottom: 2rem;">
    <div style="width: 90px; height: 90px; border-radius: 50%; background-color: #f1f5f9; border: 2px solid #cbd5e1; display: flex; justify-content: center; align-items: center; margin-bottom: 1rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
      <i class="fas fa-user" style="font-size: 3rem; color: #64748b;"></i>
    </div>
    <h2 style="margin: 0; font-size: 1.4rem; font-weight: 700; color: #0f172a;">{{username}}</h2>
    <span style="display: inline-block; background-color: #eff6ff; color: #3b82f6; font-size: 0.85rem; font-weight: 600; padding: 0.35rem 0.75rem; border-radius: 6px; margin-top: 0.5rem; border: 1px solid #bfdbfe;">
      <i class="fas fa-shield-alt" style="margin-right: 0.35rem;"></i>{{role_display}}
    </span>
  </div>

  <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 1.5rem 0;" />

  <!-- Profile Details List -->
  <div style="display: flex; flex-direction: column; gap: 1.25rem;">
    <!-- Code -->
    <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.25rem 0;">
      <span style="font-weight: 600; color: #64748b; font-size: 0.9rem;">Código de Usuario:</span>
      <span style="font-family: monospace; font-size: 0.95rem; color: #0f172a; font-weight: 700;">#{{usercod}}</span>
    </div>
    
    <!-- Email -->
    <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.25rem 0;">
      <span style="font-weight: 600; color: #64748b; font-size: 0.9rem;">Correo Electrónico:</span>
      <span style="font-size: 0.95rem; color: #0f172a; font-weight: 500;">{{useremail}}</span>
    </div>

    <!-- Status -->
    <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.25rem 0;">
      <span style="font-weight: 600; color: #64748b; font-size: 0.9rem;">Estado de la Cuenta:</span>
      <span class="badge {{status_class}}">{{status_dsc}}</span>
    </div>

    <!-- Member since -->
    <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.25rem 0;">
      <span style="font-weight: 600; color: #64748b; font-size: 0.9rem;">Miembro Desde:</span>
      <span style="font-size: 0.95rem; color: #0f172a; font-weight: 500;">{{userfching}}</span>
    </div>
  </div>

  <!-- Button to toggle password change form -->
  <div style="display: flex; justify-content: center; margin-top: 1.5rem; border-top: 1px solid #e2e8f0; padding-top: 1.5rem;">
    <button type="button" id="btn-toggle-pswd" class="secondary" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; min-width: 200px; display: {{displayToggle}}; align-items: center; justify-content: center; gap: 0.5rem; cursor: pointer;">
      <i class="fas fa-key"></i> Cambiar Contraseña
    </button>
  </div>

  <!-- Collapsible Password Change Form -->
  <div id="pswd-form-container" style="display: {{displayForm}}; margin-top: 1.5rem; border-top: 1px solid #e2e8f0; padding-top: 1.5rem;">
    <h3 style="margin: 0 0 1.25rem 0; font-size: 1.15rem; font-weight: 700; color: #0f172a;">Cambiar Contraseña</h3>
    
    {{if hasErrors}}
      <div style="background-color: #fef2f2; border: 1px solid #fee2e2; border-radius: 6px; padding: 1rem; margin-bottom: 1.25rem;">
        <ul style="margin: 0; padding-left: 1.25rem; color: #b91c1c; font-size: 0.9rem;">
          {{foreach errors}}
            <li>{{this}}</li>
          {{endfor errors}}
        </ul>
      </div>
    {{endif hasErrors}}

    <form action="index.php?page=sec_perfil" method="post" style="display: flex; flex-direction: column; gap: 1.25rem;">
      <div class="form_field" style="display: flex; flex-direction: column; gap: 0.35rem;">
        <label for="pswd_actual" style="font-weight: 600; font-size: 0.85rem; color: #64748b;">Contraseña Actual</label>
        <input type="password" id="pswd_actual" name="pswd_actual" required style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.65rem; font-size: 0.9rem;" />
      </div>

      <div class="form_field" style="display: flex; flex-direction: column; gap: 0.35rem;">
        <label for="pswd_nueva" style="font-weight: 600; font-size: 0.85rem; color: #64748b;">Nueva Contraseña</label>
        <input type="password" id="pswd_nueva" name="pswd_nueva" required style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.65rem; font-size: 0.9rem;" />
      </div>

      <div class="form_field" style="display: flex; flex-direction: column; gap: 0.35rem;">
        <label for="pswd_confirmar" style="font-weight: 600; font-size: 0.85rem; color: #64748b;">Confirmar Nueva Contraseña</label>
        <input type="password" id="pswd_confirmar" name="pswd_confirmar" required style="width: 100%; border: 1px solid #cbd5e1; border-radius: 6px; padding: 0.65rem; font-size: 0.9rem;" />
      </div>

      <div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1rem;">
        <button type="button" id="btn-cancel-pswd" class="secondary" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; cursor: pointer; border: 1px solid #cbd5e1; background-color: #f8fafc; color: #475569; transition: all 0.2s;">Cancelar</button>
        <button type="submit" class="primary" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600; cursor: pointer;">Guardar Clave</button>
      </div>
    </form>
  </div>

  <!-- General Actions -->
  <div style="display: flex; justify-content: center; margin-top: 2.25rem; border-top: 1px solid #e2e8f0; padding-top: 1.5rem;">
    <a href="index.php" style="display: inline-flex; align-items: center; gap: 0.5rem; text-decoration: none; background-color: #64748b; color: #fff; padding: 0.75rem 1.75rem; border-radius: 8px; font-weight: 600; transition: all 0.2s ease; box-shadow: 0 4px 6px -1px rgba(100, 116, 139, 0.2); cursor: pointer;" onmouseover="this.style.backgroundColor='#475569'" onmouseout="this.style.backgroundColor='#64748b'">
      <i class="fas fa-home"></i> Ir al Inicio
    </a>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var btnToggle = document.getElementById("btn-toggle-pswd");
    var btnCancel = document.getElementById("btn-cancel-pswd");
    var formContainer = document.getElementById("pswd-form-container");

    if (btnToggle && formContainer) {
      btnToggle.addEventListener("click", function() {
        if (formContainer.style.display === "none") {
          formContainer.style.display = "block";
          btnToggle.style.display = "none";
        } else {
          formContainer.style.display = "none";
        }
      });
    }

    if (btnCancel && formContainer && btnToggle) {
      btnCancel.addEventListener("click", function() {
        formContainer.style.display = "none";
        btnToggle.style.display = "flex";
        
        /* Clear inputs */
        document.getElementById("pswd_actual").value = "";
        document.getElementById("pswd_nueva").value = "";
        document.getElementById("pswd_confirmar").value = "";
      });
    }

    /* Hide toggle button if form is already open on page load (due to errors) */
    if (formContainer && formContainer.style.display === "block" && btnToggle) {
      btnToggle.style.display = "none";
    }
  });
</script>
