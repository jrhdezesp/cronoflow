# Sistema de Control de Inventarios con Algoritmo PEPS (FIFO)

Este es un sistema web de control de inventarios diseñado para digitalizar y optimizar la gestión de existencias en microempresas. Desarrollado en PHP bajo un patrón arquitectónico Modelo-Vista-Controlador (MVC) artesanal, el sistema automatiza la entrada de productos por compras de lotes y calcula el descuento en cascada de existencias basado en el algoritmo PEPS (Primero en Entrar, Primero en Salir).

---

##  Características Principales

* **Control de Lotes**: Registro de entradas de inventario asociadas a lotes específicos, indicando costo de adquisición y fecha de vencimiento.
* **Algoritmo PEPS / FIFO Automático**: Las salidas de inventario descuentan en cascada el stock de los lotes activos más antiguos, garantizando una contabilidad precisa y control de caducidad.
* **Kardex Contable**: Bitácora de movimientos (`ENT`, `SAL`, `MER`) que registra de forma inalterable qué cantidad se ajustó, por qué motivo y qué usuario realizó la acción.
* **Control de Acceso basado en Roles (RBAC)**:
  * **Propietario (PRP)**: Control total del sistema y administración de usuarios.
  * **Administrador (ADM)**: Registro cotidiano de inventarios (productos, lotes, entradas y salidas).
  * **Auditor (AUD)**: Acceso de solo lectura en todo el sistema.
* **Seguridad Avanzada**:
  * Prevención de Inyecciones SQL mediante consultas preparadas en PDO.
  * Enrutador protegido por lista blanca para evitar ejecución de controladores ocultos.
  * Contraseñas encriptadas con algoritmo `Bcrypt`.

---

##  Stack Tecnológico

* **Backend**: PHP 7.4+ (Orientado a Objetos).
* **Base de Datos**: MySQL 5.7+ o MariaDB 10.3+ (Motor InnoDB para soporte transaccional y llaves foráneas).
* **Frontend**: HTML5, LESS (compilado a CSS) y Vanilla JavaScript.
* **Dependencias**: Composer (para autoloading PSR-0 y Less compiler).
* **Servidor Recomendado**: Apache 2.4+ (incluido en XAMPP 8.x).

---

##  Instrucciones de Instalación

1. **Clonar el proyecto** dentro de la carpeta pública de tu servidor web:
   * En XAMPP (Windows): `C:\xampp\htdocs\proyecto-inventario`
   * En WAMP: `C:\wamp\www\proyecto-inventario`

2. **Importar la Base de Datos**:
   * Abre phpMyAdmin, crea una base de datos llamada `proyecto_inventario` e importa el archivo script:
     `docs/scripts/00_init_inventario.sql`

3. **Configurar Parámetros del Entorno**:
   * Copia el archivo `renameTo_parameters.env` a `parameters.env` en la raíz del proyecto.
   * Abre `parameters.env` y ajusta los datos de conexión de tu base de datos y la carpeta del sitio:
     ```env
     DB_USER = root
     DB_PSWD = 
     DB_DATABASE = proyecto_inventario
     BASE_DIR = proyecto-inventario
     ```

4. **Instalar Dependencias**:
   * Ejecuta en la terminal de la carpeta del proyecto para generar el autoloader:
     ```bash
     composer install
     ```

5. **Acceder a la Aplicación**:
   * Abre tu navegador e ingresa a: `http://localhost/proyecto-inventario/index.php`

---

##  Credenciales de Prueba (Semilla)

* **Contraseña común para todos**: `Test1234$`

| Rol | Correo de Acceso |
| :--- | :--- |
| **Propietario / SuperUser (PRP)** | `propietario@inventario.com` |
| **Administrador / Empleado (ADM)** | `empleado@inventario.com` |
| **Auditor (AUD)** | `auditor@inventario.com` |

---

##  Integrantes del Proyecto 
* **Yessenia Nicolle Baquedano Cruz**
* **Dania Licet Montes Carcamo**
* **Annyie Jaqueline Carcamo Vallecillo**
* **Gladys Lizeth Salmerón Ordoñez**
* **Edgar Muñoz Fuentes**

