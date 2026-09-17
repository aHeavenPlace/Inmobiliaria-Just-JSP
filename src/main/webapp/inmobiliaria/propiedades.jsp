<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,java.text.NumberFormat,java.util.Locale" %>
<%@ include file="/components/conexion.jsp" %>
<%
    String rolI = (String) session.getAttribute("rolActivo");
    if (rolI == null || (!"inmobiliaria".equals(rolI) && !"admin".equals(rolI))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String ctx = request.getContextPath();
    Object idUsrObj = session.getAttribute("idUsuario");
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("es","CO"));
    String msgProp = null;

    // Cambiar estado de propiedad
    if ("POST".equalsIgnoreCase(request.getMethod()) && idUsrObj != null) {
        String idProp = request.getParameter("idPropiedad");
        String nuevoEst = request.getParameter("nuevoEstado");
        try (Connection conn = getConn()) {
            PreparedStatement ps = conn.prepareStatement("UPDATE propiedad SET estado=? WHERE id_propiedad=? AND id_usuario=?");
            ps.setString(1, nuevoEst); ps.setInt(2, Integer.parseInt(idProp)); ps.setInt(3, (Integer) idUsrObj);
            ps.executeUpdate();
            msgProp = "Estado actualizado a '" + nuevoEst + "'.";
        } catch (Exception ex) { msgProp = "Error: " + ex.getMessage(); }
    }

    java.util.List<java.util.Map<String,String>> propiedades = new java.util.ArrayList<>();
    if (idUsrObj != null) {
        try (Connection conn = getConn()) {
            String sql = "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, p.estado, " +
                         "tp.nombre AS tipo, c.nombre AS ciudad, p.num_habitaciones, p.num_banos, p.area_m2 " +
                         "FROM propiedad p JOIN tipo_propiedad tp ON tp.id_tipo=p.id_tipo " +
                         "JOIN ciudad c ON c.id_ciudad=p.id_ciudad " +
                         "WHERE p.id_usuario=" + (Integer) idUsrObj + " ORDER BY p.fecha_publicacion DESC";
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
                propiedades.add(m);
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_inmobiliaria.jsp" %>
    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold mb-1">Mis Propiedades</h2>
                <p class="text-muted mb-0"><%= propiedades.size() %> propiedades publicadas</p>
            </div>
            <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp" class="btn btn-vesta-accent">
                <i class="bi bi-plus-circle me-1"></i> Publicar Inmueble
            </a>
        </div>
        <% if (msgProp != null) { %>
        <div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgProp %></div>
        <% } %>
        <% if (propiedades.isEmpty()) { %>
        <div class="text-center py-5" style="background:var(--bg-surface);border-radius:var(--radius-lg);border:1px solid var(--border-subtle);">
            <i class="bi bi-houses" style="font-size:3rem;color:var(--text-light);"></i>
            <h5 class="mt-3 fw-bold">Sin propiedades publicadas</h5>
            <p class="text-muted">Comienza publicando tu primer inmueble.</p>
            <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp" class="btn btn-vesta-accent">Publicar ahora</a>
        </div>
        <% } else { %>
        <div class="table-responsive">
            <table class="table-vesta">
                <thead><tr><th>ID</th><th>Título</th><th>Tipo</th><th>Ciudad</th><th>Precio</th><th>Op.</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                <% for (java.util.Map<String,String> p : propiedades) {
                    String est = p.get("estado");
                    String bc = "activo".equals(est) ? "badge-vesta-success" : "pausado".equals(est) ? "badge-vesta-warning" : "badge-vesta-danger";
                    String pr = "—"; try { pr = "$" + nf.format(Long.parseLong(p.get("precio"))); } catch (Exception e) {}
                %>
                <tr>
                    <td class="fw-600">#<%= p.get("id") %></td>
                    <td style="max-width:220px;"><div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><%= p.get("titulo") %></div></td>
                    <td><%= p.get("tipo") %></td>
                    <td><%= p.get("ciudad") %></td>
                    <td class="fw-600"><%= pr %></td>
                    <td><%= p.get("operacion") %></td>
                    <td><span class="badge-vesta <%= bc %>"><%= est %></span></td>
                    <td>
                        <div class="d-flex gap-1">
                            <a href="<%= ctx %>/detalle.jsp?id=<%= p.get("id") %>" class="btn btn-sm" style="background:var(--bg-surface-subtle);border:1px solid var(--border-subtle);padding:4px 10px;border-radius:6px;font-size:0.78rem;"><i class="bi bi-eye"></i></a>
                            <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp?id=<%= p.get("id") %>" class="btn btn-sm" style="background:var(--status-info-bg);color:var(--status-info);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;"><i class="bi bi-pencil"></i></a>
                            <form action="<%= ctx %>/inmobiliaria/propiedades.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="idPropiedad" value="<%= p.get("id") %>">
                                <% if ("activo".equals(est)) { %>
                                <input type="hidden" name="nuevoEstado" value="pausado">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-warning-bg);color:var(--status-warning);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;"><i class="bi bi-pause-circle"></i></button>
                                <% } else { %>
                                <input type="hidden" name="nuevoEstado" value="activo">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-success-bg);color:var(--status-success);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;"><i class="bi bi-check-circle"></i></button>
                                <% } %>
                            </form>
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
