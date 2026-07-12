<style>
  /* Base reset and layout */
  .login-split-container {
    display: flex;
    height: 100vh;
    width: 100vw;
    overflow: hidden;
    font-family: 'Roboto', 'Inter', sans-serif;
  }

  @media (max-width: 991px) {
    .login-split-container {
      flex-direction: column;
      height: auto;
      min-height: 100vh;
      overflow-y: auto;
    }
  }

  /* Left Panel - Project Palette (Slate to Emerald) */
  .login-visual-panel {
    display: none;
    width: 50%;
    position: relative;
    background: linear-gradient(135deg, #1e293b 0%, #0f172a 50%, #10b981 100%);
    color: #ffffff;
    overflow: hidden;
    padding: 3rem;
    box-sizing: border-box;
    flex-direction: column;
    justify-content: space-between;
  }

  @media (min-width: 992px) {
    .login-visual-panel {
      display: flex;
    }
  }

  /* Background Blobs matching project colors */
  .visual-blob-1 {
    position: absolute;
    top: -10%;
    left: -10%;
    width: 350px;
    height: 350px;
    background: rgba(255, 255, 255, 0.06);
    border-radius: 50%;
    filter: blur(50px);
  }

  .visual-blob-2 {
    position: absolute;
    bottom: -10%;
    left: 15%;
    width: 400px;
    height: 350px;
    background: rgba(16, 185, 129, 0.15); /* Emerald glow */
    border-radius: 38% 62% 63% 37% / 41% 44% 56% 59%;
    filter: blur(40px);
    animation: blobMorph 12s infinite alternate ease-in-out;
  }

  .visual-blob-3 {
    position: absolute;
    top: 25%;
    right: -10%;
    width: 250px;
    height: 250px;
    background: rgba(30, 41, 59, 0.5); /* Slate glow */
    border-radius: 50%;
    filter: blur(35px);
  }

  @keyframes blobMorph {
    0% { border-radius: 38% 62% 63% 37% / 41% 44% 56% 59%; transform: translate(0, 0) scale(1); }
    100% { border-radius: 70% 30% 50% 50% / 30% 60% 40% 70%; transform: translate(15px, -15px) scale(1.05); }
  }

  /* Decorative Striped Circle */
  .striped-circle {
    position: absolute;
    top: 15%;
    right: 15%;
    width: 80px;
    height: 80px;
    background: repeating-linear-gradient(45deg, rgba(255,255,255,0.06), rgba(255,255,255,0.06) 2px, transparent 2px, transparent 10px);
    border-radius: 50%;
  }

  /* Triangular Logo Mark */
  .visual-logo-mark {
    display: flex;
    gap: 8px;
    align-items: center;
    font-size: 1.15rem;
    font-weight: 700;
    letter-spacing: 0.05em;
    z-index: 10;
  }

  /* Mobile Logo Mark */
  .mobile-logo-mark {
    display: none;
    gap: 8px;
    align-items: center;
    font-size: 1.15rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 2.5rem;
    justify-content: center;
    letter-spacing: 0.05em;
  }

  .mobile-logo-mark .tri-2 {
    border-bottom-color: #1e293b !important;
    opacity: 0.8;
  }

  .mobile-logo-mark .tri-3 {
    border-bottom-color: #1e293b !important;
    opacity: 0.5;
  }

  @media (max-width: 991px) {
    .mobile-logo-mark {
      display: flex;
    }
  }

  .logo-triangles {
    position: relative;
    width: 36px;
    height: 24px;
  }

  .logo-triangles .tri {
    position: absolute;
    width: 0;
    height: 0;
    border-left: 8px solid transparent;
    border-right: 8px solid transparent;
    border-bottom: 14px solid #10b981; /* Emerald green */
  }

  .logo-triangles .tri-1 { left: 0; bottom: 0; }
  .logo-triangles .tri-2 { left: 10px; bottom: 0; border-bottom-color: #ffffff; opacity: 0.9; }
  .logo-triangles .tri-3 { left: 20px; bottom: 0; border-bottom-color: #ffffff; opacity: 0.6; }

  /* Visual Content */
  .visual-content {
    z-index: 10;
    margin-bottom: 4rem;
  }

  .visual-content h1 {
    font-size: 2.75rem;
    font-weight: 800;
    margin: 0 0 1rem 0;
    line-height: 1.15;
    letter-spacing: -0.03em;
  }

  .visual-content p {
    font-size: 1.05rem;
    opacity: 0.9;
    line-height: 1.5;
    margin: 0;
    max-width: 440px;
  }

  .visual-footer {
    font-size: 0.85rem;
    opacity: 0.7;
    z-index: 10;
  }

  /* Right Panel - Login Form */
  .login-form-panel {
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: #ffffff;
    padding: 2rem;
    box-sizing: border-box;
  }

  @media (max-width: 991px) {
    .login-form-panel {
      min-height: 100vh;
      padding: 2.5rem 1.5rem;
    }
  }

  @media (min-width: 992px) {
    .login-form-panel {
      width: 50%;
    }
  }

  .form-container {
    width: 100%;
    max-width: 380px;
  }

  .form-container h2 {
    font-size: 2.25rem;
    font-weight: 800;
    color: #1e293b; /* Slate 800 */
    margin: 0 0 2rem 0;
    letter-spacing: -0.02em;
  }

  @media (max-width: 991px) {
    .form-container h2 {
      text-align: center;
    }
  }

  /* Modern Pill Inputs */
  .form-group {
    margin-bottom: 1.25rem;
  }

  .input-pill-wrapper {
    position: relative;
    width: 100%;
  }

  .input-pill-wrapper i {
    position: absolute;
    left: 1.25rem;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
    font-size: 0.95rem;
    transition: color 0.25s ease;
  }

  .input-pill-wrapper input {
    width: 100%;
    padding: 0.95rem 1.25rem 0.95rem 2.75rem;
    border: 1px solid #cbd5e1; /* seconady_bg300 */
    border-radius: 50px;
    font-size: 0.95rem;
    color: #0f172a;
    background-color: #f8fafc;
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.01);
    transition: all 0.25s ease;
    box-sizing: border-box;
    outline: none;
    margin: 0px !important;
  }

  .input-pill-wrapper input:focus {
    border-color: #10b981; /* primary_action_bg */
    background-color: #ffffff;
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.08);
  }

  .input-pill-wrapper input:focus + i {
    color: #10b981;
  }

  /* Remember and Forgot password flex */
  .form-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 0.85rem;
    margin-top: 1rem;
    margin-bottom: 2rem;
  }

  .remember-me {
    display: flex;
    align-items: center;
    gap: 0.4rem;
    color: #64748b;
    cursor: pointer;
    font-weight: 500;
  }

  .remember-me input {
    cursor: pointer;
    accent-color: #10b981;
  }

  .forgot-link {
    color: #64748b;
    text-decoration: none;
    font-weight: 500;
    transition: color 0.2s ease;
  }

  .forgot-link:hover {
    color: #10b981;
  }

  /* Button with Project Gradient (Slate to Emerald) */
  .btn-gradient {
    width: 100%;
    padding: 0.95rem;
    border: none;
    border-radius: 50px;
    font-size: 0.95rem;
    font-weight: 700;
    color: #ffffff;
    background: linear-gradient(135deg, #1e293b 0%, #10b981 100%);
    cursor: pointer;
    box-shadow: 0 4px 15px rgba(16, 185, 129, 0.2);
    transition: all 0.25s ease;
    margin: 0px !important;
  }

  .btn-gradient:hover {
    box-shadow: 0 6px 20px rgba(16, 185, 129, 0.35);
    transform: translateY(-1px);
    background: linear-gradient(135deg, #334155 0%, #0ea271 100%);
  }

  .btn-gradient:active {
    transform: translateY(1px);
    box-shadow: 0 3px 10px rgba(16, 185, 129, 0.15);
  }

  /* Register link under button */
  .register-footer {
    text-align: center;
    margin-top: 2rem;
    font-size: 0.85rem;
    color: #64748b;
  }

  .register-footer a {
    color: #10b981;
    text-decoration: none;
    font-weight: 600;
    transition: color 0.2s ease;
  }

  .register-footer a:hover {
    color: #1e293b;
    text-decoration: underline;
  }

  /* Errors and alerts */
  .login-error-alert {
    display: flex;
    align-items: center;
    gap: 0.65rem;
    background-color: #fff5f5;
    border: 1px solid rgba(229, 62, 62, 0.12);
    border-left: 3px solid #e53e3e;
    border-radius: 6px;
    padding: 0.6rem 0.85rem;
    color: #9b2c2c;
    font-size: 0.82rem;
    line-height: 1.35;
    margin-top: 1rem;
    margin-bottom: 0.25rem;
    text-align: left;
    font-weight: 500;
    box-shadow: 0 2px 5px rgba(229, 62, 62, 0.03);
    animation: slideInAlert 0.35s cubic-bezier(0.16, 1, 0.3, 1);
  }

  @keyframes slideInAlert {
    from {
      opacity: 0;
      transform: translateY(-4px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .login-error-alert i {
    font-size: 1rem;
    color: #e53e3e;
    flex-shrink: 0;
  }

  .field-error-msg {
    display: flex;
    align-items: center;
    gap: 0.4rem;
    color: #b91c1c;
    font-size: 0.8rem;
    margin-top: 0.4rem;
    padding-left: 1rem;
    font-weight: 500;
  }

  .field-error-msg i {
    font-size: 0.85rem;
    flex-shrink: 0;
  }
</style>

<div class="login-split-container">
  
  <!-- Left Side: Visual/Welcome -->
  <div class="login-visual-panel">
    <div class="visual-blob-1"></div>
    <div class="visual-blob-2"></div>
    <div class="visual-blob-3"></div>
    <div class="striped-circle"></div>

    <div class="visual-logo-mark">
      <div class="logo-triangles">
        <div class="tri tri-1"></div>
        <div class="tri tri-2"></div>
        <div class="tri tri-3"></div>
      </div>
      <span>Sistema de Inventario</span>
    </div>

    <div class="visual-content">
      <h1>¡Bienvenido de nuevo!</h1>
      <p>Inicia sesión para acceder a tu cuenta y gestionar tu inventario en tiempo real.</p>
    </div>

    <div class="visual-footer">
      Todo los Derechos Reservados 2026 &copy; Sistema de Inventario
    </div>
  </div>

  <!-- Right Side: Login Form -->
  <div class="login-form-panel">
    <div class="form-container">
      
      <!-- Mobile Logo Mark -->
      <div class="mobile-logo-mark">
        <div class="logo-triangles">
          <div class="tri tri-1"></div>
          <div class="tri tri-2"></div>
          <div class="tri tri-3"></div>
        </div>
        <span>Sistema de Inventario</span>
      </div>
      
      <h2>Iniciar Sesión</h2>

      <form method="post" action="index.php?page=sec_login{{if redirto}}&redirto={{redirto}}{{endif redirto}}">
        
        <div class="form-group">
          <div class="input-pill-wrapper">
            <input type="email" id="txtEmail" name="txtEmail" placeholder="Correo Electrónico" value="{{txtEmail}}" required />
            <i class="fas fa-envelope"></i>
          </div>
          {{if errorEmail}}
            <div class="field-error-msg">
              <i class="fas fa-exclamation-circle"></i> <span>{{errorEmail}}</span>
            </div>
          {{endif errorEmail}}
        </div>

        <div class="form-group">
          <div class="input-pill-wrapper">
            <input type="password" id="txtPswd" name="txtPswd" placeholder="Contraseña" value="{{txtPswd}}" required />
            <i class="fas fa-lock"></i>
          </div>
          {{if errorPswd}}
            <div class="field-error-msg">
              <i class="fas fa-exclamation-circle"></i> <span>{{errorPswd}}</span>
            </div>
          {{endif errorPswd}}
        </div>

        {{if generalError}}
          <div class="login-error-alert">
            <i class="fas fa-exclamation-circle"></i>
            <span>{{generalError}}</span>
          </div>
        {{endif generalError}}

        <button class="btn-gradient" id="btnLogin" type="submit" style="margin-top: 1.25rem !important;">Iniciar Sesión</button>

      </form>
    </div>
  </div>

</div>
