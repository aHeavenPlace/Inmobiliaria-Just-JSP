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
    java.util.List<String> listaImagenesExistentes = new java.util.ArrayList<>();

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
                operacion   = rp.getString("tipo_operacion");
                direccion   = rp.getString("direccion") != null ? rp.getString("direccion") : "";
                idCiudad    = rp.getString("id_ciudad");
                idTipo      = rp.getString("id_tipo");
                idInmob     = rp.getString("id_inmobiliaria") != null ? rp.getString("id_inmobiliaria") : "1";
                hab         = rp.getString("habitaciones") != null ? rp.getString("habitaciones") : "";
                ban         = rp.getString("banos") != null ? rp.getString("banos") : "";
                area        = rp.getString("area_m2") != null ? rp.getString("area_m2") : "";
                parq        = "true";
            }
            PreparedStatement psImgLoad = conn.prepareStatement("SELECT url FROM imagen_propiedad WHERE id_propiedad=? ORDER BY orden ASC LIMIT 5");
            psImgLoad.setInt(1, Integer.parseInt(editId));
            ResultSet rImgLoad = psImgLoad.executeQuery();
            while (rImgLoad.next()) {
                String u = rImgLoad.getString("url");
                if (u != null && !u.trim().isEmpty()) listaImagenesExistentes.add(u.trim());
            }
            if (!listaImagenesExistentes.isEmpty()) imgUrl = listaImagenesExistentes.get(0);
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
        editId      = request.getParameter("editId");

        // Colección de nuevas fotos procesadas
        java.util.List<String> fotosNuevas = new java.util.ArrayList<>();

        // 1. Procesar subida de múltiples archivos locales desde la PC (hasta 5)
        try {
            java.util.Collection<Part> parts = request.getParts();
            for (Part filePart : parts) {
                if ("imagenArchivo".equals(filePart.getName()) && filePart.getSize() > 0) {
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
                        fotosNuevas.add(ctx + "/uploads/propiedades/" + fileName);
                        if (fotosNuevas.size() >= 5) break;
                    }
                }
            }
        } catch (Exception exPart) {
            System.err.println("Error procesando imágenes de propiedad: " + exPart.getMessage());
        }

        // 2. Procesar URLs manuales si se ingresaron
        String[] urlsParam = request.getParameterValues("imagenUrl");
        if (urlsParam != null) {
            for (String u : urlsParam) {
                if (u != null && !u.trim().isEmpty() && fotosNuevas.size() < 5) {
                    fotosNuevas.add(u.trim());
                }
            }
        }

        try (Connection conn = getConn()) {
            int inmobId = (idInmob != null && !idInmob.isEmpty()) ? Integer.parseInt(idInmob) : 1;
            String opNorm = (operacion != null && operacion.equalsIgnoreCase("arriendo")) ? "arriendo" : "venta";
            int numHab = (hab != null && !hab.isEmpty()) ? Integer.parseInt(hab) : 0;
            int numBan = (ban != null && !ban.isEmpty()) ? Integer.parseInt(ban) : 0;
            double numArea = (area != null && !area.isEmpty()) ? Double.parseDouble(area) : 0.0;

            if (editId != null && !editId.isEmpty()) {
                // Actualizar datos de la propiedad
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE propiedad SET titulo=?, descripcion=?, precio=?, tipo_operacion=?, direccion=?, " +
                    "id_ciudad=?, id_tipo=?, id_inmobiliaria=?, habitaciones=?, banos=?, area_m2=? " +
                    "WHERE id_propiedad=?");
                ps.setString(1, titulo);
                ps.setString(2, descripcion);
                ps.setBigDecimal(3, new java.math.BigDecimal(precio));
                ps.setString(4, opNorm);
                ps.setString(5, direccion);
                ps.setInt(6, Integer.parseInt(idCiudad));
                ps.setInt(7, Integer.parseInt(idTipo));
                ps.setInt(8, inmobId);
                ps.setInt(9, numHab);
                ps.setInt(10, numBan);
                ps.setDouble(11, numArea);
                ps.setInt(12, Integer.parseInt(editId));
                ps.executeUpdate();

                // Construir lista de imágenes finales (conservadas + nuevas)
                java.util.List<String> imagenesFinales = new java.util.ArrayList<>();
                String[] conservar = request.getParameterValues("conservarImagen");
                if (conservar != null) {
                    for (String c : conservar) {
                        if (c != null && !c.trim().isEmpty() && imagenesFinales.size() < 5) {
                            imagenesFinales.add(c.trim());
                        }
                    }
                }
                for (String fn : fotosNuevas) {
                    if (imagenesFinales.size() < 5) {
                        imagenesFinales.add(fn);
                    }
                }

                // Si hay imágenes para actualizar la galería
                if (!imagenesFinales.isEmpty()) {
                    PreparedStatement psDelImg = conn.prepareStatement("DELETE FROM imagen_propiedad WHERE id_propiedad=?");
                    psDelImg.setInt(1, Integer.parseInt(editId));
                    psDelImg.executeUpdate();

                    for (int i = 0; i < imagenesFinales.size(); i++) {
                        PreparedStatement psImgIn = conn.prepareStatement("INSERT INTO imagen_propiedad (id_propiedad, url, orden) VALUES (?,?,?)");
                        psImgIn.setInt(1, Integer.parseInt(editId));
                        psImgIn.setString(2, imagenesFinales.get(i));
                        psImgIn.setInt(3, i + 1);
                        psImgIn.executeUpdate();
                    }
                    listaImagenesExistentes = imagenesFinales;
                }
                msgForm = "Propiedad actualizada exitosamente con " + (!imagenesFinales.isEmpty() ? imagenesFinales.size() : listaImagenesExistentes.size()) + " imágenes.";
            } else {
                // Insertar con matricula autogenerada y columnas correctas
                String matricula = "MAT-" + System.currentTimeMillis() + "-" + ((int)(Math.random() * 900) + 100);
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO propiedad (id_inmobiliaria, id_ciudad, id_tipo, matricula_inmobiliaria, " +
                    "titulo, descripcion, direccion, precio, area_m2, habitaciones, banos, tipo_operacion, estado) " +
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?, 'disponible')", Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, inmobId);
                ps.setInt(2, Integer.parseInt(idCiudad));
                ps.setInt(3, Integer.parseInt(idTipo));
                ps.setString(4, matricula);
                ps.setString(5, titulo);
                ps.setString(6, descripcion);
                ps.setString(7, direccion);
                ps.setBigDecimal(8, new java.math.BigDecimal(precio));
                ps.setDouble(9, numArea);
                ps.setInt(10, numHab);
                ps.setInt(11, numBan);
                ps.setString(12, opNorm);
                ps.executeUpdate();
                ResultSet gk = ps.getGeneratedKeys();
                int nuevoId = gk.next() ? gk.getInt(1) : -1;

                // Guardar hasta 5 imágenes
                java.util.List<String> imagenesFinales = new java.util.ArrayList<>();
                for (String fn : fotosNuevas) {
                    if (imagenesFinales.size() < 5) imagenesFinales.add(fn);
                }
                if (imagenesFinales.isEmpty()) {
                    imagenesFinales.add("https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=1200");
                }
                if (nuevoId > 0) {
                    for (int i = 0; i < imagenesFinales.size(); i++) {
                        PreparedStatement psImgIn = conn.prepareStatement("INSERT INTO imagen_propiedad (id_propiedad, url, orden) VALUES (?,?,?)");
                        psImgIn.setInt(1, nuevoId);
                        psImgIn.setString(2, imagenesFinales.get(i));
                        psImgIn.setInt(3, i + 1);
                        psImgIn.executeUpdate();
                    }
                }
                msgForm = "Propiedad publicada exitosamente con " + imagenesFinales.size() + " imágenes.";
                titulo=""; descripcion=""; precio=""; operacion="Venta"; direccion="";
                idCiudad=""; idTipo=""; idInmob=""; hab=""; ban=""; area=""; parq="false"; imgUrl="";
                listaImagenesExistentes.clear();
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

                    <!-- SECCIÓN DE FOTOS / GALERÍA (HASTA 5 IMÁGENES) -->
                    <div class="col-12"><hr style="border-color:var(--border-subtle);margin:15px 0;"></div>
                    <div class="col-12">
                        <h5 class="fw-bold mb-1"><i class="bi bi-images me-2 text-vesta-accent"></i>Fotografías del Inmueble (Hasta 5 fotos)</h5>
                        <p class="text-muted small mb-3">La primera imagen será la foto principal en el catálogo y página de inicio. Puedes seleccionar hasta 5 fotos a la vez desde tu PC.</p>
                    </div>

                    <% if (esEdicion && !listaImagenesExistentes.isEmpty()) { %>
                    <div class="col-12 mb-3">
                        <label class="form-label-vesta fw-bold">Fotos actuales del inmueble (<%= listaImagenesExistentes.size() %>/5):</label>
                        <div class="d-flex flex-wrap gap-3 mt-1">
                            <% for (int idx = 0; idx < listaImagenesExistentes.size(); idx++) {
                                String curImg = listaImagenesExistentes.get(idx);
                                String curImgSrc = curImg.startsWith("/uploads/") ? ctx + curImg : curImg;
                            %>
                            <div style="width:145px;border:1px solid var(--border-subtle);border-radius:var(--radius-md);overflow:hidden;background:var(--bg-surface-subtle);padding:8px;text-align:center;">
                                <img src="<%= curImgSrc %>" alt="Foto <%= idx + 1 %>" style="width:100%;height:95px;object-fit:cover;border-radius:var(--radius-sm);">
                                <div class="mt-2" style="font-size:0.8rem;">
                                    <span class="badge <%= idx == 0 ? "bg-primary" : "bg-secondary" %> mb-1 d-block"><%= idx == 0 ? "1 (Principal)" : "Foto " + (idx + 1) %></span>
                                    <div class="form-check text-start d-inline-block">
                                        <input class="form-check-input" type="checkbox" name="conservarImagen" value="<%= curImg %>" id="keep_<%= idx %>" checked>
                                        <label class="form-check-label" for="keep_<%= idx %>" style="font-size:0.75rem;">Conservar</label>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <small class="text-muted d-block mt-2"><i class="bi bi-info-circle me-1"></i> Desmarca la casilla si deseas quitar alguna foto. Las nuevas fotos que selecciones abajo se añadirán a las que conserves.</small>
                    </div>
                    <% } %>

                    <div class="col-12">
                        <label class="form-label-vesta fw-bold"><i class="bi bi-upload me-1 text-primary"></i> Seleccionar Fotos desde tu PC</label>
                        <input type="file" name="imagenArchivo" id="inputFotosMultiples" multiple accept="image/png, image/jpeg, image/webp" class="form-control-vesta">
                        <small class="text-muted d-block mt-1">Puedes elegir de 1 a 5 imágenes (mantén presionado <kbd>Ctrl</kbd> o <kbd>Shift</kbd> al seleccionarlas en la ventana). Formatos: JPG, PNG, WEBP.</small>
                        
                        <!-- Contenedor dinámico de previsualización -->
                        <div id="previewContainer" class="d-flex flex-wrap gap-2 mt-3"></div>
                    </div>

                    <!-- URLs opcionales -->
                    <div class="col-12 mt-2">
                        <details style="background:var(--bg-surface-subtle);border-radius:var(--radius-md);padding:12px 16px;">
                            <summary class="fw-600" style="cursor:pointer;font-size:0.9rem;color:var(--text-muted);">
                                <i class="bi bi-link-45deg me-1"></i> ¿Prefieres ingresar URLs directas de fotos web? (Opcional)
                            </summary>
                            <div class="row g-2 mt-2">
                                <div class="col-md-6">
                                    <input type="url" name="imagenUrl" class="form-control-vesta" placeholder="URL Foto 1 (Principal)">
                                </div>
                                <div class="col-md-6">
                                    <input type="url" name="imagenUrl" class="form-control-vesta" placeholder="URL Foto 2">
                                </div>
                                <div class="col-md-4">
                                    <input type="url" name="imagenUrl" class="form-control-vesta" placeholder="URL Foto 3">
                                </div>
                                <div class="col-md-4">
                                    <input type="url" name="imagenUrl" class="form-control-vesta" placeholder="URL Foto 4">
                                </div>
                                <div class="col-md-4">
                                    <input type="url" name="imagenUrl" class="form-control-vesta" placeholder="URL Foto 5">
                                </div>
                            </div>
                        </details>
                    </div>

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

<script>
document.addEventListener('DOMContentLoaded', function() {
    var inputFotos = document.getElementById('inputFotosMultiples');
    var container = document.getElementById('previewContainer');
    if (inputFotos && container) {
        inputFotos.addEventListener('change', function() {
            container.innerHTML = '';
            var files = Array.from(inputFotos.files).slice(0, 5);
            if (files.length === 0) return;
            files.forEach(function(file, index) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    var card = document.createElement('div');
                    card.style.cssText = 'width:130px;border:1px solid var(--border-subtle);border-radius:var(--radius-md);overflow:hidden;background:#fff;padding:6px;text-align:center;box-shadow:0 2px 6px rgba(0,0,0,0.05);';
                    var img = document.createElement('img');
                    img.src = e.target.result;
                    img.style.cssText = 'width:100%;height:85px;object-fit:cover;border-radius:var(--radius-sm);';
                    var badge = document.createElement('span');
                    badge.className = 'badge ' + (index === 0 ? 'bg-primary' : 'bg-secondary') + ' mt-1 d-block';
                    badge.textContent = index === 0 ? 'Foto 1 (Principal)' : 'Foto ' + (index + 1);
                    card.appendChild(img);
                    card.appendChild(badge);
                    container.appendChild(card);
                };
                reader.readAsDataURL(file);
            });
        });
    }
});
</script>
<%@ include file="/components/footer.jsp" %>
