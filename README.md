# Polkadot snapshot generator

This is a self-container Kuberneted cluster to generate Polkadot snapshots, deployable with just one command.

When running your own polkadot baking operations, it is essential to be able to quickly recover from a disaster. Snapshots help you to get a node fully bootstrapped sooner.

These snapshots are available at [Polkashots](https://polkahots.io), but you may want to deploy the entire snapshot generation engine yourself, so your disaster recovery plan does not depend on any third-party services.

## Features

* runs a Kubernetes full node with "full" storage mode
* leverages the Kubernetes Persistent Volume Snapshot feature: takes a snapshot of the storage at filesystem level before generating the polkadot snapshot
* runs the snapshot generation job on a configurable cron schedule, for both "full" and "rolling" modes
* generates markdown metadata and a Jekyll static webpage describing the snapshots
* deploys snapshot and static webpage to Firebase

## How to deploy

### Prerequisites

1. Download and install [Terraform](https://terraform.io)

1. Download, install, and configure the [Google Cloud SDK](https://cloud.google.com/sdk/).

1. Install the [kubernetes
   CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (aka
   `kubectl`)


### Authentication

Using your Google account, active your Google Cloud access.

Login to gcloud using `gcloud auth login`

Set up [Google Default Application Credentials](https://cloud.google.com/docs/authentication/production) by issuing the command:

```
gcloud auth application-default login
```

### Populate terraform variables

All custom values unique to your deployment are set as terraform variables. You must populate these variables manually before deploying the setup.

A simple way is to populate a file called `terraform.tfvars`.

First, go to `terraform` folder:

```
cd terraform
```

Below is a list of variables you must set.

#### Google Cloud project

A default Google Cloud project should have been created when you activated your account. Verify its ID with `gcloud projects list`. You may also create a dedicated project to deploy the cluster.

Set the project id in the `project` terraform variable.

#### Polkadot version (optional)

Set the `polkadot_version` variable to the desired branch of the polkadot software release.

#### Snapshot url (optional)

Yes, the snapshot engine also can take a snapshot to sync faster. Pass the snapshot URL as `snapshot_url` parameter.

#### Firebase args

Note: I tried to make the firebase project and the token automatically with terraform, but there was a bug. See `terraform/firebase.tf`

For now, the terraform project must be created separately, and a CI token must be created with the `firebase login:ci` command.

Then pass the project id as `firebase_project` and the token as `firebase_token`.

#### Snapshot cron schedule (optional)

Fill the `snapshot_cron_schedule` variable if you want to alter how often or when the snapshot generation cronjob runs.

### Deploy

1. Run the following:

```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

This will take time as it will:
* create a Google Cloud project
* create a Kubernetes cluster
* build the necessary containers
* push the kubernetes configuration, which will spin up a node a start synchronization

In case of error, run the `plan` and `apply` steps again:

```
terraform plan -out plan.out
terraform apply plan.out
```

### Connect to the cluster

Once the command returns, you can verify that the pods are up by running:

```
kubectl get pods
```

## Wrapping up

To delete everything and terminate all the charges, issue the command:

```
terraform destroy
```

Alternatively, go to the GCP console and delete the project.
