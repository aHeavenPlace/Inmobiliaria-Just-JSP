<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*" %>
<%@ include file="/components/conexion.jsp" %>
<%
    String rolA = (String) session.getAttribute("rolActivo");
    if (rolA == null || !"admin".equals(rolA)) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    String ctx = request.getContextPath();
    String msgUsr = null;

    // Acciones POST: cambiar rol o estado
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String accion   = request.getParameter("accion");
        String idTarget = request.getParameter("idUsuario");
        try (Connection conn = getConn()) {
            if ("cambiarEstado".equals(accion)) {
                String nuevoEstado = request.getParameter("nuevoEstado");
                conn.prepareStatement("UPDATE usuario SET estado='" + nuevoEstado + "' WHERE id_usuario=" + idTarget).executeUpdate();
                msgUsr = "Estado del usuario actualizado a '" + nuevoEstado + "'.";
            } else if ("cambiarRol".equals(accion)) {
                int nuevoRol = Integer.parseInt(request.getParameter("nuevoRol"));
                conn.prepareStatement("DELETE FROM usuario_rol WHERE id_usuario=" + idTarget).executeUpdate();
                conn.prepareStatement("INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (" + idTarget + "," + nuevoRol + ")").executeUpdate();
                msgUsr = "Rol del usuario actualizado.";
            }
        } catch (Exception ex) { msgUsr = "Error: " + ex.getMessage(); }
    }

    // Listar usuarios
    java.util.List<java.util.Map<String,String>> usuarios = new java.util.ArrayList<>();
    try (Connection conn = getConn()) {
        String sql = "SELECT u.id_usuario, u.correo, u.estado, u.ultimo_acceso, " +
                     "p.nombres, p.apellidos, p.telefono, " +
                     "COALESCE((SELECT r.nombre FROM usuario_rol ur JOIN rol r ON r.id_rol=ur.id_rol WHERE ur.id_usuario=u.id_usuario ORDER BY r.id_rol LIMIT 1),'sin rol') AS rol " +
                     "FROM usuario u LEFT JOIN perfil p ON p.id_usuario=u.id_usuario ORDER BY u.id_usuario";
        ResultSet rs = conn.createStatement().executeQuery(sql);
        while (rs.next()) {
            java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
            m.put("id", rs.getString("id_usuario"));
            m.put("correo", rs.getString("correo"));
            m.put("estado", rs.getString("estado"));
            m.put("nombres", rs.getString("nombres") != null ? rs.getString("nombres") + " " + rs.getString("apellidos") : "—");
            m.put("telefono", rs.getString("telefono") != null ? rs.getString("telefono") : "—");
            m.put("rol", rs.getString("rol"));
            m.put("ultimoAcceso", rs.getString("ultimo_acceso") != null ? rs.getString("ultimo_acceso").substring(0,16) : "Nunca");
            usuarios.add(m);
        }
    } catch (Exception ex) { ex.printStackTrace(); }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_admin.jsp" %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Usuarios &amp; Roles</h2>
        <p class="text-muted mb-4">Administra las cuentas y permisos de acceso al sistema</p>

        <% if (msgUsr != null) { %>
        <div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgUsr %></div>
        <% } %>

        <div class="table-responsive">
            <table class="table-vesta">
                <thead><tr>
                    <th>ID</th><th>Nombre</th><th>Correo</th><th>Teléfono</th>
                    <th>Rol</th><th>Estado</th><th>Último Acceso</th><th>Acciones</th>
                </tr></thead>
                <tbody>
                <% for (java.util.Map<String,String> u : usuarios) {
                    String est = u.get("estado");
                    String badgeClass = "activo".equals(est) ? "badge-vesta-success" : "badge-vesta-danger";
                    String rolBadge = "admin".equals(u.get("rol")) ? "badge-vesta-danger"
                                   : "inmobiliaria".equals(u.get("rol")) ? "badge-vesta-info" : "badge-vesta-success";
                %>
                <tr>
                    <td class="fw-600">#<%= u.get("id") %></td>
                    <td><%= u.get("nombres") %></td>
                    <td><code style="font-size:0.85rem;"><%= u.get("correo") %></code></td>
                    <td><%= u.get("telefono") %></td>
                    <td><span class="badge-vesta <%= rolBadge %>"><%= u.get("rol") %></span></td>
                    <td><span class="badge-vesta <%= badgeClass %>"><%= est %></span></td>
                    <td style="font-size:0.85rem;"><%= u.get("ultimoAcceso") %></td>
                    <td>
                        <div class="d-flex gap-1 flex-wrap">
                            <!-- Cambiar Estado -->
                            <form action="<%= ctx %>/admin/usuarios.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="accion" value="cambiarEstado">
                                <input type="hidden" name="idUsuario" value="<%= u.get("id") %>">
                                <% if ("activo".equals(est)) { %>
                                <input type="hidden" name="nuevoEstado" value="inactivo">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-danger-bg);color:var(--status-danger);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;" data-confirm="¿Desactivar este usuario?">
                                    <i class="bi bi-slash-circle"></i>
                                </button>
                                <% } else { %>
                                <input type="hidden" name="nuevoEstado" value="activo">
                                <button type="submit" class="btn btn-sm" style="background:var(--status-success-bg);color:var(--status-success);border:none;padding:4px 10px;border-radius:6px;font-size:0.78rem;">
                                    <i class="bi bi-check-circle"></i>
                                </button>
                                <% } %>
                            </form>
                            <!-- Cambiar Rol -->
                            <form action="<%= ctx %>/admin/usuarios.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="accion" value="cambiarRol">
                                <input type="hidden" name="idUsuario" value="<%= u.get("id") %>">
                                <select name="nuevoRol" style="border:1px solid var(--border-subtle);border-radius:6px;padding:3px 8px;font-size:0.78rem;" onchange="this.form.submit()">
                                    <option value="1" <%= "admin".equals(u.get("rol")) ? "selected" : "" %>>Admin</option>
                                    <option value="2" <%= "inmobiliaria".equals(u.get("rol")) ? "selected" : "" %>>Inmobiliaria</option>
                                    <option value="3" <%= "cliente".equals(u.get("rol")) ? "selected" : "" %>>Cliente</option>
                                </select>
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
