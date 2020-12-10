# FIXME
# This gives the following error:

# Error: Error creating Project: googleapi: Error 403: Your application has authenticated using end user credentials from the Google Cloud SDK or Google Cloud Shell which are not supported by the firebase.googleapis.com. We recommend configuring the billing/quota_project setting in gcloud or using a service account through the auth/impersonate_service_account setting. For more information about service accounts and how to use them in your application, see https://cloud.google.com/docs/authentication/.

# But we are using a service account, so the error message does not make sense. For now, the firebase projects have to be created manually.

#resource "google_firebase_project" "default" {
#    provider = google-beta
#    project = module.terraform-gke-blockchain.project 
#}
#
#
#resource "google_firebase_web_app" "snapshot_app" {
#    provider = google-beta
#    project = module.terraform-gke-blockchain.project 
#    display_name = "Polkadot ${var.tezos_network} snapshot app"
#
#    depends_on = [google_firebase_project.default]
#}
#
#data "google_firebase_web_app_config" "snapshot_app_config" {
#  provider   = google-beta
#  web_app_id = google_firebase_web_app.snapshot_app.app_id
#}
