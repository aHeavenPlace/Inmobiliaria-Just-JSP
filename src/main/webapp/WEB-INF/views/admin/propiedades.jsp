<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Gestión Global de Inmuebles | Administración Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <jsp:include page="/WEB-INF/views/components/sidebar_admin.jsp"/>

    <div class="dashboard-content">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Inmuebles & Catálogo Global</h2>
                <p class="text-muted mb-0">Control y administración general de todas las propiedades publicadas en la plataforma</p>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="badge bg-primary px-3 py-2 fs-6">
                    <i class="bi bi-buildings me-1"></i> ${propiedades.size()} Inmuebles totales
                </span>
            </div>
        </div>

        <c:if test="${param.msg == 'propiedad_actualizada'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Inmueble actualizado correctamente por el administrador.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${param.msg == 'propiedad_eliminada'}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="bi bi-trash-fill me-2"></i> Inmueble eliminado del catálogo global exitosamente.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-octagon-fill me-2"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="bg-white rounded-4 border border-light shadow-sm p-4">
            <div class="table-responsive">
                <table class="table-vesta">
                    <thead>
                        <tr>
                            <th>Inmueble</th>
                            <th>Inmobiliaria Aliada</th>
                            <th>Ubicación</th>
                            <th>Tipo / Operación</th>
                            <th>Precio</th>
                            <th>Estado</th>
                            <th class="text-end">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${propiedades}">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="${p.getImagenPrincipalUrl(pageContext.request.contextPath)}" 
                                             alt="${p.titulo}" class="rounded-3 shadow-xs" width="56" height="56" style="object-fit: cover;">
                                        <div>
                                            <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}" 
                                               target="_blank" class="fw-bold text-primary text-decoration-none">
                                                ${p.titulo}
                                            </a>
                                            <small class="text-muted d-block">Matrícula: ${p.matriculaInmobiliaria} &bull; ${p.areaM2} m²</small>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="fw-semibold text-dark">${p.inmobiliariaNombre}</div>
                                    <small class="text-muted">ID Org: ${p.idInmobiliaria}</small>
                                </td>
                                <td>
                                    <div>${p.ciudadNombre}</div>
                                    <small class="text-muted">${p.direccion}</small>
                                </td>
                                <td>
                                    <div><span class="badge bg-light text-dark border">${p.tipoNombre}</span></div>
                                    <span class="badge ${p.tipoOperacion == 'venta' ? 'bg-primary' : 'bg-secondary'} text-uppercase mt-1" style="font-size: 0.75rem;">
                                        ${p.tipoOperacion}
                                    </span>
                                </td>
                                <td class="fw-bold text-primary">${p.precioFormateado}</td>
                                <td>
                                    <span class="badge-vesta ${p.estado == 'disponible' ? 'badge-vesta-success' : p.estado == 'vendido' ? 'badge-vesta-info' : 'badge-vesta-warning'}">
                                        ${p.estado}
                                    </span>
                                </td>
                                <td class="text-end">
                                    <div class="d-inline-flex gap-1">
                                        <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}" target="_blank" 
                                           class="btn btn-sm btn-light" title="Ver en portal público">
                                            <i class="bi bi-eye"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/propiedad-editar?id=${p.idPropiedad}" 
                                           class="btn btn-sm btn-light text-primary" title="Editar como Administrador">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <form action="${pageContext.request.contextPath}/admin/propiedad-eliminar" method="POST" 
                                              onsubmit="return confirm('¿Estás seguro de eliminar este inmueble de forma permanente? Esta acción borrará fotos, citas y solicitudes asociadas.');" style="display:inline;">
                                            <input type="hidden" name="idPropiedad" value="${p.idPropiedad}">
                                            <button type="submit" class="btn btn-sm btn-light text-danger" title="Eliminar inmueble">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty propiedades}">
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="bi bi-house-slash fs-1 d-block mb-2 opacity-50"></i>
                                    No se encontraron propiedades registradas en la base de datos.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
