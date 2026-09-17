<%@ page import="java.sql.Connection, java.sql.DriverManager" %>
<%!
    /* =========================================================
       conexion.jsp — Conexión directa JDBC a PostgreSQL (Supabase)
       Compatible con Tomcat 8.5 / Java 11 / JSP 2.3
       Incluir en cada JSP con: <%@ include file="/components/conexion.jsp" %>
       ========================================================= */
    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("[conexion.jsp] Driver PostgreSQL no encontrado: " + e.getMessage());
        }
    }

    private static final String DB_URL  =
        "jdbc:postgresql://aws-0-us-east-2.pooler.supabase.com:6543/postgres" +
        "?sslmode=require&prepareThreshold=0";
    private static final String DB_USER = "postgres.ymfqanafhpayxvxvsrhw";
    private static final String DB_PASS = "parcialJava1";

    public static Connection getConn() throws java.sql.SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
%>
