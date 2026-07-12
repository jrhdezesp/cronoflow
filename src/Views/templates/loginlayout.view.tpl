<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{SITE_TITLE}}</title>
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
  
  {{foreach SiteLinks}}
    <link rel="stylesheet" href="{{~BASE_PATH}}/{{this}}" />
  {{endfor SiteLinks}}
  {{foreach BeginScripts}}
    <script src="{{~BASE_PATH}}/{{this}}"></script>
  {{endfor BeginScripts}}
</head>
<body style="margin:0; padding:0; height:100vh; font-family:'Roboto', sans-serif; background-color: #ffffff;">
  {{{page_content}}}
  {{foreach EndScripts}}
    <script src="{{~BASE_PATH}}/{{this}}"></script>
  {{endfor EndScripts}}
</body>
</html>
