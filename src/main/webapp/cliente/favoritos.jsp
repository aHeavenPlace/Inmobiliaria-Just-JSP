<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,java.text.NumberFormat,java.util.Locale" %>
<%@ include file="/components/conexion.jsp" %>
<%
    if (session.getAttribute("rolActivo") == null) { response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=/cliente/favoritos.jsp"); return; }
    String ctx = request.getContextPath();
    Object idUsrObj = session.getAttribute("idUsuario");
    java.util.List<java.util.Map<String,String>> favoritos = new java.util.ArrayList<>();
    String msgFav = null;

    // Eliminar favorito por POST
    if ("POST".equalsIgnoreCase(request.getMethod()) && idUsrObj != null) {
        int idFav = Integer.parseInt(request.getParameter("idPropiedad"));
        try (Connection conn = getConn()) {
            PreparedStatement psDel = conn.prepareStatement("DELETE FROM favorito WHERE id_usuario=? AND id_propiedad=?");
            psDel.setInt(1, (Integer) idUsrObj); psDel.setInt(2, idFav);
            psDel.executeUpdate();
            msgFav = "Propiedad eliminada de favoritos.";
        } catch (Exception ex) { ex.printStackTrace(); }
    }

    if (idUsrObj != null) {
        int idUsr = (Integer) idUsrObj;
        NumberFormat nf = NumberFormat.getNumberInstance(new Locale("es","CO"));
        try (Connection conn = getConn()) {
            String sql = "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, tp.nombre AS tipo, c.nombre AS ciudad, " +
                         "(SELECT img.url FROM imagen_propiedad img WHERE img.id_propiedad = p.id_propiedad LIMIT 1) AS imagen " +
                         "FROM favorito f JOIN propiedad p ON p.id_propiedad = f.id_propiedad " +
                         "JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
                         "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                         "WHERE f.id_usuario=" + idUsr + " ORDER BY f.fecha_agregado DESC";
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while (rs.next()) {
                java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
                m.put("id", rs.getString("id_propiedad"));
                m.put("titulo", rs.getString("titulo"));
                m.put("precio", rs.getString("precio"));
                m.put("operacion", rs.getString("operacion"));
                m.put("tipo", rs.getString("tipo"));
                m.put("ciudad", rs.getString("ciudad"));
                m.put("imagen", rs.getString("imagen"));
                favoritos.add(m);
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("es","CO"));
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_cliente.jsp" %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Mis Favoritos</h2>
        <p class="text-muted mb-4">Propiedades que guardaste para revisitar</p>
        <% if (msgFav != null) { %>
        <div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgFav %></div>
        <% } %>
        <% if (favoritos.isEmpty()) { %>
        <div class="text-center py-5" style="background:var(--bg-surface);border-radius:var(--radius-lg);border:1px solid var(--border-subtle);">
            <i class="bi bi-heart" style="font-size:3rem;color:var(--text-light);"></i>
            <h5 class="mt-3 fw-bold">Sin favoritos aún</h5>
            <p class="text-muted">Agrega propiedades a favoritos desde el catálogo.</p>
            <a href="<%= ctx %>/catalogo.jsp" class="btn btn-vesta-accent">Explorar catálogo</a>
        </div>
        <% } else { %>
        <div class="row g-4">
            <% for (java.util.Map<String,String> p : favoritos) {
                String img = p.get("imagen");
                if (img == null || img.isEmpty()) img = "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=600";
                String precio = "—"; try { precio = "$" + nf.format(Long.parseLong(p.get("precio"))); } catch (Exception e) {}
            %>
            <div class="col-md-6 col-lg-4">
                <div class="property-card h-100">
                    <div class="property-thumb-wrap" style="height:200px;">
                        <img src="<%= img %>" alt="<%= p.get("titulo") %>" class="property-thumb">
                        <span class="badge-operation"><%= p.get("operacion") %></span>
                    </div>
                    <div class="property-body">
                        <div class="property-price"><%= precio %></div>
                        <div class="property-title"><%= p.get("titulo") %></div>
                        <div class="property-location"><i class="bi bi-geo-alt-fill" style="color:var(--color-accent);"></i> <%= p.get("ciudad") %></div>
                        <div class="d-flex gap-2 mt-3">
                            <a href="<%= ctx %>/detalle.jsp?id=<%= p.get("id") %>" class="btn btn-vesta-outline flex-grow-1" style="padding:8px;font-size:0.85rem;text-align:center;">Ver propiedad</a>
                            <form action="<%= ctx %>/cliente/favoritos.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="idPropiedad" value="<%= p.get("id") %>">
                                <button type="submit" class="btn" style="background:var(--status-danger-bg);color:var(--status-danger);border:none;padding:8px 14px;border-radius:var(--radius-md);" data-confirm="¿Eliminar de favoritos?">
                                    <i class="bi bi-heart-fill"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
