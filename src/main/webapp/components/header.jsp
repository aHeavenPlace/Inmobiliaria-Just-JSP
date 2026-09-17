<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    /* =================================================================
       header.jsp — Navbar + CSS Completo del Sistema (Vesta Design)
       Compatible con Tomcat 8.5 / JSP 2.3 / Bootstrap 5 via CDN
       ================================================================= */
    String contextPath = request.getContextPath();
    String rolSesion   = (String) session.getAttribute("rolActivo");
    String nombreSesion = (String) session.getAttribute("nombreUsuario");
    String paginaActual = request.getRequestURI();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Vesta Inmobiliaria — Encuentra tu hogar ideal en Bucaramanga y el área metropolitana. Compra, vende y alquila propiedades con los mejores asesores.">
    <title>Vesta Inmobiliaria</title>

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Bootstrap 5 CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

    <style>
        /* ========================================================
           VESTA DESIGN SYSTEM — CSS Variables (Warm Charcoal Palette)
           ======================================================== */
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');

        :root {
            --color-primary:        #1A1A1A;
            --color-primary-light:  #2D2D2D;
            --color-primary-dark:   #0D0D0D;
            --color-accent:         #C4796B;
            --color-accent-hover:   #A86559;
            --color-accent-light:   #F5E6E4;
            --color-accent-glow:    rgba(196, 121, 107, 0.25);
            --color-gold:           #B8956B;
            --color-gold-light:     #F9F4EC;
            --bg-body:              #FAF9F7;
            --bg-surface:           #FFFFFF;
            --bg-surface-elevated:  #FFFFFF;
            --bg-surface-subtle:    #F5F3F0;
            --bg-surface-glass:     rgba(255, 255, 255, 0.88);
            --border-subtle:        #E8E4DF;
            --border-medium:        #D4CFC8;
            --border-focus:         var(--color-accent);
            --font-family:          'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            --text-main:            #1A1A1A;
            --text-muted:           #6B665F;
            --text-light:           #9C968F;
            --text-inverse:         #FFFFFF;
            --status-success:       #5B8C6D;
            --status-success-bg:    #EDF5EF;
            --status-warning:       #C9A962;
            --status-warning-bg:    #FBF8ED;
            --status-danger:        #C4796B;
            --status-danger-bg:     #F5E6E4;
            --status-info:          #6B8C9E;
            --status-info-bg:       #EEF4F7;
            --shadow-xs:  0 1px 2px 0 rgba(26, 26, 26, 0.04);
            --shadow-sm:  0 1px 3px 0 rgba(26, 26, 26, 0.06), 0 1px 2px -1px rgba(26, 26, 26, 0.06);
            --shadow-md:  0 4px 6px -1px rgba(26, 26, 26, 0.05), 0 2px 4px -2px rgba(26, 26, 26, 0.05);
            --shadow-lg:  0 10px 15px -3px rgba(26, 26, 26, 0.06), 0 4px 6px -4px rgba(26, 26, 26, 0.03);
            --shadow-xl:  0 20px 25px -5px rgba(26, 26, 26, 0.07), 0 8px 10px -6px rgba(26, 26, 26, 0.03);
            --shadow-card-hover: 0 16px 32px -8px rgba(26, 26, 26, 0.08), 0 6px 12px -4px rgba(26, 26, 26, 0.04);
            --radius-sm:  8px;
            --radius-md:  12px;
            --radius-lg:  18px;
            --radius-xl:  28px;
            --radius-full: 9999px;
            --transition-fast:   150ms cubic-bezier(0.4, 0, 0.2, 1);
            --transition-normal: 250ms cubic-bezier(0.4, 0, 0.2, 1);
            --transition-slow:   350ms cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* ======================== RESET & GLOBAL ======================== */
        *, *::before, *::after { box-sizing: border-box; }
        body {
            font-family: var(--font-family);
            background-color: var(--bg-body);
            color: var(--text-main);
            line-height: 1.65;
            margin: 0; padding: 0;
            -webkit-font-smoothing: antialiased;
        }
        a { color: var(--color-accent); text-decoration: none; transition: color var(--transition-fast); }
        a:hover { color: var(--color-accent-hover); }

        /* ======================== NAVBAR ======================== */
        .navbar-glass {
            position: sticky; top: 0; z-index: 1030;
            background: rgba(255, 255, 255, 0.92);
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border-bottom: 1px solid rgba(232, 228, 223, 0.6);
            transition: all var(--transition-normal);
            box-shadow: 0 1px 3px rgba(26, 26, 26, 0.04);
        }
        .navbar-brand {
            font-weight: 700; font-size: 1.4rem;
            color: var(--color-primary) !important;
            letter-spacing: -0.3px;
            display: flex; align-items: center; gap: 10px;
        }
        .brand-badge {
            background: linear-gradient(135deg, var(--color-accent), var(--color-gold));
            color: white; padding: 3px 10px; border-radius: var(--radius-full);
            font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 1px;
        }
        .nav-link-vesta {
            font-weight: 500; color: var(--text-muted) !important;
            padding: 10px 18px !important; border-radius: var(--radius-md);
            transition: all var(--transition-fast); font-size: 0.95rem;
        }
        .nav-link-vesta:hover, .nav-link-vesta.active {
            color: var(--color-primary) !important;
            background-color: var(--bg-surface-subtle);
        }

        /* ======================== BUTTONS ======================== */
        .btn-vesta-primary {
            background: linear-gradient(135deg, var(--color-accent), #B8956B);
            color: #FFFFFF !important; border: none; font-weight: 600;
            padding: 12px 26px; border-radius: var(--radius-md);
            transition: all var(--transition-normal);
            box-shadow: 0 4px 14px var(--color-accent-glow);
            display: inline-flex; align-items: center; gap: 10px; font-size: 0.95rem;
        }
        .btn-vesta-primary:hover { filter: brightness(1.05); transform: translateY(-2px); box-shadow: 0 6px 20px rgba(196,121,107,0.35); }
        .btn-vesta-accent {
            background: linear-gradient(135deg, var(--color-accent), #B8956B);
            color: #FFFFFF !important; border: none; font-weight: 600;
            padding: 12px 26px; border-radius: var(--radius-md);
            transition: all var(--transition-normal);
            box-shadow: 0 4px 14px var(--color-accent-glow);
            display: inline-flex; align-items: center; gap: 10px; font-size: 0.95rem;
        }
        .btn-vesta-accent:hover { filter: brightness(1.05); transform: translateY(-2px); box-shadow: 0 6px 20px rgba(196,121,107,0.35); }
        .btn-vesta-outline {
            background-color: transparent; color: var(--color-primary) !important;
            border: 1px solid var(--border-medium); font-weight: 600;
            padding: 11px 24px; border-radius: var(--radius-md);
            transition: all var(--transition-fast); font-size: 0.95rem;
        }
        .btn-vesta-outline:hover { border-color: var(--color-primary); background-color: var(--bg-surface-subtle); transform: translateY(-1px); }
        .btn-outline-vesta {
            background-color: transparent; color: var(--text-muted) !important;
            border: 1px solid var(--border-medium); font-weight: 500;
            padding: 8px 14px; border-radius: var(--radius-md);
            transition: all var(--transition-fast); font-size: 0.85rem;
        }
        .btn-outline-vesta:hover { border-color: var(--color-accent); background-color: var(--color-accent-light); color: var(--color-accent) !important; }

        /* ======================== HERO ======================== */
        .hero-section {
            position: relative; padding: 120px 0 160px 0;
            background: linear-gradient(135deg, rgba(26,26,26,0.85), rgba(26,26,26,0.75)),
                        url('https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1920') center/cover no-repeat;
            color: white; text-align: center;
        }
        .hero-section::before {
            content: ''; position: absolute; inset: 0;
            background: radial-gradient(circle at 50% 30%, rgba(196,121,107,0.15), transparent 60%);
            pointer-events: none;
        }
        .hero-title { font-size: 3.5rem; font-weight: 700; letter-spacing: -1.2px; line-height: 1.15; margin-bottom: 24px; text-shadow: 0 2px 20px rgba(0,0,0,0.3); }
        .hero-subtitle { font-size: 1.25rem; color: rgba(255,255,255,0.9); max-width: 680px; margin: 0 auto 40px auto; font-weight: 300; line-height: 1.7; }

        /* ======================== SEARCH CARD ======================== */
        .search-card-float {
            background: var(--bg-surface); border-radius: var(--radius-xl);
            box-shadow: var(--shadow-xl); padding: 32px;
            border: 1px solid rgba(232,228,223,0.8);
            margin-top: -70px; position: relative; z-index: 20;
        }
        .form-label-vesta {
            font-size: 0.75rem; text-transform: uppercase; font-weight: 700;
            letter-spacing: 0.8px; color: var(--text-muted); margin-bottom: 8px; display: block;
        }
        .form-control-vesta, .form-select-vesta {
            width: 100%; padding: 14px 18px; border-radius: var(--radius-md);
            border: 1px solid var(--border-subtle); background-color: var(--bg-surface-subtle);
            color: var(--text-main); font-weight: 500; font-size: 0.95rem;
            transition: all var(--transition-fast);
        }
        .form-control-vesta:focus, .form-select-vesta:focus {
            outline: none; border-color: var(--color-accent);
            background-color: var(--bg-surface); box-shadow: 0 0 0 4px var(--color-accent-light);
        }

        /* ======================== PROPERTY CARDS ======================== */
        .property-card {
            background: var(--bg-surface); border-radius: var(--radius-lg);
            overflow: hidden; border: 1px solid var(--border-subtle);
            box-shadow: var(--shadow-sm); transition: all var(--transition-normal);
            display: flex; flex-direction: column; height: 100%; position: relative;
        }
        .property-card:hover { transform: translateY(-8px); box-shadow: var(--shadow-card-hover); border-color: var(--border-medium); }
        .property-thumb-wrap { position: relative; height: 240px; overflow: hidden; background-color: #E8E4DF; }
        .property-thumb { width: 100%; height: 100%; object-fit: cover; transition: transform var(--transition-slow); }
        .property-card:hover .property-thumb { transform: scale(1.08); }
        .badge-operation { position: absolute; top: 16px; left: 16px; background: rgba(26,26,26,0.9); backdrop-filter: blur(10px); color: white; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; padding: 5px 12px; border-radius: var(--radius-full); }
        .badge-type { position: absolute; top: 16px; right: 60px; background: rgba(196,121,107,0.95); backdrop-filter: blur(10px); color: white; font-size: 0.7rem; font-weight: 600; padding: 5px 12px; border-radius: var(--radius-full); }
        .btn-favorite-heart { position: absolute; top: 14px; right: 14px; width: 40px; height: 40px; border-radius: var(--radius-full); background: rgba(255,255,255,0.95); backdrop-filter: blur(8px); border: none; display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--text-muted); font-size: 1.15rem; transition: all var(--transition-fast); box-shadow: var(--shadow-sm); }
        .btn-favorite-heart:hover { transform: scale(1.15); color: var(--status-danger); box-shadow: var(--shadow-md); }
        .btn-favorite-heart.is-favorite { color: var(--status-danger); }
        .property-body { padding: 22px; display: flex; flex-direction: column; flex-grow: 1; }
        .property-price { font-size: 1.5rem; font-weight: 700; color: var(--color-primary); letter-spacing: -0.5px; margin-bottom: 8px; }
        .property-title { font-size: 1.05rem; font-weight: 600; color: var(--text-main); line-height: 1.4; margin-bottom: 10px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .property-location { font-size: 0.88rem; color: var(--text-muted); display: flex; align-items: center; gap: 6px; margin-bottom: 18px; }
        .property-features { display: flex; align-items: center; gap: 18px; padding-top: 16px; margin-top: auto; border-top: 1px solid var(--border-subtle); font-size: 0.85rem; color: var(--text-muted); }
        .feature-item { display: flex; align-items: center; gap: 6px; }

        /* ======================== DASHBOARD ======================== */
        .dashboard-wrapper { display: flex; min-height: calc(100vh - 72px); }
        .dashboard-sidebar { width: 270px; background: var(--bg-surface); border-right: 1px solid var(--border-subtle); padding: 28px 18px; display: flex; flex-direction: column; flex-shrink: 0; }
        .sidebar-user { padding-bottom: 22px; margin-bottom: 22px; border-bottom: 1px solid var(--border-subtle); display: flex; align-items: center; gap: 14px; }
        .sidebar-avatar { width: 48px; height: 48px; border-radius: var(--radius-full); object-fit: cover; border: 2px solid var(--color-accent); }
        .sidebar-nav { display: flex; flex-direction: column; gap: 6px; flex-grow: 1; }
        .sidebar-link { display: flex; align-items: center; gap: 12px; padding: 12px 18px; border-radius: var(--radius-md); color: var(--text-muted); font-weight: 600; font-size: 0.93rem; transition: all var(--transition-fast); }
        .sidebar-link:hover, .sidebar-link.active { background-color: var(--color-accent-light); color: var(--color-accent) !important; }
        .sidebar-link i { font-size: 1.15rem; }
        .dashboard-content { flex-grow: 1; background-color: var(--bg-body); padding: 36px; overflow-y: auto; }

        /* ======================== STAT CARDS ======================== */
        .stat-card { background: var(--bg-surface); border-radius: var(--radius-lg); padding: 26px; border: 1px solid var(--border-subtle); box-shadow: var(--shadow-sm); display: flex; align-items: center; justify-content: space-between; transition: transform var(--transition-normal); }
        .stat-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-md); }
        .stat-number { font-size: 2.2rem; font-weight: 700; color: var(--color-primary); line-height: 1; margin: 10px 0 6px 0; }
        .stat-icon-wrap { width: 60px; height: 60px; border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; font-size: 1.6rem; }
        .stat-icon-blue   { background-color: #EEF4F7; color: #6B8C9E; }
        .stat-icon-green  { background-color: #EDF5EF; color: #5B8C6D; }
        .stat-icon-amber  { background-color: #FBF8ED; color: #C9A962; }
        .stat-icon-purple { background-color: #F5F0EB; color: #B8956B; }

        /* ======================== TABLES ======================== */
        .table-vesta { width: 100%; border-collapse: separate; border-spacing: 0; background: var(--bg-surface); border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-sm); border: 1px solid var(--border-subtle); }
        .table-vesta th { background-color: var(--bg-surface-subtle); color: var(--text-muted); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.8px; font-weight: 700; padding: 16px 20px; border-bottom: 1px solid var(--border-subtle); }
        .table-vesta td { padding: 18px 20px; vertical-align: middle; border-bottom: 1px solid var(--border-subtle); font-size: 0.93rem; }
        .table-vesta tr:last-child td { border-bottom: none; }
        .table-vesta tr:hover td { background-color: var(--bg-surface-subtle); }
        .badge-vesta { display: inline-flex; align-items: center; gap: 5px; padding: 5px 12px; border-radius: var(--radius-full); font-size: 0.73rem; font-weight: 700; text-transform: capitalize; }
        .badge-vesta-success { background-color: var(--status-success-bg); color: var(--status-success); }
        .badge-vesta-warning { background-color: var(--status-warning-bg); color: var(--status-warning); }
        .badge-vesta-danger  { background-color: var(--status-danger-bg);  color: var(--status-danger);  }
        .badge-vesta-info    { background-color: var(--status-info-bg);    color: var(--status-info);    }

        /* ======================== AUTH ======================== */
        .auth-page-wrapper { min-height: calc(100vh - 72px); background: linear-gradient(135deg, var(--bg-body) 0%, var(--bg-surface-subtle) 100%); display: flex; align-items: center; padding: 40px 0; }
        .auth-card { background: var(--bg-surface-glass); backdrop-filter: blur(20px) saturate(180%); -webkit-backdrop-filter: blur(20px) saturate(180%); border: 1px solid rgba(255,255,255,0.6); box-shadow: var(--shadow-xl); }
        .vesta-logo-small { display: inline-flex; align-items: center; justify-content: center; width: 70px; height: 70px; border-radius: var(--radius-lg); background: linear-gradient(135deg, var(--color-accent), var(--color-gold)); box-shadow: 0 8px 20px rgba(196,121,107,0.3); }
        .logo-icon { font-size: 2rem; }
        .input-group-vsta { display: flex; align-items: stretch; border-radius: var(--radius-md); overflow: hidden; border: 1px solid var(--border-subtle); transition: all var(--transition-fast); background-color: var(--bg-surface); }
        .input-group-vsta:focus-within { border-color: var(--color-accent); box-shadow: 0 0 0 4px var(--color-accent-light); }
        .input-icon { display: flex; align-items: center; justify-content: center; padding: 0 16px; background-color: var(--bg-surface-subtle); border-right: 1px solid var(--border-subtle); color: var(--text-muted); font-size: 1rem; transition: all var(--transition-fast); }
        .input-group-vsta:focus-within .input-icon { color: var(--color-accent); background-color: var(--color-accent-light); }
        .alert-danger-vsta { background-color: var(--status-danger-bg); color: var(--status-danger); border: 1px solid rgba(196,121,107,0.2); border-radius: var(--radius-md); padding: 12px 16px; font-weight: 500; font-size: 0.9rem; }
        .alert-success-vsta { background-color: var(--status-success-bg); color: var(--status-success); border: 1px solid rgba(91,140,109,0.2); border-radius: var(--radius-md); padding: 12px 16px; font-weight: 500; font-size: 0.9rem; }

        /* ======================== FOOTER ======================== */
        .footer-vesta { background-color: var(--color-primary); color: #9C968F; padding: 70px 0 28px 0; margin-top: 80px; }
        .footer-vesta h5 { color: #FFFFFF; font-weight: 600; margin-bottom: 20px; font-size: 1rem; }
        .footer-vesta a { color: #9C968F; transition: color var(--transition-fast); }
        .footer-vesta a:hover { color: #FFFFFF; }

        /* ======================== MISC UTILITIES ======================== */
        .glass-effect { background: rgba(255,255,255,0.85); backdrop-filter: blur(20px) saturate(180%); -webkit-backdrop-filter: blur(20px) saturate(180%); }
        .text-vesta-charcoal { color: var(--color-primary); }
        .text-vesta-gray { color: var(--text-muted); }
        .text-vesta-accent { color: var(--color-accent); }
        .text-charcoal { color: var(--color-primary) !important; }
        .text-terracotta-muted { color: #A67C6B !important; }
        .vesta-badge { background: linear-gradient(135deg, rgba(196,121,107,0.1), rgba(184,149,107,0.1)); color: var(--color-accent) !important; border: 1px solid rgba(196,121,107,0.2); font-weight: 600; }
        .vesta-header-section { background-color: var(--bg-surface-subtle); border-radius: var(--radius-lg); padding: 40px 30px; border: 1px solid var(--border-subtle); }
        .quick-access-panel { background-color: var(--bg-surface-subtle); border-color: var(--border-subtle) !important; }

        /* ======================== RESPONSIVE ======================== */
        @media (max-width: 991px) {
            .hero-title { font-size: 2.4rem; }
            .dashboard-wrapper { flex-direction: column; }
            .dashboard-sidebar { width: 100%; border-right: none; border-bottom: 1px solid var(--border-subtle); }
            .search-card-float { margin-top: -40px; padding: 24px; }
        }
    </style>
</head>
<body>

<!-- ========== NAVBAR ========== -->
<nav class="navbar-glass py-2" id="main-navbar">
    <div class="container d-flex align-items-center justify-content-between flex-wrap gap-2">

        <!-- Brand -->
        <a href="<%= contextPath %>/index.jsp" class="navbar-brand">
            <span class="brand-badge">VESTA</span>
            Inmobiliaria
        </a>

        <!-- Nav Links públicos -->
        <div class="d-flex align-items-center gap-1 flex-wrap">
            <a href="<%= contextPath %>/index.jsp"
               class="nav-link-vesta <%= paginaActual.endsWith("index.jsp") ? "active" : "" %>">
                <i class="bi bi-house me-1"></i>Inicio
            </a>
            <a href="<%= contextPath %>/catalogo.jsp"
               class="nav-link-vesta <%= paginaActual.contains("catalogo") ? "active" : "" %>">
                <i class="bi bi-grid me-1"></i>Catálogo
            </a>

            <% if (rolSesion == null) { %>
                <!-- Usuario no autenticado -->
                <a href="<%= contextPath %>/login.jsp" class="btn-vesta-outline ms-2" style="padding:9px 20px; border-radius:var(--radius-md);">
                    <i class="bi bi-box-arrow-in-right me-1"></i>Iniciar sesión
                </a>
                <a href="<%= contextPath %>/registro.jsp" class="btn-vesta-accent ms-2" style="padding:9px 20px; border-radius:var(--radius-md);">
                    <i class="bi bi-person-plus me-1"></i>Registrarse
                </a>
            <% } else if ("admin".equals(rolSesion)) { %>
                <a href="<%= contextPath %>/admin/dashboard.jsp" class="nav-link-vesta <%= paginaActual.contains("/admin/") ? "active" : "" %>">
                    <i class="bi bi-shield-check me-1"></i>Admin
                </a>
                <a href="<%= contextPath %>/logout.jsp" class="btn-vesta-outline ms-2" style="padding:9px 20px; border-radius:var(--radius-md);">
                    <i class="bi bi-box-arrow-right me-1"></i><%= nombreSesion != null ? nombreSesion : "Salir" %>
                </a>
            <% } else if ("inmobiliaria".equals(rolSesion)) { %>
                <a href="<%= contextPath %>/inmobiliaria/dashboard.jsp" class="nav-link-vesta <%= paginaActual.contains("/inmobiliaria/") ? "active" : "" %>">
                    <i class="bi bi-building me-1"></i>Mi Panel
                </a>
                <a href="<%= contextPath %>/logout.jsp" class="btn-vesta-outline ms-2" style="padding:9px 20px; border-radius:var(--radius-md);">
                    <i class="bi bi-box-arrow-right me-1"></i><%= nombreSesion != null ? nombreSesion : "Salir" %>
                </a>
            <% } else if ("cliente".equals(rolSesion)) { %>
                <a href="<%= contextPath %>/cliente/dashboard.jsp" class="nav-link-vesta <%= paginaActual.contains("/cliente/") ? "active" : "" %>">
                    <i class="bi bi-person me-1"></i>Mi Cuenta
                </a>
                <a href="<%= contextPath %>/logout.jsp" class="btn-vesta-outline ms-2" style="padding:9px 20px; border-radius:var(--radius-md);">
                    <i class="bi bi-box-arrow-right me-1"></i><%= nombreSesion != null ? nombreSesion : "Salir" %>
                </a>
            <% } %>
        </div>
    </div>
</nav>
