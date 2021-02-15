# Polkadot snapshot generator

This is a self-container Kuberneted cluster to generate Polkadot snapshots, deployable with just one command.

When running your own polkadot validation operations, it is essential to be able to quickly recover from a disaster. Snapshots help you to get a node fully synchronized sooner.

These snapshots are available at [Polkashots](https://polkahots.io), but you may want to deploy the entire snapshot generation engine yourself, so your disaster recovery plan does not depend on any third-party services.

## Features

* runs a Kubernetes node
* leverages the Kubernetes Persistent Volume Snapshot feature: takes a snapshot of the storage at filesystem level before generating the polkadot snapshot
* runs the snapshot generation job on a configurable cron schedule
* generates markdown metadata and a Jekyll static webpage describing the snapshots
* deploys snapshot and static webpage to Firebase

## How to deploy

### Prerequisites

1. Download and install [Terraform](https://terraform.io)

1. Download, install, and configure the [Google Cloud SDK](https://cloud.google.com/sdk/).

1. Install the [kubernetes
   CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (aka
   `kubectl`)

1. Download and install the [Firebase CLI](https://firebase.google.com/docs/cli).

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

Below is a list of variables you must set in `terraform.tfvars` using the `variable=value` format.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | Billing account ID. | `string` | `""` | no |
| chain | chain (polkadot, kusama) | `string` | `"polkadot"` | no |
| cluster\_ca\_certificate | kubernetes cluster certificate | `string` | `""` | no |
| cluster\_name | name of the kubernetes cluster | `string` | `""` | no |
| database | the database backend to use | `string` | `"RocksDb"` | no |
| firebase\_project | name of the firebase project for the snapshot website | `string` | `""` | no |
| firebase\_subdomain | name of the firebase subdomain to generate proper urls in examples | `string` | `"dot"` | no |
| firebase\_token | firebase token (secret) to publish to the polkashots website | `string` | `""` | no |
| kubernetes\_access\_token | name of the kubernetes endpoint | `string` | `""` | no |
| kubernetes\_endpoint | name of the kubernetes endpoint | `string` | `""` | no |
| kubernetes\_name\_prefix | kubernetes name prefix to prepend to all resources (should be short, like dot) | `string` | `"dot"` | no |
| kubernetes\_namespace | kubernetes namespace to deploy the resource into | `string` | `"tzshots"` | no |
| kubernetes\_pool\_name | when kubernetes cluster has several node pools, specify which ones to deploy the baking setup into. only effective when deploying on an external cluster with terraform\_no\_cluster\_create | `string` | `"blockchain-pool"` | no |
| node\_locations | Zones in which to create the nodes | `list` | <pre>[<br>  "us-central1-b",<br>  "us-central1-f"<br>]</pre> | no |
| org\_id | Organization ID. | `string` | `""` | no |
| polkadot\_version | The polkadot container software version | `string` | `"latest-release"` | no |
| project | Project ID where Terraform is authenticated to run to create additional projects. If provided, Terraform will great the GKE and Polkadot cluster inside this project. If not given, Terraform will generate a new project. | `string` | `""` | no |
| region | Region in which to create the cluster, or region where the cluster exists. | `string` | `"us-central1"` | no |
| snapshot\_cron\_schedule | the schedule on which to generate snapshots, in cron format | `string` | `"7 13 * * *"` | no |
| snapshot\_url | url of the snapshot of type full to download | `string` | `""` | no |
| terraform\_service\_account\_credentials | path to terraform service account file, created following the instructions in https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform | `string` | `"~/.config/gcloud/application_default_credentials.json"` | no |


#### Google Cloud project

A default Google Cloud project should have been created when you activated your account. Verify its ID with `gcloud projects list`. You may also create a dedicated project to deploy the cluster.

Set the project id in the `project` terraform variable.

#### Polkadot version (optional)

Set the `polkadot_version` variable to the desired branch of the polkadot software release.

#### Database format

Set the `database` parameter to either `ParityDb` or `RocksDb`.

#### Snapshot url (optional)

Yes, the snapshot engine also can take a snapshot to sync faster. Pass the snapshot URL as `snapshot_url` parameter.

#### Firebase args

Note: I tried to make the firebase project and the token automatically with terraform, but there was a bug. See `terraform/firebase.tf`

For now, the terraform project must be created separately, and a CI token must be created with the `firebase login:ci` command.

Then pass the project id as `firebase_project` and the token as `firebase_token`.

Also pass `firebase_subdomain` so the snapshot webpage example points to the correct URL.

#### Snapshot cron schedule (optional)

Fill the `snapshot_cron_schedule` variable if you want to alter how often or when the snapshot generation cronjob runs.

#### Full example of terraform.tfvars

More variables, can be configured, see terraform/variables.tf file for details. Below is a full example:

```
project = "My Project"
kubernetes_namespace="dop"
kubernetes_name_prefix="dop"
pokladot_version="v0.8.26-1"
firebase_project = "polkashots-dot"
firebase_subdomain = "dot"
firebase_token = "1//0xxxxxxxxxxxx"
snapshot_url = "https://dot.polkashots.io/snapshot"
snapshot_cron_schedule = "43 2,14 * * *"
database = "ParityDb"
```

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
