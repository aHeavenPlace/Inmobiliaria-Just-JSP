package com.inmobiliariavesta.dao;

import com.inmobiliariavesta.config.DBConnection;
import com.inmobiliariavesta.model.Perfil;
import com.inmobiliariavesta.model.Rol;
import com.inmobiliariavesta.model.Usuario;
import com.inmobiliariavesta.util.BCryptUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    private PerfilDAO perfilDAO = new PerfilDAO();

    /**
     * Autentica un usuario verificando su correo y su contraseña con BCrypt.
     * ACCESOS UNIVERSALES DE PRUEBA: admin@vesta.com, carlos@inmobiliaria.com, juan@cliente.com
     * Estos usuarios acceden siempre con sus contraseñas por defecto sin validar hash (solo desarrollo).
     */
    public Usuario autenticar(String correo, String password) {
        String sql = "SELECT * FROM usuario WHERE correo = ? AND estado = 'activo'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, correo != null ? correo.trim().toLowerCase() : "");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String hash = rs.getString("password_hash");
                    boolean passwordValida = false;
                    
                    // ACCESOS UNIVERSALES - bypass total de contraseña para demos
                    if ("admin@vesta.com".equals(rs.getString("correo")) && "admin123".equals(password)) {
                        passwordValida = true;
                    } else if ("carlos@inmobiliaria.com".equals(rs.getString("correo")) && "inmobiliaria123".equals(password)) {
                        passwordValida = true;
                    } else if ("juan@cliente.com".equals(rs.getString("correo")) && "cliente123".equals(password)) {
                        passwordValida = true;
                    } else {
                        // Verificación normal con BCrypt para demás usuarios
                        passwordValida = BCryptUtil.checkPassword(password, hash);
                    }
                    
                    if (passwordValida) {
                        Usuario u = new Usuario(
                            rs.getInt("id_usuario"),
                            rs.getString("correo"),
                            hash,
                            rs.getString("estado"),
                            rs.getTimestamp("fecha_creacion"),
                            rs.getTimestamp("ultimo_acceso")
                        );
                        // Cargar roles y perfil
                        u.setRoles(obtenerRolesDeUsuario(u.getIdUsuario()));
                        u.setPerfil(perfilDAO.obtenerPorIdUsuario(u.getIdUsuario()));

                        // Actualizar último acceso
                        actualizarUltimoAcceso(u.getIdUsuario());
                        return u;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al autenticar usuario: " + e.getMessage());
        }
        return null;
    }

    /**
     * Actualiza la fecha/hora del último acceso exitoso del usuario.
     */
    public void actualizarUltimoAcceso(int idUsuario) {
        String sql = "UPDATE usuario SET ultimo_acceso = CURRENT_TIMESTAMP WHERE id_usuario = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al actualizar último acceso: " + e.getMessage());
        }
    }

    /**
     * CONSULTA SQL OBLIGATORIA (Relación N:M):
     * Obtiene la lista de roles asociados a un usuario mediante la tabla intermedia usuario_rol.
     */
    public List<Rol> obtenerRolesDeUsuario(int idUsuario) {
        List<Rol> roles = new ArrayList<>();
        String sql = "SELECT r.id_rol, r.nombre, r.descripcion " +
                     "FROM rol r " +
                     "INNER JOIN usuario_rol ur ON r.id_rol = ur.id_rol " +
                     "WHERE ur.id_usuario = ? " +
                     "ORDER BY r.id_rol ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roles.add(new Rol(
                        rs.getInt("id_rol"),
                        rs.getString("nombre"),
                        rs.getString("descripcion")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al obtener roles N:M: " + e.getMessage());
        }
        return roles;
    }

    public Usuario obtenerPorId(int idUsuario) {
        String sql = "SELECT * FROM usuario WHERE id_usuario = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Usuario u = new Usuario(
                        rs.getInt("id_usuario"),
                        rs.getString("correo"),
                        rs.getString("password_hash"),
                        rs.getString("estado"),
                        rs.getTimestamp("fecha_creacion"),
                        rs.getTimestamp("ultimo_acceso")
                    );
                    u.setRoles(obtenerRolesDeUsuario(u.getIdUsuario()));
                    u.setPerfil(perfilDAO.obtenerPorIdUsuario(u.getIdUsuario()));
                    return u;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al obtener usuario por ID: " + e.getMessage());
        }
        return null;
    }

    public Usuario obtenerPorCorreo(String correo) {
        String sql = "SELECT * FROM usuario WHERE correo = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, correo != null ? correo.trim().toLowerCase() : "");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Usuario u = new Usuario(
                        rs.getInt("id_usuario"),
                        rs.getString("correo"),
                        rs.getString("password_hash"),
                        rs.getString("estado"),
                        rs.getTimestamp("fecha_creacion"),
                        rs.getTimestamp("ultimo_acceso")
                    );
                    u.setRoles(obtenerRolesDeUsuario(u.getIdUsuario()));
                    u.setPerfil(perfilDAO.obtenerPorIdUsuario(u.getIdUsuario()));
                    return u;
                }
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al obtener usuario por correo: " + e.getMessage());
        }
        return null;
    }

    /**
     * Registra un nuevo usuario con su perfil y rol asignado dentro de una transacción.
     * Captura violación de restricción UNIQUE en correo.
     */
    public Usuario registrar(Usuario usuario, Perfil perfil, int idRol) throws SQLException {
        String sqlUsuario = "INSERT INTO usuario (correo, password_hash, estado) VALUES (?, ?, 'activo')";
        String sqlPerfil = "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion, foto_url) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String sqlRol = "INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int idUsuarioGenerado = -1;
                try (PreparedStatement psU = conn.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS)) {
                    psU.setString(1, usuario.getCorreo().trim().toLowerCase());
                    psU.setString(2, usuario.getPasswordHash());
                    psU.executeUpdate();
                    try (ResultSet rs = psU.getGeneratedKeys()) {
                        if (rs.next()) {
                            idUsuarioGenerado = rs.getInt(1);
                        }
                    }
                }

                if (idUsuarioGenerado <= 0) {
                    throw new SQLException("No se pudo generar el ID del nuevo usuario.");
                }

                try (PreparedStatement psP = conn.prepareStatement(sqlPerfil)) {
                    psP.setInt(1, idUsuarioGenerado);
                    psP.setString(2, perfil.getNombres());
                    psP.setString(3, perfil.getApellidos());
                    psP.setString(4, perfil.getDocumento() != null ? perfil.getDocumento() : "");
                    psP.setString(5, perfil.getTelefono() != null ? perfil.getTelefono() : "");
                    psP.setString(6, perfil.getDireccion() != null ? perfil.getDireccion() : "");
                    psP.setString(7, (perfil.getFotoUrl() != null && !perfil.getFotoUrl().isBlank() && !perfil.getFotoUrl().contains("pravatar")) ? perfil.getFotoUrl() : null);
                    psP.executeUpdate();
                }

                try (PreparedStatement psR = conn.prepareStatement(sqlRol)) {
                    psR.setInt(1, idUsuarioGenerado);
                    psR.setInt(2, idRol);
                    psR.executeUpdate();
                }

                conn.commit();

                usuario.setIdUsuario(idUsuarioGenerado);
                perfil.setIdUsuario(idUsuarioGenerado);
                usuario.setPerfil(perfil);
                usuario.setRoles(obtenerRolesDeUsuario(idUsuarioGenerado));
                return usuario;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public List<Usuario> listarTodos() {
        List<Usuario> lista = new ArrayList<>();
        String sql = "SELECT * FROM usuario ORDER BY id_usuario ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Usuario u = new Usuario(
                    rs.getInt("id_usuario"),
                    rs.getString("correo"),
                    rs.getString("password_hash"),
                    rs.getString("estado"),
                    rs.getTimestamp("fecha_creacion"),
                    rs.getTimestamp("ultimo_acceso")
                );
                u.setRoles(obtenerRolesDeUsuario(u.getIdUsuario()));
                u.setPerfil(perfilDAO.obtenerPorIdUsuario(u.getIdUsuario()));
                lista.add(u);
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al listar usuarios: " + e.getMessage());
        }
        return lista;
    }

    public boolean actualizarEstado(int idUsuario, String nuevoEstado) {
        String sql = "UPDATE usuario SET estado = ? WHERE id_usuario = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idUsuario);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al actualizar estado de usuario: " + e.getMessage());
            return false;
        }
    }

    public boolean asignarRol(int idUsuario, int idRol) {
        String sql = "INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?) ON CONFLICT DO NOTHING";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idRol);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al asignar rol: " + e.getMessage());
            return false;
        }
    }

    public boolean removerRol(int idUsuario, int idRol) {
        String sql = "DELETE FROM usuario_rol WHERE id_usuario = ? AND id_rol = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            ps.setInt(2, idRol);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al remover rol: " + e.getMessage());
            return false;
        }
    }

    /**
     * Sincroniza atómicamente los roles de un usuario en la tabla intermedia usuario_rol.
     */
    public boolean sincronizarRoles(int idUsuario, List<Integer> idRoles) {
        if (idRoles == null || idRoles.isEmpty()) {
            return false; // Un usuario no puede quedarse sin ningún rol
        }
        String sqlDelete = "DELETE FROM usuario_rol WHERE id_usuario = ?";
        String sqlInsert = "INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement psDel = conn.prepareStatement(sqlDelete)) {
                    psDel.setInt(1, idUsuario);
                    psDel.executeUpdate();
                }

                try (PreparedStatement psIns = conn.prepareStatement(sqlInsert)) {
                    for (Integer idRol : idRoles) {
                        psIns.setInt(1, idUsuario);
                        psIns.setInt(2, idRol);
                        psIns.addBatch();
                    }
                    psIns.executeBatch();
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[UsuarioDAO] Error al sincronizar roles: " + e.getMessage());
            return false;
        }
    }
}
