# default-environment-charts
The default git repository used when creating new GitOps based Environments

## MongoDB Setup

A MongoDB cluster is deployed in this environment - before the microservices that rely on it can use it, a database must be configured in the cluster.

To connect to the cluster, run:

```
kubectl exec -it mongodb-replicaset-0 -- mongo -u $(safe get secret/staging/mongodb:adminUser) -p $(safe get secret/staging/mongodb:adminPassword) --authenticationDatabase admin
```
