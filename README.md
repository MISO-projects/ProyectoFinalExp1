# Experimento 1 - CQRS para la gestión de órdenes

## Arquitectura

Se utiliza la arquitectura CQRS para la gestión de órdenes. Utilizando comandos y consultas con 4 microservicios.


**Command API**: Microservicio que se encarga de recibir los comandos de creación de órdenes. Y publicar el comando en un topic de Pub/Sub.

**Command Handler**: Microservicio que se encarga de manejar los comandos de creación de órdenes. Y publicar el evento de creación de orden en un topic de Pub/Sub.

**Query Projection**: Microservicio que se encarga de proyectar las órdenes en una base de datos.

**Query API**: Microservicio que se encarga de consultar las órdenes.

![Ordenes](./docs/sub-orden.svg)

## Persistencia

Se utiliza una base de datos PostgreSQL para almacenar las órdenes.

Las proyecciones se realizan en una base de datos PostgreSQL denormalizando los detalles de la orden en un campo JSON.

## Broker de eventos

Se utiliza Pub/Sub para publicar y suscribirse a los eventos.


# Instrucciones de configuración local

### Variables de entorno
Cada microservicio tiene sus propias variables de entorno de ejemplo en el archivo `.env.example`.

### Configuración de Pub/Sub

En el script `scripts/setup_gcp.sh` se configuran los topics y las suscripciones. Para poder ejecutar el script se debe tener el servicio de Pub/Sub habilitado en el proyecto de GCP.

Para poder usar pub/sub en local se debe incluir el archivo `credentials.json` en el directorio `src/commands/api` y `src/commands/handlers`, que es el archivo de credenciales de la cuenta de servicio de Pub/Sub.

### Iniciar el proyecto

```bash
docker compose up -d
```

### Detener el proyecto

```bash
docker compose down
```

## Consumir los servicios
En la carpeta collection se encuentra el archivo `Orders.postman_collection.json` que contiene las peticiones para consumir los servicios.

Los handlers reciben los eventos de los topics de Pub/Sub de forma push, por lo que 
en el body se include el mensaje codificado en base64.

# Despliegue en GCP

TODO: Despliegue en GCP.