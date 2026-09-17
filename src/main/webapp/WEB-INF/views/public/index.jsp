<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Vesta | Inmuebles Exclusivos en Colombia"/>
</jsp:include>

<!-- Hero Section -->
<section class="hero-section">
    <div class="container">
        <span class="badge bg-white text-dark px-3 py-2 rounded-pill fw-bold mb-3 shadow-sm" style="background: rgba(255,255,255,0.95) !important;">
            <i class="bi bi-stars" style="color: var(--color-gold);"></i> Experiencia Inmobiliaria Premium
        </span>
        <h1 class="hero-title">Encuentra el hogar o espacio ideal<br>con elegancia y confianza absoluta</h1>
        <p class="hero-subtitle">
            Explora una colección curada de casas, apartamentos, locales y oficinas en las ciudades más exclusivas de Colombia.
        </p>
    </div>
</section>

<!-- Floating Search Card -->
<div class="container">
    <div class="search-card-float">
        <form action="${pageContext.request.contextPath}/catalogo" method="GET" class="row g-3 align-items-end">
            <div class="col-lg-3 col-md-6">
                <label class="form-label-vesta"><i class="bi bi-geo-alt me-1"></i> Ciudad</label>
                <select name="ciudad" class="form-select form-select-vesta">
                    <option value="">Todas las ciudades</option>
                    <c:forEach var="c" items="${ciudades}">
                        <option value="${c.idCiudad}">${c.nombre} (${c.departamento})</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-lg-3 col-md-6">
                <label class="form-label-vesta"><i class="bi bi-building me-1"></i> Tipo de Inmueble</label>
                <select name="tipo" class="form-select form-select-vesta">
                    <option value="">Todos los tipos</option>
                    <c:forEach var="t" items="${tiposPropiedad}">
                        <option value="${t.idTipo}">${t.nombre}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="col-lg-2 col-md-6">
                <label class="form-label-vesta"><i class="bi bi-arrow-left-right me-1"></i> Operación</label>
                <select name="operacion" class="form-select form-select-vesta">
                    <option value="todos">Venta y Arriendo</option>
                    <option value="venta">Venta</option>
                    <option value="arriendo">Arriendo</option>
                </select>
            </div>

            <div class="col-lg-2 col-md-6">
                <label class="form-label-vesta"><i class="bi bi-cash me-1"></i> Precio Máx ($)</label>
                <input type="number" name="precio" class="form-control form-control-vesta" placeholder="Ej: 500000000" step="10000000">
            </div>

            <div class="col-lg-2 col-md-12">
                <button type="submit" class="btn btn-vesta-accent w-100 py-3 justify-content-center">
                    <i class="bi bi-search"></i> Buscar
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Propiedades Destacadas -->
<section class="py-5 mt-4">
    <div class="container">
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <span class="text-uppercase fw-bold" style="color: var(--text-muted); font-size: 0.75rem; letter-spacing: 1.2px;">Portafolio Selecto</span>
                <h2 class="fw-bold mb-0" style="color: var(--color-primary);">Propiedades Destacadas</h2>
            </div>
            <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-vesta-outline d-none d-md-inline-flex">
                Ver Todo el Catálogo <i class="bi bi-arrow-right"></i>
            </a>
        </div>

        <div class="row g-4">
            <c:forEach var="p" items="${propiedadesDestacadas}">
                <div class="col-lg-4 col-md-6">
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
                                <i class="bi bi-geo-alt-fill" style="color: var(--status-danger);"></i>
                                <span>${p.direccion}, ${p.ciudadNombre}</span>
                            </div>

                            <div class="property-features">
                                <div class="feature-item" title="Habitaciones">
                                    <i class="bi bi-door-open"></i>
                                    <span>${p.habitaciones} habs</span>
                                </div>
                                <div class="feature-item" title="Baños">
                                    <i class="bi bi-droplet"></i>
                                    <span>${p.banos} baños</span>
                                </div>
                                <div class="feature-item" title="Área construida">
                                    <i class="bi bi-aspect-ratio"></i>
                                    <span>${p.areaM2} m²</span>
                                </div>
                            </div>

                            <div class="pt-3 mt-2 d-flex justify-content-between align-items-center">
                                <small style="color: var(--text-muted);"><i class="bi bi-building"></i> ${p.inmobiliariaNombre}</small>
                                <a href="${pageContext.request.contextPath}/propiedad?id=${p.idPropiedad}" class="btn btn-sm btn-vesta-outline">
                                    Ver Detalle
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <div class="text-center mt-5 d-md-none">
            <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-vesta-outline w-100">
                Ver Todo el Catálogo <i class="bi bi-arrow-right ms-1"></i>
            </a>
        </div>
    </div>
</section>

<!-- Sección de Servicios y Valor Agregado -->
<section class="py-5" style="background: var(--bg-surface); border-top: 1px solid var(--border-subtle); border-bottom: 1px solid var(--border-subtle);">
    <div class="container py-4">
        <div class="text-center mb-5">
            <span class="text-uppercase fw-bold" style="color: var(--text-muted); font-size: 0.75rem; letter-spacing: 1.2px;">Nuestros Servicios</span>
            <h2 class="fw-bold mb-3" style="color: var(--color-primary);">¿Por qué elegir Vesta?</h2>
            <p class="text-muted mx-auto" style="max-width: 600px; color: var(--text-muted);">
                Combinamos asesoría experta, tecnología premium y la mayor visibilidad en el mercado inmobiliario nacional.
            </p>
        </div>

        <div class="row g-4">
            <div class="col-lg-4 col-md-6">
                <div class="p-4 h-100" style="background: var(--bg-body); border-radius: var(--radius-lg); border: 1px solid var(--border-subtle);">
                    <div class="stat-icon-wrap stat-icon-blue mb-3">
                        <i class="bi bi-shield-check"></i>
                    </div>
                    <h5 class="fw-bold mb-2" style="color: var(--color-primary);">Seguridad Jurídica Total</h5>
                    <p class="mb-0" style="color: var(--text-muted); font-size: 0.93rem;">
                        Validación rigurosa de matrículas inmobiliarias, certificados de tradición y libertad para transacciones 100% transparentes.
                    </p>
                </div>
            </div>

            <div class="col-lg-4 col-md-6">
                <div class="p-4 h-100" style="background: var(--bg-body); border-radius: var(--radius-lg); border: 1px solid var(--border-subtle);">
                    <div class="stat-icon-wrap stat-icon-green mb-3">
                        <i class="bi bi-calendar2-check"></i>
                    </div>
                    <h5 class="fw-bold mb-2" style="color: var(--color-primary);">Agendamiento Inmediato</h5>
                    <p class="mb-0" style="color: var(--text-muted); font-size: 0.93rem;">
                        Programa visitas presenciales en tiempo real con agentes certificados, recibiendo confirmación desde tu panel personal.
                    </p>
                </div>
            </div>

            <div class="col-lg-4 col-md-6">
                <div class="p-4 h-100" style="background: var(--bg-body); border-radius: var(--radius-lg); border: 1px solid var(--border-subtle);">
                    <div class="stat-icon-wrap stat-icon-amber mb-3">
                        <i class="bi bi-file-earmark-lock"></i>
                    </div>
                    <h5 class="fw-bold mb-2" style="color: var(--color-primary);">Radicación Digital</h5>
                    <p class="mb-0" style="color: var(--text-muted); font-size: 0.93rem;">
                        Presenta solicitudes cargando tus documentos en formato digital con cifrado y seguimiento en tiempo real.
                    </p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Testimonios -->
<section class="py-5">
    <div class="container py-4">
        <div class="text-center mb-5">
            <span class="text-uppercase fw-bold" style="color: var(--text-muted); font-size: 0.75rem; letter-spacing: 1.2px;">Experiencias Reales</span>
            <h2 class="fw-bold mb-3" style="color: var(--color-primary);">Lo que opinan nuestros clientes</h2>
        </div>

        <div class="row g-4">
            <div class="col-lg-4 col-md-6">
                <div class="p-4 h-100 d-flex flex-column" style="background: var(--bg-surface); border-radius: var(--radius-lg); border: 1px solid var(--border-subtle); box-shadow: var(--shadow-sm);">
                    <div class="mb-3" style="color: var(--color-gold);">
                        <i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i>
                    </div>
                    <p class="fst-italic flex-grow-1 mb-3" style="color: var(--text-muted);">
                        "El proceso de arrendar mi apartamento fue impecable. Pude radicar mis documentos en línea y en 48 horas ya tenía la aprobación."
                    </p>
                    <div class="d-flex align-items-center gap-3 pt-3" style="border-top: 1px solid var(--border-subtle);">
                        <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold" 
                             style="width: 44px; height: 44px; background: var(--color-accent-light); color: var(--color-accent); font-size: 1rem; border: 2px solid var(--border-subtle); flex-shrink: 0;">
                            JP
                        </div>
                        <div>
                            <h6 class="fw-bold mb-0" style="color: var(--color-primary);">Juan Pérez</h6>
                            <small style="color: var(--text-muted);">Comprador en Bucaramanga</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6">
                <div class="p-4 h-100 d-flex flex-column" style="background: var(--bg-surface); border-radius: var(--radius-lg); border: 1px solid var(--border-subtle); box-shadow: var(--shadow-sm);">
                    <div class="mb-3" style="color: var(--color-gold);">
                        <i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i>
                    </div>
                    <p class="fst-italic flex-grow-1 mb-3" style="color: var(--text-muted);">
                        "Excelente plataforma. La galería fotográfica es fiel a la realidad y el agente respondió todas nuestras inquietudes."
                    </p>
                    <div class="d-flex align-items-center gap-3 pt-3" style="border-top: 1px solid var(--border-subtle);">
                        <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold" 
                             style="width: 44px; height: 44px; background: var(--color-gold-light); color: var(--color-gold); font-size: 1rem; border: 2px solid var(--border-subtle); flex-shrink: 0;">
                            AL
                        </div>
                        <div>
                            <h6 class="fw-bold mb-0" style="color: var(--color-primary);">Ana López</h6>
                            <small style="color: var(--text-muted);">Inversionista en Floridablanca</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6">
                <div class="p-4 h-100 d-flex flex-column" style="background: var(--bg-surface); border-radius: var(--radius-lg); border: 1px solid var(--border-subtle); box-shadow: var(--shadow-sm);">
                    <div class="mb-3" style="color: var(--color-gold);">
                        <i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i><i class="bi bi-star-fill"></i>
                    </div>
                    <p class="fst-italic flex-grow-1 mb-3" style="color: var(--text-muted);">
                        "Como inmobiliaria aliada, la gestión de inmuebles y citas ha multiplicado la productividad de nuestro equipo."
                    </p>
                    <div class="d-flex align-items-center gap-3 pt-3" style="border-top: 1px solid var(--border-subtle);">
                        <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold" 
                             style="width: 44px; height: 44px; background: var(--status-info-bg); color: var(--status-info); font-size: 1rem; border: 2px solid var(--border-subtle); flex-shrink: 0;">
                            CR
                        </div>
                        <div>
                            <h6 class="fw-bold mb-0" style="color: var(--color-primary);">Carlos Ramírez</h6>
                            <small style="color: var(--text-muted);">Agente Inmobiliario</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
