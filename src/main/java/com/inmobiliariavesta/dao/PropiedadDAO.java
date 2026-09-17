package com.inmobiliariavesta.dao;

import com.inmobiliariavesta.config.DBConnection;
import com.inmobiliariavesta.model.Caracteristica;
import com.inmobiliariavesta.model.ImagenPropiedad;
import com.inmobiliariavesta.model.Propiedad;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class PropiedadDAO {

    /**
     * CONSULTA SQL OBLIGATORIA (INNER JOIN con 3+ tablas #1):
     * Obtiene la ficha técnica completa de una propiedad integrando información descriptiva
     * de 4 tablas: propiedad, ciudad, tipo_propiedad e inmobiliaria.
     */
    public Propiedad obtenerPorIdConDetalle(int idPropiedad) {
        String sql = "SELECT p.*, " +
                     "c.nombre AS ciudad_nombre, c.departamento AS departamento_nombre, " +
                     "tp.nombre AS tipo_nombre, " +
                     "i.nombre AS inmobiliaria_nombre, i.telefono AS inmobiliaria_telefono " +
                     "FROM propiedad p " +
                     "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                     "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                     "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
                     "WHERE p.id_propiedad = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Propiedad p = mapearPropiedad(rs);
                    p.setCiudadNombre(rs.getString("ciudad_nombre"));
                    p.setDepartamentoNombre(rs.getString("departamento_nombre"));
                    p.setTipoNombre(rs.getString("tipo_nombre"));
                    p.setInmobiliariaNombre(rs.getString("inmobiliaria_nombre"));
                    p.setInmobiliariaTelefono(rs.getString("inmobiliaria_telefono"));

                    // Cargar galería y características
                    p.setImagenes(obtenerImagenesDePropiedad(idPropiedad));
                    p.setCaracteristicas(obtenerCaracteristicasDePropiedad(idPropiedad));
                    return p;
                }
            }
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error en INNER JOIN con 3+ tablas: " + e.getMessage());
        }
        return null;
    }

    /**
     * CONSULTA SQL OBLIGATORIA (Relación N:M #2):
     * Obtiene todas las características (amenidades) asociadas a una propiedad
     * a través de la tabla intermedia propiedad_caracteristica.
     */
    public List<Caracteristica> obtenerCaracteristicasDePropiedad(int idPropiedad) {
        List<Caracteristica> lista = new ArrayList<>();
        String sql = "SELECT c.id_caracteristica, c.nombre, c.descripcion " +
                     "FROM caracteristica c " +
                     "INNER JOIN propiedad_caracteristica pc ON c.id_caracteristica = pc.id_caracteristica " +
                     "WHERE pc.id_propiedad = ? " +
                     "ORDER BY c.nombre ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new Caracteristica(
                        rs.getInt("id_caracteristica"),
                        rs.getString("nombre"),
                        rs.getString("descripcion")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error en consulta N:M caracteristicas: " + e.getMessage());
        }
        return lista;
    }

    /**
     * CONSULTA SQL OBLIGATORIA (LEFT JOIN #1):
     * Lista propiedades aplicando LEFT JOIN con imagen_propiedad (para mostrar foto principal incluso
     * si aún no tiene imagen asignada) y LEFT JOIN con favorito para verificar si el usuario
     * en sesión ya la marcó como favorita.
     */
    public List<Propiedad> listarCatalogoConFiltros(Integer idCiudad, Integer idTipo, String tipoOperacion, 
                                                    BigDecimal maxPrecio, Integer idUsuarioSesion, String keyword) {
        List<Propiedad> lista = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT p.*, " +
            "c.nombre AS ciudad_nombre, c.departamento AS departamento_nombre, " +
            "tp.nombre AS tipo_nombre, " +
            "i.nombre AS inmobiliaria_nombre, " +
            "img.url AS imagen_principal, " +
            "CASE WHEN fav.id_usuario IS NOT NULL THEN TRUE ELSE FALSE END AS es_favorito " +
            "FROM propiedad p " +
            "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
            "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
            "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
            "LEFT JOIN ( " +
            "    SELECT DISTINCT ON (id_propiedad) id_propiedad, url " +
            "    FROM imagen_propiedad " +
            "    ORDER BY id_propiedad, orden ASC " +
            ") img ON p.id_propiedad = img.id_propiedad " +
            "LEFT JOIN favorito fav ON p.id_propiedad = fav.id_propiedad AND fav.id_usuario = ? " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        params.add(idUsuarioSesion != null ? idUsuarioSesion : -1);

        if (idCiudad != null && idCiudad > 0) {
            sql.append(" AND p.id_ciudad = ? ");
            params.add(idCiudad);
        }

        if (idTipo != null && idTipo > 0) {
            sql.append(" AND p.id_tipo = ? ");
            params.add(idTipo);
        }

        if (tipoOperacion != null && !tipoOperacion.isBlank() && !tipoOperacion.equalsIgnoreCase("todos")) {
            sql.append(" AND p.tipo_operacion = ? ");
            params.add(tipoOperacion.trim().toLowerCase());
        }

        if (maxPrecio != null && maxPrecio.compareTo(BigDecimal.ZERO) > 0) {
            sql.append(" AND p.precio <= ? ");
            params.add(maxPrecio);
        }

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(p.titulo) LIKE ? OR LOWER(p.descripcion) LIKE ? OR LOWER(p.direccion) LIKE ?) ");
            String pat = "%" + keyword.trim().toLowerCase() + "%";
            params.add(pat);
            params.add(pat);
            params.add(pat);
        }

        sql.append(" ORDER BY p.fecha_publicacion DESC ");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Propiedad p = mapearPropiedad(rs);
                    p.setCiudadNombre(rs.getString("ciudad_nombre"));
                    p.setDepartamentoNombre(rs.getString("departamento_nombre"));
                    p.setTipoNombre(rs.getString("tipo_nombre"));
                    p.setInmobiliariaNombre(rs.getString("inmobiliaria_nombre"));
                    p.setImagenPrincipal(rs.getString("imagen_principal"));
                    p.setEsFavorito(rs.getBoolean("es_favorito"));
                    lista.add(p);
                }
            }
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error en LEFT JOIN catálogo con filtros: " + e.getMessage());
        }

        return lista;
    }

    public List<Propiedad> listarDestacadas(int limit, Integer idUsuarioSesion) {
        List<Propiedad> lista = new ArrayList<>();
        String sql = "SELECT p.*, " +
                     "c.nombre AS ciudad_nombre, c.departamento AS departamento_nombre, " +
                     "tp.nombre AS tipo_nombre, " +
                     "i.nombre AS inmobiliaria_nombre, " +
                     "img.url AS imagen_principal, " +
                     "CASE WHEN fav.id_usuario IS NOT NULL THEN TRUE ELSE FALSE END AS es_favorito " +
                     "FROM propiedad p " +
                     "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                     "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                     "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
                     "LEFT JOIN ( " +
                     "    SELECT DISTINCT ON (id_propiedad) id_propiedad, url " +
                     "    FROM imagen_propiedad " +
                     "    ORDER BY id_propiedad, orden ASC " +
                     ") img ON p.id_propiedad = img.id_propiedad " +
                     "LEFT JOIN favorito fav ON p.id_propiedad = fav.id_propiedad AND fav.id_usuario = ? " +
                     "WHERE p.estado = 'disponible' " +
                     "ORDER BY p.fecha_publicacion DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idUsuarioSesion != null ? idUsuarioSesion : -1);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Propiedad p = mapearPropiedad(rs);
                    p.setCiudadNombre(rs.getString("ciudad_nombre"));
                    p.setDepartamentoNombre(rs.getString("departamento_nombre"));
                    p.setTipoNombre(rs.getString("tipo_nombre"));
                    p.setInmobiliariaNombre(rs.getString("inmobiliaria_nombre"));
                    p.setImagenPrincipal(rs.getString("imagen_principal"));
                    p.setEsFavorito(rs.getBoolean("es_favorito"));
                    lista.add(p);
                }
            }
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error al listar destacadas: " + e.getMessage());
        }
        return lista;
    }

    public List<Propiedad> listarPorInmobiliaria(int idInmobiliaria) {
        List<Propiedad> lista = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre AS ciudad_nombre, tp.nombre AS tipo_nombre, " +
                     "img.url AS imagen_principal " +
                     "FROM propiedad p " +
                     "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                     "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                     "LEFT JOIN ( " +
                     "    SELECT DISTINCT ON (id_propiedad) id_propiedad, url " +
                     "    FROM imagen_propiedad " +
                     "    ORDER BY id_propiedad, orden ASC " +
                     ") img ON p.id_propiedad = img.id_propiedad " +
                     "WHERE p.id_inmobiliaria = ? " +
                     "ORDER BY p.fecha_publicacion DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idInmobiliaria);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Propiedad p = mapearPropiedad(rs);
                    p.setCiudadNombre(rs.getString("ciudad_nombre"));
                    p.setTipoNombre(rs.getString("tipo_nombre"));
                    p.setImagenPrincipal(rs.getString("imagen_principal"));
                    lista.add(p);
                }
            }
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error al listar propiedades de inmobiliaria: " + e.getMessage());
        }
        return lista;
    }

    public List<ImagenPropiedad> obtenerImagenesDePropiedad(int idPropiedad) {
        List<ImagenPropiedad> lista = new ArrayList<>();
        String sql = "SELECT * FROM imagen_propiedad WHERE id_propiedad = ? ORDER BY orden ASC, id_imagen ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new ImagenPropiedad(
                        rs.getInt("id_imagen"),
                        rs.getInt("id_propiedad"),
                        rs.getString("url"),
                        rs.getString("descripcion"),
                        rs.getInt("orden")
                    ));
                }
            }
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error al obtener imágenes: " + e.getMessage());
        }
        return lista;
    }

    public int insertar(Propiedad p, List<Integer> idCaracteristicas, List<String> urlsImagenes) throws SQLException {
        String sqlProp = "INSERT INTO propiedad (id_inmobiliaria, id_ciudad, id_tipo, matricula_inmobiliaria, " +
                         "titulo, descripcion, direccion, precio, area_m2, habitaciones, banos, tipo_operacion, estado) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlCarac = "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?, ?)";
        String sqlImg = "INSERT INTO imagen_propiedad (id_propiedad, url, descripcion, orden) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int idPropiedadGenerado = -1;
                try (PreparedStatement psP = conn.prepareStatement(sqlProp, Statement.RETURN_GENERATED_KEYS)) {
                    psP.setInt(1, p.getIdInmobiliaria());
                    psP.setInt(2, p.getIdCiudad());
                    psP.setInt(3, p.getIdTipo());
                    psP.setString(4, p.getMatriculaInmobiliaria());
                    psP.setString(5, p.getTitulo());
                    psP.setString(6, p.getDescripcion());
                    psP.setString(7, p.getDireccion());
                    psP.setBigDecimal(8, p.getPrecio());
                    if (p.getAreaM2() != null) psP.setBigDecimal(9, p.getAreaM2()); else psP.setNull(9, Types.DECIMAL);
                    psP.setInt(10, p.getHabitaciones());
                    psP.setInt(11, p.getBanos());
                    psP.setString(12, p.getTipoOperacion());
                    psP.setString(13, p.getEstado() != null ? p.getEstado() : "disponible");
                    psP.executeUpdate();

                    try (ResultSet rs = psP.getGeneratedKeys()) {
                        if (rs.next()) {
                            idPropiedadGenerado = rs.getInt(1);
                        }
                    }
                }

                if (idPropiedadGenerado <= 0) {
                    throw new SQLException("No se pudo obtener el ID de la propiedad generada.");
                }

                if (idCaracteristicas != null) {
                    try (PreparedStatement psC = conn.prepareStatement(sqlCarac)) {
                        for (Integer idCarac : idCaracteristicas) {
                            psC.setInt(1, idPropiedadGenerado);
                            psC.setInt(2, idCarac);
                            psC.addBatch();
                        }
                        psC.executeBatch();
                    }
                }

                if (urlsImagenes != null && !urlsImagenes.isEmpty()) {
                    try (PreparedStatement psI = conn.prepareStatement(sqlImg)) {
                        int orden = 1;
                        for (String url : urlsImagenes) {
                            if (url != null && !url.isBlank()) {
                                psI.setInt(1, idPropiedadGenerado);
                                psI.setString(2, url.trim());
                                psI.setString(3, "Foto " + orden);
                                psI.setInt(4, orden++);
                                psI.addBatch();
                            }
                        }
                        psI.executeBatch();
                    }
                }

                conn.commit();
                return idPropiedadGenerado;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean actualizar(Propiedad p, List<Integer> idCaracteristicas) throws SQLException {
        String sqlProp = "UPDATE propiedad SET id_ciudad = ?, id_tipo = ?, matricula_inmobiliaria = ?, " +
                         "titulo = ?, descripcion = ?, direccion = ?, precio = ?, area_m2 = ?, " +
                         "habitaciones = ?, banos = ?, tipo_operacion = ?, estado = ? WHERE id_propiedad = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlProp)) {
                    ps.setInt(1, p.getIdCiudad());
                    ps.setInt(2, p.getIdTipo());
                    ps.setString(3, p.getMatriculaInmobiliaria());
                    ps.setString(4, p.getTitulo());
                    ps.setString(5, p.getDescripcion());
                    ps.setString(6, p.getDireccion());
                    ps.setBigDecimal(7, p.getPrecio());
                    if (p.getAreaM2() != null) ps.setBigDecimal(8, p.getAreaM2()); else ps.setNull(8, Types.DECIMAL);
                    ps.setInt(9, p.getHabitaciones());
                    ps.setInt(10, p.getBanos());
                    ps.setString(11, p.getTipoOperacion());
                    ps.setString(12, p.getEstado());
                    ps.setInt(13, p.getIdPropiedad());
                    ps.executeUpdate();
                }

                if (idCaracteristicas != null) {
                    try (PreparedStatement psDel = conn.prepareStatement("DELETE FROM propiedad_caracteristica WHERE id_propiedad = ?")) {
                        psDel.setInt(1, p.getIdPropiedad());
                        psDel.executeUpdate();
                    }

                    try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?, ?)")) {
                        for (Integer idCarac : idCaracteristicas) {
                            psIns.setInt(1, p.getIdPropiedad());
                            psIns.setInt(2, idCarac);
                            psIns.addBatch();
                        }
                        psIns.executeBatch();
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean eliminar(int idPropiedad) {
        String sql = "DELETE FROM propiedad WHERE id_propiedad = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idPropiedad);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error al eliminar propiedad: " + e.getMessage());
            return false;
        }
    }

    /**
     * Elimina una imagen específica por su ID y retorna la URL para permitir borrar el archivo si es local.
     */
    public String eliminarImagen(int idImagen) {
        String sqlSelect = "SELECT url FROM imagen_propiedad WHERE id_imagen = ?";
        String sqlDelete = "DELETE FROM imagen_propiedad WHERE id_imagen = ?";
        try (Connection conn = DBConnection.getConnection()) {
            String url = null;
            try (PreparedStatement psS = conn.prepareStatement(sqlSelect)) {
                psS.setInt(1, idImagen);
                try (ResultSet rs = psS.executeQuery()) {
                    if (rs.next()) {
                        url = rs.getString("url");
                    }
                }
            }
            if (url != null) {
                try (PreparedStatement psD = conn.prepareStatement(sqlDelete)) {
                    psD.setInt(1, idImagen);
                    psD.executeUpdate();
                }
            }
            return url;
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error al eliminar imagen: " + e.getMessage());
            return null;
        }
    }

    /**
     * Agrega nuevas imágenes a una propiedad existente asignando orden incremental.
     */
    public boolean agregarImagenes(int idPropiedad, List<String> urls) {
        if (urls == null || urls.isEmpty()) return true;
        String sqlCount = "SELECT COALESCE(MAX(orden), 0) FROM imagen_propiedad WHERE id_propiedad = ?";
        String sqlInsert = "INSERT INTO imagen_propiedad (id_propiedad, url, descripcion, orden) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            int maxOrden = 0;
            try (PreparedStatement psC = conn.prepareStatement(sqlCount)) {
                psC.setInt(1, idPropiedad);
                try (ResultSet rs = psC.executeQuery()) {
                    if (rs.next()) maxOrden = rs.getInt(1);
                }
            }
            try (PreparedStatement psI = conn.prepareStatement(sqlInsert)) {
                for (String u : urls) {
                    if (u != null && !u.isBlank()) {
                        psI.setInt(1, idPropiedad);
                        psI.setString(2, u.trim());
                        psI.setString(3, "Foto " + (++maxOrden));
                        psI.setInt(4, maxOrden);
                        psI.addBatch();
                    }
                }
                psI.executeBatch();
            }
            return true;
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error al agregar imágenes: " + e.getMessage());
            return false;
        }
    }

    /**
     * Lista todas las propiedades para el panel de administración global.
     */
    public List<Propiedad> listarTodasAdmin() {
        List<Propiedad> lista = new ArrayList<>();
        String sql = "SELECT p.*, " +
                     "c.nombre AS ciudad_nombre, " +
                     "tp.nombre AS tipo_nombre, " +
                     "i.nombre AS inmobiliaria_nombre, " +
                     "(SELECT url FROM imagen_propiedad ip WHERE ip.id_propiedad = p.id_propiedad ORDER BY orden ASC, id_imagen ASC LIMIT 1) AS imagen_principal " +
                     "FROM propiedad p " +
                     "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
                     "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo " +
                     "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
                     "ORDER BY p.fecha_publicacion DESC, p.id_propiedad DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Propiedad p = mapearPropiedad(rs);
                p.setCiudadNombre(rs.getString("ciudad_nombre"));
                p.setTipoNombre(rs.getString("tipo_nombre"));
                p.setInmobiliariaNombre(rs.getString("inmobiliaria_nombre"));
                p.setImagenPrincipal(rs.getString("imagen_principal"));
                lista.add(p);
            }
        } catch (SQLException e) {
            System.err.println("[PropiedadDAO] Error al listar propiedades admin: " + e.getMessage());
        }
        return lista;
    }

    private Propiedad mapearPropiedad(ResultSet rs) throws SQLException {
        Propiedad p = new Propiedad();
        p.setIdPropiedad(rs.getInt("id_propiedad"));
        p.setIdInmobiliaria(rs.getInt("id_inmobiliaria"));
        p.setIdCiudad(rs.getInt("id_ciudad"));
        p.setIdTipo(rs.getInt("id_tipo"));
        p.setMatriculaInmobiliaria(rs.getString("matricula_inmobiliaria"));
        p.setTitulo(rs.getString("titulo"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setDireccion(rs.getString("direccion"));
        p.setPrecio(rs.getBigDecimal("precio"));
        p.setAreaM2(rs.getBigDecimal("area_m2"));
        p.setHabitaciones(rs.getInt("habitaciones"));
        p.setBanos(rs.getInt("banos"));
        p.setTipoOperacion(rs.getString("tipo_operacion"));
        p.setEstado(rs.getString("estado"));
        p.setFechaPublicacion(rs.getTimestamp("fecha_publicacion"));
        return p;
    }
}
