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

echo "Starting Load test with Preview URL: $PREVIEW_URL"

url=$PREVIEW_URL \
users=$LOAD_TEST_USERS \
rampDuration=$LOAD_TEST_RAMP_DURATION \
fullLoadDuration=$LOAD_TEST_FULL_LOAD_DURATION \
k6 --quiet --summary-export load-test-results run load-test.js > load-test-output

echo "Load test complete:"
cat load-test-output

slack_message=`cat load-test-output |  sed '/starting/,$!d'`

curl --silent --data-urlencode "payload={
\"text\": \"*Load Test Results:*

A load test was run as a result of a new release to staging.

To see the build logs that started this test run \`jx get build logs '$JOB_NAME #$BUILD_NUMBER'\`

The load test was configured to simulate a maximum of $LOAD_TEST_USERS concurrent users. The number of users ramped up to the target number over $LOAD_TEST_RAMP_DURATION, ran at full capacity for $LOAD_TEST_FULL_LOAD_DURATION, and then ramped back down to 0 over the next $LOAD_TEST_RAMP_DURATION. 

Here are the results of that test:

\`\`\`
$slack_message
\`\`\`
\"}
" \
--request POST \
--url $(safe get secret/staging/k6:slackUrl)

jx step pr comment -c "```\n$slack_message\n```" -p $PULL_NUMBER -o $REPO_OWNER -r $REPO_NAME