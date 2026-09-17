<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*,org.mindrot.jbcrypt.BCrypt" %>
<%-- =====================================================================
     registro.jsp — Registro de usuarios JSP puro (Tomcat 8.5 / JSP 2.3)
     ===================================================================== --%>
<%@ include file="/components/conexion.jsp" %>
<%
    /* Redirigir si ya tiene sesión */
    if (session.getAttribute("rolActivo") != null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String errorReg   = null;
    String exitoReg   = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String nombres    = request.getParameter("nombres");
        String apellidos  = request.getParameter("apellidos");
        String correo     = request.getParameter("correo");
        String documento  = request.getParameter("documento");
        String telefono   = request.getParameter("telefono");
        String direccion  = request.getParameter("direccion");
        String password   = request.getParameter("password");
        String confirmPwd = request.getParameter("confirmPassword");
        String tipo       = request.getParameter("tipoCuenta");

        if (nombres == null || nombres.trim().isEmpty() ||
            apellidos == null || apellidos.trim().isEmpty() ||
            correo == null || correo.trim().isEmpty() ||
            password == null || password.length() < 6) {
            errorReg = "Por favor completa todos los campos obligatorios (mínimo 6 caracteres para la contraseña).";
        } else if (!password.equals(confirmPwd)) {
            errorReg = "Las contraseñas no coinciden.";
        } else {
            correo = correo.trim().toLowerCase();
            try (Connection conn = getConn()) {
                // Verificar si correo ya existe
                PreparedStatement chk = conn.prepareStatement("SELECT id_usuario FROM usuario WHERE correo = ?");
                chk.setString(1, correo);
                ResultSet rsChk = chk.executeQuery();
                if (rsChk.next()) {
                    errorReg = "Ya existe una cuenta con ese correo. <a href='" + request.getContextPath() + "/login.jsp'>Inicia sesión</a>.";
                } else {
                    String hash = BCrypt.hashpw(password, BCrypt.gensalt(10));
                    // Insertar usuario
                    PreparedStatement insU = conn.prepareStatement(
                        "INSERT INTO usuario (correo, password_hash, estado) VALUES (?, ?, 'activo')",
                        Statement.RETURN_GENERATED_KEYS);
                    insU.setString(1, correo);
                    insU.setString(2, hash);
                    insU.executeUpdate();
                    ResultSet gk = insU.getGeneratedKeys();
                    if (gk.next()) {
                        int nuevoId = gk.getInt(1);
                        // Insertar perfil
                        PreparedStatement insP = conn.prepareStatement(
                            "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion) VALUES (?,?,?,?,?,?)");
                        insP.setInt(1, nuevoId);
                        insP.setString(2, nombres.trim());
                        insP.setString(3, apellidos.trim());
                        insP.setString(4, documento != null ? documento.trim() : null);
                        insP.setString(5, telefono != null ? telefono.trim() : null);
                        insP.setString(6, direccion != null ? direccion.trim() : null);
                        insP.executeUpdate();
                        // Asignar rol
                        int idRol = "inmobiliaria".equals(tipo) ? 2 : 3;
                        PreparedStatement insR = conn.prepareStatement(
                            "INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)");
                        insR.setInt(1, nuevoId);
                        insR.setInt(2, idRol);
                        insR.executeUpdate();
                        exitoReg = "¡Registro exitoso! Ya puedes iniciar sesión.";
                    }
                }
            } catch (SQLException ex) {
                errorReg = "Error al registrar: " + ex.getMessage();
                ex.printStackTrace();
            }
        }
    }
%>
<%@ include file="/components/header.jsp" %>

<div class="auth-page-wrapper">
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-10 col-lg-7">
                <div class="auth-card glass-effect p-4 p-md-5 rounded-4 shadow-xl">
                    <div class="text-center mb-4">
                        <div class="vesta-logo-small mb-3"><span class="logo-icon">🏛️</span></div>
                        <h2 class="fw-bold text-vesta-charcoal mb-1">Crea tu Cuenta en Vesta</h2>
                        <p class="text-vesta-gray muted">Únete para guardar favoritos y agendar citas en línea</p>
                    </div>

                    <% if (errorReg != null) { %>
                    <div class="alert-danger-vsta mb-3">
                        <i class="bi bi-exclamation-octagon me-1"></i> <%=errorReg%>
                    </div>
                    <% } %>
                    <% if (exitoReg != null) { %>
                    <div class="alert-success-vsta mb-3">
                        <i class="bi bi-check-circle me-1"></i> <%=exitoReg%>
                        <a href="<%= request.getContextPath() %>/login.jsp" class="fw-bold ms-2">Ir al Login</a>
                    </div>
                    <% } %>

                    <form action="<%= request.getContextPath() %>/registro.jsp" method="POST">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label-vesta">Nombres *</label>
                                <input type="text" name="nombres" class="form-control-vesta" placeholder="Juan" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Apellidos *</label>
                                <input type="text" name="apellidos" class="form-control-vesta" placeholder="Pérez" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Correo Electrónico *</label>
                                <input type="email" name="correo" class="form-control-vesta" placeholder="correo@ejemplo.com" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Documento de Identidad</label>
                                <input type="text" name="documento" class="form-control-vesta" placeholder="C.C. o NIT">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Teléfono de Contacto</label>
                                <input type="tel" name="telefono" class="form-control-vesta" placeholder="3001234567">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Dirección</label>
                                <input type="text" name="direccion" class="form-control-vesta" placeholder="Calle 50 #10-20">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Contraseña *</label>
                                <input type="password" name="password" class="form-control-vesta" placeholder="Mínimo 6 caracteres" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Confirmar Contraseña *</label>
                                <input type="password" name="confirmPassword" class="form-control-vesta" placeholder="Repite la contraseña" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label-vesta">Tipo de Perfil</label>
                                <select name="tipoCuenta" class="form-select-vesta">
                                    <option value="cliente" selected>Cliente (Comprador o Arrendatario)</option>
                                    <option value="inmobiliaria">Agente / Inmobiliaria (Publicar inmuebles)</option>
                                </select>
                            </div>
                        </div>
                        <button type="submit"
                                class="btn btn-vesta-primary w-100 py-3 d-flex align-items-center justify-content-center fw-semibold mt-4">
                            <i class="bi bi-check2-circle me-2"></i> Completar Registro
                        </button>
                    </form>

                    <div class="text-center mt-4 pt-3 border-top">
                        <span class="text-muted">¿Ya tienes una cuenta?</span>
                        <a href="<%= request.getContextPath() %>/login.jsp"
                           class="fw-bold text-vesta-accent ms-1 text-decoration-none">Inicia sesión aquí</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/components/footer.jsp" %>
