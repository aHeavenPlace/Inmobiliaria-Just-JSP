<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/components/header.jsp" %>
<div style="min-height:60vh;display:flex;align-items:center;justify-content:center;text-align:center;padding:40px;">
    <div>
        <div style="font-size:6rem;font-weight:800;color:var(--color-accent);line-height:1;">404</div>
        <h2 class="fw-bold mt-2">Página no encontrada</h2>
        <p class="text-muted mb-4">La página que buscas no existe o fue movida.</p>
        <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-vesta-accent">
            <i class="bi bi-house me-1"></i> Volver al inicio
        </a>
    </div>
</div>
<%@ include file="/components/footer.jsp" %>
