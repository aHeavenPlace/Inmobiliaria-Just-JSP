package com.inmobiliariavesta.dao;

import com.inmobiliariavesta.config.DBConnection;
import com.inmobiliariavesta.model.EstadisticaCiudadDTO;
import com.inmobiliariavesta.model.EstadisticaTipoDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportesDAO {

    /**
     * CONSULTA SQL OBLIGATORIA (GROUP BY + HAVING #1):
     * Agrupa propiedades disponibles por ciudad calculando total de propiedades,
     * precio promedio, mínimo y máximo, filtrando con HAVING aquellas ciudades que
     * superen un umbral mínimo de inmuebles.
     */
    public List<EstadisticaCiudadDTO> obtenerEstadisticasCiudades(int minPropiedades) {
        List<EstadisticaCiudadDTO> lista = new ArrayList<>();
        String sql = "SELECT c.id_ciudad, c.nombre AS ciudad, c.departamento, " +
                     "COUNT(p.id_propiedad) AS total_propiedades, " +
                     "ROUND(AVG(p.precio), 2) AS precio_promedio, " +
                     "MIN(p.precio) AS precio_minimo, " +
                     "MAX(p.precio) AS precio_maximo " +
                     "FROM propiedad p " +
                     "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                     "WHERE p.estado = 'disponible' " +
                     "GROUP BY c.id_ciudad, c.nombre, c.departamento " +
                     "HAVING COUNT(p.id_propiedad) >= ? " +
                     "ORDER BY total_propiedades DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, minPropiedades);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new EstadisticaCiudadDTO(
                        rs.getInt("id_ciudad"),
                        rs.getString("ciudad"),
                        rs.getString("departamento"),
                        rs.getLong("total_propiedades"),
                        rs.getBigDecimal("precio_promedio"),
                        rs.getBigDecimal("precio_minimo"),
                        rs.getBigDecimal("precio_maximo")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReportesDAO] Error en GROUP BY + HAVING por ciudad: " + e.getMessage());
        }
        return lista;
    }

    /**
     * CONSULTA SQL OBLIGATORIA (GROUP BY + HAVING #2):
     * Agrupa propiedades disponibles por tipo de propiedad calculando el total y
     * el precio promedio con condición HAVING.
     */
    public List<EstadisticaTipoDTO> obtenerEstadisticasTiposPropiedad(int minPropiedades) {
        List<EstadisticaTipoDTO> lista = new ArrayList<>();
        String sql = "SELECT tp.id_tipo, tp.nombre AS tipo, " +
                     "COUNT(p.id_propiedad) AS total_propiedades, " +
                     "ROUND(AVG(p.precio), 2) AS precio_promedio " +
                     "FROM propiedad p " +
                     "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                     "WHERE p.estado = 'disponible' " +
                     "GROUP BY tp.id_tipo, tp.nombre " +
                     "HAVING COUNT(p.id_propiedad) >= ? " +
                     "ORDER BY total_propiedades DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, minPropiedades);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new EstadisticaTipoDTO(
                        rs.getInt("id_tipo"),
                        rs.getString("tipo"),
                        rs.getLong("total_propiedades"),
                        rs.getBigDecimal("precio_promedio")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("[ReportesDAO] Error en GROUP BY + HAVING por tipo: " + e.getMessage());
        }
        return lista;
    }

    /**
     * Métricas globales para dashboards (Admin, Inmobiliaria, Cliente).
     */
    public Map<String, Object> obtenerMetricasDashboard(Integer idInmobiliaria, Integer idCliente) {
        Map<String, Object> metricas = new HashMap<>();

        try (Connection conn = DBConnection.getConnection()) {
            if (idInmobiliaria != null && idInmobiliaria > 0) {
                // Métricas Agente Inmobiliaria
                String q1 = "SELECT COUNT(*) FROM propiedad WHERE id_inmobiliaria = ?";
                try (PreparedStatement ps = conn.prepareStatement(q1)) {
                    ps.setInt(1, idInmobiliaria);
                    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("misPropiedades", rs.getInt(1)); }
                }

                String q2 = "SELECT COUNT(*) FROM cita c JOIN propiedad p ON c.id_propiedad = p.id_propiedad WHERE p.id_inmobiliaria = ? AND c.estado = 'pendiente'";
                try (PreparedStatement ps = conn.prepareStatement(q2)) {
                    ps.setInt(1, idInmobiliaria);
                    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("citasPendientes", rs.getInt(1)); }
                }

                String q3 = "SELECT COUNT(*) FROM propiedad WHERE id_inmobiliaria = ? AND estado = 'disponible'";
                try (PreparedStatement ps = conn.prepareStatement(q3)) {
                    ps.setInt(1, idInmobiliaria);
                    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("propiedadesDisponibles", rs.getInt(1)); }
                }
            } else if (idCliente != null && idCliente > 0) {
                // Métricas Cliente
                String q1 = "SELECT COUNT(*) FROM favorito WHERE id_usuario = ?";
                try (PreparedStatement ps = conn.prepareStatement(q1)) {
                    ps.setInt(1, idCliente);
                    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("misFavoritos", rs.getInt(1)); }
                }

                String q2 = "SELECT COUNT(*) FROM cita WHERE id_cliente = ? AND estado IN ('pendiente', 'confirmada')";
                try (PreparedStatement ps = conn.prepareStatement(q2)) {
                    ps.setInt(1, idCliente);
                    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("misCitasActivas", rs.getInt(1)); }
                }
            } else {
                // Métricas Administrador
                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM usuario");
                     ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("totalUsuarios", rs.getInt(1)); }

                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM propiedad");
                     ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("totalPropiedades", rs.getInt(1)); }

                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM propiedad WHERE estado = 'disponible'");
                     ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("propiedadesDisponibles", rs.getInt(1)); }

                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM cita");
                     ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("totalCitas", rs.getInt(1)); }

                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM solicitud");
                     ResultSet rs = ps.executeQuery()) { if (rs.next()) metricas.put("totalSolicitudes", rs.getInt(1)); }
            }
        } catch (SQLException e) {
            System.err.println("[ReportesDAO] Error calculando métricas de dashboard: " + e.getMessage());
        }

        return metricas;
    }
}
