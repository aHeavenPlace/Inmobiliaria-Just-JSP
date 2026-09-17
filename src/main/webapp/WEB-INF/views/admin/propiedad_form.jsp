<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Editar Inmueble | Administración Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <jsp:include page="/WEB-INF/views/components/sidebar_admin.jsp"/>

    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Editar Inmueble (Administrador)</h2>
                <p class="text-muted mb-0">Modifica detalles, cambia la inmobiliaria asociada y gestiona la galería fotográfica</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/propiedades" class="btn btn-vesta-outline">
                <i class="bi bi-arrow-left"></i> Volver a Inmuebles
            </a>
        </div>

        <c:if test="${param.msg == 'imagen_eliminada'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Foto eliminada correctamente de la propiedad.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-octagon-fill me-1"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="bg-white p-4 p-md-5 rounded-4 border border-light shadow-sm">
            <form action="${pageContext.request.contextPath}/admin/propiedad-editar" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="idPropiedad" value="${propiedad.idPropiedad}">

                <div class="row g-4">
                    <!-- Asignación Inmobiliaria & Estado -->
                    <div class="col-12">
                        <h5 class="fw-bold text-primary pb-2 border-bottom"><i class="bi bi-building me-2"></i> 1. Organización & Publicación</h5>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label-vesta">Inmobiliaria Propietaria *</label>
                        <select name="idInmobiliaria" class="form-select form-select-vesta" required>
                            <c:forEach var="inmob" items="${inmobiliarias}">
                                <option value="${inmob.idInmobiliaria}" ${propiedad.idInmobiliaria == inmob.idInmobiliaria ? 'selected' : ''}>
                                    ${inmob.nombre} (${inmob.nit})
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label-vesta">Estado del Inmueble *</label>
                        <select name="estado" class="form-select form-select-vesta" required>
                            <option value="disponible" ${propiedad.estado == 'disponible' ? 'selected' : ''}>Disponible</option>
                            <option value="vendido" ${propiedad.estado == 'vendido' ? 'selected' : ''}>Vendido</option>
                            <option value="arrendado" ${propiedad.estado == 'arrendado' ? 'selected' : ''}>Arrendado</option>
                            <option value="inactivo" ${propiedad.estado == 'inactivo' ? 'selected' : ''}>Inactivo</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label-vesta">Tipo de Operación *</label>
                        <select name="tipoOperacion" class="form-select form-select-vesta" required>
                            <option value="venta" ${propiedad.tipoOperacion == 'venta' ? 'selected' : ''}>Venta</option>
                            <option value="arriendo" ${propiedad.tipoOperacion == 'arriendo' ? 'selected' : ''}>Arriendo</option>
                        </select>
                    </div>

                    <!-- Información General -->
                    <div class="col-12 mt-4">
                        <h5 class="fw-bold text-primary pb-2 border-bottom"><i class="bi bi-info-circle me-2"></i> 2. Información Descriptiva</h5>
                    </div>

                    <div class="col-md-8">
                        <label class="form-label-vesta">Título del Inmueble *</label>
                        <input type="text" name="titulo" class="form-control form-control-vesta" value="${propiedad.titulo}" required>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label-vesta">Matrícula Inmobiliaria *</label>
                        <input type="text" name="matriculaInmobiliaria" class="form-control form-control-vesta" value="${propiedad.matriculaInmobiliaria}" required>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label-vesta">Tipo de Inmueble *</label>
                        <select name="idTipo" class="form-select form-select-vesta" required>
                            <c:forEach var="t" items="${tipos}">
                                <option value="${t.idTipo}" ${propiedad.idTipo == t.idTipo ? 'selected' : ''}>${t.nombre}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label-vesta">Precio ($ COP) *</label>
                        <input type="number" name="precio" class="form-control form-control-vesta" value="${propiedad.precio}" required step="100000">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label-vesta">Ciudad *</label>
                        <select name="idCiudad" class="form-select form-select-vesta" required>
                            <c:forEach var="c" items="${ciudades}">
                                <option value="${c.idCiudad}" ${propiedad.idCiudad == c.idCiudad ? 'selected' : ''}>
                                    ${c.nombre} (${c.departamento})
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label-vesta">Dirección Física *</label>
                        <input type="text" name="direccion" class="form-control form-control-vesta" value="${propiedad.direccion}" required>
                    </div>

                    <div class="col-md-2">
                        <label class="form-label-vesta">Área (m²)</label>
                        <input type="number" name="areaM2" class="form-control form-control-vesta" value="${propiedad.areaM2}" step="0.1">
                    </div>

                    <div class="col-md-2">
                        <label class="form-label-vesta">Habitaciones</label>
                        <input type="number" name="habitaciones" class="form-control form-control-vesta" value="${propiedad.habitaciones}" min="0">
                    </div>

                    <div class="col-md-2">
                        <label class="form-label-vesta">Baños</label>
                        <input type="number" name="banos" class="form-control form-control-vesta" value="${propiedad.banos}" min="0">
                    </div>

                    <div class="col-12">
                        <label class="form-label-vesta">Descripción Detallada</label>
                        <textarea name="descripcion" rows="4" class="form-control form-control-vesta">${propiedad.descripcion}</textarea>
                    </div>

                    <!-- Características N:M -->
                    <div class="col-12 mt-4">
                        <h5 class="fw-bold text-primary pb-2 border-bottom"><i class="bi bi-check2-square me-2"></i> 3. Amenidades y Características (N:M)</h5>
                        <div class="row g-3 mt-1">
                            <c:forEach var="carac" items="${caracteristicas}">
                                <c:set var="tieneCarac" value="false"/>
                                <c:forEach var="pc" items="${propiedad.caracteristicas}">
                                    <c:if test="${pc.idCaracteristica == carac.idCaracteristica}">
                                        <c:set var="tieneCarac" value="true"/>
                                    </c:if>
                                </c:forEach>
                                <div class="col-md-4 col-lg-3">
                                    <div class="form-check p-2 rounded-3 bg-light">
                                        <input class="form-check-input ms-1" type="checkbox" name="caracteristicas" 
                                               value="${carac.idCaracteristica}" id="carac_${carac.idCaracteristica}"
                                               ${tieneCarac ? 'checked' : ''}>
                                        <label class="form-check-label fw-semibold small ms-2" for="carac_${carac.idCaracteristica}">
                                            ${carac.nombre}
                                        </label>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Galería de Fotos -->
                    <div class="col-12 mt-4">
                        <h5 class="fw-bold text-primary pb-2 border-bottom"><i class="bi bi-images me-2"></i> 4. Galería de Imágenes</h5>
                        
                        <c:if test="${not empty propiedad.imagenes}">
                            <div class="mb-4">
                                <label class="form-label-vesta d-block mb-2">Fotos actuales del inmueble (${propiedad.imagenes.size()})</label>
                                <div class="row g-3">
                                    <c:forEach var="img" items="${propiedad.imagenes}" varStatus="st">
                                        <div class="col-6 col-md-4 col-lg-3">
                                            <div class="card border rounded-3 overflow-hidden shadow-xs h-100 position-relative">
                                                <img src="${img.getUrlCompleta(pageContext.request.contextPath)}" 
                                                     alt="${img.descripcion}" class="card-img-top" style="height: 120px; object-fit: cover;">
                                                <div class="p-2 d-flex justify-content-between align-items-center bg-light">
                                                    <span class="badge ${st.first ? 'bg-primary' : 'bg-secondary'} small">
                                                        ${st.first ? 'Principal' : 'Foto '.concat(st.index + 1)}
                                                    </span>
                                                    <button type="submit" 
                                                            formaction="${pageContext.request.contextPath}/admin/propiedad-eliminar-imagen" 
                                                            formmethod="POST"
                                                            onclick="return confirm('¿Eliminar esta foto del inmueble?');"
                                                            name="idImagen" value="${img.idImagen}"
                                                            class="btn btn-sm btn-outline-danger py-0 px-2" title="Eliminar foto">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <div class="mb-3">
                            <label class="form-label-vesta">Subir nuevas imágenes</label>
                            <input type="file" name="imagenesFiles" class="form-control form-control-vesta" 
                                   accept="image/jpeg,image/png,image/gif,image/webp" multiple onchange="previewImages(this)">
                            <small class="text-muted">Formatos permitidos: JPG, PNG, GIF, WEBP. Máximo 10MB por archivo.</small>
                            <div id="imagePreview" class="row g-2 mt-2"></div>
                        </div>
                        
                        <div class="mt-3">
                            <label class="form-label-vesta">O agregar URLs de imágenes adicionales (una por línea)</label>
                            <textarea name="imagenesUrls" rows="3" class="form-control form-control-vesta" 
                                      placeholder="https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800"></textarea>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-3 mt-5 pt-3 border-top">
                    <a href="${pageContext.request.contextPath}/admin/propiedades" class="btn btn-light">Cancelar</a>
                    <button type="submit" class="btn btn-vesta-accent px-4 py-2">
                        <i class="bi bi-check2-circle me-1"></i> Guardar Cambios (Administrador)
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function previewImages(input) {
    const preview = document.getElementById('imagePreview');
    preview.innerHTML = '';
    
    if (input.files) {
        Array.from(input.files).forEach((file, index) => {
            if (!file.type.startsWith('image/')) return;
            
            const reader = new FileReader();
            reader.onload = function(e) {
                const col = document.createElement('div');
                col.className = 'col-3';
                col.innerHTML = `
                    <div class="position-relative">
                        <img src="${e.target.result}" class="img-fluid rounded border" style="height: 80px; width: 100%; object-fit: cover;">
                        <span class="badge bg-primary position-absolute top-0 start-0">Nueva</span>
                    </div>
                `;
                preview.appendChild(col);
            };
            reader.readAsDataURL(file);
        });
    }
}
</script>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
