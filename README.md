# Prueba Tecnica
## Authors
- [@Daniel Jaimes](https://github.com/danso55)
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


