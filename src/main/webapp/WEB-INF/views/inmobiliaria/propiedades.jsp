<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Gestión de Inmuebles | Inmobiliaria Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <jsp:include page="/WEB-INF/views/components/sidebar_inmobiliaria.jsp"/>

    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Portafolio de Inmuebles</h2>
                <p class="text-muted mb-0">Administra las propiedades publicadas por tu inmobiliaria</p>
            </div>
            <a href="${pageContext.request.contextPath}/inmobiliaria/propiedad-nueva" class="btn btn-vesta-accent">
                <i class="bi bi-plus-lg"></i> Publicar Nueva Propiedad
            </a>
        </div>

        <c:if test="${param.msg == 'propiedad_creada'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Propiedad publicada exitosamente en el catálogo.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${param.msg == 'propiedad_actualizada'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Propiedad actualizada exitosamente.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${param.msg == 'propiedad_eliminada'}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="bi bi-trash-fill me-2"></i> Propiedad eliminada del portafolio.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="table-responsive">
            <table class="table-vesta">
                <thead>
                    <tr>
                        <th>Inmueble</th>
                        <th>Ubicación</th>
                        <th>Tipo</th>
                        <th>Operación</th>
                        <th>Precio</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${propiedades}">
                        <tr>
                            <td>
                                <div class="d-flex align-items-center gap-3">
                                    <img src="${p.getImagenPrincipalUrl(pageContext.request.contextPath)}" alt="${p.titulo}" class="rounded-3 shadow-xs" width="56" height="56" style="object-fit: cover;">
                                    <div>
                                        <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}" class="fw-bold text-primary text-decoration-none">
                                            ${p.titulo}
                                        </a>
                                        <small class="text-muted d-block">${p.matriculaInmobiliaria} &bull; ${p.areaM2} m²</small>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div>${p.ciudadNombre}</div>
                                <small class="text-muted">${p.direccion}</small>
                            </td>
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
                                    <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}" class="btn btn-sm btn-light" title="Ver en portal">
                                        <i class="bi bi-eye"></i>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/inmobiliaria/propiedad-editar?id=${p.idPropiedad}" class="btn btn-sm btn-light text-primary" title="Editar">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/inmobiliaria/propiedad-eliminar" method="POST" onsubmit="return confirm('¿Confirmas la eliminación de este inmueble?');" style="display:inline;">
                                        <input type="hidden" name="idPropiedad" value="${p.idPropiedad}">
                                        <button type="submit" class="btn btn-sm btn-light text-danger" title="Eliminar">
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
                                No tienes propiedades registradas en este momento.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
