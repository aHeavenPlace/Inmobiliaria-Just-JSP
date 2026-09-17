package com.inmobiliariavesta.dao;

import com.inmobiliariavesta.config.DBConnection;
import com.inmobiliariavesta.model.Perfil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PerfilDAO {

    public Perfil obtenerPorIdUsuario(int idUsuario) {
        String sql = "SELECT * FROM perfil WHERE id_usuario = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String fotoUrl = rs.getString("foto_url");
                    if (fotoUrl != null && fotoUrl.toLowerCase().contains("pravatar")) {
                        fotoUrl = null;
                    }
                    return new Perfil(
                        rs.getInt("id_perfil"),
                        rs.getInt("id_usuario"),
                        rs.getString("nombres"),
                        rs.getString("apellidos"),
                        rs.getString("documento"),
                        rs.getString("telefono"),
                        rs.getString("direccion"),
                        fotoUrl
                    );
                }
            }
        } catch (SQLException e) {
            System.err.println("[PerfilDAO] Error al obtener perfil por usuario: " + e.getMessage());
        }
        return null;
    }

    public boolean guardarOActualizar(Perfil p) {
        if (p == null) return false;
        Perfil existente = obtenerPorIdUsuario(p.getIdUsuario());
        if (existente != null) {
            return actualizar(p);
        } else {
            return insertar(p);
        }
    }

    public boolean actualizar(Perfil p) {
        String sql = "UPDATE perfil SET nombres = ?, apellidos = ?, documento = ?, telefono = ?, direccion = ?, foto_url = ? WHERE id_usuario = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getNombres());
            ps.setString(2, p.getApellidos());
            ps.setString(3, p.getDocumento());
            ps.setString(4, p.getTelefono());
            ps.setString(5, p.getDireccion());
            ps.setString(6, p.getFotoUrl());
            ps.setInt(7, p.getIdUsuario());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PerfilDAO] Error al actualizar perfil: " + e.getMessage());
            return false;
        }
    }

    public boolean insertar(Perfil p) {
        String sql = "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion, foto_url) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getIdUsuario());
            ps.setString(2, p.getNombres());
            ps.setString(3, p.getApellidos());
            ps.setString(4, p.getDocumento());
            ps.setString(5, p.getTelefono());
            ps.setString(6, p.getDireccion());
            ps.setString(7, p.getFotoUrl());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PerfilDAO] Error al insertar perfil: " + e.getMessage());
            return false;
        }
    }
}
