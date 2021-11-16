#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")
source $SCRIPT_DIR/init-env.sh

# Delete the hpa 
kubectl delete hpa test -n ${TNF_EXAMPLE_CNF_NAMESPACE}
# Delete test deployment
oc delete  deployment.apps/hpa -n ${TNF_EXAMPLE_CNF_NAMESPACE}

