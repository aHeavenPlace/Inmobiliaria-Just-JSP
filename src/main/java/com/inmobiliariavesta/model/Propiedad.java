package com.inmobiliariavesta.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Propiedad implements Serializable {
    private static final long serialVersionUID = 1L;

    private int idPropiedad;
    private int idInmobiliaria;
    private int idCiudad;
    private int idTipo;
    private String matriculaInmobiliaria;
    private String titulo;
    private String descripcion;
    private String direccion;
    private BigDecimal precio;
    private BigDecimal areaM2;
    private int habitaciones;
    private int banos;
    private String tipoOperacion; // 'venta', 'arriendo'
    private String estado;        // 'disponible', 'vendido', 'arrendado', 'inactivo'
    private Timestamp fechaPublicacion;

    // Campos enriquecidos por JOINs
    private String ciudadNombre;
    private String departamentoNombre;
    private String tipoNombre;
    private String inmobiliariaNombre;
    private String inmobiliariaTelefono;
    private String imagenPrincipal;
    private boolean esFavorito;

    // Colecciones asociadas
    private List<ImagenPropiedad> imagenes = new ArrayList<>();
    private List<Caracteristica> caracteristicas = new ArrayList<>();

    public Propiedad() {}

    public int getIdPropiedad() { return idPropiedad; }
    public void setIdPropiedad(int idPropiedad) { this.idPropiedad = idPropiedad; }

    public int getIdInmobiliaria() { return idInmobiliaria; }
    public void setIdInmobiliaria(int idInmobiliaria) { this.idInmobiliaria = idInmobiliaria; }

    public int getIdCiudad() { return idCiudad; }
    public void setIdCiudad(int idCiudad) { this.idCiudad = idCiudad; }

    public int getIdTipo() { return idTipo; }
    public void setIdTipo(int idTipo) { this.idTipo = idTipo; }

    public String getMatriculaInmobiliaria() { return matriculaInmobiliaria; }
    public void setMatriculaInmobiliaria(String matriculaInmobiliaria) { this.matriculaInmobiliaria = matriculaInmobiliaria; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }

    public BigDecimal getPrecio() { return precio; }
    public void setPrecio(BigDecimal precio) { this.precio = precio; }

    public String getPrecioFormateado() {
        if (precio == null) return "$0";
        NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
        nf.setMaximumFractionDigits(0);
        return nf.format(precio);
    }

    public BigDecimal getAreaM2() { return areaM2; }
    public void setAreaM2(BigDecimal areaM2) { this.areaM2 = areaM2; }

    public int getHabitaciones() { return habitaciones; }
    public void setHabitaciones(int habitaciones) { this.habitaciones = habitaciones; }

    public int getBanos() { return banos; }
    public void setBanos(int banos) { this.banos = banos; }

    public String getTipoOperacion() { return tipoOperacion; }
    public void setTipoOperacion(String tipoOperacion) { this.tipoOperacion = tipoOperacion; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Timestamp getFechaPublicacion() { return fechaPublicacion; }
    public void setFechaPublicacion(Timestamp fechaPublicacion) { this.fechaPublicacion = fechaPublicacion; }

    public String getCiudadNombre() { return ciudadNombre; }
    public void setCiudadNombre(String ciudadNombre) { this.ciudadNombre = ciudadNombre; }

    public String getDepartamentoNombre() { return departamentoNombre; }
    public void setDepartamentoNombre(String departamentoNombre) { this.departamentoNombre = departamentoNombre; }

    public String getTipoNombre() { return tipoNombre; }
    public void setTipoNombre(String tipoNombre) { this.tipoNombre = tipoNombre; }

    public String getInmobiliariaNombre() { return inmobiliariaNombre; }
    public void setInmobiliariaNombre(String inmobiliariaNombre) { this.inmobiliariaNombre = inmobiliariaNombre; }

    public String getInmobiliariaTelefono() { return inmobiliariaTelefono; }
    public void setInmobiliariaTelefono(String inmobiliariaTelefono) { this.inmobiliariaTelefono = inmobiliariaTelefono; }

    public String getImagenPrincipal() {
        if (imagenPrincipal != null && !imagenPrincipal.isBlank()) return imagenPrincipal;
        if (imagenes != null && !imagenes.isEmpty()) return imagenes.get(0).getUrl();
        return "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800";
    }

    public String getImagenPrincipalUrl(String contextPath) {
        String img = getImagenPrincipal();
        if (img == null || img.isBlank()) return "";
        if (img.startsWith("http://") || img.startsWith("https://")) return img;
        if (contextPath == null || contextPath.isEmpty()) return img;
        return contextPath + (img.startsWith("/") ? "" : "/") + img;
    }

    public void setImagenPrincipal(String imagenPrincipal) { this.imagenPrincipal = imagenPrincipal; }

    public boolean isEsFavorito() { return esFavorito; }
    public void setEsFavorito(boolean esFavorito) { this.esFavorito = esFavorito; }

    public List<ImagenPropiedad> getImagenes() { return imagenes; }
    public void setImagenes(List<ImagenPropiedad> imagenes) { this.imagenes = imagenes; }

    public List<Caracteristica> getCaracteristicas() { return caracteristicas; }
    public void setCaracteristicas(List<Caracteristica> caracteristicas) { this.caracteristicas = caracteristicas; }
}
