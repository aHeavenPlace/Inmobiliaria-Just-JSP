<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Mis Favoritos | Inmobiliaria Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <jsp:include page="/WEB-INF/views/components/sidebar_cliente.jsp"/>

    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Mis Propiedades Favoritas</h2>
                <p class="text-muted mb-0">Inmuebles que has marcado para seguimiento rápido</p>
            </div>
            <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-vesta-outline">
                <i class="bi bi-search"></i> Buscar Más
            </a>
        </div>

        <c:choose>
            <c:when test="${empty favoritos}">
                <div class="bg-white p-5 rounded-4 text-center border border-light shadow-sm my-4">
                    <i class="bi bi-heart text-muted mb-3" style="font-size: 3.5rem;"></i>
                    <h4 class="fw-bold text-primary">Aún no tienes favoritos guardados</h4>
                    <p class="text-muted max-w-md mx-auto mb-4" style="max-width: 450px;">
                        Navega por nuestro catálogo y haz clic en el icono de corazón de cualquier propiedad para guardarla aquí.
                    </p>
                    <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-vesta-accent">
                        Explorar Catálogo
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="row g-4">
                    <c:forEach var="p" items="${favoritos}">
                        <div class="col-md-6 col-xl-4" id="fav-card-${p.idPropiedad}">
                            <div class="property-card">
                                <div class="property-thumb-wrap">
                                    <img src="${p.getImagenPrincipalUrl(pageContext.request.contextPath)}" alt="${p.titulo}" class="property-thumb" loading="lazy">
                                    <span class="badge-operation">${p.tipoOperacion}</span>
                                    <span class="badge-type">${p.tipoNombre}</span>
                                    <button class="btn-favorite-heart is-favorite" 
                                            data-id="${p.idPropiedad}" 
                                            data-context="${pageContext.request.contextPath}"
                                            title="Remover de favoritos">
                                        <i class="bi bi-heart-fill"></i>
                                    </button>
                                </div>
                                <div class="property-body">
                                    <div class="property-price">${p.precioFormateado}</div>
                                    <h3 class="property-title">
                                        <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}">${p.titulo}</a>
                                    </h3>
                                    <div class="property-location">
                                        <i class="bi bi-geo-alt-fill text-danger"></i>
                                        <span>${p.direccion}, ${p.ciudadNombre}</span>
                                    </div>

                                    <div class="property-features">
                                        <div class="feature-item" title="Habitaciones">
                                            <i class="bi bi-door-open"></i>
                                            <span>${p.habitaciones}</span>
                                        </div>
                                        <div class="feature-item" title="Baños">
                                            <i class="bi bi-droplet"></i>
                                            <span>${p.banos}</span>
                                        </div>
                                        <div class="feature-item" title="Área">
                                            <i class="bi bi-aspect-ratio"></i>
                                            <span>${p.areaM2} m²</span>
                                        </div>
                                    </div>

                                    <div class="pt-3 mt-2 d-flex justify-content-between align-items-center">
                                        <small class="text-muted"><i class="bi bi-building"></i> ${p.inmobiliariaNombre}</small>
                                        <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}" class="btn btn-sm btn-vesta-primary">
                                            Ver Ficha
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
