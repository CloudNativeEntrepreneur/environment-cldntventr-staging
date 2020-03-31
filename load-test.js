import http from 'k6/http';
import { sleep, check } from 'k6';

const { url, users, rampDuration = '5m', fullLoadDuration = '10m' } = __ENV;

export let options = {
  stages: [
    { duration: rampDuration, target: parseInt(users, 10) }, // simulate ramp-up of traffic from 1 to ${users} users
    { duration: fullLoadDuration, target: parseInt(users, 10) }, // stay at ${users} users
    { duration: rampDuration, target: 0 }, // ramp-down to 0 users
  ],
  thresholds: {
    "http_req_duration": [{ threshold: "p(95)<500", abortOnFail: true }], // 95% of requests must complete below .5s
  }
};

// export let options = {
//   stages: [
//     { duration: "10s", target: parseInt(users, 10) }
//   ],
//   thresholds: {
//     "http_req_duration": [{ threshold: "p(95)<500", abortOnFail: true }], // 95% of requests must complete below .5s
//   }
// };

export default function() {
  let res = http.get(url);
  if(!check(res, {
    'status was 200': r => r.status == 200,
  })) {

  };
  sleep(1)
}
