-- =============================================================================
-- PROYECTO: Sistema de Detección de Fraude en Transacciones Bancarias
-- AUTOR: Gian Carlo Duval Minchola Valdivia
-- MOTOR: Microsoft SQL Server 2019
-- BASE DE DATOS: PDAN_bs_sistema_riesgo_crediticio
-- ARCHIVO: sql/01_schema_ddl.sql
-- =============================================================================

USE master;
GO

-- Asegurar existencia de la base de datos
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'PDAN_bs_sistema_riesgo_crediticio')
BEGIN
    CREATE DATABASE PDAN_bs_sistema_riesgo_crediticio;
END;
GO

USE PDAN_bs_sistema_riesgo_crediticio;
GO

-- -----------------------------------------------------------------------------
-- LIMPIEZA DE TABLAS PREVIAS (Por si ejecutas el script múltiples veces)
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Incidente', 'U') IS NOT NULL DROP TABLE dbo.Incidente;
IF OBJECT_ID('dbo.Revision_Alerta', 'U') IS NOT NULL DROP TABLE dbo.Revision_Alerta;
IF OBJECT_ID('dbo.Alerta_Fraude', 'U') IS NOT NULL DROP TABLE dbo.Alerta_Fraude;
IF OBJECT_ID('dbo.Analista', 'U') IS NOT NULL DROP TABLE dbo.Analista;
IF OBJECT_ID('dbo.Transaccion', 'U') IS NOT NULL DROP TABLE dbo.Transaccion;
IF OBJECT_ID('dbo.Dispositivo', 'U') IS NOT NULL DROP TABLE dbo.Dispositivo;
IF OBJECT_ID('dbo.Tarjeta', 'U') IS NOT NULL DROP TABLE dbo.Tarjeta;
IF OBJECT_ID('dbo.Cuenta', 'U') IS NOT NULL DROP TABLE dbo.Cuenta;
IF OBJECT_ID('dbo.Cliente', 'U') IS NOT NULL DROP TABLE dbo.Cliente;
GO

-- -----------------------------------------------------------------------------
-- CREACIÓN DE TABLAS SEGÚN MODELO LÓGICO
-- -----------------------------------------------------------------------------

-- 1. TABLA: Cliente
CREATE TABLE Cliente (
    Cliente_DNI VARCHAR(15) PRIMARY KEY,
    Nombres VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    Fecha_nacimiento DATE NOT NULL,
    Correo_electronico VARCHAR(150) NOT NULL UNIQUE,
    Numero_telefonico VARCHAR(20) NOT NULL,
    Direccion VARCHAR(250) NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
);
GO

-- 2. TABLA: Cuenta
CREATE TABLE Cuenta (
    Num_cuenta VARCHAR(30) PRIMARY KEY,
    Tipo_cuenta VARCHAR(30) NOT NULL CHECK (Tipo_cuenta IN ('Ahorros', 'Corriente')),
    Saldo_disponible DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (Saldo_disponible >= 0.00),
    Estado_cuenta VARCHAR(20) NOT NULL DEFAULT 'Activa' CHECK (Estado_cuenta IN ('Activa', 'Bloqueada', 'Inactiva')),
    fecha_apertura DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Cliente_DNI VARCHAR(15) NOT NULL,
    CONSTRAINT FK_Cuenta_Cliente FOREIGN KEY (Cliente_DNI) REFERENCES Cliente(Cliente_DNI)
);
GO

-- 3. TABLA: Tarjeta
CREATE TABLE Tarjeta (
    Num_tarjeta VARCHAR(20) PRIMARY KEY,
    tipo_tarjeta VARCHAR(20) NOT NULL CHECK (tipo_tarjeta IN ('Debito', 'Credito')),
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Activa' CHECK (Estado IN ('Activa', 'Bloqueada', 'Vencida')),
    Num_Cuenta VARCHAR(30) NOT NULL,
    CONSTRAINT FK_Tarjeta_Cuenta FOREIGN KEY (Num_Cuenta) REFERENCES Cuenta(Num_cuenta)
);
GO

-- 4. TABLA: Dispositivo
CREATE TABLE Dispositivo (
    ID_Hardware VARCHAR(50) PRIMARY KEY,
    ID_Cliente VARCHAR(15) NOT NULL,
    Tipo_dispositivo VARCHAR(50) NOT NULL,
    Sistema_operativo VARCHAR(50) NOT NULL,
    Direccion_IP VARCHAR(45) NOT NULL,
    Ubicacion VARCHAR(100) NOT NULL,
    Fecha_acceso DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Hora_acceso TIME(0) NOT NULL DEFAULT CAST(GETDATE() AS TIME),
    CONSTRAINT FK_Dispositivo_Cliente FOREIGN KEY (ID_Cliente) REFERENCES Cliente(Cliente_DNI)
);
GO

-- 5. TABLA: Transaccion
CREATE TABLE Transaccion (
    ID_transaccion VARCHAR(30) PRIMARY KEY,
    Tipo_transaccion VARCHAR(40) NOT NULL 
        CHECK (Tipo_transaccion IN ('Transferencia', 'Pago en linea', 'Retiro', 'Deposito', 'Compra con tarjeta')),
    fecha_transaccion DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    hora_transaccion TIME(0) NOT NULL DEFAULT CAST(GETDATE() AS TIME),
    monto_transaccion DECIMAL(12,2) NOT NULL CHECK (monto_transaccion > 0.00),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Aprobada' 
        CHECK (Estado IN ('Aprobada', 'Rechazada', 'En Revision', 'Bloqueada')),
    canal_operacion VARCHAR(30) NOT NULL 
        CHECK (canal_operacion IN ('Web', 'App Movil', 'Cajero', 'POS', 'Ventanilla')),
    Num_Cuenta VARCHAR(30) NOT NULL,
    Num_Tarjeta VARCHAR(20) NULL,
    ID_Hardware VARCHAR(50) NULL,
    CONSTRAINT FK_Transaccion_Cuenta FOREIGN KEY (Num_Cuenta) REFERENCES Cuenta(Num_cuenta),
    CONSTRAINT FK_Transaccion_Tarjeta FOREIGN KEY (Num_Tarjeta) REFERENCES Tarjeta(Num_tarjeta),
    CONSTRAINT FK_Transaccion_Dispositivo FOREIGN KEY (ID_Hardware) REFERENCES Dispositivo(ID_Hardware)
);
GO

-- 6. TABLA: Analista
CREATE TABLE Analista (
    ID_Empleado VARCHAR(20) PRIMARY KEY,
    Nombres VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    Cargo VARCHAR(50) NOT NULL DEFAULT 'Analista de Riesgo y Fraude',
    correo_corporativo VARCHAR(150) NOT NULL UNIQUE
);
GO

-- 7. TABLA: Alerta_Fraude
CREATE TABLE Alerta_Fraude (
    ID_Alerta VARCHAR(30) PRIMARY KEY,
    Fecha DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Hora TIME(0) NOT NULL DEFAULT CAST(GETDATE() AS TIME),
    tipo_alerta VARCHAR(50) NOT NULL,
    nivel_riesgo VARCHAR(10) NOT NULL CHECK (nivel_riesgo IN ('Bajo', 'Medio', 'Alto')),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente' 
        CHECK (Estado IN ('Pendiente', 'En Investigacion', 'Resuelta', 'Falso Positivo')),
    ID_Transaccion VARCHAR(30) NOT NULL,
    CONSTRAINT FK_Alerta_Transaccion FOREIGN KEY (ID_Transaccion) REFERENCES Transaccion(ID_transaccion)
);
GO

-- 8. TABLA: Revision_Alerta
CREATE TABLE Revision_Alerta (
    ID_Empleado VARCHAR(20) NOT NULL,
    ID_Alerta VARCHAR(30) NOT NULL,
    Fecha_revision DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Hora_Revision TIME(0) NOT NULL DEFAULT CAST(GETDATE() AS TIME),
    CONSTRAINT PK_Revision_Alerta PRIMARY KEY (ID_Empleado, ID_Alerta, Fecha_revision, Hora_Revision),
    CONSTRAINT FK_Revision_Analista FOREIGN KEY (ID_Empleado) REFERENCES Analista(ID_Empleado),
    CONSTRAINT FK_Revision_Alerta FOREIGN KEY (ID_Alerta) REFERENCES Alerta_Fraude(ID_Alerta)
);
GO

-- 9. TABLA: Incidente
CREATE TABLE Incidente (
    ID_Incidente VARCHAR(30) PRIMARY KEY,
    ID_Alerta VARCHAR(30) NOT NULL UNIQUE,
    Fecha_incidente DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Hora_incidente TIME(0) NOT NULL DEFAULT CAST(GETDATE() AS TIME),
    accion_tomada VARCHAR(50) NOT NULL 
        CHECK (accion_tomada IN ('Bloqueo Temporal', 'Bloqueo Permanente', 'Contacto con Cliente', 'Sin Accion')),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Abierto' 
        CHECK (Estado IN ('Abierto', 'En Proceso', 'Cerrado Confirmado', 'Cerrado Desestimado')),
    Observaciones VARCHAR(500) NULL,
    ID_Empleado VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Incidente_Alerta FOREIGN KEY (ID_Alerta) REFERENCES Alerta_Fraude(ID_Alerta),
    CONSTRAINT FK_Incidente_Analista FOREIGN KEY (ID_Empleado) REFERENCES Analista(ID_Empleado)
);
GO

-- -----------------------------------------------------------------------------
-- ÍNDICES DE RENDIMIENTO
-- -----------------------------------------------------------------------------
CREATE INDEX IX_Transaccion_Cuenta_Fecha ON Transaccion(Num_Cuenta, fecha_transaccion, hora_transaccion);
CREATE INDEX IX_Alerta_Estado_Riesgo ON Alerta_Fraude(Estado, nivel_riesgo);
GO