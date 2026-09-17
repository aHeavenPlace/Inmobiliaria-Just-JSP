<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,javax.servlet.http.Part,java.io.*,java.util.UUID" %>
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
            PreparedStatement psImgLoad = conn.prepareStatement("SELECT url FROM imagen_propiedad WHERE id_propiedad=? ORDER BY orden ASC LIMIT 1");
            psImgLoad.setInt(1, Integer.parseInt(editId));
            ResultSet rImgLoad = psImgLoad.executeQuery();
            if (rImgLoad.next()) imgUrl = rImgLoad.getString("url");
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

        // Procesar subida de archivo local desde la PC
        try {
            Part filePart = request.getPart("imagenArchivo");
            if (filePart != null && filePart.getSize() > 0) {
                String subName = filePart.getSubmittedFileName();
                if (subName != null && !subName.trim().isEmpty()) {
                    String ext = "jpg";
                    int dot = subName.lastIndexOf(".");
                    if (dot > 0) ext = subName.substring(dot + 1).toLowerCase();
                    String fileName = "prop_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + ext;
                    String uploadPath = application.getRealPath("/uploads/propiedades");
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    File dest = new File(uploadDir, fileName);
                    try (InputStream in = filePart.getInputStream(); OutputStream outStream = new FileOutputStream(dest)) {
                        byte[] buf = new byte[8192];
                        int len;
                        while ((len = in.read(buf)) > 0) outStream.write(buf, 0, len);
                    }
                    imgUrl = ctx + "/uploads/propiedades/" + fileName;
                }
            }
        } catch (Exception exPart) {
            System.err.println("Error procesando imagen de propiedad: " + exPart.getMessage());
        }

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

                // Actualizar imagen si se proporcionó una nueva
                if (imgUrl != null && !imgUrl.isEmpty()) {
                    PreparedStatement psImgCheck = conn.prepareStatement("SELECT id_imagen FROM imagen_propiedad WHERE id_propiedad=? ORDER BY orden ASC LIMIT 1");
                    psImgCheck.setInt(1, Integer.parseInt(editId));
                    ResultSet rsImg = psImgCheck.executeQuery();
                    if (rsImg.next()) {
                        PreparedStatement psImgUp = conn.prepareStatement("UPDATE imagen_propiedad SET url=? WHERE id_imagen=?");
                        psImgUp.setString(1, imgUrl);
                        psImgUp.setInt(2, rsImg.getInt("id_imagen"));
                        psImgUp.executeUpdate();
                    } else {
                        PreparedStatement psImgIn = conn.prepareStatement("INSERT INTO imagen_propiedad (id_propiedad, url, orden) VALUES (?,?,1)");
                        psImgIn.setInt(1, Integer.parseInt(editId));
                        psImgIn.setString(2, imgUrl);
                        psImgIn.executeUpdate();
                    }
                }
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
                // Guardar imagen si la puso o subió
                if (imgUrl != null && !imgUrl.isEmpty() && nuevoId > 0) {
                    PreparedStatement psImgIn = conn.prepareStatement("INSERT INTO imagen_propiedad (id_propiedad, url, orden) VALUES (?,?,1)");
                    psImgIn.setInt(1, nuevoId);
                    psImgIn.setString(2, imgUrl);
                    psImgIn.executeUpdate();
                }
                msgForm = "Propiedad publicada exitosamente.";
                titulo=""; descripcion=""; precio=""; operacion="Venta"; direccion="";
                idCiudad=""; idTipo=""; idInmob=""; hab=""; ban=""; area=""; parq="false"; imgUrl="";
            }
        } catch (Exception ex) { errForm = "Error al guardar: " + ex.getMessage(); ex.printStackTrace(); }
    }

    boolean esEdicion = editId != null && !editId.isEmpty();
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
        <p class="text-muted mb-4"><%= esEdicion ? "Actualiza los datos del inmueble y su fotografía" : "Completa los datos y sube las fotos para publicar un nuevo inmueble en el catálogo" %></p>

        <% if (msgForm != null) { %><div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgForm %></div><% } %>
        <% if (errForm != null) { %><div class="alert-danger-vsta mb-4"><i class="bi bi-x-circle me-1"></i> <%= errForm %></div><% } %>

        <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:32px;border:1px solid var(--border-subtle);max-width:850px;">
            <form action="<%= ctx %>/<%= "admin".equals(rolI) ? "admin" : "inmobiliaria" %>/propiedad_form.jsp" method="POST" enctype="multipart/form-data">
                <% if (esEdicion) { %><input type="hidden" name="editId" value="<%= editId %>"><% } %>
                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label-vesta">Título de la Publicación *</label>
                        <input type="text" name="titulo" class="form-control-vesta" value="<%= titulo %>" required placeholder="Ej: Hermoso Apartamento con Vista Panorámica">
                    </div>
                    <div class="col-12">
                        <label class="form-label-vesta">Descripción Detallada</label>
                        <textarea name="descripcion" class="form-control-vesta" rows="3" placeholder="Describe los espacios, acabados y amenidades..."><%= descripcion %></textarea>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Precio ($ COP) *</label>
                        <input type="number" name="precio" class="form-control-vesta" value="<%= precio %>" required placeholder="350000000" min="0">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Tipo de Operación *</label>
                        <select name="operacion" class="form-select-vesta" required>
                            <option value="Venta" <%= "Venta".equalsIgnoreCase(operacion) ? "selected" : "" %>>Venta</option>
                            <option value="Arriendo" <%= "Arriendo".equalsIgnoreCase(operacion) ? "selected" : "" %>>Arriendo</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Ciudad *</label>
                        <select name="idCiudad" class="form-select-vesta" required>
                            <option value="">Selecciona Ciudad</option>
                            <% for (String[] c : ciudades) { %>
                            <option value="<%= c[0] %>" <%= c[0].equals(idCiudad) ? "selected" : "" %>><%= c[1] %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Tipo de Inmueble *</label>
                        <select name="idTipo" class="form-select-vesta" required>
                            <option value="">Selecciona Tipo</option>
                            <% for (String[] t : tipos) { %>
                            <option value="<%= t[0] %>" <%= t[0].equals(idTipo) ? "selected" : "" %>><%= t[1] %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-vesta">Inmobiliaria Asignada</label>
                        <select name="idInmobiliaria" class="form-select-vesta">
                            <option value="">Sin inmobiliaria asignada</option>
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
                    <div class="col-md-2">
                        <label class="form-label-vesta">Área (m²)</label>
                        <input type="number" name="area" class="form-control-vesta" value="<%= area %>" step="0.5">
                    </div>
                    <div class="col-12">
                        <div class="form-check" style="padding:10px 0;">
                            <input type="checkbox" name="parqueadero" id="parqueadero" value="true" <%= "true".equals(parq) ? "checked" : "" %>
                                   style="width:20px;height:20px;accent-color:var(--color-accent);vertical-align:middle;">
                            <label for="parqueadero" class="ms-2 fw-600" style="font-size:0.95rem;">Cuenta con Parqueadero / Cochera</label>
                        </div>
                    </div>

                    <!-- SECCIÓN DE FOTO / IMAGEN -->
                    <div class="col-12"><hr style="border-color:var(--border-subtle);margin:10px 0;"></div>
                    <div class="col-md-6">
                        <label class="form-label-vesta"><i class="bi bi-upload me-1 text-primary"></i> Subir Foto desde tu PC</label>
                        <input type="file" name="imagenArchivo" accept="image/png, image/jpeg, image/webp" class="form-control-vesta">
                        <small class="text-muted">Selecciona una imagen local de tu ordenador (JPG, PNG, WEBP)</small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta"><i class="bi bi-link-45deg me-1"></i> O Ingresa URL de Imagen</label>
                        <input type="url" name="imagenUrl" class="form-control-vesta" value="<%= imgUrl != null ? imgUrl : "" %>" placeholder="https://ejemplo.com/inmueble.jpg">
                        <small class="text-muted">Si subes un archivo local, este tendrá prioridad</small>
                    </div>
                    <% if (imgUrl != null && !imgUrl.isEmpty()) { %>
                    <div class="col-12 mt-2">
                        <span class="text-muted small d-block mb-1">Fotografía actual del inmueble:</span>
                        <img src="<%= imgUrl %>" alt="Vista previa" style="height:120px;border-radius:var(--radius-md);object-fit:cover;border:1px solid var(--border-subtle);">
                    </div>
                    <% } %>

                    <div class="col-12 mt-4">
                        <button type="submit" class="btn btn-vesta-accent me-2">
                            <i class="bi bi-save me-1"></i> <%= esEdicion ? "Guardar Cambios" : "Publicar Propiedad" %>
                        </button>
                        <a href="<%= ctx %>/<%= "admin".equals(rolI) ? "admin" : "inmobiliaria" %>/propiedades.jsp" class="btn btn-vesta-outline">Cancelar</a>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
