<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String nombreAdmin  = (String) session.getAttribute("nombreUsuario");
    String correoAdmin  = (String) session.getAttribute("correoUsuario");
    String uriAdmin     = request.getRequestURI();
    String ctxAdmin     = request.getContextPath();
    String inicialAdmin = (nombreAdmin != null && !nombreAdmin.isEmpty())
                        ? String.valueOf(nombreAdmin.charAt(0)).toUpperCase() : "A";
%>
<div class="dashboard-sidebar">
    <div class="sidebar-user">
        <div class="sidebar-avatar d-flex align-items-center justify-content-center fw-bold"
             style="background:linear-gradient(135deg,#C4796B,#B8956B);color:#fff;font-size:1.3rem;">
            <%= inicialAdmin %>
        </div>
        <div class="overflow-hidden">
            <h6 class="fw-bold mb-0 text-truncate"><%= nombreAdmin != null ? nombreAdmin : "Administrador" %></h6>
            <small class="text-muted d-block text-truncate"><%= correoAdmin != null ? correoAdmin : "" %></small>
            <span class="badge small mt-1" style="background:rgba(196,121,107,0.1);color:#C4796B;padding:3px 8px;border-radius:99px;">Admin Global</span>
        </div>
    </div>

    <div class="sidebar-nav">
        <a href="<%= ctxAdmin %>/admin/dashboard.jsp"
           class="sidebar-link <%= uriAdmin.contains("/admin/dashboard") ? "active" : "" %>">
            <i class="bi bi-speedometer2"></i><span>Dashboard Global</span>
        </a>
        <a href="<%= ctxAdmin %>/admin/usuarios.jsp"
           class="sidebar-link <%= uriAdmin.contains("/admin/usuarios") ? "active" : "" %>">
            <i class="bi bi-people"></i><span>Usuarios &amp; Roles</span>
        </a>
        <a href="<%= ctxAdmin %>/admin/propiedades.jsp"
           class="sidebar-link <%= uriAdmin.contains("/admin/propiedad") ? "active" : "" %>">
            <i class="bi bi-houses"></i><span>Inmuebles &amp; Catálogo</span>
        </a>
        <a href="<%= ctxAdmin %>/admin/catalogos.jsp"
           class="sidebar-link <%= uriAdmin.contains("/admin/catalogos") ? "active" : "" %>">
            <i class="bi bi-sliders"></i><span>Parametrización</span>
        </a>
        <a href="<%= ctxAdmin %>/cliente/perfil.jsp"
           class="sidebar-link <%= uriAdmin.contains("/cliente/perfil") ? "active" : "" %>">
            <i class="bi bi-person-gear"></i><span>Mi Perfil</span>
        </a>
        <hr class="my-2 text-muted opacity-25">
        <a href="<%= ctxAdmin %>/catalogo.jsp" class="sidebar-link">
            <i class="bi bi-eye"></i><span>Portal Público</span>
        </a>
        <a href="<%= ctxAdmin %>/logout.jsp" class="sidebar-link" style="color:#C4796B !important;">
            <i class="bi bi-box-arrow-right"></i><span>Cerrar Sesión</span>
        </a>
    </div>
</div>
