/*1- 
Redactar las sentencias que permitan agregar las restricciones de integridad referencial permitiendo 
la actualizacion automatica para el caso de actualizar o eliminar un banco, moneda o persona.
Demostrar el correcto funcionamiento de las restricciones creadas
Redactar las sentencias que permitan eliminar las restricciones creadas en el paso anterior.
*/

-- PIOLAAAAAAAAAAAA

/*2-
Listar los bancos que operan todas las monedas
Usar una vista
*/

/*
        CREATE VIEW BancosTodasDivisas AS
        SELECT
            b.id,
            b.nombre,
            b.pais
        FROM Opera o
        JOIN Banco b ON o.idBanco = b.id
        GROUP BY b.id, b.nombre, b.pais
        HAVING (SELECT COUNT(id) FROM Moneda) = COUNT(o.idMoneda)
*/

/*4-
Crear una funcion que devuelva el valor oro de una moneda. La misma debe recibir como parametro el 
codigo de la moneda y devolver el valor -1 para el caso en que la moneda no exista.
Escribir la sentencia que prueba el correcto funcionamiento.
*/

/*
        CREATE FUNCTION ValorOro ( @IdMoneda char(2) ) RETURNS DECIMAL(18,3) AS
        BEGIN
            DECLARE @ValorOro DECIMAL(18,3)
            SET @ValorOro = (SELECT m.valorOro FROM Moneda m WHERE m.id = @IdMoneda)
            IF @ValorOro IS NULL
                SET @ValorOro = -1
            RETURN @ValorOro;
        END;

        DROP FUNCTION ValorOro;

        SELECT dbo.ValorOro('AR') AS VALOR;
*/

/*5- 
Crear una funcion que retorne el pasaporte y el nombre de las personas que tienen cuenta en todos los bancos.
Escribir la sentencia que prueba el correcto funcionamiento.
*/



/*6-
Crear un SP que muestre por pantalla a las personas que tienen mas de 3 cuentas en dolares en bancos extranjeros. 
Escribir la sentencia que prueba el correcto funcionamiento.
*/

/*
CREATE PROCEDURE PersonaMas3Cuentas AS
BEGIN
    SELECT p.pasaporte, nombre FROM Persona p
    JOIN (
        SELECT p.pasaporte FROM Cuenta c
        JOIN Persona p ON p.pasaporte = c.idPersona
        JOIN Banco b ON b.id = c.idBanco
        WHERE b.pais <> 'Argentina' AND c.idMoneda = 'US'
        GROUP BY p.pasaporte
        HAVING COUNT(c.id) >= 3
    ) AS CuentasMas3 ON p.pasaporte = CuentasMas3.pasaporte
END;

--DROP PROCEDURE PersonaMas3Cuentas

EXEC PersonaMas3Cuentas;
*/

/*7- 
Crear un SP que reciba por parametro un pasaporte y muestre las cuentas asociadas a la misma. Si el pasaporte no existe, mostrar un mensaje de error.
Escribir la sentencia que prueba el correcto funcionamiento.
*/

/*
CREATE PROCEDURE CuentasPorPasaporte
    @Pasaporte char(15)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Persona WHERE pasaporte = @Pasaporte)
    BEGIN
        SELECT * FROM Cuenta c
        JOIN Persona p ON p.pasaporte = c.idPersona
        WHERE
            p.pasaporte = @Pasaporte;
    END
    ELSE
    BEGIN
        RAISERROR('El pasaporte "%s" no existe en la base de datos.', 16, 1, @Pasaporte);
    END
END;

EXEC CuentasPorPasaporte '5';
DROP PROCEDURE CuentasPorPasaporte;

*/

/*8-
Crear un Trigger que realice el respaldo de los datos de un Banco cuando el mismo es eliminado. El trigger no debe 
permitir que se eliminen bancos que operan con la moneda "PESO ARGENTINO"
Se debe crear una tabla "banco_respaldo"
Escribir las sentencias que prueban el correcto funcionamiento.
*/

/*
CREATE TRIGGER respaldar_banco
ON Banco
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted d
               JOIN Opera o ON d.id = o.idBanco
               WHERE o.idMoneda = 'AR')
    BEGIN
        RAISERROR ('ERROR: No se puede eliminar un banco que opera con "PESO ARGENTINO".', 16, 1);
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT * FROM sys.tables s WHERE s.name = 'banco_respaldo')
        BEGIN
            CREATE TABLE banco_respaldo(id int primary key, nombre varchar(50), pais char(50));
        END

        INSERT INTO banco_respaldo(id, nombre, pais)
        SELECT * FROM deleted d

        DELETE b from Banco b
        JOIN deleted d ON b.id = d.id

        PRINT 'Operación completada: Banco(s) eliminado(s) y respaldado(s) correctamente.';
    END
END;
DROP TRIGGER respaldar_banco
DELETE FROM Banco WHERE id = 4;

SELECT * FROM Banco;
*/


/*9-
Crear un Trigger que actualice el id de moneda en las tablas opera y cuenta para cuando un codigo de moneda 
sea actualizado en la tabla moneda.
Escribir la sentencia que prueba el correcto funcionamiento.
*/

CREATE TRIGGER t_actualizarIdMoneda
ON moneda
