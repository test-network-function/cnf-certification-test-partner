#!/usr/bin/env bash

# Initialization
SCRIPT_DIR=$(dirname "$0")

# shellcheck disable=SC1091 # Not following.
source "$SCRIPT_DIR"/init-env.sh

# Delete tnf, partner and operator
./"$SCRIPT_DIR"/delete-test-pods.sh
./"$SCRIPT_DIR"/delete-special-resources.sh
./"$SCRIPT_DIR"/delete-hpa.sh
./"$SCRIPT_DIR"/delete-test-crds.sh
./"$SCRIPT_DIR"/delete-statefulset-pods.sh
./"$SCRIPT_DIR"/delete-community-operator.sh
./"$SCRIPT_DIR"/delete-resource-quota.sh
./"$SCRIPT_DIR"/delete-pod-disruption-budget.sh
./"$SCRIPT_DIR"/delete-cr-scale-operator.sh
./"$SCRIPT_DIR"/delete-storage.sh
