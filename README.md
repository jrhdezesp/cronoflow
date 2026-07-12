# CronoFlow v2.0 - Sistema de Control de Inventarios con Algoritmo PEPS (FIFO)

![PHP](https://img.shields.io/badge/PHP-8.1%2B-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)
![Composer](https://img.shields.io/badge/Composer-2.x-885630?logo=composer&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-3-1572B6?logo=css3&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-5-E34F26?logo=html5&logoColor=white)
![XAMPP](https://img.shields.io/badge/XAMPP-8.x-FB7A24?logo=xampp&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-ES6%2B-F7DF1E?logo=javascript&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green)

## Integrantes
- Anyelo Favian Rivera Galindo - 1501200402099
- Carlos Gustavo Luna Acosta - 0301200400911
- Jose Ramon Hernandez Espinal - 0801200306613 - Coordinador
- Maria del Carmen Aguilar Martel - 0801200707818
- Leibo Moisés Raibstein Aguiluz - 0801200104787

## Tecnologías utilizadas
- **Backend**: PHP 8.1+ + Composer (MVC propio)
- **Base de Datos**: MySQL 8.0 (Motor InnoDB transaccional)
- **Frontend**: HTML5, CSS3 (LESS compilado), JavaScript vanilla (ES6+)
- **DevOps / Servidor**: Docker / Apache 2.4+ (XAMPP)
- **Control de versiones**: Git + GitHub

## Problema planteado
Las microempresas y pequeños comercios administran frecuentemente su inventario de forma manual mediante libretas o tablas desestructuradas. Este enfoque empírico genera pérdidas directas por robo hormiga, mermas no registradas, rupturas inesperadas de stock y el vencimiento de productos perecederos debido a la falta de un control estricto de fechas y costos de adquisición. Sin datos confiables, calcular el valor real del inventario y los márgenes de ganancia se vuelve una tarea imposible.

## Solución tecnológica
**CronoFlow** es una solución web accesible y de bajo costo de infraestructura diseñada específicamente para digitalizar y formalizar la gestión de existencias adaptándose al perfil real de las microempresas hondureñas. Desarrollado bajo un patrón arquitectónico **MVC artesanal** en PHP orientado a objetos, automatiza el ciclo de vida de las mercancías mediante un estricto control de lotes. Su núcleo contable ejecuta de forma transparente el algoritmo PEPS (Primero en Entrar, Primero en Salir), garantizando la trazabilidad absoluta de cada producto desde su ingreso hasta su salida y protegiendo la integridad del negocio mediante un esquema robusto de seguridad por roles.

---

## ✨ Novedades v2.0 (Características Core)

| Área | Componente y Beneficio Técnico |
|------|--------------------------------|
| ⚙️ **Algoritmo PEPS** | Deducción automática en cascada que consume secuencialmente los lotes activos más antiguos según su fecha de ingreso o vencimiento. Permite también selección manual con autocompletado en tiempo real. |
| 📊 **Trazabilidad** | Bitácora de movimientos (**Kardex Contable**) inalterable para registrar entradas (`ENT`), salidas (`SAL`) y mermas (`MER`) especificando motivos obligatorios y el usuario responsable. |
| 🔐 **Seguridad RBAC** | Control de acceso basado en roles tripartito (Propietario, Administrador, Auditor) con ocultamiento dinámico de componentes de UI y rechazo estricto de peticiones POST no autorizadas. |
| 🛡️ **Defensa** | Cifrado de contraseñas mediante `Bcrypt`, aislamiento de rutas por lista blanca, y erradicación de Inyecciones SQL mediante un modelo DAO sustentado en consultas preparadas con PDO Singleton. |
| 🏎️ **Rendimiento** | Arquitectura desacoplada sin dependencias pesadas de runtime, uso del motor de plantillas ligero `SimplePHPMvcOOP` (`.tpl`) y tiempos de respuesta inferiores a 2 segundos. |

---

## Alcance funcional

### Gestión de Usuarios y Seguridad (RBAC)
- Autenticación segura mediante contraseñas encriptadas con el algoritmo `Bcrypt`.
- **Propietario (PRP)**: Control total del sistema, auditoría de seguridad y gestión integral de usuarios.
- **Administrador (ADM)**: Operación diaria del inventario incluyendo el registro de productos, categorías, entradas y salidas.
- **Auditor (AUD)**: Modo estricto de solo lectura; la interfaz oculta automáticamente las acciones de escritura y el backend deniega modificaciones.

### Módulo Catálogo y Mantenimiento
- CRUD completo de Categorías para el agrupamiento y filtrado dinámico de artículos.
- CRUD de Productos incluyendo el control de código interno, código de barras, precios de venta, costos y stock mínimo.
- Módulo de Proveedores integrado directamente al flujo de abastecimiento de productos.

### Control de Lotes y Algoritmo PEPS
- Registro detallado de entradas asociadas a lotes específicos, almacenando costos unitarios de adquisición y fechas de vencimiento.
- **Descuento en cascada automático**: Las salidas disminuyen el inventario del lote más antiguo disponible para mitigar pérdidas por caducidad.
- Buscador inteligente con autocompletado para la asignación manual de lotes específicos en ajustes especiales.

### Kardex Contable e Historial
- Registro cronológico completo e inalterable de cada alteración física del stock.
- Clasificación estricta por tipo de ajuste: Entrada (`ENT`), Salida (`SAL`) y Merma (`MER`) con justificación obligatoria.
- Interfaz paginada equipada con filtros rápidos por producto, tipo de movimiento y rango de fechas.

### Dashboard y Alertas Operativas
- Vista consolidada de métricas clave del inventario a través de un dashboard resumen operativo.
- Monitoreo de niveles críticos de stock con alertas automatizadas cuando las existencias caen por debajo del mínimo establecido.

---

## 🚀 Instalación

### Opción A: Docker

# 1. Clonar el repositorio
git clone [https://github.com/tu-usuario/CronoFlow.git](https://github.com/tu-usuario/CronoFlow.git)
cd CronoFlow

# 2. Levantar los contenedores de la aplicación
docker compose up -d

# 3. Acceder a la aplicación
# App: http://localhost:8080 | DB: localhost:3306


### Opción B: Servidor Local (XAMPP)

1. **Clonar el proyecto** dentro de la carpeta pública de tu entorno local:
   * En XAMPP (Windows): `C:\xampp\htdocs\inventario`
   * En WAMP: `C:\wamp\www\inventario`

2. **Importar la Base de Datos**:
   * Accede a phpMyAdmin e importa el script SQL completo ubicado en: `docs/scripts/00_database.sql` (crea la BD y las tablas automáticamente).

3. **Configurar Parámetros del Entorno**:
   * Renombra el archivo `renameTo_parameters.env` a `parameters.env` en la raíz del proyecto.
   * Configura las credenciales de conexión y la zona horaria (`America/Tegucigalpa`):
     ```env
     DB_USER = root
     DB_PSWD = 
     DB_DATABASE = proyecto_inventario
     BASE_DIR = inventario
     ```

4. **Instalar Dependencias y Autoloading**:
   * Ejecuta Composer en la terminal dentro de la raíz del proyecto para inicializar el autoloader PSR-0:
     ```bash
     composer install
     ```

5. **Acceder al Sistema**:
   * Abre tu navegador e ingresa a: `http://localhost/inventario/index.php?page=sec_login`.

---

## 🔐 Credenciales de Prueba (Semilla)

* **Contraseña global para el entorno de desarrollo**: `Test1234$`

| Rol de Acceso | Correo Electrónico | Permisos Operativos |
| :--- | :--- | :--- |
| **Propietario / SuperUser (PRP)** | `propietario@inventario.com` | Control total + Configuración de seguridad |
| **Administrador / Empleado (ADM)** | `empleado@inventario.com` | Operaciones de inventario y movimientos |
| **Auditor (AUD)** | `auditor@inventario.com` | Solo lectura y verificación de Kardex |

---

## 📁 Estructura del Proyecto
La organización del código fuente mantiene un desacoplamiento estricto de componentes bajo el estándar PSR-0:

```text
proyecto-inventario/
├── public/                 # Recursos accesibles públicamente
│   └── css/                # Hojas de estilo compiladas desde LESS
├── src/                    # Código fuente de la aplicación
│   ├── Controllers/        # Controladores MVC (Lógica de control y seguridad)
│   ├── Dao/                # Capa del Modelo (Consultas SQL parametrizadas PDO)
│   ├── Utilities/          # Clases de soporte (Security, Nav, Context)
│   └── Views/              # Capa de Presentación
│       └── templates/      # Plantillas de diseño dinámicas (.view.tpl)
├── docs/                   
│   └── scripts/            # Scripts SQL de inicialización de la BD
├── index.php               # Front Controller (Punto único de entrada)
├── autoloader.php          # Inicialización del cargador automático de clases
├── composer.json           # Declaración de paquetes y dependencias del sistema
└── parameters.env          # Configuración sensible de variables de entorno
```

---

## 📄 Licencia
MIT License — Consulta el archivo [LICENSE](LICENSE) para más detalles.