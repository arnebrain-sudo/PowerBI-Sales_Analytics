				-- 1. Conteo de Duplicados
-- Codigo para eliminar duplicados
/*DELETE FROM dim_Productos
WHERE Id_Producto IN (
    SELECT Id_Producto
    FROM dim_Productos
    GROUP BY Id_Producto
    HAVING COUNT(*) > 1
);*/
--=====================================================================================================
-- tabla Clientes
SELECT 'Clientes' AS Tabla_Duplicados;
WITH duplicados AS (
    SELECT  *,
           ROW_NUMBER() OVER (-- rownumber crea numeracion sucesiva por grupo de datos
               PARTITION BY Id_Cliente, Nombre_Cliente, Ciudad_Cliente, Edad_Cliente, Cedula_Cliente -- genera grupos de duplicados
               ORDER BY Id_Cliente -- ordena aquellos grupos de forma sucesiva
           ) AS fila_Clientes -- campo que enumera cada grupo resultante
    FROM dim_clientes
)
SELECT *
FROM duplicados
WHERE fila_Clientes > 1;

-- tabla Productos
SELECT 'Productos' AS Tabla_Duplicados;
WITH duplicados AS(
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY Id_Producto, Desc_Producto, Precio_Unitario
            ORDER BY Id_Producto
        ) AS fila_Productos
    FROM dim_Productos
)
SELECT *
FROM duplicados
WHERE fila_Productos > 1;

-- Tabla Tiendas
SELECT 'Tiendas' AS Tabla_Duplicados;
WITH duplicados AS(
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY Id_Tiendas, Tiendas, Zonas
            ORDER BY Id_Tiendas
        )AS fila_Tiendas
    FROM dim_Tiendas
)
SELECT *
FROM duplicados
WHERE fila_Tiendas > 1;


--==============================================================================================
				-- 2. Conteo de Nulos
-- Tabla Clientes
SELECT 'Clientes' AS Tabla_Nulos,  
    COUNT(*) AS total_Registros,
    SUM(CASE WHEN Id_Cliente IS NULL THEN 1 ELSE 0 END) AS Id_Cliente,
    SUM(CASE WHEN Nombre_Cliente IS NULL THEN 1 ELSE 0 END) AS Nombre_Cliente,
    SUM(CASE WHEN Ciudad_Cliente IS NULL THEN 1 ELSE 0 END) AS Ciudad_Cliente,
    SUM(CASE WHEN Edad_Cliente IS NULL THEN 1 ELSE 0 END) AS Edad_Cliente,
    SUM(CASE WHEN Cedula_Cliente IS NULL THEN 1 ELSE 0 END) AS Cedula_Cliente
FROM dim_clientes;

-- Tabla Productos
SELECT 'Productos' AS Tabla_Nulos,
    COUNT(*) AS total_Registros,
    SUM(CASE WHEN Id_Producto IS NULL THEN 1 ELSE 0 END) AS Id_Producto,
    SUM(CASE WHEN Desc_Producto IS NULL THEN 1 ELSE 0 END) AS Desc_Producto,
    SUM(CASE WHEN Precio_Unitario IS NULL THEN 1 ELSE 0 END) AS Precio_Unitario
FROM dim_Productos;

-- Tabla Tiendas
SELECT 'Tiendas' AS Tabla_Nulos,
    COUNT(*) AS total_Registros,
    SUM(CASE WHEN Id_Tiendas IS NULL THEN 1 ELSE 0 END) AS Id_Tiendas,
    SUM(CASE WHEN Tiendas IS NULL THEN 1 ELSE 0 END) AS  Tiendas,
    SUM(CASE WHEN Zonas IS NULL THEN 1 ELSE 0 END) AS Zonas
FROM dim_Tiendas;

--==================================================================================
            -- 3. Errores de Formato
SELECT 
    -- 1. Identifica IDs que tienen letras o caracteres especiales si deberían ser solo números
    COUNT(CASE WHEN Id_Producto LIKE '%[^0-9]%' THEN 1 END) AS IDs_Con_Letras,

    -- 2. Detecta nombres de productos con espacios innecesarios al inicio o al final
    COUNT(CASE WHEN Desc_Producto LIKE ' %' OR Desc_Producto LIKE '% ' THEN 1 END) AS Nombres_Con_Espacios_Extra,

    -- 3. Cuenta códigos o textos que no cumplen con una longitud fija esperada (Ejemplo: 5 caracteres)
    COUNT(CASE WHEN LEN(Id_Producto) <> 5 THEN 1 END) AS IDs_Longitud_Incorrecta,

    -- 4. Detecta correos, códigos o campos de texto que contienen caracteres extraños o invisibles
    COUNT(CASE WHEN Desc_Producto LIKE '%[^a-zA-Z0-9 ]%' THEN 1 END) AS Textos_Caracteres_Invalidos
 FROM dim_Productos_resp;

 -- Codigo para cambiar tipo de datos
ALTER TABLE fact_Ventas
ALTER COLUMN Fecha int;

-- Codigo para modificar caracteres especiales
UPDATE dim_Productos_resp
SET Desc_Producto = REPLACE(REPLACE(REPLACE(REPLACE(Desc_Producto,' ', '_'), CHAR(10)/*salto de linea*/, ''), CHAR(13)/*retorno de carro*/, ''), CHAR(9)/*tabulacion*/, '');

-- Codigo para corregir idVenta: secuencia incoherente con fecha de venta
WITH VentasOrdenadas AS (
    SELECT
        Id_Venta,
        ROW_NUMBER() OVER(ORDER BY Fecha ASC, Id_Producto ASC) AS nuevoID
    FROM fact_Ventas
)
UPDATE VentasOrdenadas
SET Id_Venta = nuevoID;

-- Codigo para modificar precios en campo PrecioUnitario
UPDATE dim_Productos 
SET Precio_Unitario = ['valor nuevo']
WHERE Id_Producto = ['1 a 15'];


--Codigo para respaldar una tabla
SELECT * INTO dim_Productos_resp FROM dim_Productos;-- Respaldo de tabla dimProductos para realizar modificaciones
