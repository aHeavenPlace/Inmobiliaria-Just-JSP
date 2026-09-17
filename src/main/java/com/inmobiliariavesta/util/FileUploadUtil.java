package com.inmobiliariavesta.util;

import jakarta.servlet.http.Part;
import java.io.*;
import java.nio.file.*;
import java.util.UUID;

/**
 * Utilidad robusta para subir archivos de imágenes (fotos de perfil y propiedades)
 * Almacena en ruta persistente de usuario (~/.inmobiliariavesta/uploads) y en el realPath de Tomcat.
 */
public class FileUploadUtil {
    
    // Usar /var/tmp para persistencia entre redespliegues de WAR — user.home apunta a /usr/share/tomcat10 bajo Tomcat y no es escribible
    public static final Path PERSISTENT_DIR;
    static {
        Path dir;
        try {
            // Intentar primero en el directorio home del usuario real
            Path homeDir = Paths.get(System.getProperty("user.home"), ".inmobiliariavesta", "uploads");
            java.nio.file.Files.createDirectories(homeDir);
            // Verificar que se puede escribir
            Path testFile = homeDir.resolve(".write_test");
            java.nio.file.Files.writeString(testFile, "test");
            java.nio.file.Files.deleteIfExists(testFile);
            dir = homeDir;
        } catch (Exception e) {
            // Fallback a /var/tmp que es siempre escribible
            dir = Paths.get("/var/tmp", "inmobiliariavesta", "uploads");
            try {
                java.nio.file.Files.createDirectories(dir);
            } catch (Exception ex) {
                System.err.println("[FileUploadUtil] CRITICAL: No se pudo crear directorio persistente: " + ex.getMessage());
            }
        }
        PERSISTENT_DIR = dir;
        System.out.println("[FileUploadUtil] Directorio persistente de uploads: " + PERSISTENT_DIR);
    }
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final String[] ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "gif", "webp"};
    
    /**
     * Guarda una imagen tanto en el almacenamiento persistente como en el contexto de la webapp.
     * @param part Archivo cargado
     * @param subfolder Subcarpeta (e.g. "perfiles" o "propiedades")
     * @param webappUploadPath Ruta del ServletContext getRealPath("/uploads/...")
     * @return Nombre del archivo único generado
     */
    public static String saveImageDual(Part part, String subfolder, String webappUploadPath) {
        if (part == null || part.getSize() == 0) {
            return null;
        }

        try {
            if (part.getSize() > MAX_FILE_SIZE) {
                throw new IllegalArgumentException("El archivo excede el tamaño máximo permitido de 10MB");
            }

            String submittedName = part.getSubmittedFileName();
            if (submittedName == null || submittedName.isBlank()) {
                return null;
            }

            String fileName = Paths.get(submittedName).getFileName().toString();
            String extension = getFileExtension(fileName);

            if (!isAllowedExtension(extension)) {
                throw new IllegalArgumentException("Tipo de archivo no permitido. Solo se aceptan imágenes JPG, PNG, GIF o WEBP");
            }

            String uniqueFileName = UUID.randomUUID().toString() + "_" + System.currentTimeMillis() + "." + extension;

            // 1. Guardar en almacenamiento persistente (~/.inmobiliariavesta/uploads/subfolder)
            Path persistentSubdir = PERSISTENT_DIR.resolve(subfolder);
            Files.createDirectories(persistentSubdir);
            Path persistentFile = persistentSubdir.resolve(uniqueFileName);

            byte[] bytes;
            try (InputStream input = part.getInputStream()) {
                bytes = input.readAllBytes();
            }

            Files.write(persistentFile, bytes, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);

            // 2. Guardar en carpeta del webapp si está disponible
            if (webappUploadPath != null && !webappUploadPath.isBlank()) {
                try {
                    Path webappSubdir = Paths.get(webappUploadPath);
                    Files.createDirectories(webappSubdir);
                    Path webappFile = webappSubdir.resolve(uniqueFileName);
                    Files.write(webappFile, bytes, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
                } catch (Exception e) {
                    System.err.println("[FileUploadUtil] Advertencia al escribir en webapp realPath: " + e.getMessage());
                }
            }

            return uniqueFileName;

        } catch (IOException e) {
            throw new RuntimeException("Error al procesar y guardar la imagen: " + e.getMessage(), e);
        }
    }

    /**
     * Guarda una imagen en la carpeta especificada
     */
    public static String saveImage(Part part, String uploadPath) {
        if (part == null || part.getSize() == 0) return null;
        String subfolder = "general";
        if (uploadPath != null) {
            if (uploadPath.contains("perfiles")) subfolder = "perfiles";
            else if (uploadPath.contains("propiedades")) subfolder = "propiedades";
        }
        return saveImageDual(part, subfolder, uploadPath);
    }
    
    /**
     * Obtiene la extensión de un archivo
     */
    private static String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf(".");
        if (lastDotIndex == -1 || lastDotIndex == fileName.length() - 1) {
            return "";
        }
        return fileName.substring(lastDotIndex + 1).toLowerCase();
    }
    
    /**
     * Valida si la extensión está permitida
     */
    public static boolean isAllowedExtension(String extension) {
        if (extension == null) return false;
        for (String allowed : ALLOWED_EXTENSIONS) {
            if (allowed.equalsIgnoreCase(extension)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Elimina un archivo de imagen en ambos almacenamientos
     */
    public static boolean deleteImage(String subfolder, String fileName, String webappUploadPath) {
        if (fileName == null || fileName.isEmpty()) return false;
        boolean deleted = false;

        // Eliminar de persistente
        try {
            Path persistentFile = PERSISTENT_DIR.resolve(subfolder).resolve(fileName);
            deleted = Files.deleteIfExists(persistentFile) || deleted;
        } catch (Exception ignored) {}

        // Eliminar de webapp
        if (webappUploadPath != null) {
            try {
                Path webappFile = Paths.get(webappUploadPath, fileName);
                deleted = Files.deleteIfExists(webappFile) || deleted;
            } catch (Exception ignored) {}
        }

        return deleted;
    }

    public static boolean deleteImage(String uploadPath, String fileName) {
        String subfolder = "general";
        if (uploadPath != null) {
            if (uploadPath.contains("perfiles")) subfolder = "perfiles";
            else if (uploadPath.contains("propiedades")) subfolder = "propiedades";
        }
        return deleteImage(subfolder, fileName, uploadPath);
    }
}
