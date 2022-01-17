
# SimpleGoApp

This porject deploys a simple go app inside a EKS Cluster

## Prerequisites

* helm
* access to an eks clusterr
* role with permission to access a dynmaodb [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)

## Deploymemt

1. Create a copy of the values-dev file. Updating the values as needed
2. Install chart onto cluster with the following command

```bash
helm upgrade app charts/simple-go-app --install --create-namespace -n simple-go-app -f charts/application/values-dev.yaml
```

## Application Description

The API has four endpoints

* `/` returns "Home"
* `/upsert` creates or updates an item
* `/show` returns the item
* `/error` throws an error

## Coding Challenge 

Here we have simple API that updates a single item in a DynamoDB table and retreives the value.

# Your Task

Write the infrastructure as code that will stand up this API in AWS.
You may use any technique or tooling that you like.
We would like to see you tackle areas like observability, security and scalability.
Take it as far as you like, to the point where you would be happy going to production.

If you choose to use Lambda, you can alter the code as you like to get it to run.

## Other information

Please include a Readme with any additional information you would like to include. You may wish to use it to explain any design decisions.

Despite this being a small API, please approach this as you would a production problem using whatever approach to coding and infrastructure you feel appropriate. Successful candidates will be asked to extend their implementation in a pair programming session as a component of the interview.

## Submitting your solution

Assuming you use Git, when you’re ready to submit your solution, please use `git bundle` to package up a copy of your repository (with complete commit history) as a single file and send it to us as an email attachment.

```
git bundle create sre-interview-submission.bundle master
```

We're looking forward to your innovative solutions!