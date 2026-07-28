<div style="margin-bottom: 2rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem;">
  <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">Ventas</h1>
  <p style="color: #64748b; margin-top: 0.25rem;">Listado de transacciones de venta registradas.</p>
</div>

<div class="WWList">
  <table>
    <thead>
      <tr>
        <th style="width: 120px;">ID Venta</th>
        <th style="width: 180px;">Número</th>
        <th>Cliente</th>
        <th style="width: 180px;">Fecha</th>
        <th style="width: 140px; text-align: right;">Total</th>
        <th style="width: 120px; text-align: center;">Estado</th>
      </tr>
    </thead>
    <tbody>
      {{foreach Sales}}
      <tr>
        <td>{{saleId}}</td>
        <td>{{saleNumber}}</td>
        <td>{{customerName}}</td>
        <td>{{saleDate}}</td>
        <td style="text-align: right; font-weight: 700;">L. {{saleTotal}}</td>
        <td style="text-align: center;"><span class="badge {{saleStatusClass}}">{{saleStatus}}</span></td>
      </tr>
      {{endfor Sales}}
      {{ifnot Sales}}
      <tr>
        <td colspan="6" style="padding: 2rem; text-align: center; color: #64748b;">No se encontraron ventas registradas.</td>
      </tr>
      {{endifnot Sales}}
    </tbody>
  </table>
</div>
