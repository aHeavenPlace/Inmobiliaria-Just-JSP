<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,org.mindrot.jbcrypt.BCrypt,javax.servlet.http.Part,java.io.*,java.util.UUID" %>
<%@ include file="/components/conexion.jsp" %>
<%
    String rolP = (String) session.getAttribute("rolActivo");
    if (rolP == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=/cliente/perfil.jsp");
        return;
    }
    String ctx = request.getContextPath();
    Object idUsrObj = session.getAttribute("idUsuario");
    String msgPerfil = null; String errPerfil = null;
    String nombres = ""; String apellidos = ""; String correo = ""; String documento = ""; String telefono = ""; String direccion = ""; String fotoActual = "";

    // Asegurar idUsuario si estuviera pendiente en la sesión
    if (idUsrObj == null && session.getAttribute("correoUsuario") != null) {
        try (Connection conn = getConn()) {
            PreparedStatement psUsr = conn.prepareStatement("SELECT id_usuario FROM usuario WHERE correo=?");
            psUsr.setString(1, (String) session.getAttribute("correoUsuario"));
            ResultSet rsUsr = psUsr.executeQuery();
            if (rsUsr.next()) {
                idUsrObj = rsUsr.getInt("id_usuario");
                session.setAttribute("idUsuario", idUsrObj);
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }

    if (idUsrObj != null) {
        int idUsr = (Integer) idUsrObj;

        // 1. Cargar datos actuales de la base de datos PRIMERO
        try (Connection conn = getConn()) {
            ResultSet rs = conn.prepareStatement(
                "SELECT p.nombres, p.apellidos, p.documento, p.telefono, p.direccion, p.foto_url, u.correo " +
                "FROM perfil p JOIN usuario u ON u.id_usuario=p.id_usuario WHERE p.id_usuario=" + idUsr).executeQuery();
            if (rs.next()) {
                nombres    = rs.getString("nombres") != null ? rs.getString("nombres") : "";
                apellidos  = rs.getString("apellidos") != null ? rs.getString("apellidos") : "";
                correo     = rs.getString("correo") != null ? rs.getString("correo") : "";
                documento  = rs.getString("documento") != null ? rs.getString("documento") : "";
                telefono   = rs.getString("telefono") != null ? rs.getString("telefono") : "";
                direccion  = rs.getString("direccion") != null ? rs.getString("direccion") : "";
                fotoActual = rs.getString("foto_url") != null ? rs.getString("foto_url") : "";
            }
        } catch (Exception ex) { ex.printStackTrace(); }

        // 2. Procesar POST de actualización
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            request.setCharacterEncoding("UTF-8");
            String pNombres   = request.getParameter("nombres");
            String pApellidos = request.getParameter("apellidos");
            String pTelefono  = request.getParameter("telefono");
            String pDocumento = request.getParameter("documento");
            String pDireccion = request.getParameter("direccion");
            String newPwd     = request.getParameter("newPassword");
            String confirmPwd = request.getParameter("confirmPassword");

            // Si vienen campos del form, sobreescribir; si vienen vacíos, conservar los que ya estaban
            if (pNombres != null && !pNombres.trim().isEmpty()) nombres = pNombres.trim();
            if (pApellidos != null && !pApellidos.trim().isEmpty()) apellidos = pApellidos.trim();
            if (pTelefono != null) telefono = pTelefono.trim();
            if (pDocumento != null) documento = pDocumento.trim();
            if (pDireccion != null) direccion = pDireccion.trim();

            // Procesar subida de archivo local si se seleccionó uno
            try {
                Part part = request.getPart("fotoArchivo");
                if (part != null && part.getSize() > 0) {
                    String subName = part.getSubmittedFileName();
                    if (subName != null && !subName.trim().isEmpty()) {
                        String ext = "jpg";
                        int dot = subName.lastIndexOf(".");
                        if (dot > 0) ext = subName.substring(dot + 1).toLowerCase();
                        String fileName = "perfil_" + idUsr + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + ext;
                        String uploadPath = application.getRealPath("/uploads/perfiles");
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdirs();
                        File dest = new File(uploadDir, fileName);
                        try (InputStream in = part.getInputStream(); OutputStream outStream = new FileOutputStream(dest)) {
                            byte[] buf = new byte[8192];
                            int len;
                            while ((len = in.read(buf)) > 0) outStream.write(buf, 0, len);
                        }
                        fotoActual = ctx + "/uploads/perfiles/" + fileName;
                        session.setAttribute("fotoUsuario", fotoActual);
                    }
                }
            } catch (Exception exPart) {
                System.err.println("Error procesando foto de perfil: " + exPart.getMessage());
            }

            // Guardar cambios en la BD
            try (Connection conn = getConn()) {
                PreparedStatement psP = conn.prepareStatement(
                    "UPDATE perfil SET nombres=?, apellidos=?, documento=?, telefono=?, direccion=?, foto_url=? WHERE id_usuario=?");
                psP.setString(1, nombres);
                psP.setString(2, apellidos);
                psP.setString(3, documento);
                psP.setString(4, telefono);
                psP.setString(5, direccion);
                psP.setString(6, fotoActual);
                psP.setInt(7, idUsr);
                psP.executeUpdate();

                session.setAttribute("nombreUsuario", nombres + " " + apellidos);

                if (newPwd != null && !newPwd.isEmpty()) {
                    if (!newPwd.equals(confirmPwd)) {
                        errPerfil = "Las contraseñas no coinciden.";
                    } else if (newPwd.length() < 6) {
                        errPerfil = "La contraseña debe tener al menos 6 caracteres.";
                    } else {
                        String hash = BCrypt.hashpw(newPwd, BCrypt.gensalt(10));
                        PreparedStatement psPwd = conn.prepareStatement("UPDATE usuario SET password_hash=? WHERE id_usuario=?");
                        psPwd.setString(1, hash);
                        psPwd.setInt(2, idUsr);
                        psPwd.executeUpdate();
                        msgPerfil = "Perfil y contraseña actualizados correctamente.";
                    }
                } else {
                    msgPerfil = "Perfil actualizado correctamente.";
                }
            } catch (Exception ex) {
                errPerfil = "Error al actualizar: " + ex.getMessage();
                ex.printStackTrace();
            }
        }
    }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%-- Renderizar el sidebar correspondiente al rol de la sesión activa --%>
    <% if ("admin".equals(rolP)) { %>
    <%@ include file="/components/sidebar_admin.jsp" %>
    <% } else if ("inmobiliaria".equals(rolP)) { %>
    <%@ include file="/components/sidebar_inmobiliaria.jsp" %>
    <% } else { %>
    <%@ include file="/components/sidebar_cliente.jsp" %>
    <% } %>

    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Mi Perfil</h2>
        <p class="text-muted mb-4">Mantén tus datos y fotografía de perfil actualizados en la plataforma</p>

        <% if (msgPerfil != null) { %><div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgPerfil %></div><% } %>
        <% if (errPerfil != null) { %><div class="alert-danger-vsta mb-4"><i class="bi bi-x-circle me-1"></i> <%= errPerfil %></div><% } %>

        <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:32px;border:1px solid var(--border-subtle);max-width:750px;">
            <form action="<%= ctx %>/cliente/perfil.jsp" method="POST" enctype="multipart/form-data">
                <div class="row g-3">
                    <%-- Foto de perfil actual y subida local --%>
                    <div class="col-12 d-flex align-items-center gap-3 pb-2">
                        <div style="width:80px;height:80px;border-radius:50%;overflow:hidden;background:var(--bg-card);display:flex;align-items:center;justify-content:center;border:2px solid var(--border-subtle);flex-shrink:0;box-shadow:var(--shadow-sm);">
                            <% if (fotoActual != null && !fotoActual.isEmpty()) { %>
                                <img src="<%= fotoActual %>" alt="Foto de perfil" style="width:100%;height:100%;object-fit:cover;">
                            <% } else { %>
                                <i class="bi bi-person-fill text-muted" style="font-size:2.8rem;"></i>
                            <% } %>
                        </div>
                        <div class="flex-grow-1">
                            <label class="form-label-vesta"><i class="bi bi-camera me-1 text-primary"></i> Cambiar Foto de Perfil (Subir desde tu PC)</label>
                            <input type="file" name="fotoArchivo" accept="image/png, image/jpeg, image/webp" class="form-control-vesta">
                            <small class="text-muted">Formatos JPG, PNG o WEBP (máx. 10MB). Si solo subes la foto, tus otros datos se conservan.</small>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label-vesta">Nombres *</label>
                        <input type="text" name="nombres" class="form-control-vesta" value="<%= nombres %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Apellidos *</label>
                        <input type="text" name="apellidos" class="form-control-vesta" value="<%= apellidos %>" required>
                    </div>
                    <div class="col-12">
                        <label class="form-label-vesta">Correo Electrónico (cuenta)</label>
                        <input type="email" class="form-control-vesta" value="<%= correo %>" disabled style="opacity:0.65;">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Documento de Identidad</label>
                        <input type="text" name="documento" class="form-control-vesta" value="<%= documento %>" placeholder="Número de cédula o ID">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Teléfono de Contacto</label>
                        <input type="tel" name="telefono" class="form-control-vesta" value="<%= telefono %>" placeholder="Ej: 315 123 4567">
                    </div>
                    <div class="col-12">
                        <label class="form-label-vesta">Dirección</label>
                        <input type="text" name="direccion" class="form-control-vesta" value="<%= direccion %>" placeholder="Dirección de residencia o despacho">
                    </div>
                    <div class="col-12"><hr style="border-color:var(--border-subtle);margin:15px 0;"></div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Nueva Contraseña (opcional)</label>
                        <input type="password" name="newPassword" class="form-control-vesta" placeholder="Dejar vacío para mantener la actual">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Confirmar Nueva Contraseña</label>
                        <input type="password" name="confirmPassword" class="form-control-vesta" placeholder="Repite la nueva contraseña">
                    </div>
                    <div class="col-12 mt-3">
                        <button type="submit" id="btnGuardarPerfil" class="btn btn-vesta-accent me-2">
                            <i class="bi bi-save me-1"></i> Guardar Cambios
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
