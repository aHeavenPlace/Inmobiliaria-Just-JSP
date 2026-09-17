package com.inmobiliariavesta.controller;

import com.inmobiliariavesta.util.FileUploadUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Servlet para servir imágenes y archivos estáticos desde /uploads/*
 * Busca primero en el directorio de la aplicación y luego en el almacenamiento persistente (~/.inmobiliariavesta/uploads).
 */
@WebServlet(name = "UploadServlet", urlPatterns = {"/uploads/*"})
public class UploadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.trim().isEmpty() || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Sanitización para prevenir Path Traversal
        Path requestedPath = Paths.get(pathInfo).normalize();
        if (requestedPath.startsWith("..") || pathInfo.contains("..")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ruta no permitida");
            return;
        }

        Path targetFile = null;

        // 1. Buscar en almacenamiento persistente de usuario (~/.inmobiliariavesta/uploads + pathInfo)
        Path persistentFile = FileUploadUtil.PERSISTENT_DIR.resolve(requestedPath.toString().startsWith("/") || requestedPath.toString().startsWith("\\") 
                ? requestedPath.toString().substring(1) : requestedPath.toString());
        if (Files.exists(persistentFile) && Files.isRegularFile(persistentFile)) {
            targetFile = persistentFile;
        }

        // 2. Si no se encontró, buscar en el realPath del webapp (war descomprimido)
        if (targetFile == null) {
            String realPath = getServletContext().getRealPath("/uploads" + pathInfo);
            if (realPath != null) {
                Path webappFile = Paths.get(realPath);
                if (Files.exists(webappFile) && Files.isRegularFile(webappFile)) {
                    targetFile = webappFile;
                }
            }
        }

        if (targetFile == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Imagen no encontrada");
            return;
        }

        // Determinar Content-Type
        String fileName = targetFile.getFileName().toString().toLowerCase();
        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null) {
            if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) contentType = "image/jpeg";
            else if (fileName.endsWith(".png")) contentType = "image/png";
            else if (fileName.endsWith(".webp")) contentType = "image/webp";
            else if (fileName.endsWith(".gif")) contentType = "image/gif";
            else contentType = "application/octet-stream";
        }

        response.setContentType(contentType);
        response.setHeader("Cache-Control", "public, max-age=86400"); // 1 día de caché
        response.setContentLengthLong(Files.size(targetFile));

        try (OutputStream out = response.getOutputStream()) {
            Files.copy(targetFile, out);
        }
    }
}
