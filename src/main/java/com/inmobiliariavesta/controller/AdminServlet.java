package com.inmobiliariavesta.controller;

import com.inmobiliariavesta.dao.AuditoriaDAO;
import com.inmobiliariavesta.dao.CaracteristicaDAO;
import com.inmobiliariavesta.dao.CiudadDAO;
import com.inmobiliariavesta.dao.InmobiliariaDAO;
import com.inmobiliariavesta.dao.PropiedadDAO;
import com.inmobiliariavesta.dao.ReportesDAO;
import com.inmobiliariavesta.dao.RolDAO;
import com.inmobiliariavesta.dao.TipoPropiedadDAO;
import com.inmobiliariavesta.dao.UsuarioDAO;
import com.inmobiliariavesta.model.Caracteristica;
import com.inmobiliariavesta.model.Ciudad;
import com.inmobiliariavesta.model.Propiedad;
import com.inmobiliariavesta.model.TipoPropiedad;
import com.inmobiliariavesta.model.Usuario;
import com.inmobiliariavesta.util.FileUploadUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminServlet", urlPatterns = {
    "/admin/dashboard",
    "/admin/usuarios",
    "/admin/usuario-estado",
    "/admin/usuario-rol",
    "/admin/usuario-roles-sincronizar",
    "/admin/propiedades",
    "/admin/propiedad-editar",
    "/admin/propiedad-eliminar",
    "/admin/propiedad-eliminar-imagen",
    "/admin/catalogos",
    "/admin/catalogo-ciudad",
    "/admin/catalogo-tipo",
    "/admin/catalogo-caracteristica"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 10 * 1024 * 1024,  // 10 MB
    maxRequestSize = 50 * 1024 * 1024 // 50 MB
)
public class AdminServlet extends HttpServlet {

    private UsuarioDAO usuarioDAO = new UsuarioDAO();
    private RolDAO rolDAO = new RolDAO();
    private CiudadDAO ciudadDAO = new CiudadDAO();
    private TipoPropiedadDAO tipoDAO = new TipoPropiedadDAO();
    private CaracteristicaDAO caracteristicaDAO = new CaracteristicaDAO();
    private InmobiliariaDAO inmobiliariaDAO = new InmobiliariaDAO();
    private AuditoriaDAO auditoriaDAO = new AuditoriaDAO();
    private ReportesDAO reportesDAO = new ReportesDAO();
    private PropiedadDAO propiedadDAO = new PropiedadDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String path = request.getServletPath();

        switch (path) {
            case "/admin/dashboard":
                Map<String, Object> metricas = reportesDAO.obtenerMetricasDashboard(null, null);
                request.setAttribute("metricas", metricas);
                List<Propiedad> todasPropiedades = propiedadDAO.listarTodasAdmin();
                request.setAttribute("propiedadesRecientes", todasPropiedades.size() > 5 ? todasPropiedades.subList(0, 5) : todasPropiedades);
                request.setAttribute("statsCiudades", reportesDAO.obtenerEstadisticasCiudades(1));
                request.setAttribute("statsTipos", reportesDAO.obtenerEstadisticasTiposPropiedad(1));
                request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
                break;

            case "/admin/usuarios":
                request.setAttribute("usuarios", usuarioDAO.listarTodos());
                request.setAttribute("roles", rolDAO.listarTodos());
                request.getRequestDispatcher("/WEB-INF/views/admin/usuarios.jsp").forward(request, response);
                break;

            case "/admin/propiedades":
                request.setAttribute("propiedades", propiedadDAO.listarTodasAdmin());
                request.setAttribute("inmobiliarias", inmobiliariaDAO.listarTodas());
                request.getRequestDispatcher("/WEB-INF/views/admin/propiedades.jsp").forward(request, response);
                break;

            case "/admin/propiedad-editar":
                cargarFormularioEditarPropiedad(request, response);
                break;

            case "/admin/catalogos":
                request.setAttribute("ciudades", ciudadDAO.listarTodas());
                request.setAttribute("tipos", tipoDAO.listarTodos());
                request.setAttribute("caracteristicas", caracteristicaDAO.listarTodas());
                request.setAttribute("inmobiliarias", inmobiliariaDAO.listarTodas());
                request.getRequestDispatcher("/WEB-INF/views/admin/catalogos.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String path = request.getServletPath();

        switch (path) {
            case "/admin/usuario-estado":
                procesarEstadoUsuario(request, response);
                break;

            case "/admin/usuario-rol":
                procesarRolUsuario(request, response);
                break;

            case "/admin/usuario-roles-sincronizar":
                procesarSincronizarRoles(request, response);
                break;

            case "/admin/propiedad-editar":
                procesarActualizarPropiedadAdmin(request, response);
                break;

            case "/admin/propiedad-eliminar":
                procesarEliminarPropiedadAdmin(request, response);
                break;

            case "/admin/propiedad-eliminar-imagen":
                procesarEliminarImagenAdmin(request, response);
                break;

            case "/admin/catalogo-ciudad":
                Ciudad c = new Ciudad();
                c.setNombre(request.getParameter("nombre"));
                c.setDepartamento(request.getParameter("departamento"));
                c.setCodigoPostal(request.getParameter("codigoPostal"));
                ciudadDAO.insertar(c);
                response.sendRedirect(request.getContextPath() + "/admin/catalogos?msg=ciudad_creada");
                break;

            case "/admin/catalogo-tipo":
                TipoPropiedad tp = new TipoPropiedad();
                tp.setNombre(request.getParameter("nombre"));
                tp.setDescripcion(request.getParameter("descripcion"));
                tipoDAO.insertar(tp);
                response.sendRedirect(request.getContextPath() + "/admin/catalogos?msg=tipo_creado");
                break;

            case "/admin/catalogo-caracteristica":
                Caracteristica carac = new Caracteristica();
                carac.setNombre(request.getParameter("nombre"));
                carac.setDescripcion(request.getParameter("descripcion"));
                caracteristicaDAO.insertar(carac);
                response.sendRedirect(request.getContextPath() + "/admin/catalogos?msg=caracteristica_creada");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                break;
        }
    }

    private void cargarFormularioEditarPropiedad(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/admin/propiedades");
            return;
        }
        try {
            int idPropiedad = Integer.parseInt(idStr);
            Propiedad p = propiedadDAO.obtenerPorIdConDetalle(idPropiedad);
            if (p == null) {
                response.sendRedirect(request.getContextPath() + "/admin/propiedades?error=Propiedad no encontrada");
                return;
            }
            request.setAttribute("propiedad", p);
            request.setAttribute("ciudades", ciudadDAO.listarTodas());
            request.setAttribute("tipos", tipoDAO.listarTodos());
            request.setAttribute("caracteristicas", caracteristicaDAO.listarTodas());
            request.setAttribute("inmobiliarias", inmobiliariaDAO.listarTodas());
            request.getRequestDispatcher("/WEB-INF/views/admin/propiedad_form.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/propiedades?error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void procesarActualizarPropiedadAdmin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        Usuario admin = (Usuario) request.getSession().getAttribute("usuarioLogueado");
        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            Propiedad p = new Propiedad();
            p.setIdPropiedad(idPropiedad);
            p.setIdInmobiliaria(Integer.parseInt(request.getParameter("idInmobiliaria")));
            p.setIdCiudad(Integer.parseInt(request.getParameter("idCiudad")));
            p.setIdTipo(Integer.parseInt(request.getParameter("idTipo")));
            p.setMatriculaInmobiliaria(request.getParameter("matriculaInmobiliaria"));
            p.setTitulo(request.getParameter("titulo"));
            p.setDescripcion(request.getParameter("descripcion"));
            p.setDireccion(request.getParameter("direccion"));
            p.setPrecio(new BigDecimal(request.getParameter("precio")));
            String areaStr = request.getParameter("areaM2");
            if (areaStr != null && !areaStr.isBlank()) p.setAreaM2(new BigDecimal(areaStr));
            p.setHabitaciones(Integer.parseInt(request.getParameter("habitaciones")));
            p.setBanos(Integer.parseInt(request.getParameter("banos")));
            p.setTipoOperacion(request.getParameter("tipoOperacion"));
            p.setEstado(request.getParameter("estado"));

            String[] caracs = request.getParameterValues("caracteristicas");
            List<Integer> idCaracs = new ArrayList<>();
            if (caracs != null) {
                for (String c : caracs) idCaracs.add(Integer.parseInt(c));
            }

            // Manejar nuevas fotos subidas
            List<String> nuevasUrls = new ArrayList<>();
            try {
                Collection<Part> allParts = request.getParts();
                String uploadPath = getServletContext().getRealPath("/uploads/propiedades");
                for (Part part : allParts) {
                    if ("imagenesFiles".equals(part.getName()) && part.getSize() > 0) {
                        String fileName = FileUploadUtil.saveImageDual(part, "propiedades", uploadPath);
                        if (fileName != null) {
                            nuevasUrls.add("/uploads/propiedades/" + fileName);
                        }
                    }
                }
            } catch (Exception ignored) {}

            String urlsStr = request.getParameter("imagenesUrls");
            if (urlsStr != null && !urlsStr.isBlank()) {
                String[] lines = urlsStr.split("[\\r\\n,]+");
                for (String u : lines) {
                    if (!u.trim().isBlank()) nuevasUrls.add(u.trim());
                }
            }

            if (!nuevasUrls.isEmpty()) {
                propiedadDAO.agregarImagenes(idPropiedad, nuevasUrls);
            }

            propiedadDAO.actualizar(p, idCaracs);
            auditoriaDAO.registrar(admin != null ? admin.getIdUsuario() : null, "ADMIN_UPDATE", "propiedad", idPropiedad, request.getRemoteAddr());

            response.sendRedirect(request.getContextPath() + "/admin/propiedades?msg=propiedad_actualizada");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/propiedades?error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void procesarEliminarPropiedadAdmin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        Usuario admin = (Usuario) request.getSession().getAttribute("usuarioLogueado");
        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            propiedadDAO.eliminar(idPropiedad);
            auditoriaDAO.registrar(admin != null ? admin.getIdUsuario() : null, "ADMIN_DELETE", "propiedad", idPropiedad, request.getRemoteAddr());
            response.sendRedirect(request.getContextPath() + "/admin/propiedades?msg=propiedad_eliminada");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/propiedades?error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void procesarEliminarImagenAdmin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        Usuario admin = (Usuario) request.getSession().getAttribute("usuarioLogueado");
        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            int idImagen = Integer.parseInt(request.getParameter("idImagen"));
            String url = propiedadDAO.eliminarImagen(idImagen);
            if (url != null && url.startsWith("/uploads/propiedades/")) {
                String fileName = url.substring("/uploads/propiedades/".length());
                String uploadPath = getServletContext().getRealPath("/uploads/propiedades");
                FileUploadUtil.deleteImage("propiedades", fileName, uploadPath);
            }
            auditoriaDAO.registrar(admin != null ? admin.getIdUsuario() : null, "ADMIN_DELETE", "imagen_propiedad", idImagen, request.getRemoteAddr());
            response.sendRedirect(request.getContextPath() + "/admin/propiedad-editar?id=" + idPropiedad + "&msg=imagen_eliminada");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/propiedades?error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void procesarEstadoUsuario(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        Usuario admin = (Usuario) request.getSession().getAttribute("usuarioLogueado");
        try {
            int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
            String nuevoEstado = request.getParameter("nuevoEstado");
            if (nuevoEstado == null || nuevoEstado.isBlank()) {
                nuevoEstado = "inactivo";
            }
            
            // Protección: no auto-desactivarse
            if (admin != null && admin.getIdUsuario() == idUsuario && "inactivo".equalsIgnoreCase(nuevoEstado)) {
                response.sendRedirect(request.getContextPath() + "/admin/usuarios?error=" + URLEncoder.encode("No puedes desactivar tu propia cuenta de administrador", StandardCharsets.UTF_8));
                return;
            }

            usuarioDAO.actualizarEstado(idUsuario, nuevoEstado);
            auditoriaDAO.registrar(admin != null ? admin.getIdUsuario() : null, "UPDATE_ESTADO", "usuario", idUsuario, request.getRemoteAddr());
            response.sendRedirect(request.getContextPath() + "/admin/usuarios?msg=estado_actualizado");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/usuarios?error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void procesarRolUsuario(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        Usuario admin = (Usuario) request.getSession().getAttribute("usuarioLogueado");
        try {
            int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
            int idRol = Integer.parseInt(request.getParameter("idRol"));
            String accion = request.getParameter("accion"); // 'asignar' o 'remover'

            if ("remover".equalsIgnoreCase(accion)) {
                // Verificar que no sea el admin removiéndose a sí mismo el rol admin (idRol == 1)
                if (admin != null && admin.getIdUsuario() == idUsuario && idRol == 1) {
                    response.sendRedirect(request.getContextPath() + "/admin/usuarios?error=" + URLEncoder.encode("No puedes removerte el rol de Super Administrador", StandardCharsets.UTF_8));
                    return;
                }
                usuarioDAO.removerRol(idUsuario, idRol);
            } else {
                usuarioDAO.asignarRol(idUsuario, idRol);
            }
            auditoriaDAO.registrar(admin != null ? admin.getIdUsuario() : null, "ROLE_CHANGE", "usuario_rol", idUsuario, request.getRemoteAddr());
            response.sendRedirect(request.getContextPath() + "/admin/usuarios?msg=rol_actualizado");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/usuarios?error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }

    private void procesarSincronizarRoles(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        Usuario admin = (Usuario) request.getSession().getAttribute("usuarioLogueado");
        try {
            int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
            String[] rolesParam = request.getParameterValues("roles");

            if (rolesParam == null || rolesParam.length == 0) {
                response.sendRedirect(request.getContextPath() + "/admin/usuarios?error=" + URLEncoder.encode("El usuario debe tener al menos un rol asignado", StandardCharsets.UTF_8));
                return;
            }

            List<Integer> roles = new ArrayList<>();
            boolean contieneAdmin = false;
            for (String r : rolesParam) {
                int rolId = Integer.parseInt(r);
                roles.add(rolId);
                if (rolId == 1) contieneAdmin = true;
            }

            // Protección: no auto-quitarse el rol admin
            if (admin != null && admin.getIdUsuario() == idUsuario && !contieneAdmin) {
                response.sendRedirect(request.getContextPath() + "/admin/usuarios?error=" + URLEncoder.encode("No puedes quitarte el rol de Administrador a ti mismo", StandardCharsets.UTF_8));
                return;
            }

            boolean ok = usuarioDAO.sincronizarRoles(idUsuario, roles);
            if (ok) {
                auditoriaDAO.registrar(admin != null ? admin.getIdUsuario() : null, "SYNC_ROLES", "usuario_rol", idUsuario, request.getRemoteAddr());
                response.sendRedirect(request.getContextPath() + "/admin/usuarios?msg=roles_actualizados");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/usuarios?error=" + URLEncoder.encode("Error al sincronizar roles", StandardCharsets.UTF_8));
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/usuarios?error=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        }
    }
}
