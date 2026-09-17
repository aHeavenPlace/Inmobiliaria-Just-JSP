<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,java.text.NumberFormat,java.util.Locale" %>
<%@ include file="/components/conexion.jsp" %>
<%
    String rolA = (String) session.getAttribute("rolActivo");
    if (rolA == null || !"admin".equals(rolA)) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    String ctx = request.getContextPath();
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("es","CO"));
    String msgProp = null;

    // Acciones POST: cambiar estado
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String idProp = request.getParameter("idPropiedad");
        String nuevoEst = request.getParameter("nuevoEstado");
        try (Connection conn = getConn()) {
            conn.prepareStatement("UPDATE propiedad SET estado='" + nuevoEst + "' WHERE id_propiedad=" + idProp).executeUpdate();
            msgProp = "Estado de la propiedad actualizado a '" + nuevoEst + "'.";
        } catch (Exception ex) { msgProp = "Error: " + ex.getMessage(); }
    }

    java.util.List<java.util.Map<String,String>> propiedades = new java.util.ArrayList<>();
    try (Connection conn = getConn()) {
        String sql = "SELECT p.id_propiedad, p.titulo, p.precio, p.tipo_operacion AS operacion, p.estado, " +
                     "tp.nombre AS tipo, c.nombre AS ciudad, " +
                     "COALESCE(i.nombre, 'Vesta Inmobiliaria') AS agente " +
                     "FROM propiedad p " +
                     "JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
                     "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                     "LEFT JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                     "ORDER BY p.fecha_publicacion DESC";
        ResultSet rs = conn.createStatement().executeQuery(sql);
        while (rs.next()) {
            java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
            m.put("id", rs.getString("id_propiedad"));
            m.put("titulo", rs.getString("titulo"));
            m.put("precio", rs.getString("precio"));
            m.put("operacion", rs.getString("operacion"));
            m.put("estado", rs.getString("estado"));
            m.put("tipo", rs.getString("tipo"));
            m.put("ciudad", rs.getString("ciudad"));
            m.put("agente", rs.getString("agente"));
            propiedades.add(m);
        }
    } catch (Exception ex) { ex.printStackTrace(); }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_admin.jsp" %>
    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1">Todas las Propiedades</h2>
                <p class="text-muted mb-0"><%= propiedades.size() %> propiedades en el sistema</p>
            </div>
            <a href="<%= ctx %>/admin/propiedad_form.jsp" class="btn btn-vesta-accent">
                <i class="bi bi-plus-circle me-1"></i> Nueva Propiedad
            </a>
        </div>
        <% if (msgProp != null) { %>
        <div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgProp %></div>
        <% } %>
        <div class="table-responsive">
            <table class="table-vesta">
                <thead><tr>
                    <th>ID</th><th>Título</th><th>Tipo</th><th>Ciudad</th>
                    <th>Precio</th><th>Operación</th><th>Agente</th><th>Estado</th><th>Acciones</th>
                </tr></thead>
                <tbody>
                <% for (java.util.Map<String,String> p : propiedades) {
                    String est = p.get("estado");
                    String badgeClass = "activo".equals(est) ? "badge-vesta-success" : "pausado".equals(est) ? "badge-vesta-warning" : "badge-vesta-danger";
                    String precioStr = "—"; try { precioStr = "$" + nf.format(Long.parseLong(p.get("precio"))); } catch (Exception e) {}
                %>
                <tr>
                    <td class="fw-600">#<%= p.get("id") %></td>
                    <td style="max-width:200px;"><div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><%= p.get("titulo") %></div></td>
                    <td><span class="badge-vesta badge-vesta-info"><%= p.get("tipo") %></span></td>
                    <td><%= p.get("ciudad") %></td>
                    <td class="fw-600"><%= precioStr %></td>
                    <td><%= p.get("operacion") %></td>
                    <td style="font-size:0.88rem;"><%= p.get("agente") %></td>
                    <td><span class="badge-vesta <%= badgeClass %>"><%= est %></span></td>
                    <td>
                        <div class="d-flex gap-1">
                            <a href="<%= ctx %>/detalle.jsp?id=<%= p.get("id") %>" class="btn btn-sm" style="background:var(--bg-surface-subtle);border:1px solid var(--border-subtle);padding:4px 10px;border-radius:6px;font-size:0.78rem;" title="Ver">
                                <i class="bi bi-eye"></i>
                            </a>
                            <form action="<%= ctx %>/admin/propiedades.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="idPropiedad" value="<%= p.get("id") %>">
                                <% if ("activo".equals(est)) { %>
                                <input type="hidden" name="nuevoEstado" value="pausado">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-warning-bg);color:var(--status-warning);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;" title="Pausar">
                                    <i class="bi bi-pause-circle"></i>
                                </button>
                                <% } else { %>
                                <input type="hidden" name="nuevoEstado" value="activo">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-success-bg);color:var(--status-success);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;" title="Activar">
                                    <i class="bi bi-check-circle"></i>
                                </button>
                                <% } %>
                            </form>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
