import http from "k6/http";
import { check, sleep } from "k6";
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.2/index.js'; 

const BASE_URL = "https://order-command-api-252012319147.us-central1.run.app/";

// Configuración de la prueba
export const options = {
  scenarios: {
    constant_load: {
      executor: "constant-arrival-rate",
      rate: 7, // ~400 órdenes por minuto (7 por segundo)
      timeUnit: "1s",
      duration: "1m",
      preAllocatedVUs: 20,
      maxVUs: 100,
    },
  },
  thresholds: {
    http_req_duration: ["p(95)<2000"], // 95% de las peticiones deben completarse en menos de 2s
  },
};


export default function () {
  const payload = {
    id_cliente: uuidv4(),
    id_vendedor: uuidv4(),
    id_bodega_origen: uuidv4(),
    fecha_entrega_estimada: "2024-12-31T10:00:00",
    observaciones: "Test order",
    creado_por: uuidv4(),
    detalles: [
      {
        id_producto: uuidv4(),
        cantidad: Math.floor(Math.random() * 5) + 1,
        precio_unitario: Math.random() * 200 + 50,
        observaciones: "Producto de prueba",
      },
    ],
  };

  const headers = {
    "Content-Type": "application/json",
  };

  const response = http.post(BASE_URL, JSON.stringify(payload), { headers });

  check(response, {
    "status is 200 or 201": (r) => r.status === 200 || r.status === 201,
    "has order id": (r) => JSON.parse(r.body).id !== undefined,
    "response time < 2s": (r) => r.timings.duration < 2000,
  });

  sleep(0.1);
}

export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
  };
}
