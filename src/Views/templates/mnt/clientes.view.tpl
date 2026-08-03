<div style="margin-bottom: 2rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem;">
  <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">Clientes Registrados</h1>
  <p style="color: #64748b; margin-top: 0.25rem;">Listado de clientes activos del sistema.</p>
</div>

<section class="WWList">
  <table>
    <thead>
      <tr>
        <th style="width: 80px;">ID</th>
        <th>Nombre</th>
        <th>Teléfono</th>
        <th>Email</th>
        <th style="width: 140px;">Estado</th>
      </tr>
    </thead>
    <tbody>
      {{foreach Clientes}}
      <tr>
        <td>{{clienteId}}</td>
        <td>{{clienteNombre}}</td>
        <td>{{clienteTelefono}}</td>
        <td>{{clienteEmail}}</td>
        <td>{{clienteEst}}</td>
      </tr>
      {{endfor Clientes}}
      {{ifnot Clientes}}
      <tr>
        <td colspan="5" style="padding: 2rem; text-align: center; color: #64748b; font-size: 0.95rem;">No hay clientes registrados.</td>
      </tr>
      {{endifnot Clientes}}
    </tbody>
  </table>
</section>
