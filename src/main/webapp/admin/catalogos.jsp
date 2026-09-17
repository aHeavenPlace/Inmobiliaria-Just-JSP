<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*" %>
<%@ include file="/components/conexion.jsp" %>
<%
    String rolA = (String) session.getAttribute("rolActivo");
    if (rolA == null || !"admin".equals(rolA)) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    String ctx = request.getContextPath();
    String msgCat = null;

    // Acciones POST
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        try (Connection conn = getConn()) {
            if ("addCiudad".equals(accion)) {
                String nombre = request.getParameter("nombreCiudad");
                String depto  = request.getParameter("departamento");
                String cp     = request.getParameter("codigoPostal");
                PreparedStatement ps = conn.prepareStatement("INSERT INTO ciudad (nombre, departamento, codigo_postal) VALUES (?,?,?)");
                ps.setString(1, nombre); ps.setString(2, depto); ps.setString(3, cp);
                ps.executeUpdate();
                msgCat = "Ciudad '" + nombre + "' agregada correctamente.";
            } else if ("addTipo".equals(accion)) {
                String nombre = request.getParameter("nombreTipo");
                String desc   = request.getParameter("descripcionTipo");
                PreparedStatement ps = conn.prepareStatement("INSERT INTO tipo_propiedad (nombre, descripcion) VALUES (?,?)");
                ps.setString(1, nombre); ps.setString(2, desc);
                ps.executeUpdate();
                msgCat = "Tipo de propiedad '" + nombre + "' agregado correctamente.";
            } else if ("delCiudad".equals(accion)) {
                conn.prepareStatement("DELETE FROM ciudad WHERE id_ciudad=" + request.getParameter("idCiudad")).executeUpdate();
                msgCat = "Ciudad eliminada.";
            } else if ("delTipo".equals(accion)) {
                conn.prepareStatement("DELETE FROM tipo_propiedad WHERE id_tipo=" + request.getParameter("idTipo")).executeUpdate();
                msgCat = "Tipo eliminado.";
            }
        } catch (Exception ex) { msgCat = "Error: " + ex.getMessage(); }
    }

    java.util.List<String[]> ciudades = new java.util.ArrayList<>();
    java.util.List<String[]> tipos    = new java.util.ArrayList<>();
    try (Connection conn = getConn()) {
        ResultSet rc = conn.createStatement().executeQuery("SELECT id_ciudad, nombre, departamento, codigo_postal FROM ciudad ORDER BY nombre");
        while (rc.next()) ciudades.add(new String[]{ rc.getString(1), rc.getString(2), rc.getString(3), rc.getString(4) });
        ResultSet rt = conn.createStatement().executeQuery("SELECT id_tipo, nombre, descripcion FROM tipo_propiedad ORDER BY nombre");
        while (rt.next()) tipos.add(new String[]{ rt.getString(1), rt.getString(2), rt.getString(3) != null ? rt.getString(3) : "" });
    } catch (Exception ex) { ex.printStackTrace(); }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_admin.jsp" %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Parametrización</h2>
        <p class="text-muted mb-4">Gestiona las ciudades y tipos de propiedad del sistema</p>

        <% if (msgCat != null) { %>
        <div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgCat %></div>
        <% } %>

        <div class="row g-4">
            <!-- Ciudades -->
            <div class="col-lg-6">
                <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:28px;border:1px solid var(--border-subtle);">
                    <h5 class="fw-bold mb-3"><i class="bi bi-geo-alt me-2" style="color:var(--color-accent);"></i>Ciudades</h5>
                    <form action="<%= ctx %>/admin/catalogos.jsp" method="POST" class="row g-2 mb-4">
                        <input type="hidden" name="accion" value="addCiudad">
                        <div class="col-5"><input type="text" name="nombreCiudad" class="form-control-vesta" placeholder="Ciudad" required style="padding:10px 14px;font-size:0.9rem;"></div>
                        <div class="col-4"><input type="text" name="departamento" class="form-control-vesta" placeholder="Departamento" required style="padding:10px 14px;font-size:0.9rem;"></div>
                        <div class="col-3"><button type="submit" class="btn btn-vesta-accent w-100" style="padding:10px;font-size:0.85rem;"><i class="bi bi-plus"></i> Agregar</button></div>
                        <input type="hidden" name="codigoPostal" value="">
                    </form>
                    <table class="table-vesta" style="font-size:0.9rem;">
                        <thead><tr><th>Ciudad</th><th>Departamento</th><th></th></tr></thead>
                        <tbody>
                        <% for (String[] c : ciudades) { %>
                        <tr>
                            <td class="fw-600"><%= c[1] %></td>
                            <td><%= c[2] %></td>
                            <td>
                                <form action="<%= ctx %>/admin/catalogos.jsp" method="POST" style="display:inline;">
                                    <input type="hidden" name="accion" value="delCiudad">
                                    <input type="hidden" name="idCiudad" value="<%= c[0] %>">
                                    <button type="submit" class="btn btn-sm" style="color:var(--status-danger);background:none;border:none;" data-confirm="¿Eliminar esta ciudad?">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Tipos de Propiedad -->
            <div class="col-lg-6">
                <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:28px;border:1px solid var(--border-subtle);">
                    <h5 class="fw-bold mb-3"><i class="bi bi-building me-2" style="color:var(--color-accent);"></i>Tipos de Propiedad</h5>
                    <form action="<%= ctx %>/admin/catalogos.jsp" method="POST" class="row g-2 mb-4">
                        <input type="hidden" name="accion" value="addTipo">
                        <div class="col-5"><input type="text" name="nombreTipo" class="form-control-vesta" placeholder="Nombre" required style="padding:10px 14px;font-size:0.9rem;"></div>
                        <div class="col-4"><input type="text" name="descripcionTipo" class="form-control-vesta" placeholder="Descripción" style="padding:10px 14px;font-size:0.9rem;"></div>
                        <div class="col-3"><button type="submit" class="btn btn-vesta-accent w-100" style="padding:10px;font-size:0.85rem;"><i class="bi bi-plus"></i> Agregar</button></div>
                    </form>
                    <table class="table-vesta" style="font-size:0.9rem;">
                        <thead><tr><th>Tipo</th><th>Descripción</th><th></th></tr></thead>
                        <tbody>
                        <% for (String[] t : tipos) { %>
                        <tr>
                            <td class="fw-600"><%= t[1] %></td>
                            <td><%= t[2] %></td>
                            <td>
                                <form action="<%= ctx %>/admin/catalogos.jsp" method="POST" style="display:inline;">
                                    <input type="hidden" name="accion" value="delTipo">
                                    <input type="hidden" name="idTipo" value="<%= t[0] %>">
                                    <button type="submit" class="btn btn-sm" style="color:var(--status-danger);background:none;border:none;" data-confirm="¿Eliminar este tipo?">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
