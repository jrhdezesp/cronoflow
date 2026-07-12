<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Redireccionando...</title>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body {
            background-color: #f3f4f6;
            font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
    </style>
</head>
<body>
    <script>
        Swal.fire({
            title: 'Aviso',
            text: {{msg}},
            icon: 'info',
            confirmButtonColor: '#10b981',
            confirmButtonText: 'Aceptar',
            allowOutsideClick: false
        }).then((result) => {
            window.location.assign({{url}});
        });
    </script>
</body>
</html>
