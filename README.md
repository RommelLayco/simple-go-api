
# SimpleGoApp

This porject deploys a simple go app inside a EKS Cluster

## Prerequisites

* helm
* terraform
* docker

## Build Image

Build the image using the following command

```bash
docker build -t ${DOCKER_REGISTERY}/simple-go-app:${version} ./ 
docker push ${DOCKER_REGISTERY}/simple-go-app:${version}
```

Set `DOCKER_REGISTERY` and  `version` as needed.

## Deploymemt

### Terraform deployment

To deploy the eks run the folloing commands

1. Initialise and create terraform workspace on first deployment

    ```bash
    cd terraform && terraform init && terraform workspace new dev
    ```

2. Copy the config/dev.tfvars and replace values as needed.

3. Deploy terraform stack with the following command. Replace the config with your tfvars file

    ```bash
    terraform apply -var-file config/dev.tfvars
    ```

### Helm

1. Create a copy of the values-dev file. Updating the values as needed. See terraform outputs for values needed

2. Obtain kubeclt credentials by running the following command while you have assumed the `kubernetes_admin_role_arn`
   See <https://aws.amazon.com/premiumsupport/knowledge-center/eks-cluster-connection/>

    ```bash
    aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}
    ```

    **NB** See terraform outputs for `cluster_name` and `aws_region`

3. Install chart onto cluster with the following command

    ```bash
    helm upgrade app charts/simple-go-app --install --create-namespace -n simple-go-app -f charts/simple-go-app/values-dev.yaml
    ```

    **NB** ensure you are in the root of the project

### Clean Up

Uninstall the application with the following command

```bash
helm uninstall app -n simple-go-app
cd terraform
terraform destroy -var-file config/dev.tfvars
```

## Application Description

The API has four endpoints

* `/` returns "Home"
* `/upsert` creates or updates an item
* `/show` returns the item
* `/error` throws an error
