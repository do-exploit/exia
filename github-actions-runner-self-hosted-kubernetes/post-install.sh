#!/bin/bash

kubectl create clusterrolebinding arc-exia-examples-deployer \
  --clusterrole=cluster-admin \
  --serviceaccount=arc-runners-workers:arc-exia-examples-gha-rs-no-permission
