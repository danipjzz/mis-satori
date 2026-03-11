CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    correo VARCHAR(100),
    telefono VARCHAR(20)
);
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id),
    fecha_registro TIMESTAMP,
    fecha_entrega DATE,
    hora_entrega TIME,
    tipo_pedido VARCHAR(50),
    tipo_torta VARCHAR(50),
    peso_torta VARCHAR(20),
    sabor_ponque VARCHAR(50),
    relleno_base VARCHAR(100),
    relleno_especial VARCHAR(100),
    tipo_torta_especial VARCHAR(100),
    estado VARCHAR(50) DEFAULT 'pendiente'
);
CREATE TABLE minipostres (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);
CREATE TABLE pedido_postres (
    id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedidos(id),
    postre_id INT REFERENCES minipostres(id)
);