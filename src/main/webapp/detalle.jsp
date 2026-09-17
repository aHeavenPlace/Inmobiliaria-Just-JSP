<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,java.text.NumberFormat,java.util.Locale" %>
<%-- detalle.jsp — Detalle de propiedad + Agendar Cita (JSP Modelo 1) --%>
<%@ include file="/components/conexion.jsp" %>
<%@ include file="/components/header.jsp" %>
<%
    String ctx = request.getContextPath();
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("es","CO"));
    String idParam = request.getParameter("id");
    java.util.Map<String,String> prop = null;
    java.util.List<String> imagenes   = new java.util.ArrayList<>();
    java.util.List<String[]> caracteristicas = new java.util.ArrayList<>();
    String mensajeCita = null;
    String errorCita   = null;

    if (idParam == null || idParam.isEmpty()) {
        response.sendRedirect(ctx + "/catalogo.jsp");
        return;
    }

    // Procesar POST de agendar cita
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (session.getAttribute("idUsuario") == null) {
            response.sendRedirect(ctx + "/login.jsp?redirect=/detalle.jsp?id=" + idParam);
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String fecha       = request.getParameter("fecha");
        String hora        = request.getParameter("hora");
        String observacion = request.getParameter("observacion");
        int idUsuario      = (Integer) session.getAttribute("idUsuario");

        try (Connection conn = getConn()) {
            // Obtener agente de la propiedad para asignarlo
            ResultSet rsAgt = conn.createStatement().executeQuery(
                "SELECT id_usuario FROM propiedad WHERE id_propiedad=" + Integer.parseInt(idParam) + " LIMIT 1");
            int idAgente = rsAgt.next() ? rsAgt.getInt("id_usuario") : 1;

            PreparedStatement psCita = conn.prepareStatement(
                "INSERT INTO cita (id_propiedad, id_cliente, id_agente, fecha_hora, observaciones, estado) " +
                "VALUES (?,?,?,?::timestamp,?,'pendiente')");
            psCita.setInt(1, Integer.parseInt(idParam));
            psCita.setInt(2, idUsuario);
            psCita.setInt(3, idAgente);
            psCita.setString(4, fecha + " " + hora + ":00");
            psCita.setString(5, observacion);
            psCita.executeUpdate();
            mensajeCita = "¡Cita agendada exitosamente! El agente se pondrá en contacto contigo.";
        } catch (Exception ex) {
            errorCita = "Error al agendar la cita: " + ex.getMessage();
        }
    }

    // Cargar datos de la propiedad
    try (Connection conn = getConn()) {
        String sql = "SELECT p.*, tp.nombre AS tipo_nombre, c.nombre AS ciudad_nombre, " +
                     "c.departamento, i.nombre AS inmob_nombre, " +
                     "per.nombres AS agente_nombres, per.apellidos AS agente_apellidos, per.telefono AS agente_tel " +
                     "FROM propiedad p " +
                     "JOIN tipo_propiedad tp ON tp.id_tipo = p.id_tipo " +
                     "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                     "LEFT JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                     "LEFT JOIN usuario u ON u.id_usuario = p.id_usuario " +
                     "LEFT JOIN perfil per ON per.id_usuario = u.id_usuario " +
                     "WHERE p.id_propiedad = ? AND p.estado = 'activo'";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(idParam));
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            prop = new java.util.LinkedHashMap<>();
            prop.put("id",          rs.getString("id_propiedad"));
            prop.put("titulo",      rs.getString("titulo"));
            prop.put("descripcion", rs.getString("descripcion"));
            prop.put("precio",      rs.getString("precio"));
            prop.put("operacion",   rs.getString("operacion"));
            prop.put("tipo",        rs.getString("tipo_nombre"));
            prop.put("ciudad",      rs.getString("ciudad_nombre"));
            prop.put("depto",       rs.getString("departamento"));
            prop.put("hab",         rs.getString("num_habitaciones"));
            prop.put("ban",         rs.getString("num_banos"));
            prop.put("area",        rs.getString("area_m2"));
            prop.put("parqueadero", rs.getString("parqueadero"));
            prop.put("direccion",   rs.getString("direccion"));
            prop.put("inmob",       rs.getString("inmob_nombre"));
            prop.put("agente",      rs.getString("agente_nombres") + " " + rs.getString("agente_apellidos"));
            prop.put("agenteTel",   rs.getString("agente_tel"));
        }
        if (prop == null) { response.sendRedirect(ctx + "/error_404.jsp"); return; }

        // Imágenes
        ResultSet rsImg = conn.prepareStatement(
            "SELECT url FROM imagen_propiedad WHERE id_propiedad=" + idParam + " ORDER BY orden ASC")
            .executeQuery();
        while (rsImg.next()) imagenes.add(rsImg.getString("url"));

        // Características
        ResultSet rsCar = conn.prepareStatement(
            "SELECT car.nombre, pc.valor FROM propiedad_caracteristica pc " +
            "JOIN caracteristica car ON car.id_caracteristica = pc.id_caracteristica " +
            "WHERE pc.id_propiedad=" + idParam)
            .executeQuery();
        while (rsCar.next()) caracteristicas.add(new String[]{ rsCar.getString("nombre"), rsCar.getString("valor") });

    } catch (SQLException ex) {
        ex.printStackTrace();
        response.sendRedirect(ctx + "/error_500.jsp");
        return;
    }

    String precioStr = "—";
    try { precioStr = "$" + nf.format(Long.parseLong(prop.get("precio"))); } catch (Exception e) {}
    String imgPrincipal = imagenes.isEmpty() ? "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=1200" : imagenes.get(0);
%>

<div class="container my-5">
    <nav style="font-size:0.88rem;margin-bottom:20px;">
        <a href="<%= ctx %>/index.jsp" class="text-muted">Inicio</a>
        <span class="text-muted mx-2">/</span>
        <a href="<%= ctx %>/catalogo.jsp" class="text-muted">Catálogo</a>
        <span class="text-muted mx-2">/</span>
        <span class="text-vesta-charcoal fw-600"><%= prop.get("titulo") %></span>
    </nav>

    <% if (mensajeCita != null) { %>
    <div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= mensajeCita %></div>
    <% } %>
    <% if (errorCita != null) { %>
    <div class="alert-danger-vsta mb-4"><i class="bi bi-x-circle me-1"></i> <%= errorCita %></div>
    <% } %>

    <div class="row g-4">
        <!-- Galería + Detalles -->
        <div class="col-lg-8">
            <div style="border-radius:var(--radius-lg);overflow:hidden;height:420px;background:#E8E4DF;">
                <img src="<%= imgPrincipal %>" alt="<%= prop.get("titulo") %>"
                     style="width:100%;height:100%;object-fit:cover;">
            </div>
            <% if (imagenes.size() > 1) { %>
            <div class="d-flex gap-2 mt-2 overflow-auto pb-1">
                <% for (String img : imagenes) { %>
                <img src="<%= img %>" alt="imagen"
                     style="width:90px;height:65px;object-fit:cover;border-radius:var(--radius-sm);cursor:pointer;border:2px solid transparent;"
                     onclick="this.closest('.col-lg-8').querySelector('img').src='<%= img %>'">
                <% } %>
            </div>
            <% } %>

            <div class="mt-4" style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:28px;border:1px solid var(--border-subtle);">
                <div class="d-flex flex-wrap gap-2 mb-3">
                    <span class="badge-vesta badge-vesta-info"><%= prop.get("operacion") %></span>
                    <span class="badge-vesta badge-vesta-warning"><%= prop.get("tipo") %></span>
                </div>
                <h1 class="fw-bold" style="font-size:1.6rem;"><%= prop.get("titulo") %></h1>
                <p class="text-muted mb-3"><i class="bi bi-geo-alt-fill text-vesta-accent me-1"></i>
                    <%= prop.get("direccion") %>, <%= prop.get("ciudad") %>, <%= prop.get("depto") %></p>

                <div class="row g-3 mb-4">
                    <% if (prop.get("hab") != null) { %>
                    <div class="col-6 col-md-3">
                        <div style="background:var(--bg-surface-subtle);border-radius:var(--radius-md);padding:16px;text-align:center;">
                            <i class="bi bi-door-open" style="font-size:1.5rem;color:var(--color-accent);"></i>
                            <div class="fw-bold mt-1"><%= prop.get("hab") %></div>
                            <small class="text-muted">Habitaciones</small>
                        </div>
                    </div>
                    <% } %>
                    <% if (prop.get("ban") != null) { %>
                    <div class="col-6 col-md-3">
                        <div style="background:var(--bg-surface-subtle);border-radius:var(--radius-md);padding:16px;text-align:center;">
                            <i class="bi bi-droplet" style="font-size:1.5rem;color:var(--color-accent);"></i>
                            <div class="fw-bold mt-1"><%= prop.get("ban") %></div>
                            <small class="text-muted">Baños</small>
                        </div>
                    </div>
                    <% } %>
                    <% if (prop.get("area") != null) { %>
                    <div class="col-6 col-md-3">
                        <div style="background:var(--bg-surface-subtle);border-radius:var(--radius-md);padding:16px;text-align:center;">
                            <i class="bi bi-aspect-ratio" style="font-size:1.5rem;color:var(--color-accent);"></i>
                            <div class="fw-bold mt-1"><%= prop.get("area") %>m²</div>
                            <small class="text-muted">Área</small>
                        </div>
                    </div>
                    <% } %>
                    <div class="col-6 col-md-3">
                        <div style="background:var(--bg-surface-subtle);border-radius:var(--radius-md);padding:16px;text-align:center;">
                            <i class="bi bi-car-front" style="font-size:1.5rem;color:var(--color-accent);"></i>
                            <div class="fw-bold mt-1"><%= "true".equals(prop.get("parqueadero")) ? "Sí" : "No" %></div>
                            <small class="text-muted">Parqueadero</small>
                        </div>
                    </div>
                </div>

                <% if (prop.get("descripcion") != null && !prop.get("descripcion").isEmpty()) { %>
                <h5 class="fw-bold mb-2">Descripción</h5>
                <p style="line-height:1.8;color:var(--text-muted);"><%= prop.get("descripcion") %></p>
                <% } %>

                <% if (!caracteristicas.isEmpty()) { %>
                <h5 class="fw-bold mb-3 mt-4">Características</h5>
                <div class="row g-2">
                    <% for (String[] car : caracteristicas) { %>
                    <div class="col-md-4">
                        <div style="background:var(--bg-surface-subtle);padding:10px 16px;border-radius:var(--radius-sm);font-size:0.9rem;">
                            <i class="bi bi-check-circle-fill text-vesta-accent me-2"></i>
                            <strong><%= car[0] %></strong><%= (car[1] != null && !car[1].isEmpty()) ? ": " + car[1] : "" %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Sidebar: precio + agendar cita -->
        <div class="col-lg-4">
            <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:28px;border:1px solid var(--border-subtle);position:sticky;top:90px;">
                <div style="font-size:2rem;font-weight:700;color:var(--color-primary);letter-spacing:-1px;margin-bottom:8px;"><%= precioStr %></div>
                <div class="badge-vesta badge-vesta-info mb-3"><%= prop.get("operacion") %></div>

                <% if (prop.get("agente") != null && !prop.get("agente").trim().isEmpty()) { %>
                <div class="d-flex align-items-center gap-3 mb-4 p-3" style="background:var(--bg-surface-subtle);border-radius:var(--radius-md);">
                    <div style="width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,#C4796B,#B8956B);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:1.2rem;">
                        <%= prop.get("agente").isEmpty() ? "A" : String.valueOf(prop.get("agente").charAt(0)) %>
                    </div>
                    <div>
                        <div class="fw-bold" style="font-size:0.95rem;"><%= prop.get("agente") %></div>
                        <small class="text-muted"><%= prop.get("inmob") != null ? prop.get("inmob") : "Agente" %></small>
                        <% if (prop.get("agenteTel") != null) { %>
                        <br><small><i class="bi bi-telephone me-1"></i><%= prop.get("agenteTel") %></small>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <h6 class="fw-bold mb-3">Agendar una Visita</h6>
                <% if (session.getAttribute("idUsuario") == null) { %>
                <div class="text-center py-3">
                    <p class="text-muted small mb-3">Inicia sesión para agendar una cita con el agente.</p>
                    <a href="<%= ctx %>/login.jsp?redirect=/detalle.jsp?id=<%= idParam %>" class="btn btn-vesta-accent w-100">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Iniciar Sesión
                    </a>
                </div>
                <% } else { %>
                <form action="<%= ctx %>/detalle.jsp?id=<%= idParam %>" method="POST">
                    <div class="mb-3">
                        <label class="form-label-vesta">Fecha de Visita</label>
                        <input type="date" name="fecha" class="form-control-vesta" required
                               min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                    </div>
                    <div class="mb-3">
                        <label class="form-label-vesta">Hora</label>
                        <select name="hora" class="form-select-vesta" required>
                            <option value="">Selecciona una hora</option>
                            <option value="09:00">09:00 AM</option>
                            <option value="10:00">10:00 AM</option>
                            <option value="11:00">11:00 AM</option>
                            <option value="14:00">02:00 PM</option>
                            <option value="15:00">03:00 PM</option>
                            <option value="16:00">04:00 PM</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-vesta">Observaciones (opcional)</label>
                        <textarea name="observacion" class="form-control-vesta" rows="3"
                                  style="resize:vertical;" placeholder="¿Algún detalle o pregunta?"></textarea>
                    </div>
                    <button type="submit" id="btnAgendarCita" class="btn btn-vesta-accent w-100 py-3">
                        <i class="bi bi-calendar-check me-1"></i> Confirmar Visita
                    </button>
                </form>
                <% } %>
            </div>
        </div>
    </div>
</div>

<%@ include file="/components/footer.jsp" %>
