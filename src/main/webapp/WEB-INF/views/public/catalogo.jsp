<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Catálogo de Inmuebles | Inmobiliaria Vesta"/>
</jsp:include>

<div class="vesta-header-section py-5 mb-5">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1 class="h3 fw-bold mb-1 text-charcoal">Catálogo de Inmuebles</h1>
                <p class="small text-terracotta-muted mb-0" style="font-weight: 500;">Explora propiedades verificadas disponibles para venta y arriendo en Colombia</p>
            </div>
            <span class="badge vesta-badge px-3 py-2 rounded-pill fw-semibold">
                ${propiedades.size()} propiedades encontradas
            </span>
        </div>
    </div>
</div>

<div class="container pb-5">
    <div class="row g-4">
        <!-- Sidebar de Filtros -->
        <div class="col-lg-3">
            <div class="bg-white p-4 rounded-4 border border-light shadow-sm sticky-top" style="top: 100px;">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold mb-0 text-primary"><i class="bi bi-funnel me-1"></i> Filtros</h5>
                    <a href="${pageContext.request.contextPath}/catalogo" class="small text-muted text-decoration-underline">Limpiar</a>
                </div>

                <form action="${pageContext.request.contextPath}/catalogo" method="GET" id="filterForm">
                    <!-- Búsqueda por palabra clave -->
                    <div class="mb-3">
                        <label class="form-label-vesta">Buscar por texto</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" name="q" class="form-control form-control-vesta border-start-0" 
                                   placeholder="Barrio, título..." value="${filtroQ}">
                        </div>
                    </div>

                    <!-- Ciudad -->
                    <div class="mb-3">
                        <label class="form-label-vesta">Ciudad</label>
                        <select name="ciudad" class="form-select form-select-vesta" onchange="document.getElementById('filterForm').submit();">
                            <option value="">Todas las ciudades</option>
                            <c:forEach var="c" items="${ciudades}">
                                <option value="${c.idCiudad}" ${filtroCiudad == c.idCiudad ? 'selected' : ''}>
                                    ${c.nombre}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Tipo de Propiedad -->
                    <div class="mb-3">
                        <label class="form-label-vesta">Tipo de Inmueble</label>
                        <select name="tipo" class="form-select form-select-vesta" onchange="document.getElementById('filterForm').submit();">
                            <option value="">Todos los tipos</option>
                            <c:forEach var="t" items="${tiposPropiedad}">
                                <option value="${t.idTipo}" ${filtroTipo == t.idTipo ? 'selected' : ''}>
                                    ${t.nombre}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Tipo de Operación -->
                    <div class="mb-3">
                        <label class="form-label-vesta">Operación</label>
                        <div class="d-flex gap-2">
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="operacion" id="opTodos" value="todos" 
                                       ${empty filtroOperacion || filtroOperacion == 'todos' ? 'checked' : ''} 
                                       onchange="document.getElementById('filterForm').submit();">
                                <label class="form-check-label small" for="opTodos">Todas</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="operacion" id="opVenta" value="venta" 
                                       ${filtroOperacion == 'venta' ? 'checked' : ''} 
                                       onchange="document.getElementById('filterForm').submit();">
                                <label class="form-check-label small" for="opVenta">Venta</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="operacion" id="opArriendo" value="arriendo" 
                                       ${filtroOperacion == 'arriendo' ? 'checked' : ''} 
                                       onchange="document.getElementById('filterForm').submit();">
                                <label class="form-check-label small" for="opArriendo">Arriendo</label>
                            </div>
                        </div>
                    </div>

                    <!-- Precio Máximo -->
                    <div class="mb-4">
                        <label class="form-label-vesta">Precio Máximo ($)</label>
                        <input type="number" name="precio" class="form-control form-control-vesta" 
                               placeholder="Ej: 400000000" value="${filtroPrecio}" step="10000000">
                    </div>

                    <button type="submit" class="btn btn-vesta-accent w-100 justify-content-center">
                        <i class="bi bi-filter"></i> Aplicar Filtros
                    </button>
                </form>
            </div>
        </div>

        <!-- Grid de Propiedades -->
        <div class="col-lg-9">
            <c:choose>
                <c:when test="${empty propiedades}">
                    <div class="bg-white p-5 rounded-4 text-center border border-light shadow-sm my-4">
                        <i class="bi bi-search text-muted mb-3" style="font-size: 3.5rem;"></i>
                        <h4 class="fw-bold text-primary">No se encontraron propiedades</h4>
                        <p class="text-muted max-w-md mx-auto mb-4" style="max-width: 450px;">
                            Intenta ajustar o limpiar los filtros seleccionados para ampliar los resultados de búsqueda.
                        </p>
                        <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-vesta-primary">
                            Ver todas las propiedades
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="row g-4">
                        <c:forEach var="p" items="${propiedades}">
                            <div class="col-md-6 col-xl-4">
                                <div class="property-card">
                                    <div class="property-thumb-wrap">
                                        <img src="${p.getImagenPrincipalUrl(pageContext.request.contextPath)}" alt="${p.titulo}" class="property-thumb" loading="lazy">
                                        <span class="badge-operation">${p.tipoOperacion}</span>
                                        <span class="badge-type">${p.tipoNombre}</span>
                                        <button class="btn-favorite-heart ${p.esFavorito ? 'is-favorite' : ''}" 
                                                data-id="${p.idPropiedad}" 
                                                data-context="${pageContext.request.contextPath}"
                                                title="Guardar en favoritos">
                                            <i class="bi ${p.esFavorito ? 'bi-heart-fill' : 'bi-heart'}"></i>
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
                                            <div class="feature-item" title="Área construida">
                                                <i class="bi bi-aspect-ratio"></i>
                                                <span>${p.areaM2} m²</span>
                                            </div>
                                        </div>

                                        <div class="pt-3 mt-2 d-flex justify-content-between align-items-center">
                                            <span class="badge bg-light text-dark border">
                                                <i class="bi bi-building me-1"></i> ${p.inmobiliariaNombre}
                                            </span>
                                            <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}" class="btn btn-sm btn-vesta-primary">
                                                Detalles
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
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
