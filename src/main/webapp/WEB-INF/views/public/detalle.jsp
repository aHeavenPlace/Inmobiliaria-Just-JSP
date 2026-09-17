<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="${propiedad.titulo} | Inmobiliaria Vesta"/>
</jsp:include>

<div class="container py-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb small">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home">Inicio</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/catalogo">Catálogo</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/catalogo?ciudad=${propiedad.idCiudad}">${propiedad.ciudadNombre}</a></li>
            <li class="breadcrumb-item active" aria-current="page">${propiedad.titulo}</li>
        </ol>
    </nav>

    <!-- Header de la Propiedad -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
            <div class="d-flex align-items-center gap-2 mb-2">
                <span class="badge bg-primary px-3 py-1 text-uppercase">${propiedad.tipoOperacion}</span>
                <span class="badge bg-info text-dark px-3 py-1">${propiedad.tipoNombre}</span>
                <span class="badge ${propiedad.estado == 'disponible' ? 'bg-success' : 'bg-secondary'} px-3 py-1 text-capitalize">
                    ${propiedad.estado}
                </span>
                <span class="text-muted small">Matrícula: <strong>${propiedad.matriculaInmobiliaria}</strong></span>
            </div>
            <h1 class="h2 fw-bold text-primary mb-1">${propiedad.titulo}</h1>
            <p class="text-muted mb-0">
                <i class="bi bi-geo-alt-fill text-danger me-1"></i> ${propiedad.direccion}, ${propiedad.ciudadNombre} (${propiedad.departamentoNombre})
            </p>
        </div>

        <div class="text-md-end">
            <div class="fs-2 fw-bold text-primary">${propiedad.precioFormateado}</div>
            <div class="d-flex gap-2 justify-content-md-end mt-2">
                <button class="btn btn-outline-danger btn-sm btn-favorite-heart ${propiedad.esFavorito ? 'is-favorite' : ''}"
                        data-id="${propiedad.idPropiedad}"
                        data-context="${pageContext.request.contextPath}"
                        style="position: static; width: auto; height: auto; padding: 6px 14px; border-radius: var(--radius-md);">
                    <i class="bi ${propiedad.esFavorito ? 'bi-heart-fill' : 'bi-heart'} me-1"></i>
                    <span>${propiedad.esFavorito ? 'En Favoritos' : 'Guardar'}</span>
                </button>
            </div>
        </div>
    </div>

    <!-- Galería de Imágenes -->
    <div class="row g-3 mb-4">
        <div class="col-lg-8">
            <div class="rounded-4 overflow-hidden shadow-sm" style="height: 460px; background-color: #E2E8F0;">
                <img id="mainPropertyImg" src="${propiedad.getImagenPrincipalUrl(pageContext.request.contextPath)}" alt="${propiedad.titulo}" 
                     class="w-100 h-100" style="object-fit: cover;">
            </div>
        </div>
        <div class="col-lg-4">
            <div class="d-flex flex-column gap-3 h-100 justify-content-between">
                <c:forEach var="img" items="${propiedad.imagenes}" varStatus="status">
                    <c:if test="${status.index < 3}">
                        <div class="rounded-3 overflow-hidden shadow-sm flex-grow-1" style="max-height: 140px; cursor: pointer;"
                             onclick="document.getElementById('mainPropertyImg').src='${img.getUrlCompleta(pageContext.request.contextPath)}';">
                            <img src="${img.getUrlCompleta(pageContext.request.contextPath)}" alt="${img.descripcion}" class="w-100 h-100" style="object-fit: cover;">
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Detalles y Características -->
        <div class="col-lg-8">
            <!-- Métricas Clave -->
            <div class="bg-white p-4 rounded-4 border border-light shadow-sm mb-4">
                <div class="row text-center g-3">
                    <div class="col-4 border-end">
                        <i class="bi bi-aspect-ratio text-primary fs-3"></i>
                        <div class="fw-bold fs-5 mt-1">${propiedad.areaM2} m²</div>
                        <small class="text-muted text-uppercase">Área Privada</small>
                    </div>
                    <div class="col-4 border-end">
                        <i class="bi bi-door-open text-primary fs-3"></i>
                        <div class="fw-bold fs-5 mt-1">${propiedad.habitaciones}</div>
                        <small class="text-muted text-uppercase">Habitaciones</small>
                    </div>
                    <div class="col-4">
                        <i class="bi bi-droplet text-primary fs-3"></i>
                        <div class="fw-bold fs-5 mt-1">${propiedad.banos}</div>
                        <small class="text-muted text-uppercase">Baños</small>
                    </div>
                </div>
            </div>

            <!-- Descripción -->
            <div class="bg-white p-4 rounded-4 border border-light shadow-sm mb-4">
                <h4 class="fw-bold text-primary mb-3">Descripción General</h4>
                <p class="text-muted leading-relaxed" style="white-space: pre-line;">${propiedad.descripcion}</p>
            </div>

            <!-- Características / Amenidades (Relación N:M) -->
            <div class="bg-white p-4 rounded-4 border border-light shadow-sm mb-4">
                <h4 class="fw-bold text-primary mb-3"><i class="bi bi-stars text-warning me-2"></i> Características & Amenidades</h4>
                <div class="row g-3">
                    <c:forEach var="carac" items="${propiedad.caracteristicas}">
                        <div class="col-md-6 col-lg-4">
                            <div class="d-flex align-items-center gap-2 p-2 rounded-3 bg-light">
                                <i class="bi bi-check-circle-fill text-success fs-5"></i>
                                <span class="fw-semibold small">${carac.nombre}</span>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty propiedad.caracteristicas}">
                        <p class="text-muted small">No se han especificado características adicionales.</p>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Sidebar de Contacto y Agendamiento -->
        <div class="col-lg-4">
            <div class="bg-white p-4 rounded-4 border border-light shadow-sm sticky-top" style="top: 100px;">
                <div class="text-center pb-3 border-bottom mb-3">
                    <h5 class="fw-bold text-primary mb-1">Inmobiliaria Anunciante</h5>
                    <div class="badge bg-light text-dark px-3 py-1 mb-2">
                        <i class="bi bi-building me-1"></i> ${propiedad.inmobiliariaNombre}
                    </div>
                    <p class="small text-muted mb-0"><i class="bi bi-telephone"></i> ${propiedad.inmobiliariaTelefono}</p>
                </div>

                <div class="d-grid gap-2 mb-3">
                    <button class="btn btn-vesta-accent py-3 fw-bold" data-bs-toggle="modal" data-bs-target="#modalAgendarCita">
                        <i class="bi bi-calendar-check me-2"></i> Agendar Visita
                    </button>
                    <button class="btn btn-vesta-primary py-3 fw-bold" data-bs-toggle="modal" data-bs-target="#modalRadicarSolicitud">
                        <i class="bi bi-file-earmark-arrow-up me-2"></i> Radicar Solicitud
                    </button>
                </div>

                <div class="alert alert-light border small text-muted mb-0">
                    <i class="bi bi-shield-lock-fill text-success me-1"></i> Transacción respaldada y verificada bajo los estándares de Inmobiliaria Vesta.
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Agendar Cita -->
<div class="modal fade" id="modalAgendarCita" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold text-primary"><i class="bi bi-calendar-event me-2"></i> Agendar Visita al Inmueble</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/cliente/agendar-cita" method="POST">
                <input type="hidden" name="idPropiedad" value="${propiedad.idPropiedad}">
                <div class="modal-body py-4">
                    <c:choose>
                        <c:when test="${empty sessionScope.usuarioLogueado}">
                            <div class="alert alert-warning">
                                <i class="bi bi-exclamation-triangle-fill me-1"></i> Debes <a href="${pageContext.request.contextPath}/login" class="fw-bold text-dark text-decoration-underline">iniciar sesión como Cliente</a> para agendar una visita.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="mb-3">
                                <label class="form-label-vesta">Fecha y Hora Preferida</label>
                                <input type="datetime-local" name="fechaHora" class="form-control form-control-vesta" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label-vesta">Notas / Preguntas para el Asesor</label>
                                <textarea name="notas" rows="3" class="form-control form-control-vesta" placeholder="Indica detalles adicionales de tu disponibilidad..."></textarea>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancelar</button>
                    <c:if test="${not empty sessionScope.usuarioLogueado}">
                        <button type="submit" class="btn btn-vesta-accent">Confirmar Agendamiento</button>
                    </c:if>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Informativo Radicar Solicitud -->
<div class="modal fade" id="modalRadicarSolicitud" tabindex="-1" aria-labelledby="modalRadicarSolicitudLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-4 border-0 shadow-lg">
            <div class="modal-header border-0 pb-0 pt-4 px-4">
                <div class="d-flex align-items-center gap-3">
                    <div class="stat-icon-wrap stat-icon-blue" style="width: 48px; height: 48px; font-size: 1.25rem;">
                        <i class="bi bi-file-earmark-text-fill"></i>
                    </div>
                    <div>
                        <h5 class="modal-title fw-bold text-primary mb-1" id="modalRadicarSolicitudLabel">Requisitos para Radicar Solicitud</h5>
                        <p class="text-muted small mb-0">Documentación exigida y canal oficial para presentar tu trámite</p>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            
            <div class="modal-body p-4">
                <!-- Tarjeta Destino y Matrícula -->
                <div class="p-3 mb-4 rounded-4" style="background: linear-gradient(135deg, rgba(13, 148, 136, 0.08) 0%, rgba(14, 116, 144, 0.08) 100%); border: 1px solid rgba(13, 148, 136, 0.2);">
                    <div class="row align-items-center g-3">
                        <div class="col-md-7">
                            <div class="d-flex align-items-center gap-2 mb-1">
                                <span class="badge bg-primary text-uppercase px-2 py-1">${propiedad.tipoOperacion}</span>
                                <span class="fw-semibold text-dark small text-truncate" title="${propiedad.titulo}">${propiedad.titulo}</span>
                            </div>
                            <div class="text-muted small">
                                <strong>Matrícula Inmobiliaria:</strong>
                                <span class="badge bg-white text-primary border px-2 py-1 fw-bold ms-1">${propiedad.matriculaInmobiliaria}</span>
                            </div>
                        </div>
                        <div class="col-md-5 text-md-end">
                            <small class="text-muted d-block mb-1">Dirección de correo para radicación:</small>
                            <a id="linkMailtoHeader" href="mailto:solicitudes@vesta.com.co?subject=Solicitud%20de%20${propiedad.tipoOperacion == 'arriendo' ? 'Arrendamiento' : 'Compra'}%20-%20Matr%C3%ADcula%3A%20${propiedad.matriculaInmobiliaria}" 
                               class="fw-bold text-vesta-accent text-decoration-none fs-6">
                                <i class="bi bi-envelope-fill me-1"></i> solicitudes@vesta.com.co
                            </a>
                        </div>
                    </div>

                    <!-- Recordatorio de Asunto Obligatorio -->
                    <div class="mt-3 pt-3 border-top border-secondary-subtle">
                        <div class="d-flex align-items-start gap-2">
                            <i class="bi bi-exclamation-triangle-fill text-warning fs-5 flex-shrink-0 mt-1"></i>
                            <div class="flex-grow-1">
                                <span class="fw-bold text-dark small d-block">Importante: No olvide indicar la matrícula en el asunto</span>
                                <span class="small text-muted">Para que la inmobiliaria identifique el inmueble de inmediato, el asunto debe estructurarse así:</span>
                                <div class="mt-2 p-2 bg-white rounded-3 border d-flex justify-content-between align-items-center gap-2">
                                    <code class="text-primary fw-semibold small" id="asuntoTexto">Solicitud de ${propiedad.tipoOperacion == 'arriendo' ? 'Arrendamiento' : 'Compra'} - Matrícula: ${propiedad.matriculaInmobiliaria}</code>
                                    <button type="button" class="btn btn-sm btn-outline-primary py-1 px-2" onclick="copiarAsunto()" title="Copiar asunto">
                                        <i class="bi bi-clipboard me-1"></i> <span id="btnCopiarTexto">Copiar Asunto</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Selector de Pestañas: Compra vs Arrendamiento -->
                <ul class="nav nav-pills nav-fill mb-3 p-1 bg-light rounded-3" id="solicitudTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link ${propiedad.tipoOperacion == 'arriendo' ? 'active' : ''} fw-semibold py-2" 
                                id="tab-arriendo" data-bs-toggle="pill" data-bs-target="#panel-arriendo" type="button" role="tab"
                                onclick="actualizarTipoSolicitud('Arrendamiento')">
                            <i class="bi bi-key-fill me-1"></i> Solicitud de Arrendamiento
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link ${propiedad.tipoOperacion != 'arriendo' ? 'active' : ''} fw-semibold py-2" 
                                id="tab-compra" data-bs-toggle="pill" data-bs-target="#panel-compra" type="button" role="tab"
                                onclick="actualizarTipoSolicitud('Compra')">
                            <i class="bi bi-cash-coin me-1"></i> Solicitud de Compra
                        </button>
                    </li>
                </ul>

                <div class="tab-content" id="solicitudTabsContent">
                    <!-- Panel Arrendamiento -->
                    <div class="tab-pane fade ${propiedad.tipoOperacion == 'arriendo' ? 'show active' : ''}" id="panel-arriendo" role="tabpanel">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="p-3 rounded-3 bg-light border h-100">
                                    <h6 class="fw-bold text-primary mb-2 small text-uppercase">
                                        <i class="bi bi-person-badge me-1"></i> Arrendatario Empleado
                                    </h6>
                                    <ul class="list-unstyled mb-0 small text-muted d-flex flex-column gap-2">
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Fotocopia de cédula de ciudadanía ampliada al 150%.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Certificación laboral reciente (no mayor a 30 días, con cargo, sueldo y antigüedad).</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Desprendibles de nómina de los últimos 3 meses.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Extractos bancarios de los últimos 3 meses.</span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-3 rounded-3 bg-light border h-100">
                                    <h6 class="fw-bold text-primary mb-2 small text-uppercase">
                                        <i class="bi bi-briefcase me-1"></i> Independiente / Codeudor
                                    </h6>
                                    <ul class="list-unstyled mb-0 small text-muted d-flex flex-column gap-2">
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>RUT actualizado y fotocopia de cédula (150%).</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Declaración de renta del último período gravable.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Extractos bancarios de los últimos 3 meses.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>En caso de requerir codeudor, anexar los mismos soportes.</span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Panel Compra -->
                    <div class="tab-pane fade ${propiedad.tipoOperacion != 'arriendo' ? 'show active' : ''}" id="panel-compra" role="tabpanel">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="p-3 rounded-3 bg-light border h-100">
                                    <h6 class="fw-bold text-primary mb-2 small text-uppercase">
                                        <i class="bi bi-bank me-1"></i> Compra con Crédito Hipotecario
                                    </h6>
                                    <ul class="list-unstyled mb-0 small text-muted d-flex flex-column gap-2">
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Fotocopia de cédula de ciudadanía ampliada al 150%.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Carta de preaprobación o aprobación de crédito hipotecario o leasing.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Certificación laboral o constancia de ingresos.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Carta formal con la propuesta de compra económica.</span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-3 rounded-3 bg-light border h-100">
                                    <h6 class="fw-bold text-primary mb-2 small text-uppercase">
                                        <i class="bi bi-cash-stack me-1"></i> Compra de Contado
                                    </h6>
                                    <ul class="list-unstyled mb-0 small text-muted d-flex flex-column gap-2">
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Fotocopia de cédula de ciudadanía ampliada al 150%.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Certificación bancaria de disponibilidad y procedencia de fondos.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Declaración de renta del último período gravable.</span>
                                        </li>
                                        <li class="d-flex align-items-start gap-2">
                                            <i class="bi bi-check2-circle text-success mt-1"></i>
                                            <span>Formato SARLAFT de conocimiento de cliente diligenciado.</span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="alert alert-info border-0 bg-opacity-10 d-flex align-items-center gap-2 mt-4 mb-0 small">
                    <i class="bi bi-info-circle-fill text-info fs-5 flex-shrink-0"></i>
                    <span>Envía los documentos adjuntos en formato <strong>PDF legible</strong> al correo <strong>solicitudes@vesta.com.co</strong>. Nuestro equipo inmobiliario validará la información y te contactará en un plazo de 24 a 48 horas hábiles.</span>
                </div>
            </div>
            
            <div class="modal-footer border-0 pt-0 px-4 pb-4 d-flex justify-content-between">
                <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">Entendido / Cerrar</button>
                <a id="btnMailto" 
                   href="mailto:solicitudes@vesta.com.co?subject=Solicitud%20de%20${propiedad.tipoOperacion == 'arriendo' ? 'Arrendamiento' : 'Compra'}%20-%20Matr%C3%ADcula%3A%20${propiedad.matriculaInmobiliaria}" 
                   class="btn btn-vesta-primary px-4">
                    <i class="bi bi-envelope-at me-2"></i> Abrir Correo para Enviar
                </a>
            </div>
        </div>
    </div>
</div>

<script>
function actualizarTipoSolicitud(tipo) {
    const matricula = '${propiedad.matriculaInmobiliaria}';
    const asunto = 'Solicitud de ' + tipo + ' - Matrícula: ' + matricula;
    const asuntoEl = document.getElementById('asuntoTexto');
    const mailtoBtn = document.getElementById('btnMailto');
    const mailtoHeader = document.getElementById('linkMailtoHeader');
    
    if (asuntoEl) asuntoEl.innerText = asunto;
    const mailtoHref = 'mailto:solicitudes@vesta.com.co?subject=' + encodeURIComponent(asunto);
    if (mailtoBtn) mailtoBtn.href = mailtoHref;
    if (mailtoHeader) mailtoHeader.href = mailtoHref;
}

function copiarAsunto() {
    const asuntoEl = document.getElementById('asuntoTexto');
    if (!asuntoEl) return;
    navigator.clipboard.writeText(asuntoEl.innerText).then(() => {
        const btn = document.getElementById('btnCopiarTexto');
        if (btn) {
            btn.innerText = '¡Copiado!';
            setTimeout(() => { btn.innerText = 'Copiar Asunto'; }, 2000);
        }
    });
}
</script>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
