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
            <small class="text-muted d-block text-truncate">Inmobiliaria Vesta SAS</small>
            <span class="badge bg-info bg-opacity-10 text-info small px-2 py-0 mt-1">Agente Inmobiliario</span>
        </div>
    </div>

    <div class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/inmobiliaria/dashboard" class="sidebar-link ${pageContext.request.servletPath == '/inmobiliaria/dashboard' ? 'active' : ''}">
            <i class="bi bi-speedometer2"></i>
            <span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/inmobiliaria/propiedades" class="sidebar-link ${pageContext.request.servletPath.startsWith('/inmobiliaria/propiedad') ? 'active' : ''}">
            <i class="bi bi-houses"></i>
            <span>Mis Propiedades</span>
        </a>
        <a href="${pageContext.request.contextPath}/inmobiliaria/propiedad-nueva" class="sidebar-link ${pageContext.request.servletPath == '/inmobiliaria/propiedad-nueva' ? 'active' : ''}">
            <i class="bi bi-plus-circle"></i>
            <span>Publicar Inmueble</span>
        </a>
        <a href="${pageContext.request.contextPath}/inmobiliaria/citas" class="sidebar-link ${pageContext.request.servletPath == '/inmobiliaria/citas' ? 'active' : ''}">
            <i class="bi bi-calendar-event"></i>
            <span>Gestión de Citas</span>
        </a>
        <a href="${pageContext.request.contextPath}/inmobiliaria/reportes" class="sidebar-link ${pageContext.request.servletPath == '/inmobiliaria/reportes' ? 'active' : ''}">
            <i class="bi bi-graph-up-arrow"></i>
            <span>Reportes & Métricas</span>
        </a>
        <a href="${pageContext.request.contextPath}/cliente/perfil" class="sidebar-link ${pageContext.request.servletPath == '/cliente/perfil' ? 'active' : ''}">
            <i class="bi bi-person-gear"></i>
            <span>Mi Perfil</span>
        </a>
        <hr class="my-2 text-muted opacity-25">
        <a href="${pageContext.request.contextPath}/catalogo" class="sidebar-link">
            <i class="bi bi-eye"></i>
            <span>Ver Portal Público</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="sidebar-link text-danger">
            <i class="bi bi-box-arrow-right"></i>
            <span>Cerrar Sesión</span>
        </a>
    </div>
</div>
