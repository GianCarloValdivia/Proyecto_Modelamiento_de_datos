-- =============================================================================
-- PROYECTO: Sistema de Detección de Fraude en Transacciones Bancarias
-- ARCHIVO: sql/04_analytics_views.sql
-- DESCRIPCIÓN: Vistas SQL para monitoreo, reportes y tableros de control (KPIs)
-- =============================================================================

USE PDAN_bs_sistema_riesgo_crediticio;
GO

-- -----------------------------------------------------------------------------
-- VISTA 1: Bandeja de Trabajo de Alertas Pendientes para Analistas
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_Monitor_Alertas_Pendientes AS
SELECT 
    a.ID_Alerta,
    a.Fecha AS Fecha_Alerta,
    a.Hora AS Hora_Alerta,
    a.tipo_alerta,
    a.nivel_riesgo,
    a.Estado AS Estado_Alerta,
    t.ID_transaccion,
    t.monto_transaccion,
    t.canal_operacion,
    c.Num_cuenta,
    cl.Cliente_DNI,
    CONCAT(cl.Nombres, ' ', cl.Apellidos) AS Nombre_Cliente
FROM Alerta_Fraude a
INNER JOIN Transaccion t ON a.ID_Transaccion = t.ID_transaccion
INNER JOIN Cuenta c ON t.Num_Cuenta = c.Num_cuenta
INNER JOIN Cliente cl ON c.Cliente_DNI = cl.Cliente_DNI
WHERE a.Estado = 'Pendiente';
GO

-- -----------------------------------------------------------------------------
-- VISTA 2: Resumen del Perfil de Riesgo e Historial por Cliente
-- -----------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_Resumen_Riesgo_Cliente AS
SELECT 
    cl.Cliente_DNI,
    CONCAT(cl.Nombres, ' ', cl.Apellidos) AS Cliente,
    COUNT(DISTINCT c.Num_cuenta) AS Total_Cuentas,
    COUNT(DISTINCT t.ID_transaccion) AS Total_Transacciones,
    ISNULL(SUM(t.monto_transaccion), 0) AS Volumen_Total_Monto,
    COUNT(DISTINCT a.ID_Alerta) AS Total_Alertas_Generadas,
    COUNT(DISTINCT i.ID_Incidente) AS Total_Incidentes_Confirmados
FROM Cliente cl
LEFT JOIN Cuenta c ON cl.Cliente_DNI = c.Cliente_DNI
LEFT JOIN Transaccion t ON c.Num_cuenta = t.Num_Cuenta
LEFT JOIN Alerta_Fraude a ON t.ID_transaccion = a.ID_Transaccion
LEFT JOIN Incidente i ON a.ID_Alerta = i.ID_Alerta
GROUP BY cl.Cliente_DNI, cl.Nombres, cl.Apellidos;
GO