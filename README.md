
# SimpleGoApp

This porject deploys a simple go app inside a EKS Cluster

## Prerequisites

* helm
* access to an eks cluster
* docker
* role with permission to access a dynmaodb [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)

## Build Image

Build the image using the following command

```bash
docker build -t ${DOCKER_REGISTERY}/simple-go-app:${version} ./ 
docker push ${DOCKER_REGISTERY}/simple-go-app:${version}
```

Set `DOCKER_REGISTERY` and  `version` as needed.

## Deploymemt

1. Create a copy of the values-dev file. Updating the values as needed
2. Install chart onto cluster with the following command

```bash
helm upgrade app charts/simple-go-app --install --create-namespace -n simple-go-app -f charts/simple-go-app/values-dev.yaml
```

### Clean Up

Uninstall the application with the following command

```bash
helm uninstall app -n simple-go-app
```

## Application Description

The API has four endpoints

* `/` returns "Home"
* `/upsert` creates or updates an item
* `/show` returns the item
* `/error` throws an error
