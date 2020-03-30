import http from 'k6/http';
import { sleep, check } from 'k6';

const { url, users, slackUrl } = __ENV;

// export let options = {
//   stages: [
//     { duration: "5m", target: parseInt(users, 10) }, // simulate ramp-up of traffic from 1 to ${users} users over 5 minutes.
//     { duration: "10m", target: parseInt(users, 10) }, // stay at ${users} users for 10 minutes
//     { duration: "5m", target: 0 }, // ramp-down to 0 users
//   ],
//   thresholds: {
//     "http_req_duration": [{ threshold: "p(95)<500", abortOnFail: true }], // 95% of requests must complete below .5s
//   }
// };

export let options = {
  stages: [
    { duration: "10s", target: parseInt(users, 10) }
  ],
  thresholds: {
    "http_req_duration": [{ threshold: "p(95)<500", abortOnFail: true }], // 95% of requests must complete below .5s
  }
};

export default function() {
  let res = http.get(url);
  if(!check(res, {
    'status was 200': r => r.status == 200,
  })) {

  };
  sleep(1)
}
