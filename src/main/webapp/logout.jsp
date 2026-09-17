<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- logout.jsp — Invalida la sesión y redirige al login --%>
<%
    session.invalidate();
    response.sendRedirect(request.getContextPath() + "/login.jsp?msg=sesion_cerrada");
%>
