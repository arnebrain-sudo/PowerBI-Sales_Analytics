PowerBI-Sales_Analytics
Proyecto analítico en Power BI con análisis de Pareto y KPIs de ventas corporativas

📊 Análisis Estratégico de Ventas y Comportamiento del Consumidor

📝 Descripción del Proyecto
Este proyecto fue desarrollado en tres fases. Con Python se simulan los datos creando 4 datasets que se exportan a SQL para realizar procesos ETL, finalmente, Power BI se conecta a SQL para modelar los datos y desarrollar un ecosistema analítico de punta a punta para un negocio de comercio minorista (Retail). El objetivo principal es transformar datos transaccionales en insights accionables para optimizar la rentabilidad, evaluar el rendimiento geográfico y segmentar el catálogo de productos mediante reglas de negocio avanzadas.

==================================================

🎲 Simulación de Datos
En Python se desarrolla un archivo ipynb con el uso de las librerias; pandas, numpy, faker, sqlalchemy y urllib que permite desarrollar un proceso integrado para establecer conexión con SQL Server, crear las tablas y exportarlas, integrando campos comunes que facilitan la manipulación, gestión y administración.

🧑‍💻 Procesamiento ETL SQL Server
La base de datos techno procesa las tablas realizando las siguientes tareas:
- Conteo de duplicados. 0 duplicados.
- Conteo de Nulos. 0 Nulos.
- Errores de formato
  La simulación de Python definió precios unitarios incoherentes por lo tanto, se modifican precios incoherentes. La secuencia del campo idVenta en la tabla de hechos difiere con el tiempo de la operación para lo cual se crea un CTE que corrije la incoherencia con la fecha de venta, también se modifica el tipo de dato en el campo Fecha. Se adjuntan Screenshots de las tablas.

🏗️ Modelo de Datos (Diseño Estrella)
El proyecto implementa un modelo analítico robusto optimizado en Power BI bajo una arquitectura de "Modelo Estrella", garantizando un rendimiento óptimo de las consultas DAX y un filtrado eficiente.

•   Tabla de Hechos: `fact_Ventas` (Contiene métricas transaccionales de cantidad y enlaces clave).
•   Tablas de Dimensiones: 
    -   `dim_Clientes` (Atributos geográficos y demográficos).
    -   `dim_Productos` (Catálogo, precios e identificadores).
    -   `dim_Tiendas` (Zonas y nombres de sucursales).
    -   `dim_Calendario` (Dimensión temporal para análisis dinámicos). Creada en la infraestructura de Power Query.

==================================================

📈 KPIs Analíticos e Implementación DAX

1. Ventas Totales (Ingresos)
Consolida el valor monetario global del negocio cruzando cantidades con sus precios unitarios correspondientes:
```dax
Ventas Totales = SUMx(dim_Productos,[Volumen de Venta]*dim_Productos[Precio_Unitario])
```

2. Ticket Promedio
Calcula el gasto medio de un cliente por cada transacción única:
```dax
Ticket Promedio = DIVIDE([Volumen de Venta],[Numero de Transacciones])
```

3. Frecuencia de Compra
Métrica estadística de comportamiento que mide la cantidad promedio de visitas o transacciones por cliente único en el periodo:
```dax
Frecuencia de Compra = DIVIDE(DISTINCTCOUNT(fact_Ventas[Id_Venta]), DISTINCTCOUNT(fact_Ventas[Id_Cliente]), 0)
```

4. Concentración de Ventas (% Share Geográfico)
Calcula el peso porcentual de cada zona frente al total global del negocio de forma dinámica:
```dax
% Concentración Ventas = 
VAR VentasFilaActual = [Ventas Totales]
VAR VentasGlobales = CALCULATE([Ventas Totales], ALLSELECTED(fact_Ventas))
RETURN
DIVIDE(VentasFilaActual, VentasGlobales, 0)
```

5. Análisis de Pareto (80/20) Dinámico
Utiliza el concepto de **frecuencia relativa acumulada** en DAX para identificar el 20% de los productos vitales que generan el 80% de los ingresos totales:
```dax
% Ingresos Acumulado = 
VAR IngresosActuales = [Ventas Totales]
VAR TotalIngresos = CALCULATE([Ventas Totales], ALLSELECTED(dim_Productos))
RETURN
DIVIDE(
    CALCULATE(
        [Ventas Totales],
        FILTER(ALLSELECTED(dim_Productos), [Ventas Totales] >= IngresosActuales)
    ),
    TotalIngresos
)
```
==================================================

🧠 Principales Hallazgos de Negocio (Insights)
•   Concentración de Mercado: La zona "Norte" se consolida como el mercado líder concentrando el "22,56%" de las ventas globales, seguida estrechamente por la zona Occidente.
•   Regla de Pareto aplicada: Se identificaron de manera automática los productos críticos (Clase A) que sostienen el 80% de la facturación, permitiendo optimizar las estrategias de abastecimiento e inventario.

🛠️ Tecnologías utilizadas: Python, SQL Serve, Power Query, Power BI, Lenguaje DAX, Modelado de datos multidimensional, Git, GitHub.

