import http from 'k6/http';
import { check, sleep } from 'k6';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.2/index.js';

const BASE_URL = "https://order-query-api-252012319147.us-central1.run.app";

export const options = {
  scenarios: {
    constant_load: {
      executor: 'constant-arrival-rate',
      rate: 7,
      timeUnit: '1s',
      duration: '1m',
      preAllocatedVUs: 20,
      maxVUs: 100,
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<1000'],
  },
};

// Función setup que k6 ejecutará antes de las pruebas
export function setup() {
  const response = http.get(`${BASE_URL}/orders/ids`);
  try {
    const data = JSON.parse(response.body);
    if (data.data && Array.isArray(data.data)) {
      console.log(`Retrieved ${data.data.length} order IDs`);
      return { orderIds: data.data };
    }
  } catch (e) {
    console.error('Error parsing order IDs:', e);
  }
  return { orderIds: [] };
}

export default function (data) {
  const { orderIds } = data;
  
  if (orderIds.length === 0) {
    console.error('No order IDs available for testing');
    return;
  }

  const randomId = orderIds[Math.floor(Math.random() * orderIds.length)];
  const response = http.get(`${BASE_URL}/orders/${randomId}`);

  check(response, {
    'status is 200': (r) => r.status === 200,
    'has order data': (r) => {
      try {
        const data = JSON.parse(r.body);
        return data !== null;
      } catch (e) {
        return false;
      }
    },
    'response time < 1s': (r) => r.timings.duration < 1000,
  });

  sleep(0.1);
}

export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
  };
}