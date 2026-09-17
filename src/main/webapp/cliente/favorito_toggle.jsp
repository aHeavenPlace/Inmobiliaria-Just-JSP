<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*" %>
<%-- favorito_toggle.jsp — Agrega o elimina un favorito y redirige de vuelta --%>
<%@ include file="/components/conexion.jsp" %>
<%
    if (session.getAttribute("idUsuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?msg=inicia_sesion_favorito");
        return;
    }
    int idUsuario   = (Integer) session.getAttribute("idUsuario");
    String idPropS  = request.getParameter("idPropiedad");
    String redirect = request.getParameter("redirect");

    if (idPropS != null && "POST".equalsIgnoreCase(request.getMethod())) {
        int idProp = Integer.parseInt(idPropS);
        try (Connection conn = getConn()) {
            // Verificar si ya es favorito
            PreparedStatement chk = conn.prepareStatement(
                "SELECT id_favorito FROM favorito WHERE id_usuario=? AND id_propiedad=?");
            chk.setInt(1, idUsuario); chk.setInt(2, idProp);
            ResultSet rs = chk.executeQuery();
            if (rs.next()) {
                // Eliminar
                conn.prepareStatement("DELETE FROM favorito WHERE id_usuario=" + idUsuario + " AND id_propiedad=" + idProp).executeUpdate();
            } else {
                // Agregar
                conn.prepareStatement("INSERT INTO favorito (id_usuario, id_propiedad) VALUES (" + idUsuario + "," + idProp + ")").executeUpdate();
            }
        } catch (Exception ex) { ex.printStackTrace(); }
    }

    if (redirect != null && !redirect.isEmpty()) {
        response.sendRedirect(redirect);
    } else {
        response.sendRedirect(request.getContextPath() + "/catalogo.jsp");
    }
%>
