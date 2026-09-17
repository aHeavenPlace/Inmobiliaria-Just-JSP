package com.inmobiliariavesta.config;

import com.inmobiliariavesta.dao.UsuarioDAO;
import com.inmobiliariavesta.dao.PropiedadDAO;
import com.inmobiliariavesta.model.Usuario;
import com.inmobiliariavesta.model.Propiedad;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertFalse;

public class DBConnectionTest {
    @Test
    public void testHikariCPThroughDBConnection() {
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario user = usuarioDAO.autenticar("admin@vesta.com", "admin123");
        assertNotNull(user, "El usuario admin@vesta.com debe autenticarse correctamente");

        PropiedadDAO propiedadDAO = new PropiedadDAO();
        List<Propiedad> propiedades = propiedadDAO.listarDestacadas(6, null);
        assertNotNull(propiedades, "La lista de propiedades no debe ser nula");
        assertFalse(propiedades.isEmpty(), "Debe retornar al menos una propiedad destacada");
    }

    @Test
    public void cleanupPravatarFromDatabase() {
        try (Connection c = DBConnection.getConnection();
             java.sql.Statement st = c.createStatement()) {
            int pCount = st.executeUpdate("UPDATE perfil SET foto_url = NULL WHERE foto_url LIKE '%pravatar%'");
            int iCount = st.executeUpdate("UPDATE inmobiliaria SET logo_url = NULL WHERE logo_url LIKE '%pravatar%'");
            System.out.println(">>> Pravatar cleaned up: " + pCount + " perfiles, " + iCount + " inmobiliarias.");
        } catch (Exception e) {
            System.err.println("Cleanup note: " + e.getMessage());
        }
    }
}
