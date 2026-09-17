<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,org.mindrot.jbcrypt.BCrypt,javax.servlet.http.Part,java.io.*,java.util.UUID" %>
<%@ include file="/components/conexion.jsp" %>
<%
    if (session.getAttribute("rolActivo") == null) { response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=/cliente/perfil.jsp"); return; }
    String ctx = request.getContextPath();
    Object idUsrObj = session.getAttribute("idUsuario");
    String msgPerfil = null; String errPerfil = null;
    String nombres = ""; String apellidos = ""; String correo = ""; String documento = ""; String telefono = ""; String direccion = ""; String fotoActual = "";

    if (idUsrObj != null) {
        int idUsr = (Integer) idUsrObj;

        // Procesar actualización
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            request.setCharacterEncoding("UTF-8");
            nombres   = request.getParameter("nombres");
            apellidos = request.getParameter("apellidos");
            telefono  = request.getParameter("telefono");
            documento = request.getParameter("documento");
            direccion = request.getParameter("direccion");
            String newPwd    = request.getParameter("newPassword");
            String confirmPwd= request.getParameter("confirmPassword");

            // Subir foto de perfil si se seleccionó archivo local
            String nuevaFotoUrl = null;
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
                        nuevaFotoUrl = ctx + "/uploads/perfiles/" + fileName;
                        session.setAttribute("fotoUsuario", nuevaFotoUrl);
                    }
                }
            } catch (Exception exPart) {
                System.err.println("Error procesando foto perfil: " + exPart.getMessage());
            }

            try (Connection conn = getConn()) {
                if (nuevaFotoUrl != null) {
                    PreparedStatement psP = conn.prepareStatement(
                        "UPDATE perfil SET nombres=?, apellidos=?, documento=?, telefono=?, direccion=?, foto_url=? WHERE id_usuario=?");
                    psP.setString(1, nombres); psP.setString(2, apellidos);
                    psP.setString(3, documento); psP.setString(4, telefono);
                    psP.setString(5, direccion); psP.setString(6, nuevaFotoUrl);
                    psP.setInt(7, idUsr);
                    psP.executeUpdate();
                } else {
                    PreparedStatement psP = conn.prepareStatement(
                        "UPDATE perfil SET nombres=?, apellidos=?, documento=?, telefono=?, direccion=? WHERE id_usuario=?");
                    psP.setString(1, nombres); psP.setString(2, apellidos);
                    psP.setString(3, documento); psP.setString(4, telefono);
                    psP.setString(5, direccion); psP.setInt(6, idUsr);
                    psP.executeUpdate();
                }
                session.setAttribute("nombreUsuario", nombres + " " + apellidos);
                if (newPwd != null && !newPwd.isEmpty()) {
                    if (!newPwd.equals(confirmPwd)) { errPerfil = "Las contraseñas no coinciden."; }
                    else if (newPwd.length() < 6)   { errPerfil = "La contraseña debe tener al menos 6 caracteres."; }
                    else {
                        String hash = BCrypt.hashpw(newPwd, BCrypt.gensalt(10));
                        conn.prepareStatement("UPDATE usuario SET password_hash='" + hash + "' WHERE id_usuario=" + idUsr).executeUpdate();
                        msgPerfil = "Perfil y contraseña actualizados correctamente.";
                    }
                } else { msgPerfil = "Perfil actualizado correctamente."; }
            } catch (Exception ex) { errPerfil = "Error al actualizar: " + ex.getMessage(); }
        }

        // Cargar datos actuales
        try (Connection conn = getConn()) {
            ResultSet rs = conn.prepareStatement(
                "SELECT p.nombres, p.apellidos, p.documento, p.telefono, p.direccion, p.foto_url, u.correo " +
                "FROM perfil p JOIN usuario u ON u.id_usuario=p.id_usuario WHERE p.id_usuario=" + idUsr).executeQuery();
            if (rs.next()) {
                if (nombres.isEmpty()) nombres   = rs.getString("nombres");
                if (apellidos.isEmpty()) apellidos = rs.getString("apellidos");
                correo   = rs.getString("correo");
                if (documento.isEmpty()) documento = rs.getString("documento") != null ? rs.getString("documento") : "";
                if (telefono.isEmpty()) telefono  = rs.getString("telefono") != null ? rs.getString("telefono") : "";
                if (direccion.isEmpty()) direccion = rs.getString("direccion") != null ? rs.getString("direccion") : "";
                fotoActual = rs.getString("foto_url") != null ? rs.getString("foto_url") : "";
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_cliente.jsp" %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Mi Perfil</h2>
        <p class="text-muted mb-4">Mantén tus datos y foto actualizados para facilitar la comunicación con los agentes</p>

        <% if (msgPerfil != null) { %><div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgPerfil %></div><% } %>
        <% if (errPerfil != null) { %><div class="alert-danger-vsta mb-4"><i class="bi bi-x-circle me-1"></i> <%= errPerfil %></div><% } %>

        <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:32px;border:1px solid var(--border-subtle);max-width:700px;">
            <form action="<%= ctx %>/cliente/perfil.jsp" method="POST" enctype="multipart/form-data">
                <div class="row g-3">
                    <div class="col-12 d-flex align-items-center gap-3 pb-2">
                        <div style="width:72px;height:72px;border-radius:50%;overflow:hidden;background:var(--bg-card);display:flex;align-items:center;justify-content:center;border:2px solid var(--border-subtle);flex-shrink:0;">
                            <% if (fotoActual != null && !fotoActual.isEmpty()) { %>
                                <img src="<%= fotoActual %>" alt="Foto de perfil" style="width:100%;height:100%;object-fit:cover;">
                            <% } else { %>
                                <i class="bi bi-person-fill text-muted" style="font-size:2.4rem;"></i>
                            <% } %>
                        </div>
                        <div class="flex-grow-1">
                            <label class="form-label-vesta"><i class="bi bi-camera me-1"></i> Foto de Perfil (Subir desde tu PC)</label>
                            <input type="file" name="fotoArchivo" accept="image/png, image/jpeg, image/webp" class="form-control-vesta">
                            <small class="text-muted">Formatos JPG, PNG o WEBP (máx. 10MB)</small>
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
                        <label class="form-label-vesta">Correo Electrónico (no editable)</label>
                        <input type="email" class="form-control-vesta" value="<%= correo %>" disabled style="opacity:0.6;">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Documento</label>
                        <input type="text" name="documento" class="form-control-vesta" value="<%= documento %>">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Teléfono</label>
                        <input type="tel" name="telefono" class="form-control-vesta" value="<%= telefono %>">
                    </div>
                    <div class="col-12">
                        <label class="form-label-vesta">Dirección</label>
                        <input type="text" name="direccion" class="form-control-vesta" value="<%= direccion %>">
                    </div>
                    <div class="col-12"><hr style="border-color:var(--border-subtle);"></div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Nueva Contraseña (opcional)</label>
                        <input type="password" name="newPassword" class="form-control-vesta" placeholder="Dejar vacío para no cambiar">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-vesta">Confirmar Nueva Contraseña</label>
                        <input type="password" name="confirmPassword" class="form-control-vesta" placeholder="Repite la nueva contraseña">
                    </div>
                    <div class="col-12 mt-2">
                        <button type="submit" id="btnGuardarPerfil" class="btn btn-vesta-accent">
                            <i class="bi bi-save me-1"></i> Guardar Cambios
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
