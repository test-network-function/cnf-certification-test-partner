#!/usr/bin/env bash


SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR"/init-env.sh
CRD_SCALING_URL="https://github.com/test-network-function/crd-operator-scaling.git"
git clone $CRD_SCALING_URL
## install the operator
cd crd-operator-scaling
## install the crd
uname -a
file bin/controller-gen
file bin/kustomize
chmod +x bin/controller-gen
chmod +x bin/kustomize
gcc -g -Wall bin/kustomize.c -o bin/kustomize
gcc -g -Wall bin/controller-gen.c -o bin/bin/controller-gen

make manifests
make install
make deploy IMG=quay.io/testnetworkfunction/crd-operator-scaling:latest

oc wait deployment new-pro-controller-manager -n "$TNF_EXAMPLE_CNF_NAMESPACE" --for=condition=available --timeout=240s

make addrole
kubectl apply -f config/samples  --validate=false