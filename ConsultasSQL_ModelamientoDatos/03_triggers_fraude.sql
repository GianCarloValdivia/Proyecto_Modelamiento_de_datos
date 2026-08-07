-- =============================================================================
-- PROYECTO: Sistema de Detección de Fraude en Transacciones Bancarias
-- ARCHIVO: sql/03_triggers_fraude.sql
-- DESCRIPCIÓN: Automatización de alertas en tiempo real mediante Triggers
-- =============================================================================

USE PDAN_bs_sistema_riesgo_crediticio;
GO

-- -----------------------------------------------------------------------------
-- TRIGGER 1: Detección por Monto Inusualmente Alto (> S/ 5,000.00)
-- -----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_DetectarFraude_MontoAlto
ON Transaccion
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Alerta_Fraude (ID_Alerta, Fecha, Hora, tipo_alerta, nivel_riesgo, Estado, ID_Transaccion)
    SELECT 
        CONCAT('ALT-AUTO-', LEFT(CAST(NEWID() AS VARCHAR(36)), 8)), -- Genera un ID único dinámico
        CAST(GETDATE() AS DATE),
        CAST(GETDATE() AS TIME),
        'Monto Inusual Detectado',
        'Alto',
        'Pendiente',
        i.ID_transaccion
    FROM inserted i
    WHERE i.monto_transaccion > 5000.00;
END;
GO

-- -----------------------------------------------------------------------------
-- TRIGGER 2: Detección por Ráfaga de Operaciones (Mismo cliente, varias operaciones en < 3 minutos)
-- -----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_DetectarFraude_Rafaga
ON Transaccion
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Alerta_Fraude (ID_Alerta, Fecha, Hora, tipo_alerta, nivel_riesgo, Estado, ID_Transaccion)
    SELECT 
        CONCAT('ALT-RAF-', LEFT(CAST(NEWID() AS VARCHAR(36)), 8)),
        CAST(GETDATE() AS DATE),
        CAST(GETDATE() AS TIME),
        'Ráfaga de Operaciones Sospechosa',
        'Medio',
        'Pendiente',
        i.ID_transaccion
    FROM inserted i
    WHERE (
        SELECT COUNT(*) 
        FROM Transaccion t 
        WHERE t.Num_Cuenta = i.Num_Cuenta 
          AND t.fecha_transaccion = i.fecha_transaccion
          AND DATEDIFF(SECOND, t.hora_transaccion, i.hora_transaccion) BETWEEN 0 AND 180
    ) >= 3;
END;
GO