<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{SITE_TITLE}}</title>
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
  
  <link rel="stylesheet" href="{{BASE_PATH}}/public/css/appstyle.css?v=1.4" />
  <link rel="stylesheet" href="{{BASE_PATH}}/public/css/style.css?v=1.4">
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
  <header style="justify-content: center;">
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
    <div>Todo los Derechos Reservados 2021 &copy;</div>
  </footer>
  {{foreach EndScripts}}
    <script src="{{~BASE_PATH}}/{{this}}"></script>
  {{endfor EndScripts}}
</body>
</html>
