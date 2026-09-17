<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,org.mindrot.jbcrypt.BCrypt" %>
<%-- =====================================================================
     login.jsp — Autenticación JSP puro (Tomcat 8.5 / JSP 2.3)
     Procesa GET (mostrar form) y POST (autenticar contra PostgreSQL)
     ===================================================================== --%>
<%@ include file="/components/conexion.jsp" %>
<%
    /* ---- Redireccionar si ya está autenticado ---- */
    String rolActivo = (String) session.getAttribute("rolActivo");
    if (rolActivo != null) {
        if ("admin".equals(rolActivo))         { response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp"); return; }
        else if ("inmobiliaria".equals(rolActivo)) { response.sendRedirect(request.getContextPath() + "/inmobiliaria/dashboard.jsp"); return; }
        else                                   { response.sendRedirect(request.getContextPath() + "/cliente/dashboard.jsp"); return; }
    }

    String errorMsg    = null;
    String correoPrev  = "";

    /* ---- Procesar POST ---- */
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String correoParam = request.getParameter("correo");
        String passParam   = request.getParameter("password");
        correoParam = correoParam != null ? correoParam.trim().toLowerCase() : "";
        correoPrev  = correoParam;

        boolean autenticado = false;
        String  rolDetectado = null;
        String  nombreDetectado = null;
        int     idUsuario = -1;

        // Accesos rápidos universales (demo)
        if ("admin@vesta.com".equals(correoParam) && "admin123".equals(passParam)) {
            autenticado = true; rolDetectado = "admin"; nombreDetectado = "Super Administrador";
        } else if ("carlos@inmobiliaria.com".equals(correoParam) && "inmobiliaria123".equals(passParam)) {
            autenticado = true; rolDetectado = "inmobiliaria"; nombreDetectado = "Carlos Ramírez";
        } else if ("juan@cliente.com".equals(correoParam) && "cliente123".equals(passParam)) {
            autenticado = true; rolDetectado = "cliente"; nombreDetectado = "Juan Pérez";
        } else {
            // Verificación normal contra la BD
            try (Connection conn = getConn()) {
                String sql = "SELECT u.id_usuario, u.password_hash, u.estado, p.nombres, p.apellidos, r.nombre AS rol " +
                             "FROM usuario u " +
                             "JOIN perfil p ON p.id_usuario = u.id_usuario " +
                             "JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario " +
                             "JOIN rol r ON r.id_rol = ur.id_rol " +
                             "WHERE u.correo = ? AND u.estado = 'activo' " +
                             "ORDER BY r.id_rol ASC LIMIT 1";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, correoParam);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String hash = rs.getString("password_hash");
                    if (BCrypt.checkpw(passParam, hash)) {
                        autenticado   = true;
                        idUsuario     = rs.getInt("id_usuario");
                        rolDetectado  = rs.getString("rol");
                        nombreDetectado = rs.getString("nombres") + " " + rs.getString("apellidos");
                        // Actualizar ultimo_acceso
                        PreparedStatement upd = conn.prepareStatement(
                            "UPDATE usuario SET ultimo_acceso = NOW() WHERE id_usuario = ?");
                        upd.setInt(1, idUsuario);
                        upd.executeUpdate();
                    } else {
                        errorMsg = "Contraseña incorrecta. Por favor intente nuevamente.";
                    }
                } else {
                    errorMsg = "No se encontró una cuenta activa con ese correo.";
                }
            } catch (SQLException ex) {
                errorMsg = "Error de conexión. Inténtelo más tarde.";
                ex.printStackTrace();
            }
        }

        if (autenticado) {
            session.setAttribute("rolActivo", rolDetectado);
            session.setAttribute("nombreUsuario", nombreDetectado);
            session.setAttribute("correoUsuario", correoParam);
            if (idUsuario > 0) session.setAttribute("idUsuario", idUsuario);

            String redirect = request.getParameter("redirect");
            if (redirect != null && !redirect.isEmpty() && redirect.startsWith("/")) {
                response.sendRedirect(request.getContextPath() + redirect);
            } else if ("admin".equals(rolDetectado)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            } else if ("inmobiliaria".equals(rolDetectado)) {
                response.sendRedirect(request.getContextPath() + "/inmobiliaria/dashboard.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/cliente/dashboard.jsp");
            }
            return;
        }
    }

    String msgParam = request.getParameter("msg");
%>
<%@ include file="/components/header.jsp" %>

<div class="auth-page-wrapper">
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-5">
                <div class="auth-card glass-effect p-4 p-md-5 rounded-4 shadow-xl">

                    <div class="text-center mb-4">
                        <div class="vesta-logo-small mb-3"><span class="logo-icon">🏛️</span></div>
                        <h2 class="fw-bold text-vesta-charcoal mb-1">Bienvenido a Vesta</h2>
                        <p class="text-vesta-gray muted">Ingresa tus credenciales para acceder a tu panel</p>
                    </div>

                    <% if (errorMsg != null) { %>
                    <div class="alert-danger-vsta mb-3">
                        <i class="bi bi-exclamation-octagon me-1"></i> <%= errorMsg %>
                    </div>
                    <% } %>

                    <% if ("sesion_cerrada".equals(msgParam)) { %>
                    <div class="alert-success-vsta mb-3 alert-dismissible">
                        <i class="bi bi-check-circle me-1"></i> Sesión cerrada exitosamente.
                    </div>
                    <% } %>

                    <% if ("inactivo".equals(msgParam)) { %>
                    <div class="alert-danger-vsta mb-3">
                        <i class="bi bi-slash-circle me-1"></i> Tu cuenta está inactiva. Contacta al administrador.
                    </div>
                    <% } %>

                    <form action="<%= request.getContextPath() %>/login.jsp" method="POST" id="loginForm">
                        <input type="hidden" name="redirect" value="<%= request.getParameter("redirect") != null ? request.getParameter("redirect") : "" %>">

                        <div class="mb-3">
                            <label class="form-label-vesta">Correo Electrónico</label>
                            <div class="input-group-vsta">
                                <span class="input-icon"><i class="bi bi-envelope"></i></span>
                                <input type="email" name="correo" id="loginCorreo" class="form-control-vesta"
                                       placeholder="usuario@ejemplo.com" value="<%= correoPrev %>" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label-vesta">Contraseña</label>
                            <div class="input-group-vsta">
                                <span class="input-icon"><i class="bi bi-lock"></i></span>
                                <input type="password" name="password" id="loginPassword" class="form-control-vesta"
                                       placeholder="••••••••" required>
                            </div>
                        </div>

                        <button type="submit" id="btnLogin"
                                class="btn btn-vesta-primary w-100 py-3 d-flex align-items-center justify-content-center fw-semibold mb-3">
                            <i class="bi bi-box-arrow-in-right me-2"></i> Iniciar Sesión
                        </button>
                    </form>

                    <!-- Accesos rápidos de prueba -->
                    <div class="quick-access-panel mt-4 p-3 rounded-3 border">
                        <div class="fw-bold small text-muted text-uppercase mb-2 text-center d-flex align-items-center justify-content-center gap-2">
                            <i class="bi bi-lightning-charge-fill text-warning"></i> Accesos Rápidos de Prueba
                        </div>
                        <div class="d-grid gap-2">
                            <button class="btn btn-sm btn-outline-vesta text-start" onclick="fillLogin('admin@vesta.com','admin123')" type="button">
                                <strong>Admin:</strong> admin@vesta.com / <code>admin123</code>
                            </button>
                            <button class="btn btn-sm btn-outline-vesta text-start" onclick="fillLogin('carlos@inmobiliaria.com','inmobiliaria123')" type="button">
                                <strong>Inmobiliaria:</strong> carlos@inmobiliaria.com / <code>inmobiliaria123</code>
                            </button>
                            <button class="btn btn-sm btn-outline-vesta text-start" onclick="fillLogin('juan@cliente.com','cliente123')" type="button">
                                <strong>Cliente:</strong> juan@cliente.com / <code>cliente123</code>
                            </button>
                        </div>
                    </div>

                    <div class="text-center mt-4 pt-3 border-top">
                        <span class="text-muted">¿No tienes una cuenta aún?</span>
                        <a href="<%= request.getContextPath() %>/registro.jsp"
                           class="fw-bold text-vesta-accent ms-1 text-decoration-none">Regístrate aquí</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function fillLogin(email, pass) {
    document.getElementById('loginCorreo').value = email;
    document.getElementById('loginPassword').value = pass;
}
</script>

<%@ include file="/components/footer.jsp" %>
