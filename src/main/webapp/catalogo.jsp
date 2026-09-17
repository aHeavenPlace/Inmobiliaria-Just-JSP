<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,java.text.NumberFormat,java.util.Locale" %>
<%-- =====================================================================
     catalogo.jsp — Listado de propiedades con filtros (JSP Modelo 1)
     ===================================================================== --%>
<%@ include file="/components/conexion.jsp" %>
<%@ include file="/components/header.jsp" %>
<%
    String ctx = request.getContextPath();
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("es","CO"));

    // Parámetros de filtro
    String pCiudad   = request.getParameter("ciudad");
    String pTipo     = request.getParameter("tipo");
    String pOper     = request.getParameter("operacion");
    String pPrecioMax= request.getParameter("precioMax");
    String pPrecioMin= request.getParameter("precioMin");
    String pHab      = request.getParameter("habitaciones");
    String pOrden    = request.getParameter("orden");
    if (pOrden == null || pOrden.isEmpty()) pOrden = "reciente";

    java.util.List<String[]> ciudades = new java.util.ArrayList<>();
    java.util.List<String[]> tipos    = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,String>> propiedades = new java.util.ArrayList<>();

    try (Connection conn = getConn()) {
        // Ciudades para filtro
        ResultSet rsCiud = conn.createStatement().executeQuery("SELECT id_ciudad, nombre, departamento FROM ciudad ORDER BY nombre");
        while (rsCiud.next()) ciudades.add(new String[]{ rsCiud.getString("id_ciudad"), rsCiud.getString("nombre"), rsCiud.getString("departamento") });

        // Tipos para filtro
        ResultSet rsTipo = conn.createStatement().executeQuery("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
        while (rsTipo.next()) tipos.add(new String[]{ rsTipo.getString("id_tipo"), rsTipo.getString("nombre") });

        // Construir consulta dinámica
        StringBuilder sql = new StringBuilder(
            "SELECT p.id_propiedad, p.titulo, p.precio, p.tipo_operacion AS operacion, p.habitaciones, p.banos, p.area_m2, " +
            "tp.nombre AS tipo, c.nombre AS ciudad, c.id_ciudad, " +
            "(SELECT img.url FROM imagen_propiedad img WHERE img.id_propiedad = p.id_propiedad ORDER BY img.orden ASC LIMIT 1) AS imagen " +
            "FROM propiedad p " +
            "JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
            "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
            "WHERE p.estado = 'disponible' ");
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (pCiudad != null && !pCiudad.isEmpty()) {
            sql.append("AND p.id_ciudad = ? "); params.add(Integer.parseInt(pCiudad));
        }
        if (pTipo != null && !pTipo.isEmpty()) {
            sql.append("AND p.id_tipo = ? "); params.add(Integer.parseInt(pTipo));
        }
        if (pOper != null && !pOper.isEmpty()) {
            sql.append("AND LOWER(p.tipo_operacion) = LOWER(?) "); params.add(pOper);
        }
        if (pPrecioMax != null && !pPrecioMax.isEmpty()) {
            sql.append("AND p.precio <= ? "); params.add(Long.parseLong(pPrecioMax));
        }
        if (pPrecioMin != null && !pPrecioMin.isEmpty()) {
            sql.append("AND p.precio >= ? "); params.add(Long.parseLong(pPrecioMin));
        }
        if (pHab != null && !pHab.isEmpty()) {
            sql.append("AND p.habitaciones >= ? "); params.add(Integer.parseInt(pHab));
        }
        if ("precio_asc".equals(pOrden))  sql.append("ORDER BY p.precio ASC ");
        else if ("precio_desc".equals(pOrden)) sql.append("ORDER BY p.precio DESC ");
        else sql.append("ORDER BY p.fecha_publicacion DESC ");

        PreparedStatement ps = conn.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            Object o = params.get(i);
            if (o instanceof Integer) ps.setInt(i+1, (Integer) o);
            else if (o instanceof Long) ps.setLong(i+1, (Long) o);
            else ps.setString(i+1, (String) o);
        }
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
            m.put("id",        rs.getString("id_propiedad"));
            m.put("titulo",    rs.getString("titulo"));
            m.put("precio",    rs.getString("precio"));
            m.put("operacion", rs.getString("operacion"));
            m.put("tipo",      rs.getString("tipo"));
            m.put("ciudad",    rs.getString("ciudad"));
            m.put("hab",       rs.getString("habitaciones"));
            m.put("ban",       rs.getString("banos"));
            m.put("area",      rs.getString("area_m2"));
            m.put("imagen",    rs.getString("imagen"));
            propiedades.add(m);
        }
    } catch (SQLException ex) {
        ex.printStackTrace();
    }
%>

<div class="container my-5">
    <div class="vesta-header-section mb-4">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div>
                <span class="badge vesta-badge px-3 py-2 rounded-pill mb-2"><i class="bi bi-grid me-1"></i>Catálogo</span>
                <h1 class="fw-bold text-charcoal mb-1" style="font-size:2rem;">Propiedades Disponibles</h1>
                <p class="text-terracotta-muted mb-0"><%= propiedades.size() %> resultado(s) encontrado(s)</p>
            </div>
        </div>
    </div>

    <!-- Filtros -->
    <form action="<%= ctx %>/catalogo.jsp" method="GET" id="filtroForm">
        <div class="row g-2 mb-4 align-items-end">
            <div class="col-md-2">
                <label class="form-label-vesta">Ciudad</label>
                <select name="ciudad" class="form-select-vesta">
                    <option value="">Todas</option>
                    <% for (String[] c : ciudades) { %>
                    <option value="<%= c[0] %>" <%= (pCiudad != null && pCiudad.equals(c[0])) ? "selected" : "" %>><%= c[1] %></option>
                    <% } %>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label-vesta">Tipo</label>
                <select name="tipo" class="form-select-vesta">
                    <option value="">Todos</option>
                    <% for (String[] t : tipos) { %>
                    <option value="<%= t[0] %>" <%= (pTipo != null && pTipo.equals(t[0])) ? "selected" : "" %>><%= t[1] %></option>
                    <% } %>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label-vesta">Operación</label>
                <select name="operacion" class="form-select-vesta">
                    <option value="">Todas</option>
                    <option value="Venta"   <%= "Venta".equals(pOper)   ? "selected" : "" %>>Venta</option>
                    <option value="Arriendo"<%= "Arriendo".equals(pOper) ? "selected" : "" %>>Arriendo</option>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label-vesta">Precio Máx ($)</label>
                <input type="number" name="precioMax" class="form-control-vesta" value="<%= pPrecioMax != null ? pPrecioMax : "" %>" step="10000000">
            </div>
            <div class="col-md-2">
                <label class="form-label-vesta">Ordenar por</label>
                <select name="orden" class="form-select-vesta">
                    <option value="reciente" <%= "reciente".equals(pOrden) ? "selected" : "" %>>Más reciente</option>
                    <option value="precio_asc" <%= "precio_asc".equals(pOrden) ? "selected" : "" %>>Precio ↑</option>
                    <option value="precio_desc" <%= "precio_desc".equals(pOrden) ? "selected" : "" %>>Precio ↓</option>
                </select>
            </div>
            <div class="col-md-2">
                <button type="submit" id="btnFiltrar" class="btn btn-vesta-accent w-100" style="padding:14px;">
                    <i class="bi bi-funnel me-1"></i> Filtrar
                </button>
            </div>
        </div>
    </form>

    <!-- Resultados -->
    <% if (propiedades.isEmpty()) { %>
    <div class="text-center py-5" style="background:var(--bg-surface);border-radius:var(--radius-lg);border:1px solid var(--border-subtle);">
        <i class="bi bi-house-x" style="font-size:3rem;color:var(--text-light);"></i>
        <h5 class="mt-3 fw-bold">Sin resultados</h5>
        <p class="text-muted">No encontramos propiedades con esos filtros. Prueba con otros criterios.</p>
        <a href="<%= ctx %>/catalogo.jsp" class="btn btn-vesta-outline">Limpiar filtros</a>
    </div>
    <% } else { %>
    <div class="row g-4">
        <% for (java.util.Map<String,String> p : propiedades) {
            String imgSrc = p.get("imagen");
            if (imgSrc == null || imgSrc.isEmpty())
                imgSrc = "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=600";
            String precioStr = "—";
            try { precioStr = "$" + nf.format(Long.parseLong(p.get("precio"))); } catch (Exception e) {}
        %>
        <div class="col-lg-4 col-md-6">
            <div class="property-card h-100">
                <div class="property-thumb-wrap">
                    <img src="<%= imgSrc %>" alt="<%= p.get("titulo") %>" class="property-thumb" loading="lazy">
                    <span class="badge-operation"><%= p.get("operacion") %></span>
                    <span class="badge-type"><%= p.get("tipo") %></span>
                    <% if ("cliente".equals(rolSesion)) { %>
                    <button class="btn-favorite-heart" data-id="<%= p.get("id") %>" data-context="<%= ctx %>" type="button">
                        <i class="bi bi-heart"></i>
                    </button>
                    <% } %>
                </div>
                <div class="property-body">
                    <div class="property-price"><%= precioStr %></div>
                    <div class="property-title"><%= p.get("titulo") %></div>
                    <div class="property-location">
                        <i class="bi bi-geo-alt-fill" style="color:var(--color-accent);"></i>
                        <%= p.get("ciudad") %>
                    </div>
                    <div class="property-features">
                        <% if (p.get("hab") != null) { %><span class="feature-item"><i class="bi bi-door-open"></i> <%= p.get("hab") %></span><% } %>
                        <% if (p.get("ban") != null) { %><span class="feature-item"><i class="bi bi-droplet"></i> <%= p.get("ban") %></span><% } %>
                        <% if (p.get("area") != null) { %><span class="feature-item"><i class="bi bi-aspect-ratio"></i> <%= p.get("area") %>m²</span><% } %>
                        <a href="<%= ctx %>/detalle.jsp?id=<%= p.get("id") %>"
                           class="ms-auto btn-vesta-outline" style="padding:6px 14px;font-size:0.82rem;border-radius:var(--radius-md);">
                            Ver más
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

<%@ include file="/components/footer.jsp" %>
