<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*" %>
<%@ include file="/components/conexion.jsp" %>
<%
    String rolI = (String) session.getAttribute("rolActivo");
    if (rolI == null || (!"inmobiliaria".equals(rolI) && !"admin".equals(rolI))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    Object idUsrObj = session.getAttribute("idUsuario");
    int totalProp = 0; int citasPend = 0; int citasReal = 0;
    if (idUsrObj != null) {
        int idUsr = (Integer) idUsrObj;
        try (Connection conn = getConn()) {
            ResultSet r1 = conn.prepareStatement("SELECT COUNT(*) FROM propiedad WHERE id_usuario=" + idUsr).executeQuery();
            if (r1.next()) totalProp = r1.getInt(1);
            ResultSet r2 = conn.prepareStatement("SELECT COUNT(*) FROM cita WHERE id_agente=" + idUsr + " AND estado='pendiente'").executeQuery();
            if (r2.next()) citasPend = r2.getInt(1);
            ResultSet r3 = conn.prepareStatement("SELECT COUNT(*) FROM cita WHERE id_agente=" + idUsr + " AND estado='realizada'").executeQuery();
            if (r3.next()) citasReal = r3.getInt(1);
        } catch (Exception ex) { ex.printStackTrace(); }
    }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_inmobiliaria.jsp" %>
    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-vesta-charcoal mb-1">Panel de Agente</h2>
                <p class="text-vesta-gray mb-0">Gestiona tus propiedades y citas agendadas</p>
            </div>
            <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp" class="btn btn-vesta-accent">
                <i class="bi bi-plus-circle me-1"></i> Publicar Inmueble
            </a>
        </div>
        <div class="row g-3 mb-5">
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">Propiedades</div>
                        <div class="stat-number"><%= totalProp %></div>
                        <small class="text-muted">Publicadas</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-purple"><i class="bi bi-houses"></i></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">Citas Pendientes</div>
                        <div class="stat-number"><%= citasPend %></div>
                        <small class="text-muted">Visitas por atender</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-amber"><i class="bi bi-calendar-event"></i></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">Citas Realizadas</div>
                        <div class="stat-number"><%= citasReal %></div>
                        <small class="text-muted">Visitas completadas</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-green"><i class="bi bi-check-circle"></i></div>
                </div>
            </div>
        </div>
        <h5 class="fw-bold mb-3">Accesos Rápidos</h5>
        <div class="row g-3">
            <div class="col-md-4">
                <a href="<%= ctx %>/inmobiliaria/propiedades.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-purple mb-3"><i class="bi bi-houses"></i></div>
                        <h6 class="fw-bold mb-1">Mis Propiedades</h6>
                        <p class="text-muted small mb-0">Gestionar inmuebles publicados</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="<%= ctx %>/inmobiliaria/citas.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-amber mb-3"><i class="bi bi-calendar-event"></i></div>
                        <h6 class="fw-bold mb-1">Citas Recibidas</h6>
                        <p class="text-muted small mb-0">Aprobar y gestionar visitas</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="<%= ctx %>/inmobiliaria/reportes.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-green mb-3"><i class="bi bi-graph-up-arrow"></i></div>
                        <h6 class="fw-bold mb-1">Reportes</h6>
                        <p class="text-muted small mb-0">Ver estadísticas y métricas</p>
                    </div>
                </a>
            </div>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
