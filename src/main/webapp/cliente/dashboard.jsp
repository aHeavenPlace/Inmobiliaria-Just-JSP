<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*" %>
<%-- =====================================================================
     cliente/dashboard.jsp — Panel del Cliente (JSP Modelo 1)
     ===================================================================== --%>
<%@ include file="/components/conexion.jsp" %>
<%
    /* === Verificación de sesión y rol === */
    String rolDash = (String) session.getAttribute("rolActivo");
    if (rolDash == null) { response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=/cliente/dashboard.jsp"); return; }
    if (!"cliente".equals(rolDash) && !"admin".equals(rolDash) && !"inmobiliaria".equals(rolDash)) {
        response.sendRedirect(request.getContextPath() + "/error_403.jsp"); return;
    }
    String ctx = request.getContextPath();
    Object idUsrObj = session.getAttribute("idUsuario");

    int totalFavoritos = 0; int citasPendientes = 0; int citasRealizadas = 0;

    if (idUsrObj != null) {
        int idUsr = (Integer) idUsrObj;
        try (Connection conn = getConn()) {
            ResultSet rsF = conn.prepareStatement("SELECT COUNT(*) FROM favorito WHERE id_usuario=" + idUsr).executeQuery();
            if (rsF.next()) totalFavoritos = rsF.getInt(1);
            ResultSet rsCp = conn.prepareStatement("SELECT COUNT(*) FROM cita WHERE id_cliente=" + idUsr + " AND estado='pendiente'").executeQuery();
            if (rsCp.next()) citasPendientes = rsCp.getInt(1);
            ResultSet rsCr = conn.prepareStatement("SELECT COUNT(*) FROM cita WHERE id_cliente=" + idUsr + " AND estado='realizada'").executeQuery();
            if (rsCr.next()) citasRealizadas = rsCr.getInt(1);
        } catch (SQLException ex) { ex.printStackTrace(); }
    }
%>
<%@ include file="/components/header.jsp" %>

<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_cliente.jsp" %>
    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-vesta-charcoal mb-1">¡Hola, <%= (String) session.getAttribute("nombreUsuario") %>!</h2>
                <p class="text-vesta-gray mb-0">Aquí tienes un resumen de tu actividad en Vesta</p>
            </div>
            <a href="<%= ctx %>/catalogo.jsp" class="btn btn-vesta-accent">
                <i class="bi bi-search me-1"></i> Explorar Inmuebles
            </a>
        </div>

        <!-- Stat Cards -->
        <div class="row g-3 mb-5">
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;letter-spacing:0.5px;">Favoritos</div>
                        <div class="stat-number"><%= totalFavoritos %></div>
                        <small class="text-muted">Propiedades guardadas</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-blue"><i class="bi bi-heart"></i></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;letter-spacing:0.5px;">Citas Pendientes</div>
                        <div class="stat-number"><%= citasPendientes %></div>
                        <small class="text-muted">Visitas agendadas</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-amber"><i class="bi bi-calendar-check"></i></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;letter-spacing:0.5px;">Citas Realizadas</div>
                        <div class="stat-number"><%= citasRealizadas %></div>
                        <small class="text-muted">Visitas completadas</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-green"><i class="bi bi-check-circle"></i></div>
                </div>
            </div>
        </div>

        <!-- Accesos Rápidos -->
        <h5 class="fw-bold mb-3">Accesos Rápidos</h5>
        <div class="row g-3">
            <div class="col-md-4">
                <a href="<%= ctx %>/cliente/favoritos.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-blue mb-3"><i class="bi bi-heart-fill"></i></div>
                        <h6 class="fw-bold mb-1">Mis Favoritos</h6>
                        <p class="text-muted small mb-0">Ver propiedades guardadas</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="<%= ctx %>/cliente/citas.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-amber mb-3"><i class="bi bi-calendar-event"></i></div>
                        <h6 class="fw-bold mb-1">Mis Citas</h6>
                        <p class="text-muted small mb-0">Administrar visitas agendadas</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="<%= ctx %>/cliente/perfil.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-green mb-3"><i class="bi bi-person-gear"></i></div>
                        <h6 class="fw-bold mb-1">Mi Perfil</h6>
                        <p class="text-muted small mb-0">Editar datos personales</p>
                    </div>
                </a>
            </div>
        </div>
    </div>
</div>

<%@ include file="/components/footer.jsp" %>
