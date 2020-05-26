# default-environment-charts
The default git repository used when creating new GitOps based Environments

## MongoDB Setup

A MongoDB cluster is deployed in this environment - before the microservices that rely on it can use it, a database must be configured in the cluster.

### Connect as admin

```
eval $(jx get vault-config)
kubectl exec -n jx-staging -it jx-mongodb-replicaset-0 -- mongo -u $(safe get secret/staging/mongodb:adminUser) -p $(safe get secret/staging/mongodb:adminPassword) --authenticationDatabase admin
```

### Create sourced db and user

```
use sourced
db.createUser({user: 'sourced', pwd: '<make password then store in vault at /env/mongodb:sourcedPassword>', roles: ['readWrite']})
db.grantRolesToUser('sourced',[{ role: "dbAdmin", db: "sourced" }])
```

# Looking for demo-app settings?

`demo-app` is not enabled in this environment, but here they are:

```
- name: demo-app
  repository: http://bucketrepo/bucketrepo/charts/
  version: 0.0.11
```

And the values:

```
demo-app:
  keycloak:
    redirectUris:
      allowAll: false
      domain: cloudnativeentrepreneur.dev
      includeNamespace: true
      serviceName: demo-app
```