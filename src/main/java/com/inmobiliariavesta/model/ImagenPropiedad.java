package com.inmobiliariavesta.model;

import java.io.Serializable;

public class ImagenPropiedad implements Serializable {
    private static final long serialVersionUID = 1L;

    private int idImagen;
    private int idPropiedad;
    private String url;
    private String descripcion;
    private int orden;

    public ImagenPropiedad() {}

    public ImagenPropiedad(int idImagen, int idPropiedad, String url, String descripcion, int orden) {
        this.idImagen = idImagen;
        this.idPropiedad = idPropiedad;
        this.url = url;
        this.descripcion = descripcion;
        this.orden = orden;
    }

    public int getIdImagen() { return idImagen; }
    public void setIdImagen(int idImagen) { this.idImagen = idImagen; }

    public int getIdPropiedad() { return idPropiedad; }
    public void setIdPropiedad(int idPropiedad) { this.idPropiedad = idPropiedad; }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public int getOrden() { return orden; }
    public void setOrden(int orden) { this.orden = orden; }

    public String getUrlCompleta(String contextPath) {
        if (url == null || url.isBlank()) return "";
        if (url.startsWith("http://") || url.startsWith("https://")) return url;
        if (contextPath == null || contextPath.isEmpty()) return url;
        return contextPath + (url.startsWith("/") ? "" : "/") + url;
    }
}
