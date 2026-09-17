<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ include file="/components/header.jsp" %>
<div style="min-height:60vh;display:flex;align-items:center;justify-content:center;text-align:center;padding:40px;">
    <div>
        <div style="font-size:6rem;font-weight:800;color:var(--status-danger);line-height:1;">500</div>
        <h2 class="fw-bold mt-2">Error interno del servidor</h2>
        <p class="text-muted mb-4">Ocurrió un error inesperado. Por favor intenta de nuevo más tarde.</p>
        <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-vesta-primary">
            <i class="bi bi-house me-1"></i> Volver al inicio
        </a>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
