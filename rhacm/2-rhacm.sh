#!/bin/bash

source 0-setup_env.sh

if [ -z "${RED_HAT_PULL_SECRET_PATH}" ]; then echo "You must export the RED_HAT_PULL_SECRET_PATH environment variable prior to run the RHACM installer."; exit 999; fi

#
# Create Operator Namespace
#
oc new-project $RHACM_NAMESPACE

#
# Create RH pull secret
#
oc create secret generic $RHACM_SECRET_NAME -n $RHACM_NAMESPACE --from-file=.dockerconfigjson=$RED_HAT_PULL_SECRET_PATH --type=kubernetes.io/dockerconfigjson

#
# Create Operator Group
#
oc create -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: $RHACM_OPERATOR_GROUP_NAME
spec:
  targetNamespaces:
  - $RHACM_NAMESPACE
EOF

#
# Apply the subscription
#
oc create -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: acm-operator-subscription
spec:
  sourceNamespace: openshift-marketplace
  source: redhat-operators
  channel: release-2.0
  installPlanApproval: Automatic
  name: advanced-cluster-management
EOF

#
# Wait for RHACM Subscription to be created
#
log "Waiting for RHACM Subscription (180 seconds)"
progress-bar 180

#
# Create the Installation
#
log "Applying the RHACM 2.0 - Multiclusterhub Installation"
cat << EOF | oc apply -f -
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
  name: multiclusterhub
  namespace: $RHACM_NAMESPACE
spec:
  imagePullSecret: $RHACM_SECRET_NAME
EOF

#
# Wait for Installation to be created
#
log "Waiting for multiclusterhub to start (5 minutes)"
progress-bar 300

rhacmstatus

#
# Get the route
#
RHACM_ROUTE=`oc get route multicloud-console --template '{{.spec.host}}'`
printf "\r"
log "RHACM has been successfully installed. You can access it at https://$RHACM_ROUTE"
printf "\r"
