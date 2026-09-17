<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String nombreInmob  = (String) session.getAttribute("nombreUsuario");
    String correoInmob  = (String) session.getAttribute("correoUsuario");
    String uriInmob     = request.getRequestURI();
    String ctxInmob     = request.getContextPath();
    String inicialInmob = (nombreInmob != null && !nombreInmob.isEmpty())
                        ? String.valueOf(nombreInmob.charAt(0)).toUpperCase() : "I";
%>
<div class="dashboard-sidebar">
    <div class="sidebar-user">
        <div class="sidebar-avatar d-flex align-items-center justify-content-center fw-bold"
             style="background:linear-gradient(135deg,#6B8C9E,#C9A962);color:#fff;font-size:1.3rem;">
            <%= inicialInmob %>
        </div>
        <div class="overflow-hidden">
            <h6 class="fw-bold mb-0 text-truncate"><%= nombreInmob != null ? nombreInmob : "Agente" %></h6>
            <small class="text-muted d-block text-truncate"><%= correoInmob != null ? correoInmob : "" %></small>
            <span class="badge small mt-1" style="background:rgba(107,140,158,0.1);color:#6B8C9E;padding:3px 8px;border-radius:99px;">Agente Inmobiliario</span>
        </div>
    </div>

    <div class="sidebar-nav">
        <a href="<%= ctxInmob %>/inmobiliaria/dashboard.jsp"
           class="sidebar-link <%= uriInmob.contains("/inmobiliaria/dashboard") ? "active" : "" %>">
            <i class="bi bi-speedometer2"></i><span>Dashboard</span>
        </a>
        <a href="<%= ctxInmob %>/inmobiliaria/propiedades.jsp"
           class="sidebar-link <%= uriInmob.contains("/inmobiliaria/propiedad") ? "active" : "" %>">
            <i class="bi bi-houses"></i><span>Mis Propiedades</span>
        </a>
        <a href="<%= ctxInmob %>/inmobiliaria/propiedad_form.jsp"
           class="sidebar-link">
            <i class="bi bi-plus-circle"></i><span>Publicar Inmueble</span>
        </a>
        <a href="<%= ctxInmob %>/inmobiliaria/citas.jsp"
           class="sidebar-link <%= uriInmob.contains("/inmobiliaria/citas") ? "active" : "" %>">
            <i class="bi bi-calendar-event"></i><span>Gestión de Citas</span>
        </a>
        <a href="<%= ctxInmob %>/inmobiliaria/reportes.jsp"
           class="sidebar-link <%= uriInmob.contains("/inmobiliaria/reportes") ? "active" : "" %>">
            <i class="bi bi-graph-up-arrow"></i><span>Reportes &amp; Métricas</span>
        </a>
        <a href="<%= ctxInmob %>/cliente/perfil.jsp"
           class="sidebar-link <%= uriInmob.contains("/cliente/perfil") ? "active" : "" %>">
            <i class="bi bi-person-gear"></i><span>Mi Perfil</span>
        </a>
        <hr class="my-2 text-muted opacity-25">
        <a href="<%= ctxInmob %>/catalogo.jsp" class="sidebar-link">
            <i class="bi bi-eye"></i><span>Ver Portal Público</span>
        </a>
        <a href="<%= ctxInmob %>/logout.jsp" class="sidebar-link" style="color:#C4796B !important;">
            <i class="bi bi-box-arrow-right"></i><span>Cerrar Sesión</span>
        </a>
    </div>
</div>
