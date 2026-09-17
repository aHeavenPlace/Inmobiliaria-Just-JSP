<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<div class="dashboard-sidebar">
    <div class="sidebar-user">
        <c:choose>
            <c:when test="${not empty sessionScope.usuarioLogueado.perfil.fotoUrl}">
                <img src="${sessionScope.usuarioLogueado.perfil.fotoUrl.startsWith('http') ? sessionScope.usuarioLogueado.perfil.fotoUrl : pageContext.request.contextPath.concat('/uploads/perfiles/').concat(sessionScope.usuarioLogueado.perfil.fotoUrl)}"
                     alt="Avatar" class="sidebar-avatar" style="object-fit: cover;">
            </c:when>
            <c:otherwise>
                <div class="sidebar-avatar bg-primary text-white d-flex align-items-center justify-content-center fw-bold"
                     style="font-size: 1.5rem;">
                    ${not empty sessionScope.nombreUsuario ? fn:substring(sessionScope.nombreUsuario, 0, 1) : 'U'}
                </div>
            </c:otherwise>
        </c:choose>
        <div class="overflow-hidden">
            <h6 class="fw-bold mb-0 text-truncate">${sessionScope.nombreUsuario}</h6>
            <small class="text-muted d-block text-truncate">Super Administrador</small>
            <span class="badge bg-danger bg-opacity-10 text-danger small px-2 py-0 mt-1">Admin Global</span>
        </div>
    </div>

    <div class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-link ${pageContext.request.servletPath == '/admin/dashboard' ? 'active' : ''}">
            <i class="bi bi-speedometer2"></i>
            <span>Dashboard Global</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/usuarios" class="sidebar-link ${pageContext.request.servletPath == '/admin/usuarios' ? 'active' : ''}">
            <i class="bi bi-people"></i>
            <span>Usuarios & Roles</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/propiedades" class="sidebar-link ${pageContext.request.servletPath.startsWith('/admin/propiedad') ? 'active' : ''}">
            <i class="bi bi-houses"></i>
            <span>Inmuebles & Catálogo</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/catalogos" class="sidebar-link ${pageContext.request.servletPath == '/admin/catalogos' ? 'active' : ''}">
            <i class="bi bi-sliders"></i>
            <span>Parametrización</span>
        </a>
        <a href="${pageContext.request.contextPath}/cliente/perfil" class="sidebar-link ${pageContext.request.servletPath == '/cliente/perfil' ? 'active' : ''}">
            <i class="bi bi-person-gear"></i>
            <span>Mi Perfil</span>
        </a>
        <hr class="my-2 text-muted opacity-25">
        <a href="${pageContext.request.contextPath}/catalogo" class="sidebar-link">
            <i class="bi bi-eye"></i>
            <span>Portal Público</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-link text-danger">
            <i class="bi bi-box-arrow-right"></i>
            <span>Cerrar Sesión</span>
        </a>
    </div>
</div>
