<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Crear Cuenta | Vesta Inmobiliaria"/>
</jsp:include>

<div class="auth-page-wrapper">
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-10 col-lg-7">
                <div class="auth-card glass-effect p-4 p-md-5 rounded-4 shadow-xl">
                    <div class="text-center mb-4">
                        <div class="vesta-logo-small mb-3">
                            <span class="logo-icon">🏛️</span>
                        </div>
                        <h2 class="fw-bold text-vesta-charcoal mb-1">Crea tu Cuenta en Vesta</h2>
                        <p class="text-vesta-gray muted">Únete a Vesta Inmobiliaria para guardar favoritos y agendar citas en línea</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger-vsta alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-octagon me-1"></i> ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/registro" method="POST">
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

                        <button type="submit" class="btn btn-vesta-primary w-100 py-3 d-flex align-items-center justify-content-center fw-semibold mt-4">
                            <i class="bi bi-check2-circle me-2"></i> Completar Registro
                        </button>
                    </form>

                    <div class="text-center mt-4 pt-3 border-top">
                        <span class="text-muted">¿Ya tienes una cuenta?</span>
                        <a href="${pageContext.request.contextPath}/login" class="fw-bold text-vesta-accent ms-1 text-decoration-none">Inicia sesión</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
