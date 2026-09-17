<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Panel Administrador | Inmobiliaria Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <jsp:include page="/WEB-INF/views/components/sidebar_admin.jsp"/>

    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Panel de Administración Global</h2>
                <p class="text-muted mb-0">Vista consolidada del sistema inmobiliario: usuarios, propiedades, citas y solicitudes</p>
            </div>
            <span class="badge bg-danger text-white px-3 py-2 rounded-pill fs-6">
                <i class="bi bi-shield-fill-exclamation me-1"></i> Acceso Super Administrador
            </span>
        </div>

        <!-- KPIs Globales del Sistema -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Total Usuarios</span>
                        <div class="stat-number">${metricas.totalUsuarios != null ? metricas.totalUsuarios : 0}</div>
                        <small class="text-muted">Registrados en la plataforma</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-blue">
                        <i class="bi bi-people-fill"></i>
                    </div>
                </div>
            </div>

            <div class="col-md-3">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Propiedades</span>
                        <div class="stat-number">${metricas.totalPropiedades != null ? metricas.totalPropiedades : 0}</div>
                        <small class="text-success"><i class="bi bi-check-circle"></i> En catálogo</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-green">
                        <i class="bi bi-houses-fill"></i>
                    </div>
                </div>
            </div>

            <div class="col-md-3">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Citas Agendadas</span>
                        <div class="stat-number">${metricas.totalCitas != null ? metricas.totalCitas : 0}</div>
                        <small class="text-info">En el período</small>
                    </div>
                    <div class="stat-icon-wrap stat-icon-amber">
                        <i class="bi bi-calendar-event-fill"></i>
                    </div>
                </div>
            </div>

            <div class="col-md-3">
                <div class="stat-card">
                    <div>
                        <span class="text-muted text-uppercase fw-bold small">Solicitudes</span>
                        <div class="stat-number">${metricas.totalSolicitudes != null ? metricas.totalSolicitudes : 0}</div>
                        <small class="text-warning">Tramitadas en sistema</small>
                    </div>
                    <div class="stat-icon-wrap" style="background: rgba(220, 38, 38, 0.1); color: #DC2626;">
                        <i class="bi bi-file-earmark-check-fill"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Inmuebles Recientes en la Plataforma -->
            <div class="col-lg-8">
                <div class="bg-white p-4 rounded-4 border border-light shadow-sm">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold text-primary mb-0"><i class="bi bi-houses me-2"></i> Inmuebles Recientes en la Plataforma</h5>
                        <a href="${pageContext.request.contextPath}/admin/propiedades" class="small text-muted">Ver todas</a>
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
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${propiedadesRecientes}">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <img src="${p.getImagenPrincipalUrl(pageContext.request.contextPath)}" alt="${p.titulo}" class="rounded-2 shadow-xs" width="40" height="40" style="object-fit: cover;">
                                                <div class="text-truncate" style="max-width: 180px;">
                                                    <strong class="text-primary d-block text-truncate">${p.titulo}</strong>
                                                    <small class="text-muted">${p.inmobiliariaNombre}</small>
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
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty propiedadesRecientes}">
                                    <tr>
                                        <td colspan="6" class="text-center py-4 text-muted">
                                            <i class="bi bi-houses fs-3 d-block mb-2"></i>
                                            No hay inmuebles registrados aún en el catálogo.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Accesos Rápidos Admin -->
            <div class="col-lg-4">
                <div class="bg-white p-4 rounded-4 border border-light shadow-sm">
                    <h5 class="fw-bold text-primary mb-3"><i class="bi bi-grid-3x3-gap me-2"></i> Acciones Administrativas</h5>
                    <div class="d-grid gap-2">
                        <a href="${pageContext.request.contextPath}/admin/usuarios" class="btn btn-vesta-outline justify-content-start">
                            <i class="bi bi-people me-2"></i> Gestionar Usuarios & Roles
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/propiedades" class="btn btn-vesta-outline justify-content-start">
                            <i class="bi bi-houses me-2"></i> Inmuebles & Catálogo Global
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/catalogos" class="btn btn-vesta-outline justify-content-start">
                            <i class="bi bi-sliders me-2"></i> Parametrización & Catálogos
                        </a>
                        <a href="${pageContext.request.contextPath}/reportes/exportar-csv" class="btn btn-vesta-primary justify-content-start">
                            <i class="bi bi-file-earmark-spreadsheet me-2"></i> Exportar Reporte CSV
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
