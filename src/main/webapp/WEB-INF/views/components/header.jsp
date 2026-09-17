<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Vesta - Portal inmobiliario premium. Venta y arriendo de casas, apartamentos y oficinas exclusivos.">
    <title>${not empty pageTitle ? pageTitle : 'Vesta | Inmuebles Exclusivos'}</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <!-- Vesta Custom Design System -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/variables.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body>

<!-- Navbar Glassmorphism -->
<nav class="navbar navbar-expand-lg navbar-glass py-3">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/home">
            <i class="bi bi-buildings-fill" style="color: var(--color-accent);"></i>
            <span>VESTA</span>
            <span class="brand-badge">Inmobiliaria</span>
        </a>

        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
            <i class="bi bi-list fs-2"></i>
        </button>

        <div class="collapse navbar-collapse" id="navbarMain">
            <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link nav-link-vesta" href="${pageContext.request.contextPath}/home">
                        <i class="bi bi-house me-1"></i> Inicio
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-link-vesta" href="${pageContext.request.contextPath}/catalogo">
                        <i class="bi bi-grid me-1"></i> Catálogo
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-link-vesta" href="${pageContext.request.contextPath}/catalogo?operacion=venta">
                        <i class="bi bi-tag me-1"></i> En Venta
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-link-vesta" href="${pageContext.request.contextPath}/catalogo?operacion=arriendo">
                        <i class="bi bi-key me-1"></i> En Arriendo
                    </a>
                </li>
            </ul>

            <div class="d-flex align-items-center gap-2">
                <c:choose>
                    <c:when test="${not empty sessionScope.usuarioLogueado}">
                        <div class="dropdown">
                            <button class="btn btn-vesta-outline dropdown-toggle d-flex align-items-center gap-2" type="button" data-bs-toggle="dropdown">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.usuarioLogueado.perfil.fotoUrl}">
                                        <img src="${sessionScope.usuarioLogueado.perfil.fotoUrl.startsWith('http') ? sessionScope.usuarioLogueado.perfil.fotoUrl : pageContext.request.contextPath.concat('/uploads/perfiles/').concat(sessionScope.usuarioLogueado.perfil.fotoUrl)}" 
                                             alt="Avatar" class="rounded-circle" width="28" height="28" style="object-fit: cover;">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center fw-bold" style="width: 28px; height: 28px; font-size: 0.9rem;">${not empty sessionScope.nombreUsuario ? fn:substring(sessionScope.nombreUsuario, 0, 1) : 'U'}</div>
                                    </c:otherwise>
                                </c:choose>
                                <span>${sessionScope.nombreUsuario}</span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2" style="border-radius: var(--radius-md);">
                                <li>
                                    <h6 class="dropdown-header text-uppercase fw-bold text-muted small">
                                        Rol: ${sessionScope.rolPrincipal}
                                    </h6>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/cliente/perfil"><i class="bi bi-person-gear me-2" style="color: var(--color-accent);"></i> Mi Perfil</a></li>
                                <c:if test="${sessionScope.usuarioLogueado.hasRole('admin')}">
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-shield-lock me-2" style="color: var(--color-primary);"></i> Panel Administrador</a></li>
                                </c:if>
                                <c:if test="${sessionScope.usuarioLogueado.hasRole('inmobiliaria')}">
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/inmobiliaria/dashboard"><i class="bi bi-building me-2" style="color: var(--color-accent);"></i> Panel Inmobiliaria</a></li>
                                </c:if>
                                <c:if test="${sessionScope.usuarioLogueado.hasRole('cliente')}">
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/cliente/dashboard"><i class="bi bi-person-circle me-2" style="color: var(--status-success);"></i> Mi Panel</a></li>
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/cliente/favoritos"><i class="bi bi-heart me-2" style="color: var(--status-danger);"></i> Mis Favoritos</a></li>
                                    <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/cliente/citas"><i class="bi bi-calendar-event me-2" style="color: var(--status-warning);"></i> Mis Citas</a></li>
                                </c:if>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item py-2 text-danger fw-semibold" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i> Cerrar Sesión</a></li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-vesta-outline">
                            <i class="bi bi-person"></i> Ingresar
                        </a>
                        <a href="${pageContext.request.contextPath}/registro" class="btn btn-vesta-accent">
                            <i class="bi bi-plus-circle"></i> Registrarse
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
