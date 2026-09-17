package com.inmobiliariavesta.controller;

import com.inmobiliariavesta.dao.AuditoriaDAO;
import com.inmobiliariavesta.dao.CaracteristicaDAO;
import com.inmobiliariavesta.dao.CitaDAO;
import com.inmobiliariavesta.dao.CiudadDAO;
import com.inmobiliariavesta.dao.InmobiliariaDAO;
import com.inmobiliariavesta.dao.PropiedadDAO;
import com.inmobiliariavesta.dao.ReportesDAO;
import com.inmobiliariavesta.dao.TipoPropiedadDAO;
import com.inmobiliariavesta.model.Cita;
import com.inmobiliariavesta.model.Propiedad;
import com.inmobiliariavesta.model.Usuario;
import com.inmobiliariavesta.util.FileUploadUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;

@WebServlet(name = "InmobiliariaServlet", urlPatterns = {
    "/inmobiliaria/dashboard",
    "/inmobiliaria/propiedades",
    "/inmobiliaria/propiedad-nueva",
    "/inmobiliaria/propiedad-editar",
    "/inmobiliaria/propiedad-eliminar",
    "/inmobiliaria/propiedad-eliminar-imagen",
    "/inmobiliaria/citas",
    "/inmobiliaria/cita-estado",
    "/inmobiliaria/reportes"
})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 10 * 1024 * 1024,  // 10 MB
    maxRequestSize = 50 * 1024 * 1024 // 50 MB (para múltiples imágenes)
)
public class InmobiliariaServlet extends HttpServlet {

    private PropiedadDAO propiedadDAO = new PropiedadDAO();
    private CitaDAO citaDAO = new CitaDAO();
    private CiudadDAO ciudadDAO = new CiudadDAO();
    private TipoPropiedadDAO tipoDAO = new TipoPropiedadDAO();
    private CaracteristicaDAO caracteristicaDAO = new CaracteristicaDAO();
    private InmobiliariaDAO inmobiliariaDAO = new InmobiliariaDAO();
    private ReportesDAO reportesDAO = new ReportesDAO();
    private AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
        int idInmobiliaria = 1; // Por defecto asignado a Inmobiliaria Vesta SAS (id 1) para pruebas universitarias

        String path = request.getServletPath();

        switch (path) {
            case "/inmobiliaria/dashboard":
                cargarDashboard(request, response, idInmobiliaria);
                break;

            case "/inmobiliaria/propiedades":
                request.setAttribute("propiedades", propiedadDAO.listarPorInmobiliaria(idInmobiliaria));
                request.getRequestDispatcher("/WEB-INF/views/inmobiliaria/propiedades.jsp").forward(request, response);
                break;

            case "/inmobiliaria/propiedad-nueva":
                cargarFormularioPropiedad(request, response, null);
                break;

            case "/inmobiliaria/propiedad-editar":
                String idPropStr = request.getParameter("id");
                if (idPropStr != null) {
                    Propiedad p = propiedadDAO.obtenerPorIdConDetalle(Integer.parseInt(idPropStr));
                    cargarFormularioPropiedad(request, response, p);
                } else {
                    response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedades");
                }
                break;

            case "/inmobiliaria/citas":
                request.setAttribute("citas", citaDAO.listarPorInmobiliariaConDetalle(idInmobiliaria));
                request.getRequestDispatcher("/WEB-INF/views/inmobiliaria/citas.jsp").forward(request, response);
                break;

            case "/inmobiliaria/reportes":
                request.setAttribute("metricas", reportesDAO.obtenerMetricasDashboard(idInmobiliaria, null));
                request.setAttribute("statsCiudades", reportesDAO.obtenerEstadisticasCiudades(1));
                request.setAttribute("statsTipos", reportesDAO.obtenerEstadisticasTiposPropiedad(1));
                request.getRequestDispatcher("/WEB-INF/views/inmobiliaria/reportes.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/inmobiliaria/dashboard");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
        int idInmobiliaria = 1;

        String path = request.getServletPath();

        switch (path) {
            case "/inmobiliaria/propiedad-nueva":
                procesarCrearPropiedad(request, response, usuario, idInmobiliaria);
                break;

            case "/inmobiliaria/propiedad-editar":
                procesarActualizarPropiedad(request, response, usuario);
                break;

            case "/inmobiliaria/propiedad-eliminar":
                procesarEliminarPropiedad(request, response, usuario);
                break;

            case "/inmobiliaria/propiedad-eliminar-imagen":
                procesarEliminarImagenPropiedad(request, response, usuario);
                break;

            case "/inmobiliaria/cita-estado":
                procesarCambiarEstadoCita(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/inmobiliaria/dashboard");
                break;
        }
    }

    private void cargarDashboard(HttpServletRequest request, HttpServletResponse response, int idInmobiliaria) 
            throws ServletException, IOException {
        Map<String, Object> metricas = reportesDAO.obtenerMetricasDashboard(idInmobiliaria, null);
        List<Cita> citasRecientes = citaDAO.listarPorInmobiliariaConDetalle(idInmobiliaria);
        List<Propiedad> misPropiedades = propiedadDAO.listarPorInmobiliaria(idInmobiliaria);

        request.setAttribute("metricas", metricas);
        request.setAttribute("citas", citasRecientes);
        request.setAttribute("propiedades", misPropiedades);

        request.getRequestDispatcher("/WEB-INF/views/inmobiliaria/dashboard.jsp").forward(request, response);
    }

    private void cargarFormularioPropiedad(HttpServletRequest request, HttpServletResponse response, Propiedad propiedad) 
            throws ServletException, IOException {
        request.setAttribute("propiedad", propiedad);
        request.setAttribute("ciudades", ciudadDAO.listarTodas());
        request.setAttribute("tiposPropiedad", tipoDAO.listarTodos());
        request.setAttribute("caracteristicas", caracteristicaDAO.listarTodas());
        request.setAttribute("inmobiliarias", inmobiliariaDAO.listarTodas());
        request.getRequestDispatcher("/WEB-INF/views/inmobiliaria/propiedad_form.jsp").forward(request, response);
    }

    private void procesarCrearPropiedad(HttpServletRequest request, HttpServletResponse response, Usuario usuario, int idInmobiliaria) 
            throws IOException {
        try {
            Propiedad p = new Propiedad();
            p.setIdInmobiliaria(idInmobiliaria);
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

            // Características seleccionadas
            String[] caracs = request.getParameterValues("caracteristicas");
            List<Integer> idCaracs = new ArrayList<>();
            if (caracs != null) {
                for (String c : caracs) idCaracs.add(Integer.parseInt(c));
            }

            // Manejar subida de imágenes
            List<String> urls = new ArrayList<>();
            
            // Obtener todas las partes del request multipart
            Collection<Part> allParts = request.getParts();
            List<Part> imageParts = new ArrayList<>();
            
            for (Part part : allParts) {
                if ("imagenesFiles".equals(part.getName())) {
                    imageParts.add(part);
                }
            }
            
            if (!imageParts.isEmpty()) {
                String uploadPath = getServletContext().getRealPath("/uploads/propiedades");
                for (Part part : imageParts) {
                    if (part.getSize() > 0) {
                        String fileName = FileUploadUtil.saveImageDual(part, "propiedades", uploadPath);
                        if (fileName != null) {
                            urls.add("/uploads/propiedades/" + fileName);
                        }
                    }
                }
            }
            
            // Si no se subieron imágenes, verificar URLs manuales
            if (urls.isEmpty()) {
                String urlsStr = request.getParameter("imagenesUrls");
                if (urlsStr != null && !urlsStr.isBlank()) {
                    String[] lines = urlsStr.split("[\\r\\n,]+");
                    for (String u : lines) {
                        if (!u.trim().isBlank()) urls.add(u.trim());
                    }
                }
            }
            
            // Si aún está vacío, usar imagen por defecto
            if (urls.isEmpty()) {
                urls.add("https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800");
            }

            int idProp = propiedadDAO.insertar(p, idCaracs, urls);
            auditoriaDAO.registrar(usuario.getIdUsuario(), "INSERT", "propiedad", idProp, request.getRemoteAddr());

            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedades?msg=propiedad_creada");
        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedad-nueva?error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedad-nueva?error=" + java.net.URLEncoder.encode("Error al crear la propiedad: " + e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void procesarActualizarPropiedad(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws IOException {
        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            Propiedad p = new Propiedad();
            p.setIdPropiedad(idPropiedad);
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

            // Manejar nuevas fotos subidas en edición
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

            // Nuevas URLs de texto
            String urlsStr = request.getParameter("imagenesUrls");
            if (urlsStr != null && !urlsStr.isBlank()) {
                String[] lines = urlsStr.split("[\\r\\n,]+");
                for (String u : lines) {
                    if (!u.trim().isBlank()) nuevasUrls.add(u.trim());
                }
            }

            // Agregar imágenes nuevas si las hay
            if (!nuevasUrls.isEmpty()) {
                propiedadDAO.agregarImagenes(idPropiedad, nuevasUrls);
            }

            propiedadDAO.actualizar(p, idCaracs);
            auditoriaDAO.registrar(usuario.getIdUsuario(), "UPDATE", "propiedad", idPropiedad, request.getRemoteAddr());

            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedades?msg=propiedad_actualizada");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedades?error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void procesarEliminarImagenPropiedad(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws IOException {
        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            int idImagen = Integer.parseInt(request.getParameter("idImagen"));
            String url = propiedadDAO.eliminarImagen(idImagen);
            if (url != null && url.startsWith("/uploads/propiedades/")) {
                String fileName = url.substring("/uploads/propiedades/".length());
                String uploadPath = getServletContext().getRealPath("/uploads/propiedades");
                FileUploadUtil.deleteImage("propiedades", fileName, uploadPath);
            }
            auditoriaDAO.registrar(usuario.getIdUsuario(), "DELETE", "imagen_propiedad", idImagen, request.getRemoteAddr());
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedad-editar?id=" + idPropiedad + "&msg=imagen_eliminada");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedades?error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void procesarEliminarPropiedad(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws IOException {
        try {
            int idPropiedad = Integer.parseInt(request.getParameter("idPropiedad"));
            propiedadDAO.eliminar(idPropiedad);
            auditoriaDAO.registrar(usuario.getIdUsuario(), "DELETE", "propiedad", idPropiedad, request.getRemoteAddr());
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedades?msg=propiedad_eliminada");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/propiedades?error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8));
        }
    }

    private void procesarCambiarEstadoCita(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int idCita = Integer.parseInt(request.getParameter("idCita"));
            String nuevoEstado = request.getParameter("nuevoEstado");
            citaDAO.cambiarEstado(idCita, nuevoEstado);
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/citas?msg=estado_actualizado");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/citas?error=" + e.getMessage());
        }
    }
}
