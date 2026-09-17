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

    // Estadísticas
    java.util.List<String[]> porCiudad = new java.util.ArrayList<>();
    java.util.List<String[]> porTipo   = new java.util.ArrayList<>();
    int totalActivas = 0; int totalVenta = 0; int totalArriendo = 0;

    if (idUsrObj != null) {
        try (Connection conn = getConn()) {
            ResultSet r1 = conn.prepareStatement("SELECT COUNT(*) FROM propiedad WHERE estado='disponible'").executeQuery();
            if (r1.next()) totalActivas = r1.getInt(1);
            ResultSet r2 = conn.prepareStatement("SELECT COUNT(*) FROM propiedad WHERE LOWER(tipo_operacion)='venta'").executeQuery();
            if (r2.next()) totalVenta = r2.getInt(1);
            ResultSet r3 = conn.prepareStatement("SELECT COUNT(*) FROM propiedad WHERE LOWER(tipo_operacion)='arriendo'").executeQuery();
            if (r3.next()) totalArriendo = r3.getInt(1);

            ResultSet rc = conn.createStatement().executeQuery(
                "SELECT c.nombre, COUNT(*) AS total FROM propiedad p JOIN ciudad c ON c.id_ciudad=p.id_ciudad " +
                "GROUP BY c.nombre ORDER BY total DESC LIMIT 10");
            while (rc.next()) porCiudad.add(new String[]{ rc.getString("nombre"), rc.getString("total") });

            ResultSet rt = conn.createStatement().executeQuery(
                "SELECT tp.nombre, COUNT(*) AS total FROM propiedad p JOIN tipo_propiedad tp ON tp.id_tipo=p.id_tipo " +
                "GROUP BY tp.nombre ORDER BY total DESC LIMIT 10");
            while (rt.next()) porTipo.add(new String[]{ rt.getString("nombre"), rt.getString("total") });
        } catch (Exception ex) { ex.printStackTrace(); }
    }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_inmobiliaria.jsp" %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Reportes &amp; Métricas</h2>
        <p class="text-muted mb-4">Resumen estadístico de tus propiedades publicadas</p>

        <!-- Stats rápidos -->
        <div class="row g-3 mb-5">
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">Activas</div>
                        <div class="stat-number"><%= totalActivas %></div>
                    </div>
                    <div class="stat-icon-wrap stat-icon-green"><i class="bi bi-check-circle"></i></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">En Venta</div>
                        <div class="stat-number"><%= totalVenta %></div>
                    </div>
                    <div class="stat-icon-wrap stat-icon-blue"><i class="bi bi-tag"></i></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <div class="text-muted fw-600" style="font-size:0.8rem;text-transform:uppercase;">En Arriendo</div>
                        <div class="stat-number"><%= totalArriendo %></div>
                    </div>
                    <div class="stat-icon-wrap stat-icon-amber"><i class="bi bi-key"></i></div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Por Ciudad -->
            <div class="col-lg-6">
                <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:28px;border:1px solid var(--border-subtle);">
                    <h5 class="fw-bold mb-3"><i class="bi bi-geo-alt me-2" style="color:var(--color-accent);"></i>Propiedades por Ciudad</h5>
                    <% if (porCiudad.isEmpty()) { %>
                    <p class="text-muted">Sin datos disponibles.</p>
                    <% } else { %>
                    <% int maxCiud = 1; for (String[] s : porCiudad) { int v = Integer.parseInt(s[1]); if (v > maxCiud) maxCiud = v; } %>
                    <% for (String[] s : porCiudad) { int v = Integer.parseInt(s[1]); int pct = (v * 100) / maxCiud; %>
                    <div class="mb-3">
                        <div class="d-flex justify-content-between mb-1">
                            <span class="fw-600" style="font-size:0.9rem;"><%= s[0] %></span>
                            <span class="text-muted" style="font-size:0.85rem;"><%= s[1] %></span>
                        </div>
                        <div style="height:8px;background:var(--bg-surface-subtle);border-radius:99px;overflow:hidden;">
                            <div style="height:100%;width:<%= pct %>%;background:linear-gradient(135deg,var(--color-accent),var(--color-gold));border-radius:99px;transition:width 0.5s;"></div>
                        </div>
                    </div>
                    <% } %>
                    <% } %>
                </div>
            </div>

            <!-- Por Tipo -->
            <div class="col-lg-6">
                <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:28px;border:1px solid var(--border-subtle);">
                    <h5 class="fw-bold mb-3"><i class="bi bi-building me-2" style="color:var(--color-accent);"></i>Propiedades por Tipo</h5>
                    <% if (porTipo.isEmpty()) { %>
                    <p class="text-muted">Sin datos disponibles.</p>
                    <% } else { %>
                    <% int maxTipo = 1; for (String[] s : porTipo) { int v = Integer.parseInt(s[1]); if (v > maxTipo) maxTipo = v; } %>
                    <% for (String[] s : porTipo) { int v = Integer.parseInt(s[1]); int pct = (v * 100) / maxTipo; %>
                    <div class="mb-3">
                        <div class="d-flex justify-content-between mb-1">
                            <span class="fw-600" style="font-size:0.9rem;"><%= s[0] %></span>
                            <span class="text-muted" style="font-size:0.85rem;"><%= s[1] %></span>
                        </div>
                        <div style="height:8px;background:var(--bg-surface-subtle);border-radius:99px;overflow:hidden;">
                            <div style="height:100%;width:<%= pct %>%;background:linear-gradient(135deg,var(--status-info),var(--status-success));border-radius:99px;transition:width 0.5s;"></div>
                        </div>
                    </div>
                    <% } %>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
