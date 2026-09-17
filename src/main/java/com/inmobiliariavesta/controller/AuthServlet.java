package com.inmobiliariavesta.controller;

import com.inmobiliariavesta.dao.AuditoriaDAO;
import com.inmobiliariavesta.dao.PerfilDAO;
import com.inmobiliariavesta.dao.UsuarioDAO;
import com.inmobiliariavesta.model.Perfil;
import com.inmobiliariavesta.model.Usuario;
import com.inmobiliariavesta.util.BCryptUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "AuthServlet", urlPatterns = {"/login", "/registro", "/logout"})
public class AuthServlet extends HttpServlet {

    private UsuarioDAO usuarioDAO = new UsuarioDAO();
    private PerfilDAO perfilDAO = new PerfilDAO();
    private AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                Usuario u = (Usuario) session.getAttribute("usuarioLogueado");
                if (u != null) {
                    auditoriaDAO.registrar(u.getIdUsuario(), "LOGOUT", "usuario", u.getIdUsuario(), request.getRemoteAddr());
                }
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login?msg=sesion_cerrada");
            return;
        }

        if ("/registro".equals(path)) {
            request.getRequestDispatcher("/WEB-INF/views/auth/registro.jsp").forward(request, response);
            return;
        }

        // Vista de login por defecto
        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/login".equals(path)) {
            procesarLogin(request, response);
        } else if ("/registro".equals(path)) {
            procesarRegistro(request, response);
        }
    }

    private void procesarLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String correo = request.getParameter("correo");
        String password = request.getParameter("password");
        String redirect = request.getParameter("redirect");

        if (correo == null || correo.isBlank() || password == null || password.isBlank()) {
            request.setAttribute("error", "Por favor ingresa tu correo y contraseña.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        Usuario usuario = usuarioDAO.autenticar(correo, password);

        if (usuario == null) {
            request.setAttribute("error", "Credenciales incorrectas o cuenta inactiva.");
            request.setAttribute("correoPrevio", correo);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Crear sesión HTTP
        HttpSession session = request.getSession(true);
        session.setAttribute("usuarioLogueado", usuario);
        session.setAttribute("idUsuario", usuario.getIdUsuario());
        session.setAttribute("correoUsuario", usuario.getCorreo());
        session.setAttribute("nombreUsuario", usuario.getPerfil() != null ? usuario.getPerfil().getNombreCompleto() : usuario.getCorreo());
        session.setAttribute("rolPrincipal", usuario.getPrimaryRole());

        // Registrar en auditoría
        auditoriaDAO.registrar(usuario.getIdUsuario(), "LOGIN", "usuario", usuario.getIdUsuario(), request.getRemoteAddr());

        // Si venía de una ruta interceptada protegida
        if (redirect != null && !redirect.isBlank() && !redirect.contains("login") && !redirect.contains("logout")) {
            response.sendRedirect(request.getContextPath() + redirect);
            return;
        }

        // Redirección automática al dashboard según rol
        if (usuario.hasRole("admin")) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else if (usuario.hasRole("inmobiliaria")) {
            response.sendRedirect(request.getContextPath() + "/inmobiliaria/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/cliente/dashboard");
        }
    }

    private void procesarRegistro(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String correo = request.getParameter("correo");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String nombres = request.getParameter("nombres");
        String apellidos = request.getParameter("apellidos");
        String documento = request.getParameter("documento");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");
        String tipoCuenta = request.getParameter("tipoCuenta"); // 'cliente' o 'inmobiliaria'

        if (correo == null || correo.isBlank() || password == null || password.isBlank() ||
            nombres == null || nombres.isBlank() || apellidos == null || apellidos.isBlank()) {
            request.setAttribute("error", "Todos los campos obligatorios deben ser diligenciados.");
            request.getRequestDispatcher("/WEB-INF/views/auth/registro.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Las contraseñas no coinciden.");
            request.getRequestDispatcher("/WEB-INF/views/auth/registro.jsp").forward(request, response);
            return;
        }

        // Verificar si el correo ya existe
        if (usuarioDAO.obtenerPorCorreo(correo) != null) {
            request.setAttribute("error", "El correo electrónico ya se encuentra registrado.");
            request.getRequestDispatcher("/WEB-INF/views/auth/registro.jsp").forward(request, response);
            return;
        }

        try {
            Usuario nuevoUsuario = new Usuario();
            nuevoUsuario.setCorreo(correo.trim().toLowerCase());
            // Usar BCrypt para TODOS los usuarios para evitar problemas de hash
            nuevoUsuario.setPasswordHash(BCryptUtil.hashPassword(password));

            Perfil nuevoPerfil = new Perfil();
            nuevoPerfil.setNombres(nombres.trim());
            nuevoPerfil.setApellidos(apellidos.trim());
            nuevoPerfil.setDocumento(documento != null ? documento.trim() : "");
            nuevoPerfil.setTelefono(telefono != null ? telefono.trim() : "");
            nuevoPerfil.setDireccion(direccion != null ? direccion.trim() : "");

            // Asignar rol según tipo de cuenta: 2: Inmobiliaria, 3: Cliente (no se permite admin por registro)
            int idRol;
            if ("inmobiliaria".equalsIgnoreCase(tipoCuenta)) {
                idRol = 2; // Rol de inmobiliaria
            } else {
                idRol = 3; // Rol de cliente (por defecto)
            }

            Usuario usuarioCreado = usuarioDAO.registrar(nuevoUsuario, nuevoPerfil, idRol);

            // Iniciar sesión automáticamente
            HttpSession session = request.getSession(true);
            session.setAttribute("usuarioLogueado", usuarioCreado);
            session.setAttribute("idUsuario", usuarioCreado.getIdUsuario());
            session.setAttribute("correoUsuario", usuarioCreado.getCorreo());
            session.setAttribute("nombreUsuario", usuarioCreado.getPerfil().getNombreCompleto());
            session.setAttribute("rolPrincipal", usuarioCreado.getPrimaryRole());

            // Auditoría
            auditoriaDAO.registrar(usuarioCreado.getIdUsuario(), "REGISTRO", "usuario", usuarioCreado.getIdUsuario(), request.getRemoteAddr());

            // Redirección según el rol del usuario creado
            if (usuarioCreado.hasRole("admin")) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?registro=ok");
            } else if (usuarioCreado.hasRole("inmobiliaria")) {
                response.sendRedirect(request.getContextPath() + "/inmobiliaria/dashboard?registro=ok");
            } else {
                response.sendRedirect(request.getContextPath() + "/cliente/dashboard?registro=ok");
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Ocurrió un error al registrar el usuario: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/auth/registro.jsp").forward(request, response);
        }
    }
}
