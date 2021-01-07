#!/bin/bash

# Use this script to validate terraform, kubernetes and docker syntax.
# Requires docker as a dependency.
# This requires an internet connection for terraform init
# and docker pull (which needs only happen once).
# For the docker pull to work, you need to be logged in to docker hub.
# This also requires a kubernetes server backend, see issue:
#   https://github.com/kubernetes/kubernetes/issues/51475

set -ex

# validate terraform syntax with `terraform validate`
cd terraform
terraform init
terraform validate

cd ..

# validate kubernetes syntax with `kubectl apply --dry-run`
cd validate
terraform init
terraform destroy -auto-approve
terraform apply -auto-approve
terraform destroy -auto-approve

if ! ls hadolint; then
    # download hadolink, a dockerfile linter
    id=$(docker create hadolint/hadolint:latest)
    docker cp "$id":/bin/hadolint .
    docker rm "$id"
fi

# Lint all dockerfiles, but ignore pinning warnings.
# It is safer to have stable versions of everything.
find ../docker/ -name  Dockerfile.template | xargs ./hadolint --ignore DL3008 --ignore DL3018 --ignore DL3016 --ignore DL3006

cd ..
