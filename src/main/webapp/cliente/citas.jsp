<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*" %>
<%@ include file="/components/conexion.jsp" %>
<%
    if (session.getAttribute("rolActivo") == null) { response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=/cliente/citas.jsp"); return; }
    String ctx = request.getContextPath();
    Object idUsrObj = session.getAttribute("idUsuario");
    java.util.List<java.util.Map<String,String>> citas = new java.util.ArrayList<>();
    String msgCita = null;

    // Cancelar cita
    if ("POST".equalsIgnoreCase(request.getMethod()) && idUsrObj != null && "cancelar".equals(request.getParameter("accion"))) {
        try (Connection conn = getConn()) {
            PreparedStatement psCancel = conn.prepareStatement(
                "UPDATE cita SET estado='cancelada' WHERE id_cita=? AND id_cliente=?");
            psCancel.setInt(1, Integer.parseInt(request.getParameter("idCita")));
            psCancel.setInt(2, (Integer) idUsrObj);
            psCancel.executeUpdate();
            msgCita = "Cita cancelada.";
        } catch (Exception ex) { ex.printStackTrace(); }
    }

    if (idUsrObj != null) {
        try (Connection conn = getConn()) {
            String sql = "SELECT ci.id_cita, ci.fecha_hora, ci.estado, ci.observaciones, " +
                         "p.titulo AS propiedad, c.nombre AS ciudad, " +
                         "per.nombres || ' ' || per.apellidos AS agente " +
                         "FROM cita ci " +
                         "JOIN propiedad p ON p.id_propiedad = ci.id_propiedad " +
                         "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                         "LEFT JOIN usuario ua ON ua.id_usuario = ci.id_agente " +
                         "LEFT JOIN perfil per ON per.id_usuario = ua.id_usuario " +
                         "WHERE ci.id_cliente=" + (Integer) idUsrObj + " ORDER BY ci.fecha_hora DESC";
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while (rs.next()) {
                java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
                m.put("id",          rs.getString("id_cita"));
                m.put("fechaHora",   rs.getString("fecha_hora"));
                m.put("estado",      rs.getString("estado"));
                m.put("propiedad",   rs.getString("propiedad"));
                m.put("ciudad",      rs.getString("ciudad"));
                m.put("agente",      rs.getString("agente"));
                m.put("obs",         rs.getString("observaciones"));
                citas.add(m);
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_cliente.jsp" %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Mis Citas</h2>
        <p class="text-muted mb-4">Historial de visitas agendadas a propiedades</p>
        <% if (msgCita != null) { %>
        <div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgCita %></div>
        <% } %>
        <% if (citas.isEmpty()) { %>
        <div class="text-center py-5" style="background:var(--bg-surface);border-radius:var(--radius-lg);border:1px solid var(--border-subtle);">
            <i class="bi bi-calendar-x" style="font-size:3rem;color:var(--text-light);"></i>
            <h5 class="mt-3 fw-bold">Sin citas agendadas</h5>
            <p class="text-muted">Agenda visitas desde la página de detalle de una propiedad.</p>
            <a href="<%= ctx %>/catalogo.jsp" class="btn btn-vesta-accent">Ver propiedades</a>
        </div>
        <% } else { %>
        <div class="table-responsive">
            <table class="table-vesta">
                <thead><tr>
                    <th>Propiedad</th><th>Ciudad</th><th>Fecha y Hora</th>
                    <th>Agente</th><th>Estado</th><th>Acciones</th>
                </tr></thead>
                <tbody>
                    <% for (java.util.Map<String,String> c : citas) {
                        String est = c.get("estado");
                        String badgeClass = "pendiente".equals(est) ? "badge-vesta-warning"
                                          : "realizada".equals(est) ? "badge-vesta-success" : "badge-vesta-danger";
                    %>
                    <tr>
                        <td class="fw-600"><%= c.get("propiedad") %></td>
                        <td><%= c.get("ciudad") %></td>
                        <td><%= c.get("fechaHora") != null ? c.get("fechaHora").substring(0, 16) : "—" %></td>
                        <td><%= c.get("agente") != null ? c.get("agente") : "—" %></td>
                        <td><span class="badge-vesta <%= badgeClass %>"><%= est %></span></td>
                        <td>
                            <% if ("pendiente".equals(est)) { %>
                            <form action="<%= ctx %>/cliente/citas.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="idCita" value="<%= c.get("id") %>">
                                <input type="hidden" name="accion" value="cancelar">
                                <button type="submit" class="btn btn-sm"
                                        style="background:var(--status-danger-bg);color:var(--status-danger);border:none;padding:6px 12px;border-radius:var(--radius-sm);font-size:0.82rem;"
                                        data-confirm="¿Cancelar esta cita?">
                                    <i class="bi bi-x-circle me-1"></i>Cancelar
                                </button>
                            </form>
                            <% } else { %>
                            <span class="text-muted small">—</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
