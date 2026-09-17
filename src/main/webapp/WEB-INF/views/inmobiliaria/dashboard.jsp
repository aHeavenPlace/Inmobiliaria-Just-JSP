<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Panel Inmobiliaria | Inmobiliaria Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <jsp:include page="/WEB-INF/views/components/sidebar_inmobiliaria.jsp"/>

    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Panel de Gestión Inmobiliaria</h2>
                <p class="text-muted mb-0">Control integral de publicaciones, agenda de visitas y métricas del catálogo</p>
            </div>
            <a href="${pageContext.request.contextPath}/inmobiliaria/propiedad-nueva" class="btn btn-vesta-accent">
                <i class="bi bi-plus-lg"></i> Publicar Nueva Propiedad
            </a>
        </div>

        <!-- Tarjetas de Métricas -->
        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Propiedades Publicadas</span>
                        <div class="stat-number">${metricas.misPropiedades != null ? metricas.misPropiedades : 0}</div>
                        <small class="text-success"><i class="bi bi-check-circle"></i> Inmuebles en catálogo</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-blue">
                        <i class="bi bi-buildings"></i>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Inmuebles Disponibles</span>
                        <div class="stat-number">${metricas.propiedadesDisponibles != null ? metricas.propiedadesDisponibles : 0}</div>
                        <small class="text-primary"><i class="bi bi-tag"></i> Listas para negociar</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-green">
                        <i class="bi bi-patch-check"></i>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Citas Pendientes</span>
                        <div class="stat-number">${metricas.citasPendientes != null ? metricas.citasPendientes : 0}</div>
                        <small class="text-warning"><i class="bi bi-clock-history"></i> Por confirmar</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-amber">
                        <i class="bi bi-calendar-event"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Propiedades Recientes de la Inmobiliaria -->
        <div class="bg-white p-4 rounded-4 border border-light shadow-sm mb-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold text-primary mb-0"><i class="bi bi-houses me-2"></i> Mis Inmuebles Recientes</h5>
                <a href="${pageContext.request.contextPath}/inmobiliaria/propiedades" class="small text-muted">Ver todas</a>
            </div>

            <div class="table-responsive">
                <table class="table-vesta">
                    <thead>
                        <tr>
                            <th>Inmueble</th>
                            <th>Ciudad</th>
                            <th>Tipo</th>
                            <th>Operación</th>
                            <th>Precio</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${propiedades}" end="4">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="${p.getImagenPrincipalUrl(pageContext.request.contextPath)}" alt="${p.titulo}" class="rounded-3 shadow-xs" width="50" height="50" style="object-fit: cover;">
                                        <div>
                                            <strong class="text-primary d-block">${p.titulo}</strong>
                                            <small class="text-muted">${p.matriculaInmobiliaria}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>${p.ciudadNombre}</td>
                                <td><span class="badge bg-light text-dark border">${p.tipoNombre}</span></td>
                                <td><span class="badge bg-primary text-uppercase">${p.tipoOperacion}</span></td>
                                <td class="fw-bold text-primary">${p.precioFormateado}</td>
                                <td>
                                    <span class="badge-vesta ${p.estado == 'disponible' ? 'badge-vesta-success' : p.estado == 'vendido' ? 'badge-vesta-info' : 'badge-vesta-warning'}">
                                        ${p.estado}
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex gap-1">
                                        <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}" class="btn btn-sm btn-light" title="Ver en portal"><i class="bi bi-eye"></i></a>
                                        <a href="${pageContext.request.contextPath}/inmobiliaria/propiedad-editar?id=${p.idPropiedad}" class="btn btn-sm btn-light text-primary" title="Editar"><i class="bi bi-pencil"></i></a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
