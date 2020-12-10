terraform {
  required_version = ">= 0.12"
}

variable "org_id" {
  type        = string
  description = "Organization ID."
  default = ""
}

variable "billing_account" {
  type        = string
  description = "Billing account ID."
  default = ""
}

variable "project" {
  type        = string
  default     = ""
  description = "Project ID where Terraform is authenticated to run to create additional projects. If provided, Terraform will great the GKE and Polkadot cluster inside this project. If not given, Terraform will generate a new project."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Region in which to create the cluster, or region where the cluster exists."
}

variable "node_locations" {
  type        = list
  default     = [ "us-central1-b", "us-central1-f" ]
  description = "Zones in which to create the nodes"
}


variable "kubernetes_namespace" {
  type = string
  description = "kubernetes namespace to deploy the resource into"
  default = "tzshots"
}

variable "kubernetes_name_prefix" {
  type = string
  description = "kubernetes name prefix to prepend to all resources (should be short, like dot)"
  default = "dot"
}

variable "kubernetes_endpoint" {
  type = string
  description = "name of the kubernetes endpoint"
  default = ""
}

variable "cluster_ca_certificate" {
  type = string
  description = "kubernetes cluster certificate"
  default = ""
}

variable "cluster_name" {
  type = string
  description = "name of the kubernetes cluster"
  default = ""
}

variable "kubernetes_access_token" {
  type = string
  description = "name of the kubernetes endpoint"
  default = ""
}

variable "terraform_service_account_credentials" {
  type = string
  description = "path to terraform service account file, created following the instructions in https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform"
  default = "~/.config/gcloud/application_default_credentials.json"
}

variable "kubernetes_pool_name" {
  type = string
  description = "when kubernetes cluster has several node pools, specify which ones to deploy the baking setup into. only effective when deploying on an external cluster with terraform_no_cluster_create"
  default = "blockchain-pool"
}

#
# Polkadot node and snapshotter options
# ------------------------------

variable "polkadot_version" {
  type =string
  description = "The polkadot container software version"
  default = "latest-release"
}

variable "snapshot_url" {
  type = string
  description = "url of the snapshot of type full to download"
  default = ""
}

variable "firebase_project" {
  type = string
  description = "name of the firebase project for the snapshot website"
  default = ""
}

variable "firebase_token" {
  type = string
  description = "firebase token (secret) to publish to the polkashots website"
  default = ""
}

variable "snapshot_cron_schedule" {
  type = string
  description = "the schedule on which to generate snapshots, in cron format"
  default = "7 13 * * *"
}

variable "chain" {
  type = string
  description = "chain (polkadot, kusama)"
  default = "polkadot"
}

variable "database" {
  type = string
  description = "the database backend to use"
  default = "RocksDb"
}
