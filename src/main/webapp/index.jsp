<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,java.text.NumberFormat,java.util.Locale" %>
<%-- =====================================================================
     index.jsp — Página principal / Landing de Vesta Inmobiliaria
     JSP Modelo 1 puro — Tomcat 8.5 / JSP 2.3
     ===================================================================== --%>
<%@ include file="/components/conexion.jsp" %>
<%@ include file="/components/header.jsp" %>

<%
    /* Cargar ciudades y tipos para el buscador */
    java.util.List<String[]> ciudades = new java.util.ArrayList<>();
    java.util.List<String[]> tipos    = new java.util.ArrayList<>();
    int totalPropiedades = 0;
    int totalCiudades    = 0;
    int totalInmobiliarias = 0;

    /* Propiedades destacadas (máx 6, activas) */
    java.util.List<java.util.Map<String,String>> propiedades = new java.util.ArrayList<>();

    try (Connection conn = getConn()) {
        // Ciudades
        ResultSet rsCiud = conn.createStatement().executeQuery("SELECT id_ciudad, nombre, departamento FROM ciudad ORDER BY nombre");
        while (rsCiud.next()) ciudades.add(new String[]{ rsCiud.getString("id_ciudad"), rsCiud.getString("nombre"), rsCiud.getString("departamento") });

        // Tipos
        ResultSet rsTipo = conn.createStatement().executeQuery("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
        while (rsTipo.next()) tipos.add(new String[]{ rsTipo.getString("id_tipo"), rsTipo.getString("nombre") });

        // Stats globales
        totalPropiedades   = ((Number) conn.createStatement().executeQuery("SELECT COUNT(*) FROM propiedad WHERE estado='activo'").next() ? 0 : 0);
        ResultSet rsStats  = conn.createStatement().executeQuery("SELECT COUNT(*) AS c FROM propiedad WHERE estado='activo'");
        if (rsStats.next()) totalPropiedades = rsStats.getInt("c");
        ResultSet rsC2     = conn.createStatement().executeQuery("SELECT COUNT(*) AS c FROM ciudad");
        if (rsC2.next()) totalCiudades = rsC2.getInt("c");
        ResultSet rsI2     = conn.createStatement().executeQuery("SELECT COUNT(*) AS c FROM inmobiliaria WHERE estado='activo'");
        if (rsI2.next()) totalInmobiliarias = rsI2.getInt("c");

        // Propiedades destacadas
        String sqlProp = "SELECT p.id_propiedad, p.titulo, p.precio, p.operacion, " +
                         "tp.nombre AS tipo, c.nombre AS ciudad, " +
                         "p.num_habitaciones, p.num_banos, p.area_m2, " +
                         "(SELECT img.url FROM imagen_propiedad img WHERE img.id_propiedad = p.id_propiedad LIMIT 1) AS imagen " +
                         "FROM propiedad p " +
                         "JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
                         "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                         "WHERE p.estado = 'activo' ORDER BY p.fecha_publicacion DESC LIMIT 6";
        ResultSet rsP = conn.createStatement().executeQuery(sqlProp);
        while (rsP.next()) {
            java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
            m.put("id",          rsP.getString("id_propiedad"));
            m.put("titulo",      rsP.getString("titulo"));
            m.put("precio",      rsP.getString("precio"));
            m.put("operacion",   rsP.getString("operacion"));
            m.put("tipo",        rsP.getString("tipo"));
            m.put("ciudad",      rsP.getString("ciudad"));
            m.put("hab",         rsP.getString("num_habitaciones"));
            m.put("ban",         rsP.getString("num_banos"));
            m.put("area",        rsP.getString("area_m2"));
            m.put("imagen",      rsP.getString("imagen"));
            propiedades.add(m);
        }
    } catch (SQLException ex) {
        ex.printStackTrace();
    }

    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("es","CO"));
    String ctx = request.getContextPath();
%>

<!-- ======= HERO ======= -->
<section class="hero-section">
    <div class="container">
        <span class="badge bg-white text-dark px-3 py-2 rounded-pill fw-bold mb-3 shadow-sm"
              style="background:rgba(255,255,255,0.95)!important;">
            <i class="bi bi-stars" style="color:var(--color-gold);"></i> Experiencia Inmobiliaria Premium
        </span>
        <h1 class="hero-title">Encuentra el hogar o espacio ideal<br>con elegancia y confianza absoluta</h1>
        <p class="hero-subtitle">
            Explora una colección curada de casas, apartamentos, locales y oficinas
            en las mejores ciudades de Colombia.
        </p>
    </div>
</section>

<!-- ======= BUSCADOR FLOTANTE ======= -->
<div class="container">
    <div class="search-card-float">
        <form action="<%= ctx %>/catalogo.jsp" method="GET" class="row g-3 align-items-end">
            <div class="col-lg-3 col-md-6">
                <label class="form-label-vesta"><i class="bi bi-geo-alt me-1"></i>Ciudad</label>
                <select name="ciudad" class="form-select-vesta">
                    <option value="">Todas las ciudades</option>
                    <% for (String[] c : ciudades) { %>
                    <option value="<%= c[0] %>"><%= c[1] %> (<%= c[2] %>)</option>
                    <% } %>
                </select>
            </div>
            <div class="col-lg-3 col-md-6">
                <label class="form-label-vesta"><i class="bi bi-building me-1"></i>Tipo de Inmueble</label>
                <select name="tipo" class="form-select-vesta">
                    <option value="">Todos los tipos</option>
                    <% for (String[] t : tipos) { %>
                    <option value="<%= t[0] %>"><%= t[1] %></option>
                    <% } %>
                </select>
            </div>
            <div class="col-lg-2 col-md-6">
                <label class="form-label-vesta"><i class="bi bi-arrow-left-right me-1"></i>Operación</label>
                <select name="operacion" class="form-select-vesta">
                    <option value="">Venta y Arriendo</option>
                    <option value="Venta">Venta</option>
                    <option value="Arriendo">Arriendo</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-6">
                <label class="form-label-vesta"><i class="bi bi-cash me-1"></i>Precio Máx ($)</label>
                <input type="number" name="precioMax" class="form-control-vesta" placeholder="Ej: 500000000" step="10000000">
            </div>
            <div class="col-lg-2 col-md-12">
                <button type="submit" id="btnBuscar" class="btn btn-vesta-accent w-100 py-3 justify-content-center">
                    <i class="bi bi-search"></i> Buscar
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ======= STATS ======= -->
<div class="container my-5">
    <div class="row g-3 text-center">
        <div class="col-md-4">
            <div class="stat-card flex-column align-items-center text-center p-4">
                <div class="stat-icon-wrap stat-icon-blue mb-2"><i class="bi bi-houses"></i></div>
                <div class="stat-number"><%= totalPropiedades %>+</div>
                <small class="text-muted fw-600">Propiedades Activas</small>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card flex-column align-items-center text-center p-4">
                <div class="stat-icon-wrap stat-icon-green mb-2"><i class="bi bi-geo-alt"></i></div>
                <div class="stat-number"><%= totalCiudades %>+</div>
                <small class="text-muted fw-600">Ciudades Disponibles</small>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card flex-column align-items-center text-center p-4">
                <div class="stat-icon-wrap stat-icon-amber mb-2"><i class="bi bi-building-check"></i></div>
                <div class="stat-number"><%= totalInmobiliarias %>+</div>
                <small class="text-muted fw-600">Inmobiliarias Aliadas</small>
            </div>
        </div>
    </div>
</div>

<!-- ======= PROPIEDADES DESTACADAS ======= -->
<div class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-vesta-charcoal mb-1" style="font-size:1.8rem;">Propiedades Destacadas</h2>
            <p class="text-vesta-gray mb-0">Las mejores opciones seleccionadas para ti</p>
        </div>
        <a href="<%= ctx %>/catalogo.jsp" class="btn btn-vesta-outline d-none d-md-flex">
            Ver todo el catálogo <i class="bi bi-arrow-right ms-1"></i>
        </a>
    </div>

    <% if (propiedades.isEmpty()) { %>
    <div class="text-center py-5" style="background:var(--bg-surface-subtle);border-radius:var(--radius-lg);">
        <i class="bi bi-house-x" style="font-size:3rem;color:var(--text-light);"></i>
        <p class="text-muted mt-3">No hay propiedades disponibles por el momento.</p>
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
                    <img src="<%= imgSrc %>" alt="<%= p.get("titulo") %>" class="property-thumb">
                    <span class="badge-operation"><%= p.get("operacion") %></span>
                    <span class="badge-type"><%= p.get("tipo") %></span>
                    <% if ("cliente".equals(rolSesion)) { %>
                    <button class="btn-favorite-heart" data-id="<%= p.get("id") %>" data-context="<%= ctx %>" type="button" title="Guardar en favoritos">
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
                        <% if (p.get("hab") != null && !p.get("hab").isEmpty()) { %>
                        <span class="feature-item"><i class="bi bi-door-open"></i> <%= p.get("hab") %> hab</span>
                        <% } %>
                        <% if (p.get("ban") != null && !p.get("ban").isEmpty()) { %>
                        <span class="feature-item"><i class="bi bi-droplet"></i> <%= p.get("ban") %> baños</span>
                        <% } %>
                        <% if (p.get("area") != null && !p.get("area").isEmpty()) { %>
                        <span class="feature-item"><i class="bi bi-aspect-ratio"></i> <%= p.get("area") %>m²</span>
                        <% } %>
                        <a href="<%= ctx %>/detalle.jsp?id=<%= p.get("id") %>"
                           class="ms-auto btn-vesta-outline"
                           style="padding:6px 14px;font-size:0.82rem;border-radius:var(--radius-md);">
                            Ver más
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <div class="text-center mt-4 d-md-none">
        <a href="<%= ctx %>/catalogo.jsp" class="btn btn-vesta-accent">Ver todo el catálogo</a>
    </div>
    <% } %>
</div>

<%@ include file="/components/footer.jsp" %>
