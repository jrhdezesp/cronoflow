<h1 style="font-size: 1.4rem; font-weight: 700; color: #0f172a; margin: 1.5rem 0 1rem 0; padding: 0 1rem; word-wrap: break-word; text-align: center;">
  {{mode_dsc}}
</h1>

<section class="form_card">
  <form action="index.php?page=mnt_usuario&mode={{mode}}&id={{id}}" method="POST">
    
    <div class="form_field">
      <label for="iddummy">Código de Usuario</label>
      <input type="text" readonly id="iddummy" name="iddummy" value="{{id}}" />
      <input type="hidden" id="id" name="id" value="{{id}}" />
    </div>

    <div class="form_field">
      <label for="useremail">Correo Electrónico</label>
      <input type="email" {{readonly_email}} id="useremail" name="useremail" value="{{useremail}}" maxlength="80" placeholder="correo@ejemplo.com" required />
    </div>

    <div class="form_field">
      <label for="username">Nombre Completo</label>
      <input type="text" {{readonly}} id="username" name="username" value="{{username}}" maxlength="80" placeholder="Nombre y Apellidos" required />
    </div>

    {{if show_password}}
    <div class="form_field">
      <label for="userpswd">Contraseña</label>
      <input type="password" id="userpswd" name="userpswd" placeholder="Escribe la contraseña temporal" required 
        oncopy="return false;" oncut="return false;" ondragstart="return false;" ondrop="return false;" onselectstart="return false;"
        style="user-select: none; -moz-user-select: none; -webkit-user-select: none; -ms-user-select: none;" />
    </div>

    <div class="form_field">
      <label for="userpswd_confirm">Confirmar Contraseña</label>
      <input type="password" id="userpswd_confirm" name="userpswd_confirm" placeholder="Vuelve a escribir la contraseña" required 
        onpaste="return false;" ondragstart="return false;" ondrop="return false;" onselectstart="return false;"
        style="user-select: none; -moz-user-select: none; -webkit-user-select: none; -ms-user-select: none;" />
      
      <div class="password-requirements" style="background-color: rgba(245, 158, 11, 0.05); border-left: 4px solid #f59e0b; padding: 0.75rem 1rem; border-radius: 4px; margin-top: 0.75rem; font-size: 0.85rem; color: #475569; line-height: 1.4;">
        <strong style="color: #d97706; display: block; margin-bottom: 0.25rem;"><i class="fas fa-info-circle"></i> Requisitos de seguridad:</strong>
        <ul style="margin: 0; padding-left: 1.25rem; list-style-type: disc;">
          <li>De 8 a 32 caracteres de largo.</li>
          <li>Al menos una letra mayúscula (A-Z).</li>
          <li>Al menos una letra minúscula (a-z).</li>
          <li>Al menos un número (0-9).</li>
          <li>Al menos un carácter especial (ej. * _ - ! @ # $ % & ; excepto dos puntos : o espacios).</li>
        </ul>
      </div>
    </div>
    {{endif show_password}}

    <div class="form_field">
      <label for="userest">Estado del Usuario</label>
      <select id="userest" name="userest" {{if select_disabled}}disabled{{endif select_disabled}}>
        <option value="ACT" {{userest_ACT}}>Activo</option>
        <option value="INA" {{userest_INA}}>Inactivo (Desactivado)</option>
        {{if show_blocked_option}}
        <option value="BLQ" {{userest_BLQ}}>Bloqueado</option>
        {{endif show_blocked_option}}
      </select>
      {{if is_self_edit}}
      <span style="font-size: 0.8rem; color: #ef4444; margin-top: 0.35rem; line-height: 1.4;"><i class="fas fa-exclamation-triangle"></i> No puedes desactivar o bloquear tu propio usuario administrador.</span>
      <input type="hidden" name="userest" value="{{userest}}" />
      {{endif is_self_edit}}
    </div>

    <div class="form_field">
      <label for="rolescod">Rol del Usuario</label>
      <select id="rolescod" name="rolescod" {{if select_role_disabled}}disabled{{endif select_role_disabled}}>
        {{foreach Roles}}
        <option value="{{rolescod}}" {{selected}}>{{rolesdsc}}</option>
        {{endfor Roles}}
      </select>
      {{if is_self_edit}}
      <span style="font-size: 0.8rem; color: #ef4444; margin-top: 0.35rem; line-height: 1.4;"><i class="fas fa-exclamation-triangle"></i> No puedes cambiar tu propio rol de administrador.</span>
      <input type="hidden" name="rolescod" value="{{rolescod_selected}}" />
      {{endif is_self_edit}}
      {{ifnot is_self_edit}}
        {{if readonly}}
        <input type="hidden" name="rolescod" value="{{rolescod_selected}}" />
        {{endif readonly}}
      {{endifnot is_self_edit}}
    </div>

    {{if hasErrors}}
    <div style="margin: 1.5rem 0; background-color: rgba(239, 68, 68, 0.05); border-left: 4px solid #ef4444; padding: 0.75rem 1rem; border-radius: 4px; color: #b91c1c; font-size: 0.9rem; line-height: 1.4;">
      <ul style="margin: 0; padding-left: 1.25rem;">
        {{foreach aErrors}}
        <li>{{this}}</li>
        {{endfor aErrors}}
      </ul>
    </div>
    {{endif hasErrors}}

    <div style="display: flex; justify-content: flex-end; gap: 1rem; margin-top: 2rem;">
      {{if showaction}}
      <button type="submit" name="btnGuardar" value="G" class="primary" style="padding: 0.75rem 1.5rem; border-radius: 6px; font-weight: 600;">Guardar</button>
      {{endif showaction}}
      <button type="button" id="btnCancelar" style="padding: 0.75rem 1.5rem; border-radius: 6px; border: 1px solid #cbd5e1; background-color: #f8fafc; color: #475569; font-weight: 600; cursor: pointer; transition: all 0.2s;">Cancelar</button>
    </div>

  </form>
</section>

<script>
  document.addEventListener("DOMContentLoaded", function(){
      /* Regreso a la lista */
      document.getElementById("btnCancelar").addEventListener("click", function(e){
        e.preventDefault();
        e.stopPropagation();
        window.location.assign("index.php?page=mnt_usuarios");
      });
  });
</script>
