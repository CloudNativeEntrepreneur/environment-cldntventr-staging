
curl -L https://github.com/starkandwayne/safe/releases/download/v1.3.4/safe-linux-amd64 --output ./safe-linux-amd64
chmod +x ./safe-linux-amd64
mv ./safe-linux-amd64 /usr/bin/safe

wget https://bintray.com/loadimpact/rpm/rpm -O bintray-loadimpact-rpm.repo
mv bintray-loadimpact-rpm.repo /etc/yum.repos.d/
yum -y install k6

set -- $(jx get vault-config)
echo "webhook url - $(safe get secret/staging/k6:slackUrl)"

url=https://demo-app-jx-staging.cloudnativeentrepreneur.dev users=1 k6 --quiet --summary-export ./load-test-results run ./load-test.js
slack_message=$(echo "Load Test Results: \n\tPasses: $(cat load-test-results | jq -r '.metrics | .checks.passes') \n\tFails: $(cat load-test-results | jq -r '.metrics | .checks.fails') \n\nTo see detailed results, check the build logs")
echo $slack_message
curl --silent --data-urlencode \
  "$(printf 'payload={"text": "%s", "username": "%s", "as_user": "true", "link_names": "true", "icon_emoji": "%s" }' \
      "${slack_message}" \
      "K6" \
      ":chart_with_upwards_trend:" \
  )" \
  --request POST \
  --url $(safe get secret/staging/k6:slackUrl)