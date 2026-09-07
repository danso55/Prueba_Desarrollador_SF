
# Prueba Tecnica
## Authors

- [@Daniel Jaimes](https://github.com/danso55)




## Instrucciones 
### 1. Autenticación de la Org

• Desde la raíz del proyecto Salesforce, autenticar la Org de prueba:

sf org login web --alias OrgPrueba

• Validar posteriormente la conexión:

sf org display --target-org OrgPrueba
### 2. Carga de los componentes del repositorio

Se realizará el despliegue de los componentes contenidos en el repositorio hacia la Org de prueba:

sf project deploy start --source-dir force-app --target-org OrgPrueba

Este proceso cargará los componentes incluidos en el proyecto:


• Clases y pruebas Apex
• Triggers
• Objetos y campos
• Custom Metadata
• Flows
• Permisos
• Labels


Se recomienda realizar previamente una validación sin aplicar cambios:

sf project deploy start --source-dir force-app --target-org OrgPrueba --dry-run
### 3. Activación de Flows

Una vez desplegados los Flows, se deberá validar su estado y activar aquellos que hagan parte de la solución.

Se debe verificar especialmente que:

El Flow desplegado corresponda a la versión esperada.
Se encuentre activo.
Las condiciones de entrada sean correctas.
Las referencias a campos, objetos y acciones sean válidas.
No existan versiones anteriores activas que puedan generar ejecuciones duplicadas.
### 4. Validación de permisos

Después del despliegue se deberán validar los permisos necesarios para la correcta ejecución de la solución.

Se debe verificar:

Field-Level Security (FLS) de los campos utilizados
Permisos de lectura, creación, edición y eliminación sobre los objetos involucrados
Acceso a las clases Apex

### 5. Validación de visibilidad de botones y acciones

Se deberá comprobar que los botones, acciones y componentes utilizados por la solución sean visibles para los perfiles o usuarios correspondientes.

La validación deberá contemplar:

Visibilidad de botones y acciones en los Lightning Record Pages.
Permisos necesarios para ejecutar las acciones.

### 6. Creación del trabajo programado

Finalmente, se deberá crear el trabajo programado encargado de ejecutar debuggingQuotes_sch.

El Scheduler ejecutará diariamente el Batch Apex encargado de identificar y depurar las cotizaciones que cumplan las condiciones de retención configuradas.

Se recomienda programarlo en un horario de baja utilización del sistema, con el objetivo de minimizar el impacto sobre los procesos concurrentes y reducir el riesgo de bloqueos por Row Locking.

El tamaño del lote será tomado de la etiqueta:

Label.debuggingQuotes_batch

permitiendo ajustar el volumen de registros procesados por transacción sin modificar el código fuente.

### 7. Validación final

Una vez completado el despliegue y la configuración, se deberá validar:

Correcta ejecución de los Flows.
Acceso a los objetos y campos requeridos.
Visibilidad de botones y acciones.
Existencia y configuración del Custom Metadata Depuracion_Quotes.
Configuración de los días de retención.
Existencia del trabajo programado debuggingQuotes_sch.
Ejecución correcta del Batch Apex.
Generación de registros en Audit_Log__c ante errores o eventos definidos.
Correcto procesamiento y eliminación de las Quotes que cumplan las condiciones establecidas.

## HT-01 (Gobernanza y Transiciones de Estado)

### Gestión de versiones
• Responsable de identificar las diferentes versiones de una cotización.

• Cada cotización cuenta con un VersionKey__c, utilizado como identificador lógico de la versión la cual se llena desde un trigger flow.

• El VersionKey__c permite diferenciar las cotizaciones y mantener la relación lógica entre las versiones generadas y evitar la duplicidad.

• La creación y actualización de versiones permanece desacoplada del proceso de depuración.

### Proceso de depuración
• Implementado mediante Scheduled Apex + Batch Apex.

• El Scheduler ejecuta periódicamente el Batch.

• El Batch identifica las cotizaciones que cumplen las condiciones de depuración.

• La eliminación se realiza mediante Database.delete(records, false), permitiendo procesar individualmente los resultados y evitar que el fallo de un registro impida el procesamiento de los demás.

• Los errores y resultados del proceso son registrados en Audit_Log__c.

## HT-02 (Rendimiento y Escalabilidad)

• Implementar el proceso de depuración mediante Batch Apex, permitiendo procesar las cotizaciones de forma masiva y controlada mediante lotes configurables los cuales se dejan dentro de una metadata. 

• Se utilizará Database.QueryLocator para la consulta de grandes volúmenes de registros y operaciones DML masivas mediante Database.delete(records, false), evitando ejecuciones individuales que puedan afectar los Governor Limits de SOQL y DML.

• La ejecución se realizará mediante Scheduled Apex, preferiblemente en ventanas de baja actividad, con el objetivo de minimizar la concurrencia con procesos de actualización de cotizaciones y reducir el riesgo de Row Locking.

• Adicionalmente, se controlará que no existan ejecuciones concurrentes del proceso de depuración y se registrarán los errores de eliminación mediante Audit_Log__c, permitiendo identificar los registros que no pudieron ser procesados.

## Declaración de Uso de IA y Gobernanza
### Herramientas Utilizadas
• Ejemplos de comandos
• Refuerzo de clases test
• mejora de ortografia 
• Creacion de formulas para los flows
### Refinamiento y Corrección Humana
• Correcion en las formulas debido a fallas en tipos de datos
• Cambio de metodos tipos de datos para las clases test
• Corrección en la arquitectura del trigger 
• Correcciones en codigo muy rigido 
