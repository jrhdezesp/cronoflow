<div style="margin-bottom: 2rem; border-bottom: 1px solid #cbd5e1; padding-bottom: 1rem;">
  <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700; color: #0f172a;">
    Registrar Movimiento de Inventario
  </h1>

  <p style="color: #64748b; margin-top: 0.25rem;">
    Registra entradas, salidas y mermas de inventario.
  </p>
</div>

{{if hasErrors}}
<div style="background-color: #fef2f2; border-left: 4px solid #ef4444; padding: 1rem; border-radius: 4px; margin-bottom: 1.5rem; max-width: 700px; margin-left: auto; margin-right: auto;">
  <ul style="margin: 0; padding-left: 1.25rem; color: #b91c1c; font-size: 0.9rem;">
    {{foreach aErrors}}
    <li>{{this}}</li>
    {{endfor aErrors}}
  </ul>
</div>
{{endif hasErrors}}

<form 
  action="index.php?page=mnt_movimientos" 
  method="POST" 
  class="form_card"
  id="form-movimiento"
>

  <!-- PRODUCTO -->
  <div class="form_field">
    <label for="invPrdId">
      Producto *
    </label>

    <select 
  id="invPrdId" 
  name="invPrdId" 
  required
>
  <option value="">
    -- Selecciona un Producto --
  </option>

  {{foreach Productos}}

  <option 
    value="{{invPrdId}}" 
    {{selected}}
  >
    {{invPrdDsc}}
    {{if invPrdCodInt}}
    - Código: {{invPrdCodInt}}
    {{endif invPrdCodInt}}
    - Stock: {{invPrdStock}}
  </option>

  {{endfor Productos}}

</select>
  </div>


  <!-- TIPO DE MOVIMIENTO -->
  <div class="form_field">

    <label for="movementType">
      Tipo de Movimiento *
    </label>

    <select 
      id="movementType" 
      name="movementType" 
      required
    >

      <option value="">
        -- Selecciona un tipo --
      </option>

      <option 
        value="ENT"
        {{movementType_ENT}}
      >
        Entrada de Inventario
      </option>

      <option 
        value="SAL"
        {{movementType_SAL}}
      >
        Salida de Inventario
      </option>

      <option 
        value="MER"
        {{movementType_MER}}
      >
        Merma
      </option>

    </select>

  </div>


  <!-- BATCH -->
  <div 
    class="form_field"
    id="batch-container"
  >

    <label for="batchId">
      Batch / Lote *
    </label>

    <select 
      id="batchId" 
      name="batchId" 
      required
    >

      <option value="">
        -- Selecciona un batch --
      </option>

      {{foreach Batches}}

      <option 
        value="{{batchId}}"
        {{selected}}
      >
        {{batchCode}}
        - Disponible: {{batchQuantityAvailable}}
        {{if batchFechaVencimiento}}
        - Vence: {{batchFechaVencimiento}}
        {{endif batchFechaVencimiento}}
      </option>

      {{endfor Batches}}

    </select>

    <small style="display: block; margin-top: 0.35rem; color: #64748b;">
      Selecciona el lote sobre el cual se realizará el movimiento.
    </small>

  </div>


  <!-- CANTIDAD -->
  <div class="form_field">

    <label for="quantity">
      Cantidad *
    </label>

    <input 
      type="number" 
      id="quantity" 
      name="quantity" 
      value="{{quantity}}"
      min="1"
      step="1"
      required
      placeholder="Ej. 10"
      style="text-align: center;"
    />

  </div>


  <!-- MOTIVO -->
  <div class="form_field">

    <label for="reason">
      Motivo del Movimiento *
    </label>

    <input 
      type="text" 
      id="reason" 
      name="reason"
      value="{{reason}}"
      maxlength="255"
      required
      placeholder="Ej. Compra de mercadería, producto dañado, ajuste de inventario..."
    />

  </div>


  <!-- INFORMACIÓN -->
  <div 
    id="movement-info"
    style="
      background-color: #f8fafc;
      border: 1px dashed #cbd5e1;
      padding: 1rem;
      border-radius: 8px;
      margin-bottom: 1.5rem;
      color: #475569;
      font-size: 0.9rem;
    "
  >
    <strong>Información:</strong>

    <span id="movement-info-text">
      Selecciona un tipo de movimiento para ver información.
    </span>
  </div>


  <!-- BOTONES -->
  <div class="form_actions">

    <button 
      type="button" 
      id="btn-cancelar" 
      class="secondary"
    >
      Cancelar
    </button>

    <button 
      type="submit" 
      class="primary"
    >
      Registrar Movimiento
    </button>

  </div>

</form>


<script>

document.addEventListener(
  "DOMContentLoaded", 
  function() {

    var productoSelect =
      document.getElementById("invPrdId");

    var tipoSelect =
      document.getElementById("movementType");

    var batchSelect =
      document.getElementById("batchId");

    var quantityInput =
      document.getElementById("quantity");

    var reasonInput =
      document.getElementById("reason");

    var form =
      document.getElementById("form-movimiento");

    var infoText =
      document.getElementById("movement-info-text");

    var btnCancelar =
      document.getElementById("btn-cancelar");


    /*
     * CANCELAR
     */
    if (btnCancelar) {

      btnCancelar.addEventListener(
        "click",
        function() {

          window.location.assign(
            "index.php?page=mnt_movimientos"
          );

        }
      );

    }


    /*
     * CAMBIO DE PRODUCTO
     */
    if (productoSelect) {

      productoSelect.addEventListener(
        "change",
        function() {

          var productoId = this.value;

          if (productoId !== "") {

            window.location.href =
              "index.php?page=mnt_movimientos"
              + "&invPrdId="
              + encodeURIComponent(productoId);

          }
          else {

            window.location.href =
              "index.php?page=mnt_movimientos";

          }

        }
      );

    }


    /*
     * CAMBIO DE TIPO DE MOVIMIENTO
     */
    if (tipoSelect) {

      tipoSelect.addEventListener(
        "change",
        function() {

          var tipo =
            this.value;

          if (tipo === "ENT") {

            infoText.textContent =
              "La entrada aumentará el stock disponible del producto y del batch seleccionado.";

          }
          else if (tipo === "SAL") {

            infoText.textContent =
              "La salida disminuirá el stock disponible del producto y del batch seleccionado.";

          }
          else if (tipo === "MER") {

            infoText.textContent =
              "La merma disminuirá el inventario debido a pérdida, daño o deterioro del producto.";

          }
          else {

            infoText.textContent =
              "Selecciona un tipo de movimiento para ver información.";

          }

        }
      );

    }


    /*
     * VALIDAR CANTIDAD
     */
    if (form) {

      form.addEventListener(
        "submit",
        function(e) {

          var cantidad =
            parseInt(
              quantityInput.value,
              10
            ) || 0;

          if (cantidad <= 0) {

            e.preventDefault();

            Swal.fire({
              title: "Cantidad inválida",
              text: "La cantidad debe ser mayor a cero.",
              icon: "warning",
              confirmButtonColor: "#10b981",
              confirmButtonText: "Aceptar"
            });

            quantityInput.focus();

            return false;

          }


          /*
           * Validar producto
           */
          if (
            productoSelect.value === ""
          ) {

            e.preventDefault();

            Swal.fire({
              title: "Producto requerido",
              text: "Debe seleccionar un producto.",
              icon: "warning",
              confirmButtonColor: "#10b981",
              confirmButtonText: "Aceptar"
            });

            productoSelect.focus();

            return false;

          }


          /*
           * Validar batch
           */
          if (
            batchSelect.value === ""
          ) {

            e.preventDefault();

            Swal.fire({
              title: "Batch requerido",
              text: "Debe seleccionar un batch para realizar el movimiento.",
              icon: "warning",
              confirmButtonColor: "#10b981",
              confirmButtonText: "Aceptar"
            });

            batchSelect.focus();

            return false;

          }


          /*
           * Confirmar movimiento
           */
          e.preventDefault();

          var tipoTexto = "";

          if (tipoSelect.value === "ENT") {
            tipoTexto = "Entrada";
          }
          else if (tipoSelect.value === "SAL") {
            tipoTexto = "Salida";
          }
          else if (tipoSelect.value === "MER") {
            tipoTexto = "Merma";
          }


          Swal.fire({

            title: "¿Registrar movimiento?",

            text:
              "Se registrará una "
              + tipoTexto
              + " de "
              + cantidad
              + " unidad(es).",

            icon: "question",

            showCancelButton: true,

            confirmButtonColor: "#10b981",

            cancelButtonColor: "#64748b",

            confirmButtonText:
              "Sí, registrar",

            cancelButtonText:
              "Cancelar"

          }).then(
            function(result) {

              if (
                result.isConfirmed
              ) {

                form.submit();

              }

            }
          );

        }
      );

    }

  }
);

</script>