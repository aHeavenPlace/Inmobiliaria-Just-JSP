<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Mi Perfil | Inmobiliaria Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <c:choose>
        <c:when test="${sessionScope.usuarioLogueado.hasRole('admin')}">
            <jsp:include page="/WEB-INF/views/components/sidebar_admin.jsp"/>
        </c:when>
        <c:when test="${sessionScope.usuarioLogueado.hasRole('inmobiliaria')}">
            <jsp:include page="/WEB-INF/views/components/sidebar_inmobiliaria.jsp"/>
        </c:when>
        <c:otherwise>
            <jsp:include page="/WEB-INF/views/components/sidebar_cliente.jsp"/>
        </c:otherwise>
    </c:choose>

    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Mi Perfil</h2>
                <p class="text-muted mb-0">Actualiza tus datos personales y tu foto de perfil</p>
            </div>
        </div>

        <c:if test="${param.msg == 'perfil_actualizado'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Perfil actualizado correctamente.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-octagon-fill me-2"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="row">
            <div class="col-lg-8">
                <div class="bg-white p-4 p-md-5 rounded-4 border border-light shadow-sm">
                    <form action="${pageContext.request.contextPath}/cliente/perfil" method="POST" enctype="multipart/form-data">
                        
                        <!-- Foto de Perfil -->
                        <div class="text-center mb-4">
                            <div class="position-relative d-inline-block">
                                <div id="avatarContainer">
                                    <c:choose>
                                        <c:when test="${not empty perfil.fotoUrl}">
                                            <img src="${pageContext.request.contextPath}/uploads/perfiles/${perfil.fotoUrl}" 
                                                 alt="Foto de perfil" class="rounded-circle border border-3 border-primary" 
                                                 style="width: 140px; height: 140px; object-fit: cover;">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center mx-auto shadow-sm"
                                                 style="width: 140px; height: 140px; font-size: 3rem; font-weight: bold; background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-light) 100%);">
                                                ${not empty perfil.nombres ? fn:substring(perfil.nombres, 0, 1) : fn:substring(sessionScope.correoUsuario, 0, 1)}
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                
                                <label for="fotoPerfil" class="position-absolute bottom-0 end-0 btn btn-sm btn-vesta-accent rounded-circle d-flex align-items-center justify-content-center shadow" 
                                       style="width: 42px; height: 42px; cursor: pointer;" title="Cambiar foto de perfil">
                                    <i class="bi bi-camera-fill fs-6"></i>
                                    <input type="file" id="fotoPerfil" name="fotoPerfil" accept="image/jpeg,image/png,image/gif,image/webp" style="display: none;" onchange="previewAvatar(this)">
                                </label>
                            </div>
                            <div id="avatarNotice" class="mt-2">
                                <small class="text-muted">Haz clic en el ícono de cámara para seleccionar una nueva foto (JPG, PNG, WEBP, máx 10MB)</small>
                            </div>
                        </div>
                        
                        <hr class="my-4">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label-vesta">Nombres *</label>
                                <input type="text" name="nombres" class="form-control form-control-vesta" value="${perfil.nombres}" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Apellidos *</label>
                                <input type="text" name="apellidos" class="form-control form-control-vesta" value="${perfil.apellidos}" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label-vesta">Documento de Identidad</label>
                                <input type="text" name="documento" class="form-control form-control-vesta" value="${perfil.documento}" placeholder="C.C. o NIT">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-vesta">Teléfono de Contacto</label>
                                <input type="tel" name="telefono" class="form-control form-control-vesta" value="${perfil.telefono}" placeholder="300 123 4567">
                            </div>

                            <div class="col-12">
                                <label class="form-label-vesta">Dirección</label>
                                <input type="text" name="direccion" class="form-control form-control-vesta" value="${perfil.direccion}" placeholder="Dirección física">
                            </div>

                            <div class="col-12">
                                <label class="form-label-vesta">Correo Electrónico de la Cuenta</label>
                                <input type="email" class="form-control form-control-vesta bg-light" value="${sessionScope.correoUsuario}" readonly>
                                <small class="text-muted">El correo electrónico identifica tu cuenta de forma única y no se puede modificar.</small>
                            </div>
                        </div>

                        <div class="mt-4 pt-3 border-top d-flex align-items-center justify-content-between">
                            <span class="text-muted small">* Campos obligatorios</span>
                            <button type="submit" class="btn btn-vesta-accent px-4 py-2">
                                <i class="bi bi-check2-circle me-1"></i> Guardar Cambios
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="col-lg-4 mt-4 mt-lg-0">
                <div class="bg-white p-4 rounded-4 border border-light shadow-sm">
                    <h5 class="fw-bold text-primary mb-3"><i class="bi bi-shield-check text-success me-2"></i> Estado de la Cuenta</h5>
                    <div class="mb-3">
                        <span class="text-muted small d-block">Rol Principal</span>
                        <span class="badge bg-primary text-uppercase px-2 py-1 mt-1">${sessionScope.rolPrincipal}</span>
                    </div>
                    <div class="mb-3">
                        <span class="text-muted small d-block">Estado de Usuario</span>
                        <span class="badge-vesta badge-vesta-success mt-1">Activo</span>
                    </div>
                    <hr>
                    <p class="small text-muted mb-0">
                        <i class="bi bi-info-circle me-1"></i> Tu foto de perfil se mostrará en el encabezado, paneles laterales y en las gestiones inmobiliarias de la plataforma.
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function previewAvatar(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        if (!file.type.startsWith('image/')) {
            alert('Por favor selecciona un archivo de imagen válido (JPG, PNG, GIF, WEBP).');
            return;
        }
        if (file.size > 10 * 1024 * 1024) {
            alert('La imagen no debe superar los 10MB.');
            return;
        }
        const reader = new FileReader();
        reader.onload = function(e) {
            const container = document.getElementById('avatarContainer');
            if (container) {
                container.innerHTML = '<img src="' + e.target.result + '" alt="Foto de perfil" class="rounded-circle border border-3 border-primary" style="width: 140px; height: 140px; object-fit: cover;">';
            }
            const notice = document.getElementById('avatarNotice');
            if (notice) {
                notice.innerHTML = '<div class="alert alert-success py-1 px-2 d-inline-block small mt-1 mb-0"><i class="bi bi-check2 me-1"></i> Foto seleccionada: ' + file.name + '. Haz clic en "Guardar Cambios" para confirmar.</div>';
            }
        };
        reader.readAsDataURL(file);
    }
}
</script>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
