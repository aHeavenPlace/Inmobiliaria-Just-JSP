<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/components/header.jsp">
    <jsp:param name="pageTitle" value="Usuarios & Roles | Inmobiliaria Vesta"/>
</jsp:include>

<div class="dashboard-wrapper">
    <jsp:include page="/WEB-INF/views/components/sidebar_admin.jsp"/>

    <div class="dashboard-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-primary mb-1">Gestión de Usuarios & Roles</h2>
                <p class="text-muted mb-0">Control de acceso, estados de cuenta y asignación multirrol (N:M) de la plataforma</p>
            </div>
            <span class="badge bg-primary px-3 py-2 fs-6">
                <i class="bi bi-people-fill me-1"></i> ${usuarios.size()} Usuarios registrados
            </span>
        </div>

        <c:if test="${param.msg == 'estado_actualizado'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Estado de la cuenta actualizado exitosamente.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${param.msg == 'roles_actualizados' || param.msg == 'rol_actualizado'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-shield-check me-2"></i> Roles actualizados correctamente en el sistema.
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-octagon-fill me-2"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="bg-white rounded-4 border border-light shadow-sm overflow-hidden">
            <div class="p-3 border-bottom bg-light d-flex gap-2 align-items-center flex-wrap">
                <i class="bi bi-funnel text-muted"></i>
                <span class="small fw-bold text-muted">Filtrar por rol:</span>
                <a href="${pageContext.request.contextPath}/admin/usuarios" 
                   class="badge ${empty param.rol ? 'bg-primary' : 'bg-light text-dark border'} px-3 py-2 text-decoration-none">
                   Todos (${usuarios.size()})
                </a>
                <c:forEach var="r" items="${roles}">
                    <a href="${pageContext.request.contextPath}/admin/usuarios?rol=${r.nombre}" 
                       class="badge ${param.rol == r.nombre ? 'bg-primary' : 'bg-light text-dark border'} px-3 py-2 text-decoration-none">
                        ${r.nombre}
                    </a>
                </c:forEach>
            </div>

            <div class="table-responsive">
                <table class="table-vesta">
                    <thead>
                        <tr>
                            <th>Usuario</th>
                            <th>Correo Electrónico</th>
                            <th>Roles Asignados (N:M)</th>
                            <th>Estado</th>
                            <th class="text-end">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${usuarios}">
                            <c:if test="${empty param.rol || u.hasRole(param.rol)}">
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <c:choose>
                                                <c:when test="${not empty u.perfil and not empty u.perfil.fotoUrl}">
                                                    <img src="${u.perfil.fotoUrl.startsWith('http') ? u.perfil.fotoUrl : pageContext.request.contextPath.concat('/uploads/perfiles/').concat(u.perfil.fotoUrl)}" 
                                                         class="rounded-circle border" width="38" height="38" style="object-fit: cover;" alt="Foto de perfil">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center fw-bold shadow-xs" 
                                                         style="width: 38px; height: 38px; font-size: 14px; background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-light) 100%);">
                                                        <c:choose>
                                                            <c:when test="${not empty u.perfil and not empty u.perfil.nombres}">
                                                                ${fn:substring(u.perfil.nombres, 0, 1)}${fn:substring(u.perfil.apellidos, 0, 1)}
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${fn:substring(u.correo, 0, 1).toUpperCase()}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <strong class="text-dark d-block">
                                                    <c:choose>
                                                        <c:when test="${not empty u.perfil and not empty u.perfil.nombres}">
                                                            ${u.perfil.nombres} ${u.perfil.apellidos}
                                                        </c:when>
                                                        <c:otherwise>
                                                            Usuario sin perfil
                                                        </c:otherwise>
                                                    </c:choose>
                                                </strong>
                                                <small class="text-muted">ID: #${u.idUsuario}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="text-secondary">${u.correo}</span>
                                        <c:if test="${u.correo == sessionScope.correoUsuario}">
                                            <span class="badge bg-light text-primary border ms-1">Tú</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div class="d-flex flex-wrap gap-1 align-items-center">
                                            <c:forEach var="r" items="${u.roles}">
                                                <span class="badge ${r.nombre == 'admin' ? 'bg-danger' : r.nombre == 'inmobiliaria' ? 'bg-info text-dark' : 'bg-success'} px-2 py-1">
                                                    <i class="bi ${r.nombre == 'admin' ? 'bi-shield-fill' : r.nombre == 'inmobiliaria' ? 'bi-building' : 'bi-person'} me-1"></i>
                                                    ${r.nombre}
                                                </span>
                                            </c:forEach>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge-vesta ${u.activo ? 'badge-vesta-success' : 'badge-vesta-danger'}">
                                            <i class="bi ${u.activo ? 'bi-check-circle-fill' : 'bi-x-circle-fill'} me-1"></i>
                                            ${u.activo ? 'Activo' : 'Inactivo'}
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <div class="d-inline-flex gap-2">
                                            <!-- Botón Modal Editar Roles -->
                                            <button type="button" class="btn btn-sm btn-outline-primary" 
                                                    data-bs-toggle="modal" data-bs-target="#modalRoles_${u.idUsuario}" 
                                                    title="Modificar roles del usuario">
                                                <i class="bi bi-shield-lock me-1"></i> Roles
                                            </button>

                                            <!-- Formulario Activar / Desactivar Usuario -->
                                            <c:if test="${u.correo != sessionScope.correoUsuario}">
                                                <form action="${pageContext.request.contextPath}/admin/usuario-estado" method="POST" 
                                                      style="display:inline;">
                                                    <input type="hidden" name="idUsuario" value="${u.idUsuario}">
                                                    <input type="hidden" name="nuevoEstado" value="${u.activo ? 'inactivo' : 'activo'}">
                                                    <button type="submit" 
                                                            class="btn btn-sm ${u.activo ? 'btn-outline-danger' : 'btn-outline-success'}" 
                                                            title="${u.activo ? 'Desactivar cuenta' : 'Activar cuenta'}"
                                                            onclick="return confirm(this.closest('form').querySelector('[name=nuevoEstado]').value === 'inactivo' ? '\u00bfEst\u00e1s seguro de desactivar esta cuenta? El usuario perder\u00e1 acceso al sistema.' : '\u00bfReactivar esta cuenta de usuario?');">
                                                        <i class="bi ${u.activo ? 'bi-person-slash' : 'bi-person-check'}"></i>
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>

                                        <!-- MODAL EDITAR ROLES -->
                                        <div class="modal fade text-start" id="modalRoles_${u.idUsuario}" tabindex="-1" aria-hidden="true">
                                            <div class="modal-dialog modal-dialog-centered">
                                                <div class="modal-content rounded-4 border-0 shadow">
                                                    <form action="${pageContext.request.contextPath}/admin/usuario-roles-sincronizar" method="POST">
                                                        <input type="hidden" name="idUsuario" value="${u.idUsuario}">
                                                        <div class="modal-header border-bottom px-4 pt-4 pb-3">
                                                            <div>
                                                                <h5 class="modal-title fw-bold text-primary">Gestionar Roles de Usuario</h5>
                                                                <small class="text-muted">${u.correo}</small>
                                                            </div>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body px-4 py-4">
                                                            <p class="small text-muted mb-3">
                                                                Selecciona los roles que tendrá este usuario en la plataforma. Recuerda que un usuario debe tener al menos un rol asignado:
                                                            </p>
                                                            <div class="d-flex flex-column gap-3">
                                                                <c:forEach var="rol" items="${roles}">
                                                                    <c:set var="tieneEsteRol" value="${u.hasRole(rol.nombre)}" />
                                                                    <label class="d-flex align-items-center justify-content-between p-3 rounded-3 border ${tieneEsteRol ? 'bg-light border-primary' : ''}" style="cursor: pointer;">
                                                                        <div class="d-flex align-items-center gap-3">
                                                                            <input class="form-check-input mt-0" type="checkbox" name="roles" value="${rol.idRol}" 
                                                                                   id="rol_${u.idUsuario}_${rol.idRol}" ${tieneEsteRol ? 'checked' : ''}>
                                                                            <div>
                                                                                <strong class="d-block text-dark text-capitalize">${rol.nombre}</strong>
                                                                                <small class="text-muted">${rol.descripcion}</small>
                                                                            </div>
                                                                        </div>
                                                                        <span class="badge ${rol.nombre == 'admin' ? 'bg-danger' : rol.nombre == 'inmobiliaria' ? 'bg-info text-dark' : 'bg-success'}">
                                                                            ${rol.nombre}
                                                                        </span>
                                                                    </label>
                                                                </c:forEach>
                                                            </div>
                                                            <c:if test="${u.correo == sessionScope.correoUsuario}">
                                                                <div class="alert alert-warning small mt-3 mb-0">
                                                                    <i class="bi bi-exclamation-triangle-fill me-1"></i> Esta es tu propia cuenta. No puedes eliminar tu rol de Administrador.
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                        <div class="modal-footer border-top px-4 py-3 bg-light rounded-bottom-4">
                                                            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancelar</button>
                                                            <button type="submit" class="btn btn-vesta-accent px-4">
                                                                <i class="bi bi-check2 me-1"></i> Guardar Roles
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </c:forEach>
                        <c:if test="${empty usuarios}">
                            <tr>
                                <td colspan="5" class="text-center py-5 text-muted">No se encontraron usuarios registrados.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/components/footer.jsp"/>
