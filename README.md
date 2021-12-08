# CNF Certification Partner

This repository contains two main sections:
* test-partner:  Partner debug pods definition for use on a k8s CNF Certification cluster. Used to run platform and networking tests.
* test-target:  A trivial example CNF (including a replicaset/deployment, a CRD and an operator), primarily intended to be used to run [test-network-function](https://github.com/test-network-function/test-network-function) test suites on a development machine.

Together, they make up the basic infrastructure required for "testing the tester". The partner debug pod is always required for platform tests and networking tests.

# Glossary

* Pod Under Test (PUT): The Vendor Pod, usually provided by a CNF Partner.
* Operator Under Test (OT): The Vendor Operator, usually provided by a CNF Partner.
* Debug Pod (DP): A Pod running [RHEL support tool image](https://catalog.redhat.com/software/containers/rhel8/support-tools/5ba3eaf9bed8bd6ee819b78b) deployed as part of a daemon set for accessing node information. DPs is deployed in "default" namespace
* CRD Under Test (CRD): A basic CustomResourceDefinition.


# Namespace

By default, DP are deployed in "default" namespace. all the other deployment files in this repository use ``tnf`` as default namespace. A specific namespace can be configured using:

```shell-script
export TNF_EXAMPLE_CNF_NAMESPACE="tnf" #tnf for example
```
## Cloning the repository

The repository can be cloned to local machine using:

```shell-script
git clone git@github.com:test-network-function/cnf-certification-test-partner.git
```
## Installing the partner pod

In order to create and deploy the partner debug pods (daemonset), use the following:

```shell-script
make install-partner-pods
```

This will create a deployment named "partner" in the "default" namespace.  This Pod is the test partner for running CNF tests.
For disconnected environments, override the default image repo `quay.io/testnetworkfunction` by setting the environment variable named `TNF_PARTNER_REPO` to the local repo.
For environments with slow internet connection, override the default deployment timeout value (120s) by setting the environment variable named `TNF_DEPLOYMENT_TIMEOUT`.

# Test-target

Although any CNF Certification results should be generated using a proper CNF Certification cluster, there are times
in which using a local emulator can greatly help with test development.  As such, [test-target](./test-target)
provides a very simple PUT, OT, CRD, which satisfies the minimal requirements to perform test cases.
These can be used in conjunction with a local kind or [minikube](https://minikube.sigs.k8s.io/docs/) cluster to perform local test development.


## Dependencies

In order to run the local test setup, the following dependencies are needed:
* [minikube](https://minikube.sigs.k8s.io/docs/)
* [VirtualBox](https://www.virtualbox.org/) (or another driver for minikube)
* [oc client](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html#cli-linux)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup
Install the latest minikube by following the instructions at:
```https://minikube.sigs.k8s.io/docs/start/```

To start minikube, issue the following command:

```shell-script
minikube start --embed-certs --driver="virtualbox" --nodes 3 --network-plugin=cni --cni=calico 
```

The `--embed-certs` flag will cause minikube to embed certificates directly in its kubeconfig file.  
This will allow the minikube cluster to be reached directly from the container without the need of binding additional volumes for certificates.

The `--nodes 3` flag creates a cluster with one master node and two worker nodes. This is to support anti-affinity and pod-recreation test case.

The  `--network-plugin=cni --cni=calico` flags configure CNI support and installs Calico. This is required to install Multus later on.

To avoid having to specify this flag, set the `embed-certs` configuration key:

```shell-script
minikube config set embed-certs true
```
Or Alternatively, run:
```shell-script
make rebuild-minikube
```

## Deploy both test target and test partner as a local-test-infra

To create the resources, issue the following command:

```shell-script
make install
```

This will create a PUT named "test" in `TNF_EXAMPLE_CNF_NAMESPACE` [namespace](#namespace) and Debug Daemonset named "debug". The
example `tnf_config.yml` in [`test-network-function`](https://github.com/test-network-function/test-network-function)
will use this local infrastructure by default.

Note that this command also creates OT and CRD resources.

To verify `test` pods are running: 

```shell-script
oc get pods -n $TNF_EXAMPLE_CNF_NAMESPACE -o wide
```

You should see something like this (note that the 2 test pods are running on different nodes due to a anti-affinity rule):
```shell-script
NAME                                                              READY   STATUS      RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
4c926df73b15df26b6874260a4f71ca3bf7c6ce2bdfd87aa90759a6aeb5rhpk   0/1     Completed   0          59s     10.244.0.5   minikube       <none>           <none>
nginx-operator-controller-manager-7f8f449fbd-fvn4f                2/2     Running     0          44s     10.244.0.6   minikube       <none>           <none>
quay-io-testnetworkfunction-nginx-operator-bundle-v0-0-1          1/1     Running     0          69s     10.244.2.6   minikube-m03   <none>           <none>
test-697ff58f87-88245                                             1/1     Running     0          2m20s   10.244.2.2   minikube-m03   <none>           <none>
test-697ff58f87-mfmpv                                             1/1     Running     0          2m20s   10.244.1.3   minikube-m02   <none>           <none>
```
## Delete local-test-infra

To tear down the local test infrastruture from the cluster, use the following command. It may take some time to completely stop the PUT, CRD, OT, and DP:

```shell-script
make clean
```
