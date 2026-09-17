<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Mi Panel de Cliente | Inmobiliaria Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <jsp:include page="/WEB-INF/views/components/sidebar_cliente.jsp"/>

    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">¡Hola, ${sessionScope.nombreUsuario}!</h2>
                <p class="text-muted mb-0">Gestiona tus visitas agendadas y tus propiedades favoritas guardadas</p>
            </div>
            <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-vesta-accent">
                <i class="bi bi-search"></i> Explorar Propiedades
            </a>
        </div>

        <c:if test="${param.registro == 'ok'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> ¡Bienvenido! Tu cuenta ha sido creada exitosamente.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Tarjetas de Métricas -->
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Mis Favoritos</span>
                        <div class="stat-number">${metricas.misFavoritos != null ? metricas.misFavoritos : 0}</div>
                        <small class="text-success"><i class="bi bi-heart-fill"></i> Inmuebles guardados</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-amber">
                        <i class="bi bi-heart"></i>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Citas Activas</span>
                        <div class="stat-number">${metricas.misCitasActivas != null ? metricas.misCitasActivas : 0}</div>
                        <small class="text-info"><i class="bi bi-clock-history"></i> Visitas agendadas</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-blue">
                        <i class="bi bi-calendar-event"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Próximas Citas -->
            <div class="col-lg-6">
                <div class="bg-white p-4 rounded-4 border border-light shadow-sm h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold text-primary mb-0"><i class="bi bi-calendar2-check me-2"></i> Mis Próximas Citas</h5>
                        <a href="${pageContext.request.contextPath}/cliente/citas" class="small text-muted">Ver todas</a>
                    </div>
                    <c:choose>
                        <c:when test="${empty citas}">
                            <div class="text-center py-4 text-muted">
                                <i class="bi bi-calendar-x fs-2 mb-2 d-block"></i>
                                <p class="small mb-0">No tienes visitas programadas actualmente.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="d-flex flex-column gap-3">
                                <c:forEach var="c" items="${citas}" end="3">
                                    <div class="p-3 rounded-3 bg-light border border-light d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6 class="fw-bold mb-1">${c.propiedadTitulo}</h6>
                                            <small class="text-muted d-block"><i class="bi bi-clock"></i> ${c.fechaHoraFormateada}</small>
                                            <small class="text-muted"><i class="bi bi-building"></i> ${c.inmobiliariaNombre}</small>
                                        </div>
                                        <span class="badge-vesta ${c.estado == 'confirmada' ? 'badge-vesta-success' : c.estado == 'pendiente' ? 'badge-vesta-warning' : c.estado == 'cancelada' ? 'badge-vesta-danger' : 'badge-vesta-info'}">
                                            ${c.estado}
                                        </span>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Favoritos Recientes -->
            <div class="col-lg-6">
                <div class="bg-white p-4 rounded-4 border border-light shadow-sm h-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold text-primary mb-0"><i class="bi bi-heart me-2"></i> Inmuebles Guardados</h5>
                        <a href="${pageContext.request.contextPath}/cliente/favoritos" class="small text-muted">Ver todos</a>
                    </div>
                    <c:choose>
                        <c:when test="${empty favoritos}">
                            <div class="text-center py-4 text-muted">
                                <i class="bi bi-heartbreak fs-2 mb-2 d-block"></i>
                                <p class="small mb-0">No has guardado propiedades favoritas aún.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="d-flex flex-column gap-3">
                                <c:forEach var="f" items="${favoritos}" end="3">
                                    <div class="p-3 rounded-3 bg-light border border-light d-flex justify-content-between align-items-center">
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="${f.getImagenPrincipalUrl(pageContext.request.contextPath)}" alt="${f.titulo}" 
                                                 class="rounded-3 shadow-xs" width="48" height="48" style="object-fit: cover;">
                                            <div>
                                                <h6 class="fw-bold mb-1 text-truncate" style="max-width: 220px;">${f.titulo}</h6>
                                                <small class="text-muted d-block">${f.ciudadNombre} &bull; <strong class="text-primary">${f.precioFormateado}</strong></small>
                                            </div>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/propiedad?id=${f.idPropiedad}" class="btn btn-sm btn-vesta-outline">
                                            <i class="bi bi-eye"></i>
                                        </a>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
