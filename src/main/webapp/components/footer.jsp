<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!-- ========== FOOTER ========== -->
<footer class="footer-vesta">
    <div class="container">
        <div class="row g-4 pb-4">
            <div class="col-md-4">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <span style="background:linear-gradient(135deg,#C4796B,#B8956B);color:#fff;padding:4px 12px;border-radius:999px;font-size:0.72rem;font-weight:700;text-transform:uppercase;letter-spacing:1px;">VESTA</span>
                    <span style="color:#fff;font-weight:700;font-size:1.1rem;">Inmobiliaria</span>
                </div>
                <p style="font-size:0.9rem;line-height:1.7;">Conectamos personas con el hogar de sus sueños en Bucaramanga y el Área Metropolitana.</p>
            </div>
            <div class="col-md-2">
                <h5>Explorar</h5>
                <ul style="list-style:none;padding:0;display:flex;flex-direction:column;gap:8px;font-size:0.9rem;">
                    <li><a href="${pageContext.request.contextPath}/index.jsp">Inicio</a></li>
                    <li><a href="${pageContext.request.contextPath}/catalogo.jsp">Catálogo</a></li>
                    <li><a href="${pageContext.request.contextPath}/registro.jsp">Registrarse</a></li>
                </ul>
            </div>
            <div class="col-md-3">
                <h5>Operaciones</h5>
                <ul style="list-style:none;padding:0;display:flex;flex-direction:column;gap:8px;font-size:0.9rem;">
                    <li><a href="${pageContext.request.contextPath}/catalogo.jsp?operacion=Venta">Propiedades en Venta</a></li>
                    <li><a href="${pageContext.request.contextPath}/catalogo.jsp?operacion=Arriendo">Propiedades en Arriendo</a></li>
                </ul>
            </div>
            <div class="col-md-3">
                <h5>Contacto</h5>
                <ul style="list-style:none;padding:0;display:flex;flex-direction:column;gap:8px;font-size:0.9rem;">
                    <li><i class="bi bi-geo-alt me-2"></i>Bucaramanga, Santander</li>
                    <li><i class="bi bi-telephone me-2"></i>(607) 123-4567</li>
                    <li><i class="bi bi-envelope me-2"></i>contacto@vesta.com</li>
                </ul>
            </div>
        </div>
        <hr style="border-color:rgba(255,255,255,0.1);margin:0 0 20px 0;">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3" style="font-size:0.85rem;">
            <span>&copy; 2024 Vesta Inmobiliaria SAS. Todos los derechos reservados.</span>
            <span>Construido con JSP puro + Tomcat 8.5</span>
        </div>
    </div>
</footer>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
/* ================================================================
   VESTA — JavaScript embebido (reemplaza main.js)
   Compatible con Tomcat 8.5 / JSP 2.3
   ================================================================ */

document.addEventListener('DOMContentLoaded', function() {
    initFavoritosToggle();
    initAlertDismissal();
    initConfirmaciones();
});

/* --------- Toggle de Favoritos (envío por form POST) --------- */
function initFavoritosToggle() {
    document.querySelectorAll('.btn-favorite-heart').forEach(function(btn) {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();

            var idPropiedad = btn.getAttribute('data-id');
            var ctx = btn.getAttribute('data-context') || '';

            // Crear y enviar un form POST hacia favorito_toggle.jsp
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = ctx + '/cliente/favorito_toggle.jsp';

            var input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'idPropiedad';
            input.value = idPropiedad;

            var redirect = document.createElement('input');
            redirect.type = 'hidden';
            redirect.name = 'redirect';
            redirect.value = window.location.href;

            form.appendChild(input);
            form.appendChild(redirect);
            document.body.appendChild(form);
            form.submit();
        });
    });
}

/* --------- Auto-dismiss de alertas --------- */
function initAlertDismissal() {
    var alertas = document.querySelectorAll('.alert-dismissible');
    alertas.forEach(function(al) {
        setTimeout(function() {
            al.style.transition = 'opacity 400ms ease';
            al.style.opacity = '0';
            setTimeout(function() { al.remove(); }, 420);
        }, 5000);
    });
}

/* --------- Confirmaciones antes de eliminar --------- */
function initConfirmaciones() {
    document.querySelectorAll('[data-confirm]').forEach(function(el) {
        el.addEventListener('click', function(e) {
            var msg = el.getAttribute('data-confirm') || '¿Está seguro de realizar esta acción?';
            if (!confirm(msg)) {
                e.preventDefault();
                e.stopPropagation();
            }
        });
    });
}

/* --------- Toast flotante --------- */
function mostrarToast(mensaje, tipo) {
    tipo = tipo || 'info';
    var container = document.getElementById('vesta-toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'vesta-toast-container';
        container.style.cssText = 'position:fixed;bottom:24px;right:24px;z-index:9999;display:flex;flex-direction:column;gap:10px;';
        document.body.appendChild(container);
    }

    var toast = document.createElement('div');
    var colorBg = tipo === 'success' ? '#5B8C6D'
                : tipo === 'error'   ? '#C4796B'
                : tipo === 'warning' ? '#C9A962' : '#6B8C9E';

    toast.style.cssText = 'background-color:' + colorBg + ';color:#FFFFFF;padding:12px 20px;border-radius:12px;font-weight:600;font-size:0.9rem;box-shadow:0 10px 25px -5px rgba(0,0,0,0.2);display:flex;align-items:center;gap:10px;opacity:0;transform:translateY(10px);transition:all 250ms ease;max-width:320px;';

    var iconClass = tipo === 'success' ? 'bi-check-circle-fill' : tipo === 'error' ? 'bi-x-circle-fill' : 'bi-info-circle-fill';
    toast.innerHTML = '<i class="bi ' + iconClass + '"></i><span>' + mensaje + '</span>';
    container.appendChild(toast);

    requestAnimationFrame(function() {
        toast.style.opacity = '1';
        toast.style.transform = 'translateY(0)';
    });

    setTimeout(function() {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(10px)';
        setTimeout(function() { if (toast.parentNode) toast.remove(); }, 300);
    }, 4000);
}
</script>

</body>
</html>
