<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,org.mindrot.jbcrypt.BCrypt" %>
<%@ include file="/components/conexion.jsp" %>
<%
    if (session.getAttribute("rolActivo") == null) { response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=/cliente/perfil.jsp"); return; }
    String ctx = request.getContextPath();
    Object idUsrObj = session.getAttribute("idUsuario");
    String msgPerfil = null; String errPerfil = null;
    String nombres = ""; String apellidos = ""; String correo = ""; String documento = ""; String telefono = ""; String direccion = "";

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
            try (Connection conn = getConn()) {
                PreparedStatement psP = conn.prepareStatement(
                    "UPDATE perfil SET nombres=?, apellidos=?, documento=?, telefono=?, direccion=? WHERE id_usuario=?");
                psP.setString(1, nombres); psP.setString(2, apellidos);
                psP.setString(3, documento); psP.setString(4, telefono);
                psP.setString(5, direccion); psP.setInt(6, idUsr);
                psP.executeUpdate();
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
                "SELECT p.nombres, p.apellidos, p.documento, p.telefono, p.direccion, u.correo " +
                "FROM perfil p JOIN usuario u ON u.id_usuario=p.id_usuario WHERE p.id_usuario=" + idUsr).executeQuery();
            if (rs.next()) {
                if (nombres.isEmpty()) nombres   = rs.getString("nombres");
                if (apellidos.isEmpty()) apellidos = rs.getString("apellidos");
                correo   = rs.getString("correo");
                if (documento.isEmpty()) documento = rs.getString("documento") != null ? rs.getString("documento") : "";
                if (telefono.isEmpty()) telefono  = rs.getString("telefono") != null ? rs.getString("telefono") : "";
                if (direccion.isEmpty()) direccion = rs.getString("direccion") != null ? rs.getString("direccion") : "";
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }
%>
<%@ include file="/components/header.jsp" %>
<div class="dashboard-wrapper">
    <%@ include file="/components/sidebar_cliente.jsp" %>
    <div class="dashboard-content">
        <h2 class="fw-bold mb-1">Mi Perfil</h2>
        <p class="text-muted mb-4">Mantén tus datos actualizados para facilitar la comunicación con los agentes</p>

        <% if (msgPerfil != null) { %><div class="alert-success-vsta mb-4"><i class="bi bi-check-circle me-1"></i> <%= msgPerfil %></div><% } %>
        <% if (errPerfil != null) { %><div class="alert-danger-vsta mb-4"><i class="bi bi-x-circle me-1"></i> <%= errPerfil %></div><% } %>

        <div style="background:var(--bg-surface);border-radius:var(--radius-lg);padding:32px;border:1px solid var(--border-subtle);max-width:700px;">
            <form action="<%= ctx %>/cliente/perfil.jsp" method="POST">
                <div class="row g-3">
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
