#!/bin/bash

echo "Downloading load testing tools..."

curl -L https://github.com/starkandwayne/safe/releases/download/v1.3.4/safe-linux-amd64 --output ./safe-linux-amd64
chmod +x ./safe-linux-amd64
mv ./safe-linux-amd64 /usr/bin/safe

wget https://bintray.com/loadimpact/rpm/rpm -O bintray-loadimpact-rpm.repo
mv bintray-loadimpact-rpm.repo /etc/yum.repos.d/
yum -y install k6

echo "Configuring vault"
jx get vault-config

eval `jx get vault-config`

url=https://demo-app-jx-staging.cloudnativeentrepreneur.dev \
users=20 \
rampDuration=30s \
fullLoadDuration=1m \
k6 --quiet --summary-export ./load-test-results run ./load-test.js

slack_message="$(printf 'Load Test Results:\n```\nSuccessful Requests: %s\nFailed Requests: %s\nMax VUs: %s\nAverage Request Duration: %s```\n\nTo see detailed results, check the build logs with `jx get build logs %s`' \
  $(cat load-test-results | jq -r '.metrics | .checks.passes') \
  $(cat load-test-results | jq -r '.metrics | .checks.fails') \
  $(cat load-test-results | jq -r '.metrics | .vus_max.value') \
  $(cat load-test-results | jq -r '.metrics | .http_req_duration.avg')ms \
  "'$JOB_NAME #$BUILD_NUMBER'" \
)"

curl --silent --data-urlencode \
  "$(printf 'payload={"text": "%s"}' \
      "${slack_message}" \
  )" \
  --request POST \
  --url $(safe get secret/staging/k6:slackUrl)