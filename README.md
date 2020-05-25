# default-environment-charts
The default git repository used when creating new GitOps based Environments

## MongoDB Setup

A MongoDB cluster is deployed in this environment - before the microservices that rely on it can use it, a database must be configured in the cluster.

To connect to the cluster, run:

```
kubectl exec -it mongodb-replicaset-0 -- mongo mydb -u admin -p password --authenticationDatabase admin
```

Then create a user:

```
```

Create a database:

```
```

And make the user the owner:

```
```