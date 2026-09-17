-- ============================================
-- VESTA INMOBILIARIA - Script DML
-- Sprint 1 - Datos de Prueba
-- ============================================

DELETE FROM auditoria;
DELETE FROM documento_solicitud;
DELETE FROM solicitud;
DELETE FROM cita;
DELETE FROM favorito;
DELETE FROM propiedad_caracteristica;
DELETE FROM imagen_propiedad;
DELETE FROM propiedad;
DELETE FROM caracteristica;
DELETE FROM tipo_propiedad;
DELETE FROM ciudad;
DELETE FROM inmobiliaria;
DELETE FROM perfil;
DELETE FROM usuario_rol;
DELETE FROM usuario;
DELETE FROM rol;

ALTER SEQUENCE rol_id_rol_seq RESTART WITH 1;
ALTER SEQUENCE usuario_id_usuario_seq RESTART WITH 1;
ALTER SEQUENCE perfil_id_perfil_seq RESTART WITH 1;
ALTER SEQUENCE inmobiliaria_id_inmobiliaria_seq RESTART WITH 1;
ALTER SEQUENCE ciudad_id_ciudad_seq RESTART WITH 1;
ALTER SEQUENCE tipo_propiedad_id_tipo_seq RESTART WITH 1;
ALTER SEQUENCE propiedad_id_propiedad_seq RESTART WITH 1;
ALTER SEQUENCE caracteristica_id_caracteristica_seq RESTART WITH 1;
ALTER SEQUENCE imagen_propiedad_id_imagen_seq RESTART WITH 1;
ALTER SEQUENCE cita_id_cita_seq RESTART WITH 1;
ALTER SEQUENCE solicitud_id_solicitud_seq RESTART WITH 1;
ALTER SEQUENCE favorito_id_favorito_seq RESTART WITH 1;

-- Roles
INSERT INTO rol (nombre, descripcion) VALUES
('admin', 'Administrador del sistema con acceso total'),
('inmobiliaria', 'Agente inmobiliario que publica y gestiona propiedades'),
('cliente', 'Cliente que busca propiedades y agenda citas'),
('visitante', 'Usuario no autenticado con acceso público limitado');

-- Usuarios (contraseñas: admin123, inmobiliaria123, cliente123)
INSERT INTO usuario (correo, password_hash, estado, ultimo_acceso) VALUES
('admin@vesta.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'activo', CURRENT_TIMESTAMP),
('carlos@inmobiliaria.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('maria@inmobiliaria.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '2 days'),
('pedro@inmobiliaria.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '3 days'),
('juan@cliente.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('ana@cliente.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '4 days'),
('luis@cliente.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '5 days'),
('carmen@cliente.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '6 days'),
('diego@cliente.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '7 days'),
('laura@cliente.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '8 days'),
('miguel@cliente.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '9 days'),
('sofia@cliente.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'activo', CURRENT_TIMESTAMP - INTERVAL '10 days'),
('inactivo@test.com', '$2a$10$EqKcp1WFKAr3Bo8M3YR6N.XGFt3Ei9HGBOQmW7fjBHvJ9gZdL5mKy', 'inactivo', NULL);

-- Asignación de Roles
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
(1, 1),
(2, 3), (2, 2),
(3, 2),
(4, 2),
(5, 3),
(6, 3),
(7, 3),
(8, 3),
(9, 3),
(10, 3),
(11, 3),
(12, 3),
(13, 3);

-- Perfiles
INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion, foto_url) VALUES
(1, 'Super', 'Administrador', '1000000001', '3001000001', 'Calle 1 #1-1, Bucaramanga', NULL),
(2, 'Carlos', 'Ramírez', '1020304050', '3101234567', 'Carrera 15 #27-30, Bucaramanga', NULL),
(3, 'María', 'González', '1020304051', '3112345678', 'Calle 45 #20-15, Bucaramanga', NULL),
(4, 'Pedro', 'Martínez', '1020304052', '3123456789', 'Av. Quebrada Seca #32-10, Bucaramanga', NULL),
(5, 'Juan', 'Pérez', '1024567890', '3134567890', 'Calle 50 #10-20, Bucaramanga', NULL),
(6, 'Ana', 'López', '1024567891', '3145678901', 'Carrera 27 #45-12, Bucaramanga', NULL),
(7, 'Luis', 'García', '1024567892', '3156789012', 'Calle 35 #18-40, Floridablanca', NULL),
(8, 'Carmen', 'Rodríguez', '1024567893', '3167890123', 'Av. Libertad #20-50, Girón', NULL),
(9, 'Diego', 'Hernández', '1024567894', '3178901234', 'Calle 100 #15-30, Piedecuesta', NULL),
(10, 'Laura', 'Torres', '1024567895', '3189012345', 'Carrera 33 #50-25, Bucaramanga', NULL),
(11, 'Miguel', 'Sánchez', '1024567896', '3190123456', 'Calle 60 #25-10, Bucaramanga', NULL),
(12, 'Sofía', 'Castro', '1024567897', '3201234567', 'Av. Principal #5-100, Floridablanca', NULL),
(13, 'Usuario', 'Inactivo', '9999999999', '3000000000', 'Dirección desconocida', NULL);

-- Inmobiliarias
INSERT INTO inmobiliaria (nombre, nit, telefono, correo_contacto, direccion, logo_url, estado) VALUES
('Vesta Inmobiliaria SAS', '900.123.456-7', '6071234567', 'contacto@vesta.com', 'Carrera 15 #27-30, Bucaramanga', NULL, 'activo'),
('Hogar Verde Inmobiliaria', '900.234.567-8', '6072345678', 'info@hogarverde.com', 'Calle 45 #20-15, Bucaramanga', NULL, 'activo'),
('Casa Propia Inmobiliaria', '900.345.678-9', '6073456789', 'ventas@casapropia.com', 'Av. Quebrada Seca #32-10, Bucaramanga', NULL, 'activo');

-- Ciudades
INSERT INTO ciudad (nombre, departamento, codigo_postal) VALUES
('Bucaramanga', 'Santander', '680001'),
('Floridablanca', 'Santander', '681002'),
('Girón', 'Santander', '681003'),
('Piedecuesta', 'Santander', '681004'),
('Bogotá', 'Cundinamarca', '110001'),
('Medellín', 'Antioquia', '050001'),
('Cali', 'Valle del Cauca', '760001');

-- Tipos de Propiedad
INSERT INTO tipo_propiedad (nombre, descripcion) VALUES
('Casa', 'Vivienda unifamiliar independiente'),
('Apartamento', 'Vivienda en edificio multifamiliar'),
('Local', 'Espacio comercial para negocios'),
('Oficina', 'Espacio para trabajo profesional'),
('Terreno', 'Lote para construcción o inversión');

-- Propiedades
INSERT INTO propiedad (id_inmobiliaria, id_ciudad, id_tipo, matricula_inmobiliaria, titulo, descripcion, direccion, precio, area_m2, habitaciones, banos, tipo_operacion, estado) VALUES
(1, 1, 1, 'MAT-2024-001', 'Casa moderna en Cabecera del Llano', 'Hermosa casa de 3 pisos con jardín, garaje doble y zona de BBQ. Acabados de primera calidad.', 'Calle 50 #25-30, Bucaramanga', 450000000.00, 180.00, 4, 3, 'venta', 'disponible'),
(1, 1, 2, 'MAT-2024-002', 'Apartamento en El Laguito', 'Apartamento luminoso con vista panorámica, balcón y parqueadero. Cerca a centros comerciales.', 'Carrera 27 #48-15, Bucaramanga', 280000000.00, 85.00, 3, 2, 'venta', 'disponible'),
(1, 2, 2, 'MAT-2024-003', 'Apartamento en Cañaveral', 'Moderno apartamento en conjunto cerrado con piscina, gimnasio y zonas verdes.', 'Av. Cañaveral #150-20, Floridablanca', 320000000.00, 95.00, 3, 2, 'venta', 'disponible'),
(2, 1, 3, 'MAT-2024-004', 'Local comercial en el Centro', 'Local amplio en zona de alto tráfico, ideal para comercio o restaurante.', 'Calle 35 #15-40, Bucaramanga', 180000000.00, 120.00, 0, 1, 'venta', 'disponible'),
(2, 1, 4, 'MAT-2024-005', 'Oficina en Torre Empresarial', 'Oficina equipada con sala de juntas, recepción y parqueaderos privados.', 'Carrera 15 #30-20, Bucaramanga', 3500000.00, 60.00, 0, 2, 'arriendo', 'disponible'),
(2, 3, 1, 'MAT-2024-006', 'Casa colonial en Girón', 'Casa histórica restaurada con patio interior, techos altos y acabados originales.', 'Calle 28 #12-15, Girón', 380000000.00, 220.00, 5, 4, 'venta', 'disponible'),
(3, 4, 5, 'MAT-2024-007', 'Terreno en Piedecuesta', 'Lote plano con todos los servicios públicos, ideal para proyecto residencial.', 'Vereda El Refugio, Piedecuesta', 120000000.00, 500.00, 0, 0, 'venta', 'disponible'),
(1, 1, 2, 'MAT-2024-008', 'Apartamento en Arriendo - Sotomayor', 'Apartamento amoblado, perfecto para ejecutivos. Incluye servicios.', 'Calle 45 #20-10, Bucaramanga', 1800000.00, 70.00, 2, 2, 'arriendo', 'disponible'),
(3, 5, 2, 'MAT-2024-009', 'Apartamento en Chapinero - Bogotá', 'Apartamento remodelado en zona exclusiva, cerca a Transmilenio.', 'Carrera 13 #90-15, Bogotá', 520000000.00, 110.00, 3, 3, 'venta', 'disponible'),
(2, 6, 1, 'MAT-2024-010', 'Casa en El Poblado - Medellín', 'Casa moderna con piscina, vista a la ciudad y garaje para 3 carros.', 'Calle 10 Sur #35-50, Medellín', 850000000.00, 280.00, 5, 5, 'venta', 'disponible'),
(1, 1, 2, 'MAT-2024-011', 'Apartamento vendido - ejemplo', 'Este apartamento ya fue vendido (para probar estados).', 'Calle 60 #30-20, Bucaramanga', 295000000.00, 88.00, 3, 2, 'venta', 'vendido'),
(3, 7, 4, 'MAT-2024-012', 'Oficina en El Peñón - Cali', 'Oficina en edificio inteligente con certificación LEED.', 'Av. Roosevelt #40-50, Cali', 4200000.00, 75.00, 0, 2, 'arriendo', 'disponible');

-- Características
INSERT INTO caracteristica (nombre, descripcion) VALUES
('Piscina', 'Piscina privada o compartida'),
('Parqueadero', 'Parqueadero cubierto o descubierto'),
('Ascensor', 'Edificio con ascensor'),
('Gimnasio', 'Gimnasio en el conjunto o cercano'),
('Jardín', 'Jardín privado o zonas verdes'),
('Balcon', 'Balcón o terraza'),
('Aire acondicionado', 'Sistema de aire acondicionado'),
('Calefacción', 'Sistema de calefacción'),
('Seguridad 24/7', 'Vigilancia las 24 horas'),
('Amoblado', 'Inmueble completamente amoblado'),
('Mascotas permitidas', 'Se permiten mascotas'),
('Zona de BBQ', 'Área de parrilla o BBQ');

-- Propiedad - Características
INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES
(1, 1), (1, 2), (1, 5), (1, 12),
(2, 2), (2, 3), (2, 4), (2, 6),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5),
(4, 2),
(5, 2), (5, 3), (5, 4), (5, 7),
(6, 5), (6, 12),
(8, 2), (8, 7), (8, 10),
(9, 2), (9, 3), (9, 4), (9, 6),
(10, 1), (10, 2), (10, 5), (10, 12),
(11, 2), (11, 3),
(12, 2), (12, 3), (12, 4), (12, 7);

-- Imágenes
INSERT INTO imagen_propiedad (id_propiedad, url, descripcion, orden) VALUES
(1, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800', 'Fachada principal', 1),
(1, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800', 'Sala principal', 2),
(1, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800', 'Cocina moderna', 3),
(2, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800', 'Vista desde balcón', 1),
(2, 'https://images.unsplash.com/photo-1560448204-e02f11c3fa0e?w=800', 'Sala-comedor', 2),
(3, 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800', 'Fachada edificio', 1),
(3, 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800', 'Piscina del conjunto', 2),
(4, 'https://images.unsplash.com/photo-1582037928769-181f294ec1f9?w=800', 'Local comercial', 1),
(5, 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800', 'Oficina principal', 1),
(5, 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800', 'Sala de juntas', 2),
(6, 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800', 'Casa colonial', 1),
(7, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800', 'Terreno amplio', 1),
(8, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800', 'Apartamento amoblado', 1),
(9, 'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=800', 'Apartamento Bogotá', 1),
(10, 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800', 'Casa con piscina', 1),
(10, 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800', 'Vista panorámica', 2);

-- Citas
INSERT INTO cita (id_propiedad, id_cliente, fecha_hora, estado, notas) VALUES
(1, 5, '2026-09-10 10:00:00', 'confirmada', 'Cliente interesado en comprar'),
(1, 6, '2026-09-10 15:00:00', 'pendiente', 'Primera visita'),
(2, 7, '2026-09-11 09:00:00', 'confirmada', 'Quiere ver el balcón'),
(3, 8, '2026-09-12 14:00:00', 'pendiente', 'Interesada en la piscina'),
(5, 9, '2026-09-13 11:00:00', 'realizada', 'Ya visitó la oficina'),
(6, 10, '2026-09-14 16:00:00', 'cancelada', 'Canceló por viaje'),
(9, 11, '2026-09-15 10:00:00', 'pendiente', 'Viaja desde Bucaramanga'),
(10, 12, '2026-09-16 13:00:00', 'pendiente', 'Quiere ver la piscina');

-- Solicitudes
INSERT INTO solicitud (id_propiedad, id_cliente, tipo, estado, comentarios) VALUES
(1, 5, 'compra', 'aprobada', 'Cliente con crédito aprobado'),
(2, 6, 'compra', 'en_revision', 'Pendiente revisión de documentos'),
(3, 7, 'compra', 'pendiente', 'Primera solicitud'),
(5, 8, 'arriendo', 'aprobada', 'Contrato firmado'),
(8, 9, 'arriendo', 'en_revision', 'Falta certificado laboral'),
(9, 10, 'compra', 'rechazada', 'No cumple requisitos financieros'),
(10, 11, 'compra', 'pendiente', 'Alto interés');

-- Documentos de Solicitud
INSERT INTO documento_solicitud (id_solicitud, nombre_archivo, url, tipo_documento) VALUES
(1, 'cedula_juan.pdf', '/uploads/docs/cedula_juan.pdf', 'Cédula'),
(1, 'certificado_laboral.pdf', '/uploads/docs/certificado_juan.pdf', 'Certificado laboral'),
(2, 'cedula_ana.pdf', '/uploads/docs/cedula_ana.pdf', 'Cédula'),
(3, 'cedula_luis.pdf', '/uploads/docs/cedula_luis.pdf', 'Cédula'),
(4, 'cedula_carmen.pdf', '/uploads/docs/cedula_carmen.pdf', 'Cédula'),
(4, 'extracto_bancario.pdf', '/uploads/docs/extracto_carmen.pdf', 'Extracto bancario'),
(5, 'cedula_diego.pdf', '/uploads/docs/cedula_diego.pdf', 'Cédula'),
(7, 'cedula_miguel.pdf', '/uploads/docs/cedula_miguel.pdf', 'Cédula');

-- Favoritos
INSERT INTO favorito (id_usuario, id_propiedad) VALUES
(5, 1), (5, 3), (5, 10),
(6, 2), (6, 9),
(7, 3), (7, 6),
(8, 5), (8, 8),
(9, 1), (9, 10),
(10, 6),
(11, 1), (11, 2), (11, 3), (11, 10),
(12, 10);

-- Auditoría
INSERT INTO auditoria (id_usuario, accion, tabla_afectada, registro_id, ip_address) VALUES
(1, 'LOGIN', 'usuario', 1, '192.168.1.100'),
(2, 'INSERT', 'propiedad', 1, '192.168.1.101'),
(5, 'UPDATE', 'perfil', 5, '192.168.1.102'),
(3, 'INSERT', 'propiedad', 4, '192.168.1.103'),
(6, 'INSERT', 'cita', 1, '192.168.1.104'),
(1, 'DELETE', 'propiedad', 11, '192.168.1.100');
