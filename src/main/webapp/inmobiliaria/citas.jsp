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
    String msgCita = null;

    // Acciones POST
    if ("POST".equalsIgnoreCase(request.getMethod()) && idUsrObj != null) {
        String idCita  = request.getParameter("idCita");
        String accion  = request.getParameter("accion");
        try (Connection conn = getConn()) {
            if ("aprobar".equals(accion)) {
                conn.prepareStatement("UPDATE cita SET estado='confirmada' WHERE id_cita=" + idCita).executeUpdate();
                msgCita = "Cita confirmada exitosamente.";
            } else if ("rechazar".equals(accion)) {
                conn.prepareStatement("UPDATE cita SET estado='cancelada' WHERE id_cita=" + idCita).executeUpdate();
                msgCita = "Cita rechazada.";
            } else if ("realizada".equals(accion)) {
                conn.prepareStatement("UPDATE cita SET estado='realizada' WHERE id_cita=" + idCita).executeUpdate();
                msgCita = "Cita marcada como realizada.";
            }
        } catch (Exception ex) { msgCita = "Error: " + ex.getMessage(); }
    }

    java.util.List<java.util.Map<String,String>> citas = new java.util.ArrayList<>();
    if (idUsrObj != null) {
        try (Connection conn = getConn()) {
            String sql = "SELECT ci.id_cita, ci.fecha_hora, ci.estado, ci.observaciones, " +
                         "p.titulo AS propiedad, c.nombre AS ciudad, " +
                         "per.nombres || ' ' || per.apellidos AS cliente, u.correo AS correoCliente " +
                         "FROM cita ci " +
                         "JOIN propiedad p ON p.id_propiedad = ci.id_propiedad " +
                         "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                         "JOIN usuario u ON u.id_usuario = ci.id_cliente " +
                         "LEFT JOIN perfil per ON per.id_usuario = ci.id_cliente " +
                         "WHERE ci.id_agente=" + (Integer) idUsrObj + " ORDER BY ci.fecha_hora DESC";
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while (rs.next()) {
                java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
                m.put("id", rs.getString("id_cita"));
                m.put("fechaHora", rs.getString("fecha_hora"));
                m.put("estado", rs.getString("estado"));
                m.put("propiedad", rs.getString("propiedad"));
                m.put("ciudad", rs.getString("ciudad"));
                m.put("cliente", rs.getString("cliente"));
                m.put("correo", rs.getString("correoCliente"));
                m.put("obs", rs.getString("observaciones"));
                citas.add(m);
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_inmobiliaria.jsp" %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Gestión de Citas</h2>
        <p class="text-muted mb-4">Administra las solicitudes de visita de los clientes</p>
        <% if (msgCita != null) { %>
        <div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgCita %></div>
        <% } %>
        <% if (citas.isEmpty()) { %>
        <div class="text-center py-5" style="background:var(--bg-surface);border-radius:var(--radius-lg);border:1px solid var(--border-subtle);">
            <i class="bi bi-calendar-x" style="font-size:3rem;color:var(--text-light);"></i>
            <h5 class="mt-3 fw-bold">Sin citas recibidas</h5>
            <p class="text-muted">Cuando un cliente agende una visita, aparecerá aquí.</p>
        </div>
        <% } else { %>
        <div class="table-responsive">
            <table class="table-vesta">
                <thead><tr><th>Propiedad</th><th>Cliente</th><th>Fecha/Hora</th><th>Estado</th><th>Observaciones</th><th>Acciones</th></tr></thead>
                <tbody>
                <% for (java.util.Map<String,String> c : citas) {
                    String est = c.get("estado");
                    String bc = "pendiente".equals(est) ? "badge-vesta-warning"
                              : "confirmada".equals(est) ? "badge-vesta-info"
                              : "realizada".equals(est) ? "badge-vesta-success" : "badge-vesta-danger";
                %>
                <tr>
                    <td class="fw-600"><%= c.get("propiedad") %></td>
                    <td><div><%= c.get("cliente") %></div><small class="text-muted"><%= c.get("correo") %></small></td>
                    <td><%= c.get("fechaHora") != null ? c.get("fechaHora").substring(0,16) : "—" %></td>
                    <td><span class="badge-vesta <%= bc %>"><%= est %></span></td>
                    <td style="max-width:180px;font-size:0.88rem;"><%= c.get("obs") != null ? c.get("obs") : "—" %></td>
                    <td>
                        <div class="d-flex gap-1 flex-wrap">
                        <% if ("pendiente".equals(est)) { %>
                            <form action="<%= ctx %>/inmobiliaria/citas.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="idCita" value="<%= c.get("id") %>">
                                <input type="hidden" name="accion" value="aprobar">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-success-bg);color:var(--status-success);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;">
                                    <i class="bi bi-check"></i> Confirmar
                                </button>
                            </form>
                            <form action="<%= ctx %>/inmobiliaria/citas.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="idCita" value="<%= c.get("id") %>">
                                <input type="hidden" name="accion" value="rechazar">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-danger-bg);color:var(--status-danger);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;">
                                    <i class="bi bi-x"></i> Rechazar
                                </button>
                            </form>
                        <% } else if ("confirmada".equals(est)) { %>
                            <form action="<%= ctx %>/inmobiliaria/citas.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="idCita" value="<%= c.get("id") %>">
                                <input type="hidden" name="accion" value="realizada">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-info-bg);color:var(--status-info);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;">
                                    <i class="bi bi-check-all"></i> Realizada
                                </button>
                            </form>
                        <% } else { %>
                            <span class="text-muted small">—</span>
                        <% } %>
                        </div>
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
