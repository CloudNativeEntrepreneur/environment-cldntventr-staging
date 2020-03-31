#!/bin/bash

echo "Downloading load testing tools..."

curl -L https://github.com/starkandwayne/safe/releases/download/v1.3.4/safe-linux-amd64 --output ./safe-linux-amd64
chmod +x ./safe-linux-amd64
mv ./safe-linux-amd64 /usr/bin/safe

wget https://bintray.com/loadimpact/rpm/rpm -O bintray-loadimpact-rpm.repo
mv bintray-loadimpact-rpm.repo /etc/yum.repos.d/
yum -y install k6

echo "Configuring vault"
jx get vault-config >> /dev/null
eval `jx get vault-config`

url=https://demo-app-jx-staging.cloudnativeentrepreneur.dev \
users=$LOAD_TEST_USERS \
rampDuration=$LOAD_TEST_RAMP_DURATION \
fullLoadDuration=$LOAD_TEST_FULL_LOAD_DURATION \
k6 --quiet --summary-export ./load-test-results run ./load-test.js > load-test-output

slack_message=$(cat load-test-output | sed '0,/^.*starting/ s//starting/')

curl --silent --data-urlencode "payload={
\"text\": \"Load Test Results:
\`\`\`
$slack_message
\`\`\`
\"}
" \
--request POST \
--url $(safe get secret/staging/k6:slackUrl)