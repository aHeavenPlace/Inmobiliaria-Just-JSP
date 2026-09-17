package com.inmobiliariavesta.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static HikariDataSource dataSource;
    private static Properties dbProps = new Properties();

    static {
        try {
            // Cargar archivo db.properties
            try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    dbProps.load(input);
                } else {
                    System.err.println("[DBConnection] Archivo db.properties no encontrado, usando valores por defecto.");
                }
            }

            Class.forName("org.postgresql.Driver");

            String host = dbProps.getProperty("db.host", "aws-0-us-east-2.pooler.supabase.com");
            String port = dbProps.getProperty("db.port", "6543");
            String dbName = dbProps.getProperty("db.name", "postgres");
            String user = dbProps.getProperty("db.user", "postgres.ymfqanafhpayxvxvsrhw");
            String pass = dbProps.getProperty("db.password", "parcialJava1");

            String jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s?sslmode=require&prepareThreshold=0", host, port, dbName);

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl);
            config.setUsername(user);
            config.setPassword(pass);
            config.setDriverClassName("org.postgresql.Driver");

            // Pool settings
            config.setMaximumPoolSize(Integer.parseInt(dbProps.getProperty("pool.maximumPoolSize", "10")));
            config.setMinimumIdle(Integer.parseInt(dbProps.getProperty("pool.minimumIdle", "2")));
            config.setIdleTimeout(Long.parseLong(dbProps.getProperty("pool.idleTimeout", "30000")));
            config.setConnectionTimeout(Long.parseLong(dbProps.getProperty("pool.connectionTimeout", "20000")));
            config.setMaxLifetime(Long.parseLong(dbProps.getProperty("pool.maxLifetime", "1800000")));
            config.setPoolName("InmobiliariaVestaHikariPool");

            dataSource = new HikariDataSource(config);
            System.out.println("[DBConnection] Pool HikariCP inicializado exitosamente conectado a Supabase.");

        } catch (Exception e) {
            System.err.println("[DBConnection] Error inicializando HikariCP: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private DBConnection() {}

    /**
     * Obtiene una conexión activa a la base de datos PostgreSQL en Supabase.
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource != null && !dataSource.isClosed()) {
            return dataSource.getConnection();
        }

        // Fallback directo con DriverManager si el pool no estuviera disponible
        String host = dbProps.getProperty("db.host", "aws-0-us-east-2.pooler.supabase.com");
        String port = dbProps.getProperty("db.port", "6543");
        String dbName = dbProps.getProperty("db.name", "postgres");
        String user = dbProps.getProperty("db.user", "postgres.ymfqanafhpayxvxvsrhw");
        String pass = dbProps.getProperty("db.password", "parcialJava1");
        String jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s?sslmode=require&prepareThreshold=0", host, port, dbName);

        return DriverManager.getConnection(jdbcUrl, user, pass);
    }

    public static void closePool() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            System.out.println("[DBConnection] Pool HikariCP cerrado.");
        }
    }
}
