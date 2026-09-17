<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String nombreCliente  = (String) session.getAttribute("nombreUsuario");
    String correoCliente  = (String) session.getAttribute("correoUsuario");
    String uriCliente     = request.getRequestURI();
    String ctxCliente     = request.getContextPath();
    String inicialCliente = (nombreCliente != null && !nombreCliente.isEmpty())
                          ? String.valueOf(nombreCliente.charAt(0)).toUpperCase() : "C";
%>
<div class="dashboard-sidebar">
    <div class="sidebar-user">
        <div class="sidebar-avatar d-flex align-items-center justify-content-center fw-bold"
             style="background:linear-gradient(135deg,#5B8C6D,#6B8C9E);color:#fff;font-size:1.3rem;">
            <%= inicialCliente %>
        </div>
        <div class="overflow-hidden">
            <h6 class="fw-bold mb-0 text-truncate"><%= nombreCliente != null ? nombreCliente : "Cliente" %></h6>
            <small class="text-muted d-block text-truncate"><%= correoCliente != null ? correoCliente : "" %></small>
            <span class="badge small mt-1" style="background:rgba(91,140,109,0.1);color:#5B8C6D;padding:3px 8px;border-radius:99px;">Cliente</span>
        </div>
    </div>

    <div class="sidebar-nav">
        <a href="<%= ctxCliente %>/cliente/dashboard.jsp"
           class="sidebar-link <%= uriCliente.contains("/cliente/dashboard") ? "active" : "" %>">
            <i class="bi bi-speedometer2"></i><span>Resumen</span>
        </a>
        <a href="<%= ctxCliente %>/cliente/favoritos.jsp"
           class="sidebar-link <%= uriCliente.contains("/cliente/favoritos") ? "active" : "" %>">
            <i class="bi bi-heart"></i><span>Mis Favoritos</span>
        </a>
        <a href="<%= ctxCliente %>/cliente/citas.jsp"
           class="sidebar-link <%= uriCliente.contains("/cliente/citas") ? "active" : "" %>">
            <i class="bi bi-calendar-check"></i><span>Mis Citas</span>
        </a>
        <a href="<%= ctxCliente %>/cliente/perfil.jsp"
           class="sidebar-link <%= uriCliente.contains("/cliente/perfil") ? "active" : "" %>">
            <i class="bi bi-person-gear"></i><span>Mi Perfil</span>
        </a>
        <hr class="my-2 text-muted opacity-25">
        <a href="<%= ctxCliente %>/catalogo.jsp" class="sidebar-link">
            <i class="bi bi-search"></i><span>Explorar Inmuebles</span>
        </a>
        <a href="<%= ctxCliente %>/logout.jsp" class="sidebar-link" style="color:#C4796B !important;">
            <i class="bi bi-box-arrow-right"></i><span>Cerrar Sesión</span>
        </a>
    </div>
</div>
