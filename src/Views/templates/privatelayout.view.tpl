<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{SITE_TITLE}}</title>
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
  
  <link rel="stylesheet" href="{{BASE_PATH}}/public/css/appstyle.css?v=1.4" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  
  {{foreach SiteLinks}}
  <link rel="stylesheet" href="{{~BASE_PATH}}/{{this}}" />
  {{endfor SiteLinks}}
  {{foreach BeginScripts}}
  <script src="{{~BASE_PATH}}/{{this}}"></script>
  {{endfor BeginScripts}}
  <style>
    .swal2-container {
      z-index: 99999 !important;
    }
  </style>
</head>


<body>
  <input type="checkbox" class="menu_toggle" id="menu_toggle" />
  <nav id="menu">
    <div class="sidebar_header">
      <span class="sidebar_title">Inventario</span>
      <label for="menu_toggle" class="sidebar_toggle_btn">
        <i class="fas fa-angles-left"></i> </label>
    </div>
    <ul class="nav_list">
      <li><a href="index.php?page=admin_admin"><i class="fas fa-chart-line"></i>&nbsp;Dashboard</a></li>
      {{foreach NAVIGATION}}
          <li><a href="{{nav_url}}"><i class="{{nav_icon}}"></i>&nbsp;{{nav_label}}</a></li>
      {{endfor NAVIGATION}}
    </ul>
    <ul class="nav_logout_list">
      {{with login}}
      <li class="user_card_item">
        <a href="index.php?page=sec_perfil" class="user_card">
          <i class="fas fa-user-circle"></i>
          <div class="user_card_info">
            <span class="user_card_name">{{userName}}</span>
            <span class="user_card_email">{{userEmail}}</span>
          </div>
        </a>
      </li>
      {{endwith login}}
      <li><a href="index.php?page=sec_logout" class="logout_btn"><i class="fas fa-sign-out-alt"></i>&nbsp;Cerrar Sesión</a></li>
    </ul>
  </nav>
  <label for="menu_toggle" class="menu_overlay"></label>
  <header>
    <label for="menu_toggle" class="menu_toggle_icon">
      <div class="hmb dgn pt-1"></div>
      <div class="hmb hrz"></div>
      <div class="hmb dgn pt-2"></div>
    </label>
    <div class="brand-container">
      <svg class="brand-logo" viewBox="0 0 24 24" fill="none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
        <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
        <line x1="12" y1="22.08" x2="12" y2="12"></line>
      </svg>
      <span class="brand-name">Sistema de <span class="brand-accent">inventario</span></span>
    </div>
  </header>


  <main>
    {{{page_content}}}
  </main>

  <footer>
    <div>Todo los Derechos Reservados 2026 &copy;</div>
  </footer>
  
  {{foreach EndScripts}}
  <script src="{{~BASE_PATH}}/{{this}}"></script>
  {{endfor EndScripts}}
</body>
</html>