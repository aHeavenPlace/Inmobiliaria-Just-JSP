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
    String msgForm = null; String errForm = null;

    // Cargar ciudades y tipos
    java.util.List<String[]> ciudades = new java.util.ArrayList<>();
    java.util.List<String[]> tipos    = new java.util.ArrayList<>();
    java.util.List<String[]> inmobs   = new java.util.ArrayList<>();

    // Variables para edición
    String editId = request.getParameter("id");
    String titulo="", descripcion="", precio="", operacion="Venta", direccion="";
    String idCiudad="", idTipo="", idInmob="", hab="", ban="", area="", parq="false", imgUrl="";

    try (Connection conn = getConn()) {
        ResultSet rc = conn.createStatement().executeQuery("SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
        while (rc.next()) ciudades.add(new String[]{ rc.getString(1), rc.getString(2) });
        ResultSet rt = conn.createStatement().executeQuery("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
        while (rt.next()) tipos.add(new String[]{ rt.getString(1), rt.getString(2) });
        ResultSet ri = conn.createStatement().executeQuery("SELECT id_inmobiliaria, nombre FROM inmobiliaria WHERE estado='activo' ORDER BY nombre");
        while (ri.next()) inmobs.add(new String[]{ ri.getString(1), ri.getString(2) });

        // Cargar datos para edición
        if (editId != null && !editId.isEmpty()) {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM propiedad WHERE id_propiedad=?");
            ps.setInt(1, Integer.parseInt(editId));
            ResultSet rp = ps.executeQuery();
            if (rp.next()) {
                titulo      = rp.getString("titulo");
                descripcion = rp.getString("descripcion") != null ? rp.getString("descripcion") : "";
                precio      = rp.getString("precio");
                operacion   = rp.getString("operacion");
                direccion   = rp.getString("direccion") != null ? rp.getString("direccion") : "";
                idCiudad    = rp.getString("id_ciudad");
                idTipo      = rp.getString("id_tipo");
                idInmob     = rp.getString("id_inmobiliaria") != null ? rp.getString("id_inmobiliaria") : "";
                hab         = rp.getString("num_habitaciones") != null ? rp.getString("num_habitaciones") : "";
                ban         = rp.getString("num_banos") != null ? rp.getString("num_banos") : "";
                area        = rp.getString("area_m2") != null ? rp.getString("area_m2") : "";
                parq        = String.valueOf(rp.getBoolean("parqueadero"));
            }
        }
    } catch (Exception ex) { ex.printStackTrace(); }

    // Procesar POST
    if ("POST".equalsIgnoreCase(request.getMethod()) && idUsrObj != null) {
        request.setCharacterEncoding("UTF-8");
        titulo      = request.getParameter("titulo");
        descripcion = request.getParameter("descripcion");
        precio      = request.getParameter("precio");
        operacion   = request.getParameter("operacion");
        direccion   = request.getParameter("direccion");
        idCiudad    = request.getParameter("idCiudad");
        idTipo      = request.getParameter("idTipo");
        idInmob     = request.getParameter("idInmobiliaria");
        hab         = request.getParameter("habitaciones");
        ban         = request.getParameter("banos");
        area        = request.getParameter("area");
        parq        = request.getParameter("parqueadero") != null ? "true" : "false";
        imgUrl      = request.getParameter("imagenUrl");
        editId      = request.getParameter("editId");

        try (Connection conn = getConn()) {
            if (editId != null && !editId.isEmpty()) {
                // Actualizar
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE propiedad SET titulo=?, descripcion=?, precio=?, operacion=?, direccion=?, " +
                    "id_ciudad=?, id_tipo=?, id_inmobiliaria=?, num_habitaciones=?, num_banos=?, area_m2=?, parqueadero=? " +
                    "WHERE id_propiedad=?");
                ps.setString(1, titulo); ps.setString(2, descripcion);
                ps.setLong(3, Long.parseLong(precio)); ps.setString(4, operacion);
                ps.setString(5, direccion); ps.setInt(6, Integer.parseInt(idCiudad));
                ps.setInt(7, Integer.parseInt(idTipo));
                if (idInmob != null && !idInmob.isEmpty()) ps.setInt(8, Integer.parseInt(idInmob)); else ps.setNull(8, Types.INTEGER);
                if (hab != null && !hab.isEmpty()) ps.setInt(9, Integer.parseInt(hab)); else ps.setNull(9, Types.INTEGER);
                if (ban != null && !ban.isEmpty()) ps.setInt(10, Integer.parseInt(ban)); else ps.setNull(10, Types.INTEGER);
                if (area != null && !area.isEmpty()) ps.setDouble(11, Double.parseDouble(area)); else ps.setNull(11, Types.DOUBLE);
                ps.setBoolean(12, "true".equals(parq));
                ps.setInt(13, Integer.parseInt(editId));
                ps.executeUpdate();
                msgForm = "Propiedad actualizada exitosamente.";
            } else {
                // Insertar
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO propiedad (titulo, descripcion, precio, operacion, direccion, id_ciudad, id_tipo, id_inmobiliaria, " +
                    "id_usuario, num_habitaciones, num_banos, area_m2, parqueadero, estado) " +
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,'activo')", Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, titulo); ps.setString(2, descripcion);
                ps.setLong(3, Long.parseLong(precio)); ps.setString(4, operacion);
                ps.setString(5, direccion); ps.setInt(6, Integer.parseInt(idCiudad));
                ps.setInt(7, Integer.parseInt(idTipo));
                if (idInmob != null && !idInmob.isEmpty()) ps.setInt(8, Integer.parseInt(idInmob)); else ps.setNull(8, Types.INTEGER);
                ps.setInt(9, (Integer) idUsrObj);
                if (hab != null && !hab.isEmpty()) ps.setInt(10, Integer.parseInt(hab)); else ps.setNull(10, Types.INTEGER);
                if (ban != null && !ban.isEmpty()) ps.setInt(11, Integer.parseInt(ban)); else ps.setNull(11, Types.INTEGER);
                if (area != null && !area.isEmpty()) ps.setDouble(12, Double.parseDouble(area)); else ps.setNull(12, Types.DOUBLE);
                ps.setBoolean(13, "true".equals(parq));
                ps.executeUpdate();
                ResultSet gk = ps.getGeneratedKeys();
                int nuevoId = gk.next() ? gk.getInt(1) : -1;
                // Guardar imagen si la puso
                if (imgUrl != null && !imgUrl.isEmpty() && nuevoId > 0) {
                    conn.prepareStatement("INSERT INTO imagen_propiedad (id_propiedad, url, orden) VALUES (" + nuevoId + ",'" + imgUrl + "',1)").executeUpdate();
                }
                msgForm = "Propiedad publicada exitosamente.";
                titulo=""; descripcion=""; precio=""; operacion="Venta"; direccion="";
                idCiudad=""; idTipo=""; idInmob=""; hab=""; ban=""; area=""; parq="false";
            }
        } catch (Exception ex) { errForm = "Error al guardar: " + ex.getMessage(); ex.printStackTrace(); }
    }

    boolean esEdicion = editId != null && !editId.isEmpty();
    String sidebarInclude = "admin".equals(rolI) ? "/components/sidebar_admin.jsp" : "/components/sidebar_inmobiliaria.jsp";
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <% if ("admin".equals(rolI)) { %>
    <%@ include file="/components/sidebar_admin.jsp" %>
    <% } else { %>
    <%@ include file="/components/sidebar_inmobiliaria.jsp" %>
    <% } %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1"><%= esEdicion ? "Editar Propiedad" : "Publicar Nueva Propiedad" %></h2>
        <p class="text-muted mb-4"><%= esEdicion ? "Actualiza los datos del inmueble" : "Completa los datos para publicar un nuevo inmueble en el catálogo" %></p>

        <% if (msgForm != null) { %><div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgForm %></div><% } %>
        <% if (errForm != null) { %><div class="alert-danger-vsta mb-4"><i class="bi bi-x-circle me-1"></i> <%= errForm %></div><% } %>

        <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:32px;border:1px solid var(--border-subtle);max-width:800px;">
            <form action="<%= ctx %>/<%= "admin".equals(rolI) ? "admin" : "inmobiliaria" %>/propiedad_form.jsp" method="POST">
                <% if (esEdicion) { %><input type="hidden" name="editId" value="<%= editId %>"><% } %>
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label-vesta">Título del Inmueble *</label>
                        <input type="text" name="titulo" class="form-control-vesta" value="<%= titulo %>" placeholder="Ej: Apartamento de lujo en Cabecera" required>
                    </div>
                    <div class="col-12">
                        <label class="form-label-vesta">Descripción</label>
                        <textarea name="descripcion" class="form-control-vesta" rows="4" style="resize:vertical;" placeholder="Describe el inmueble..."><%= descripcion %></textarea>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Precio (COP) *</label>
                        <input type="number" name="precio" class="form-control-vesta" value="<%= precio %>" placeholder="250000000" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Operación *</label>
                        <select name="operacion" class="form-select-vesta" required>
                            <option value="Venta" <%= "Venta".equals(operacion) ? "selected" : "" %>>Venta</option>
                            <option value="Arriendo" <%= "Arriendo".equals(operacion) ? "selected" : "" %>>Arriendo</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Ciudad *</label>
                        <select name="idCiudad" class="form-select-vesta" required>
                            <option value="">Selecciona</option>
                            <% for (String[] c : ciudades) { %>
                            <option value="<%= c[0] %>" <%= c[0].equals(idCiudad) ? "selected" : "" %>><%= c[1] %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Tipo *</label>
                        <select name="idTipo" class="form-select-vesta" required>
                            <option value="">Selecciona</option>
                            <% for (String[] t : tipos) { %>
                            <option value="<%= t[0] %>" <%= t[0].equals(idTipo) ? "selected" : "" %>><%= t[1] %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Inmobiliaria</label>
                        <select name="idInmobiliaria" class="form-select-vesta">
                            <option value="">Sin inmobiliaria</option>
                            <% for (String[] i : inmobs) { %>
                            <option value="<%= i[0] %>" <%= i[0].equals(idInmob) ? "selected" : "" %>><%= i[1] %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Dirección</label>
                        <input type="text" name="direccion" class="form-control-vesta" value="<%= direccion %>" placeholder="Calle 50 #10-20">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-vesta">Habitaciones</label>
                        <input type="number" name="habitaciones" class="form-control-vesta" value="<%= hab %>" min="0">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-vesta">Baños</label>
                        <input type="number" name="banos" class="form-control-vesta" value="<%= ban %>" min="0">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-vesta">Área (m²)</label>
                        <input type="number" name="area" class="form-control-vesta" value="<%= area %>" step="0.5">
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <div class="form-check" style="padding:14px 0;">
                            <input type="checkbox" name="parqueadero" id="parqueadero" value="true" <%= "true".equals(parq) ? "checked" : "" %>
                                   style="width:20px;height:20px;accent-color:var(--color-accent);vertical-align:middle;">
                            <label for="parqueadero" class="ms-2 fw-600" style="font-size:0.9rem;">Parqueadero</label>
                        </div>
                    </div>
                    <% if (!esEdicion) { %>
                    <div class="col-12">
                        <label class="form-label-vesta">URL de Imagen Principal</label>
                        <input type="url" name="imagenUrl" class="form-control-vesta" placeholder="https://ejemplo.com/imagen.jpg">
                        <small class="text-muted">Pega la URL de una imagen para el inmueble</small>
                    </div>
                    <% } %>
                    <div class="col-12 mt-3">
                        <button type="submit" class="btn btn-vesta-accent me-2">
                            <i class="bi bi-save me-1"></i> <%= esEdicion ? "Actualizar" : "Publicar Propiedad" %>
                        </button>
                        <a href="<%= ctx %>/<%= "admin".equals(rolI) ? "admin" : "inmobiliaria" %>/propiedades.jsp" class="btn btn-vesta-outline">Cancelar</a>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
