[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/ENtV2bNj)
# Título Proyecto

## Miembros del grupo L6-VVF2245

1. Flores Cañabate, Julián
1. Hernández Cuadrado, Luis
1. Noguera Talavera, Sergio
1. Bader Abuhar, Morad

## 1. Introducción al problema

- Descripción del problema para poner en contexto el proyecto, incluyendo información sobre los clientes y usuarios, la situación actual, problemas, expectativas, etc. Se valorará la presencia de información multimedia (fotos, gráficos, documentos escaneados, etc.).

La empresa EasyVPM, dedicada al alquiler y gestión de vehículos de movilidad personal como patinetes eléctricos, bicicletas y monociclos, ha contactado con nuestro equipo para desarrollar una plataforma centralizada que optimice su gestión logística y administrativa.

Ante la futura expansión y apertura de nuevas sucursales, la empresa ha detectado que la documentación manual ya no resulta eficiente, pues dificulta el control del inventario, el seguimiento de los vehículos, la trazabilidad de los alquileres y la supervisión del mantenimiento.

En consecuencia, EasyVPM considera imprescindible implantar un sistema de informacion que permita un acceso ágil y seguro a grandes volúmenes de información, mejorando sus procesos internos. Con esta plataforma, la empresa busca modernizar su infraestructura, optimizar la toma de decisiones y ofrecer una experiencia de usuario más completa y satisfactoria.

<img src="imagenes/estacion_vpm.png" alt="Estación de VMP" width="50%"><br>
<em>Estación de EasyVPM</em>

## 2. Glosario de términos

- Términos específicos del dominio del problema, ordenados alfabéticamente. Se valorará la presencia de información multimedia.

**Cliente:** Persona que realiza el alquiler de un VMP a través de la plataforma. <br>
**Duración del viaje:** Tiempo que pasa entre el inicio y el fin del alquiler. <br>
**Estación:** Punto físico donde se pueden recoger o devolver los vehículos.  <br>
**Estado de la estación:** Condición actual de la estación (libre, ocupada, fuera de servicio).  <br>
**Estado del vehículo:** Condición actual del VMP (disponible, en uso, averiado, en mantenimiento, reparado).  <br>
**Inventario:** Conjunto de VMP disponibles para alquiler. <br>
**Incidencia**Añadimos esta? <br>
**Mantenimiento:** Conjunto de acciones para reparar o revisar los vehículos o las estaciones.  <br>
**Redistribución:** Movimiento de VMPs entre estaciones para equilibrar la disponibilidad. #(lo de entre estaciones se puede omitir si queremos usar esta palabra para sacar los vehiculos del taller)  <br>
**Reparado:** Estado en el que se encuentra un vehículo cuando su mantenimiento ha terminado y se tiene que redistribuir. <br>
**Reseña** Evaluación proporcionada por un usuario sobre su experiencia con un vehículo mediante calificación y comentario.  <br>
**Tiempo de espera:** Tiempo mínimo que tiene que pasar entre cada viaje.  <br>
**Tipo de tarifa:** Clasificación del modo de pago, que puede ser por suscripción (mensual, anual) o por pago individual de cada trayecto.  <br>
**VMP (Vehículo de Movilidad Personal):** Medio de transporte ligero, destinado a una sola persona (patinetes, monociclos, etc.).  <br>

## 3. Visión general del sistema

### 3.1. Requisitos generales
El sistema debe ser capaz de almacenar y gestionar la información relacionada con los usuarios, los vehículos alquilados y las estaciones, permitiendo así una correcta administración de los préstamos y del servicio ofrecido.

Para ello deberá informar al usuario sobre las estaciones más cercanas a su ubicación y mostrar la cantidad y tipo de vehículos disponibles en cada una de ellas, además de tener que gestionar automáticamente los procesos de alquiler y cobro, controlar el acceso según roles de usuario, permitir el registro de incidencias y mantenimiento, y generar informes y estadísticas para la toma de decisiones empresariales.

Finalmente, el sistema deberá registrar la ubicación del vehículo alquilado en tiempo real, con el fin de garantizar su trazabilidad y evitar pérdidas o extravíos. 

### 3.2. Usuarios del sistema

El sistema de EasyVPM contará con los siguientes tipos de usuarios: 

**Usuarios(Clientes)**
   * Se registran para alquilar vehículos, consultar estaciones y disponibilidad, iniciar y finalizar alquileres, y proporcionar valoraciones. 

**Administradores**
   * Gestionan usuarios, vehículos y estaciones, supervisan incidencias y mantenimiento, y generan informes para la empresa. 

**Técnicos de mantenimiento**
   * Reciben notificaciones de incidencias y actualizan el estado de los vehículos. 
   
## 4. Catálogo de requisitos

### 4.1. Requisitos funcionales

#### R.F.01. Título requisito funcional

Como [tipo de usuario]
quiero [servicio]
para [razón]

Como administrador de EasyVPM, quiero recibir información sobre el uso de los vehículos, las estaciones, los ingresos y las incidencias, para poder gestionar la empresa de manera eficiente y tomar decisiones sobre expansión, mantenimiento y calidad del servicio.

Como usuario de EasyVPM quiero recibir informacion sobre las estaciones cercanas y la disponibilidad de los vehiculos, iniciar y finalizar alquileres y publicar valoraciones.

Como tecnico de mantenimiento de EasyVPM quiero recibir informacion sobre inicidencias y poder actualizar el estado de los vehiculos.

**Prueba de aceptación**
- Descripción de la primera comprobación a realizar
- Descripción de la segunda comprobación a realizar
- Se debe aplicar la regla de negocio R.N.XX.
- ...

- PA-01
Gestión de información de usuarios, vehículos y estaciones
- Se puede registrar, editar y eliminar usuarios, vehículos y estaciones.
- Los datos modificados se reflejan inmediatamente en el sistema.
- No se permite duplicar registros con el mismo identificador.

- PA-02
Consulta de estaciones cercanas
- El sistema muestra un listado de estaciones ordenadas por proximidad a la ubicación actual del usuario.
- Si el usuario no permite el acceso a la ubicación, el sistema muestra un mensaje adecuado.

- PA-03
Visualización de disponibilidad de vehículos
- El usuario puede ver cuántos vehículos hay en cada estación y de qué tipo (bicicletas, scooters, etc.).
- Los datos de disponibilidad se actualizan en tiempo real.

- PA-04
Proceso automático de alquiler y cobro
- Al iniciar un alquiler, el sistema descuenta un vehículo de la estación correspondiente y registra el préstamo.
- Al finalizar, calcula el monto y genera el cobro automáticamente.
- Si el pago falla, el sistema notifica al usuario.

- PA-05	
Control de acceso por roles
- Los clientes solo pueden acceder a funciones de consulta y alquiler.
- Los administradores pueden gestionar todo el sistema.
- Los técnicos solo pueden ver incidencias y actualizar estados de mantenimiento.
- Intentar acceder a una función restringida muestra un mensaje de “Acceso no autorizado”.
  
- PA-06	
Registro y gestión de incidencias/mantenimiento	
- Los usuarios pueden reportar una incidencia durante o después del alquiler.
- Los técnicos reciben la notificación y pueden actualizar el estado del vehículo (por ejemplo: “En revisión”, “Reparado”).

- PA-07
Generación de informes y estadísticas
- Los administradores pueden generar informes de uso, mantenimiento, ingresos y disponibilidad.
- Los informes pueden descargarse en formato PDF o visualizarse en pantalla.
- Los datos mostrados son consistentes con las operaciones realizadas.
  
- PA-08	
Trazabilidad del vehículo en tiempo real	
- El sistema registra y muestra la ubicación actual de cada vehículo alquilado en un mapa.
- Si el vehículo pierde conexión, el sistema muestra la última ubicación conocida y una alerta.
- El seguimiento se actualiza en intervalos definidos (por ejemplo, cada 10 segundos).

#### 4.1.1. Requisitos de información

##### R.I.01. Título requisito de información

Como [tipo de usuario]
quiero [servicio]
para [razón]

**Prueba de aceptación**
- Descripción de la primera comprobación a realizar
- Descripción de la segunda comprobación a realizar
- ...

#### 4.1.2. Reglas de negocio

##### R.N.01. Título regla negocio

Descripción de la regla de negocio.

### 4.2. Mapa de historias de usuario (opcional)

### 4.3. Requisitos no funcionales (opcional)

**R.N.F. 01. Título requisito no funcional**
Como [tipo de usuario]
quiero [servicio]
para [razón]

-- fin entregable 1 --

## 5. Modelo conceptual

### 5.1. Diagramas de clases UML

- con restricciones.

### 5.2. Escenarios de prueba

- con descripción textual y diagrama de objetos UML.

## 6. Matrices de trazabilidad

- Matriz de trazabilidad entre los elementos del modelo conceptual y los requisitos.

|       | EntidadX   | AsociaciónX  | RestricciónX  | Entidad2 ...   | 
|:------|:-----------|:-----------|:-----------|:-----------|
| RI-1  | X          | X          | X          | X          |
| RI-2  |            | X          |            | X          |
| RF-1  |            | X          |            | X          |
| RF-2  | X          |            | X          | X          |
| RN-1  |            | X          |            |            |
| RN-2  | X          | X          | X          |            |
| ...   |            |            |            |            |

-- fin entregable 2 --

## 7. Modelo relacional en 3FN

- Relaciones obtenidas al aplicar la transformación del modelo conceptual.

### 7.1.  Justificación de la estrategia de transformación de jerarquías

- si se identificaron jerarquías en el MC.


### 8. Matriz de trazabilidad MC/SQL (opcional):

- Restricciones sobre el MC / Elementos del modelo tecnológico (SQL) (Triggers, checks, etc.)
- Incluir Reglas de negocio — Constraints/Triggers en las matrices de trazabilidad para el entregable 3

|       | EntidadX   | AsociaciónX  | RestricciónX  | Entidad2 ...   | 
|:-------|:-------|:-------|:-------|:-------|
| TABLA-1 |        |        |        |        |
| TABLA-2 |        |        |        |        |
| TABLA-3 |        |        |        |        |
| TABLA-4 |        |        |        |        |
| TRIG-1 |        |        |        |        |
| TRIG-2 | X      | X      |        | X      |
| TRIG-3 |        | X      |        | X      |
| TRIG-4 |        |        | X      |        |
| CONST-1 |        |        |        |        |
| CONST-2 | X      | X      |        | X      |
| CONST-3 |        | X      |        | X      |
| CONST-4 |        |        | X      |        |

Se consideran todo tipo de constraints declarativas (aquellas definidas durante el CREATE TABLE).
-- fin entregable 3 --

## Referencias


