-- =============================================================================
-- PROYECTO: Sistema de Detección de Fraude en Transacciones Bancarias
-- ARCHIVO: sql/02_seed_dml.sql
-- =============================================================================

USE PDAN_bs_sistema_riesgo_crediticio;
GO

-- 1. ANALISTAS DE SEGURIDAD
INSERT INTO Analista (ID_Empleado, Nombres, Apellidos, Cargo, correo_corporativo) VALUES
('EMP-9001', 'Carlos', 'Mendoza Paredes', 'Analista Senior de Fraudes', 'cmendoza@securebank.pe'),
('EMP-9002', 'Valeria', 'Ríos Castillo', 'Analista de Riesgo Operativo', 'vrios@securebank.pe');

-- 2. CLIENTES
INSERT INTO Cliente (Cliente_DNI, Nombres, Apellidos, Fecha_nacimiento, Correo_electronico, Numero_telefonico, Direccion) VALUES
('72819203', 'Gian Carlo', 'Valdivia Minchola', '1998-05-14', 'giancarlo.valdivia@email.com', '944123456', 'Av. Larco 456, Trujillo'),
('45123890', 'María Fe', 'Sánchez Torres', '1990-11-22', 'maria.sanchez@email.com', '981112233', 'Calle Las Flores 123, Lima'),
('10928374', 'Roberto', 'Gómez Bolaños', '1985-03-30', 'roberto.gomez@email.com', '977554433', 'Jr. Pizarro 789, Trujillo');

-- 3. CUENTAS BANCARIAS
INSERT INTO Cuenta (Num_cuenta, Tipo_cuenta, Saldo_disponible, Estado_cuenta, fecha_apertura, Cliente_DNI) VALUES
('191-45678901-0-12', 'Ahorros', 8500.00, 'Activa', '2023-01-15', '72819203'),
('191-98765432-0-99', 'Corriente', 15000.00, 'Activa', '2023-06-20', '72819203'),
('193-11223344-0-01', 'Ahorros', 3200.50, 'Activa', '2022-09-10', '45123890'),
('191-55667788-0-55', 'Ahorros', 25000.00, 'Activa', '2021-04-05', '10928374');

-- 4. TARJETAS
INSERT INTO Tarjeta (Num_tarjeta, tipo_tarjeta, fecha_emision, fecha_vencimiento, Estado, Num_Cuenta) VALUES
('4557880011223344', 'Debito', '2023-01-15', '2028-12-31', 'Activa', '191-45678901-0-12'),
('5412880099887766', 'Credito', '2023-06-20', '2027-08-31', 'Activa', '191-98765432-0-99'),
('4557111122223333', 'Debito', '2022-09-10', '2026-05-31', 'Activa', '193-11223344-0-01');

-- 5. DISPOSITIVOS
INSERT INTO Dispositivo (ID_Hardware, ID_Cliente, Tipo_dispositivo, Sistema_operativo, Direccion_IP, Ubicacion) VALUES
('HW-SAMSUNG-S23', '72819203', 'Smartphone Samsung S23', 'Android 14', '190.235.12.45', 'Trujillo, Perú'),
('HW-LENOVO-T14', '72819203', 'Laptop Lenovo ThinkPad', 'Windows 11', '190.235.12.46', 'Trujillo, Perú'),
('HW-IPHONE-15', '45123890', 'iPhone 15 Pro', 'iOS 17', '200.62.140.10', 'Lima, Perú');

-- 6. TRANSACCIONES (Normales y Sospechosas)
INSERT INTO Transaccion (ID_transaccion, Tipo_transaccion, fecha_transaccion, hora_transaccion, monto_transaccion, Estado, canal_operacion, Num_Cuenta, Num_Tarjeta, ID_Hardware) VALUES
('TXN-1001', 'Compra con tarjeta', '2026-08-01', '10:15:00', 45.00, 'Aprobada', 'POS', '191-45678901-0-12', '4557880011223344', 'HW-SAMSUNG-S23'),
('TXN-1002', 'Transferencia', '2026-08-02', '14:30:00', 250.00, 'Aprobada', 'Web', '191-98765432-0-99', NULL, 'HW-LENOVO-T14'),
('TXN-1003', 'Transferencia', '2026-08-06', '11:00:00', 12500.00, 'En Revision', 'Web', '191-45678901-0-12', NULL, 'HW-LENOVO-T14'),
('TXN-1004', 'Retiro', '2026-08-06', '15:00:00', 2000.00, 'Aprobada', 'Cajero', '191-55667788-0-55', NULL, NULL),
('TXN-1005', 'Retiro', '2026-08-06', '15:01:30', 2000.00, 'Aprobada', 'Cajero', '191-55667788-0-55', NULL, NULL),
('TXN-1006', 'Retiro', '2026-08-06', '15:02:45', 2000.00, 'En Revision', 'Cajero', '191-55667788-0-55', NULL, NULL),
('TXN-1007', 'Pago en linea', '2026-08-06', '18:20:00', 3500.00, 'Bloqueada', 'Web', '193-11223344-0-01', '4557111122223333', NULL);

-- 7. ALERTAS GENERADAS
INSERT INTO Alerta_Fraude (ID_Alerta, Fecha, Hora, tipo_alerta, nivel_riesgo, Estado, ID_Transaccion) VALUES
('ALT-5001', '2026-08-06', '11:00:05', 'Monto Inusual', 'Medio', 'En Investigacion', 'TXN-1003'),
('ALT-5002', '2026-08-06', '15:03:00', 'Ráfaga de Retiros', 'Alto', 'Pendiente', 'TXN-1006'),
('ALT-5003', '2026-08-06', '18:20:01', 'Ubicación / IP Sospechosa', 'Alto', 'Resuelta', 'TXN-1007');

-- 8. REVISIÓN DE ALERTA
INSERT INTO Revision_Alerta (ID_Empleado, ID_Alerta, Fecha_revision, Hora_Revision) VALUES
('EMP-9001', 'ALT-5001', '2026-08-06', '11:30:00'),
('EMP-9001', 'ALT-5003', '2026-08-06', '18:25:00');

-- 9. INCIDENTE FORMAL REGISTRADO
INSERT INTO Incidente (ID_Incidente, ID_Alerta, Fecha_incidente, Hora_incidente, accion_tomada, Estado, Observaciones, ID_Empleado) VALUES
('INC-7001', 'ALT-5003', '2026-08-06', '18:30:00', 'Bloqueo Temporal', 'Cerrado Confirmado', 'Cliente confirmó no estar realizando compras web internacionales. Tarjeta bloqueada preventivamente.', 'EMP-9001');
GO