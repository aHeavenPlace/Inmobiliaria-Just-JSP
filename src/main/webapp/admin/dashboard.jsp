<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*" %>
<%@ include file="/components/conexion.jsp" %>
<%
    String rolA = (String) session.getAttribute("rolActivo");
    if (rolA == null || !"admin".equals(rolA)) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    String ctx = request.getContextPath();
    int totalUsuarios = 0; int totalProps = 0; int totalCitas = 0; int totalInmob = 0;
    try (Connection conn = getConn()) {
        ResultSet r1 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM usuario WHERE estado='activo'");
        if (r1.next()) totalUsuarios = r1.getInt(1);
        ResultSet r2 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM propiedad WHERE estado='disponible'");
        if (r2.next()) totalProps = r2.getInt(1);
        ResultSet r3 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM cita");
        if (r3.next()) totalCitas = r3.getInt(1);
        ResultSet r4 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM inmobiliaria WHERE estado='activo'");
        if (r4.next()) totalInmob = r4.getInt(1);
    } catch (Exception ex) { ex.printStackTrace(); }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_admin.jsp" %>
    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-vesta-charcoal mb-1">Panel de Administración</h2>
                <p class="text-vesta-gray mb-0">Estadísticas globales del sistema</p>
            </div>
        </div>
        <div class="row g-3 mb-5">
            <div class="col-md-3">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">Usuarios Activos</div>
                        <div class="stat-number"><%= totalUsuarios %></div>
                    </div>
                    <div class="stat-icon-wrap stat-icon-blue"><i class="bi bi-people"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">Propiedades</div>
                        <div class="stat-number"><%= totalProps %></div>
                    </div>
                    <div class="stat-icon-wrap stat-icon-purple"><i class="bi bi-houses"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">Citas Totales</div>
                        <div class="stat-number"><%= totalCitas %></div>
                    </div>
                    <div class="stat-icon-wrap stat-icon-amber"><i class="bi bi-calendar-check"></i></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">Inmobiliarias</div>
                        <div class="stat-number"><%= totalInmob %></div>
                    </div>
                    <div class="stat-icon-wrap stat-icon-green"><i class="bi bi-building-check"></i></div>
                </div>
            </div>
        </div>
        <h5 class="fw-bold mb-3">Gestión del Sistema</h5>
        <div class="row g-3">
            <div class="col-md-4">
                <a href="<%= ctx %>/admin/usuarios.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-blue mb-3"><i class="bi bi-people"></i></div>
                        <h6 class="fw-bold mb-1">Usuarios &amp; Roles</h6>
                        <p class="text-muted small mb-0">Administrar cuentas y permisos</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="<%= ctx %>/admin/propiedades.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-purple mb-3"><i class="bi bi-houses"></i></div>
                        <h6 class="fw-bold mb-1">Todas las Propiedades</h6>
                        <p class="text-muted small mb-0">Moderar el catálogo completo</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="<%= ctx %>/admin/catalogos.jsp" style="text-decoration:none;">
                    <div class="stat-card flex-column align-items-start" style="cursor:pointer;">
                        <div class="stat-icon-wrap stat-icon-amber mb-3"><i class="bi bi-sliders"></i></div>
                        <h6 class="fw-bold mb-1">Parametrización</h6>
                        <p class="text-muted small mb-0">Ciudades y tipos de inmueble</p>
                    </div>
                </a>
            </div>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
