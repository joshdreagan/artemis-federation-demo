# Artemis Federation Demo

![Artemis Federation Demo - Architecture](img/architecture.png)

## TLS

Create the DC1 and DC2 keystores.

```
env \
BROKER_NAME=artemis-broker \
BROKER_COUNT=2 \
DOMAIN=apps.cluster-zz9jt.zz9jt.sandbox2715.opentlc.com \
NAMESPACE=dc1 \
KEYSTORE=./tls/dc1-broker-keystore.jks \
KEYSTORE_PASS=password \
./bin/generate-keystore.sh

env \
BROKER_NAME=artemis-broker \
BROKER_COUNT=2 \
DOMAIN=apps.cluster-zz9jt.zz9jt.sandbox2715.opentlc.com \
NAMESPACE=dc2 \
KEYSTORE=./tls/dc2-broker-keystore.jks \
KEYSTORE_PASS=password \
./bin/generate-keystore.sh
```

Generate the DC1 and DC2 truststores.

```
env \
KEYSTORE_DC=dc2 \
KEYSTORE=./tls/dc2-broker-keystore.jks \
KEYSTORE_PASS=password \
TRUSTSTORE=./tls/dc1-broker-truststore.jks \
TRUSTSTORE_PASS=password \
./bin/generate-truststore.sh

env \
KEYSTORE_DC=dc1 \
KEYSTORE=./tls/dc1-broker-keystore.jks \
KEYSTORE_PASS=password \
TRUSTSTORE=./tls/dc2-broker-truststore.jks \
TRUSTSTORE_PASS=password \
./bin/generate-truststore.sh
```

(Optional) Generate the client truststore.

```
env \
KEYSTORE_DC=dc1 \
KEYSTORE=./tls/dc1-broker-keystore.jks \
KEYSTORE_PASS=password \
TRUSTSTORE=./tls/client-truststore.jks \
TRUSTSTORE_PASS=password \
./bin/generate-truststore.sh

env \
KEYSTORE_DC=dc2 \
KEYSTORE=./tls/dc2-broker-keystore.jks \
KEYSTORE_PASS=password \
TRUSTSTORE=./tls/client-truststore.jks \
TRUSTSTORE_PASS=password \
./bin/generate-truststore.sh
```

## DC1

Create the OpenShift namespace.

```
oc new-project dc1
```

Install the AMQ Broker Operator using OperatorHub (must be done as a cluster-admin). You can do this per-namespace, or globally across all namespaces.

Create and configure a AMQ Broker cluster. __Note: You must modify the `artemis-broker.yaml` file with your environment specific information before you apply it. You can either do this manually by simply editing the file, or you can use the `envsubst` command as shown below.__

```
#
# Create the secret containing the broker's keystore and truststore.
oc create secret generic -n dc1 artemis-broker-tls-secret --from-file=broker.ks=./tls/dc1-broker-keystore.jks --from-file=client.ts=./tls/dc1-broker-truststore.jks --from-literal=keyStorePassword=password --from-literal=trustStorePassword=password

#
# Apply the authorization policies for the broker and console.
oc apply -n dc1 -f ./dc1/artemis-security.yaml

#
# Modify the broker cluster CR with your environment specific details and apply. Make sure to use the `${STATEFUL_SET_ORDINAL}` placeholder in your host string so that the federation applies properly (ie, ordinal-0 -> ordinal-0, ordinal-1 -> ordinal-1, ... etc). You can retrieve the generated admin password for the DC2 cluster via the web console, or via the following command `oc get secret -n dc2 security-properties-broker-prop-module -o=jsonpath='{.data.admin}' | base64 -d`. However, you must have applied the `artemis-security.yaml` in DC2 for this secret to have been generated. So you might have to hop back and forth between DC's just a bit.
env \
DC2_HOST='artemis-broker-core-tls-${STATEFUL_SET_ORDINAL}-svc-rte-dc2.apps.cluster-zz9jt.zz9jt.sandbox2715.opentlc.com' \
DC2_PORT=443 \
DC2_USER=admin \
DC2_PASS='4CrF5Ulk' \
bash -c 'cat ./dc1/artemis-broker.yaml | envsubst | oc apply -n dc1 -f-'

#
# Apply the addresses to be created on the brokers.
oc apply -n dc1 -f ./dc1/artemis-addresses.yaml
```

## DC2

Create the OpenShift namespace.

```
oc new-project dc2
```

Install the AMQ Broker Operator using OperatorHub (must be done as a cluster-admin). You can do this per-namespace, or globally across all namespaces.

Create and configure a AMQ Broker cluster. __Note: You must modify the `artemis-broker.yaml` file with your environment specific information before you apply it. You can either do this manually by simply editing the file, or you can use the `envsubst` command as shown below.__

```
#
# Create the secret containing the broker's keystore and truststore.
oc create secret generic -n dc2 artemis-broker-tls-secret --from-file=broker.ks=./tls/dc2-broker-keystore.jks --from-file=client.ts=./tls/dc2-broker-truststore.jks --from-literal=keyStorePassword=password --from-literal=trustStorePassword=password

#
# Apply the authorization policies for the broker and console.
oc apply -n dc2 -f ./dc2/artemis-security.yaml

#
# Modify the broker cluster CR with your environment specific details and apply. Make sure to use the `${STATEFUL_SET_ORDINAL}` placeholder in your host string so that the federation applies properly (ie, ordinal-0 -> ordinal-0, ordinal-1 -> ordinal-1, ... etc). You can retrieve the generated admin password for the DC1 cluster via the web console, or via the following command `oc get secret -n dc1 security-properties-broker-prop-module -o=jsonpath='{.data.admin}' | base64 -d`. However, you must have applied the `artemis-security.yaml` in DC1 for this secret to have been generated. So you might have to hop back and forth between DC's just a bit.
env \
DC1_HOST='artemis-broker-core-tls-${STATEFUL_SET_ORDINAL}-svc-rte-dc1.apps.cluster-zz9jt.zz9jt.sandbox2715.opentlc.com' \
DC1_PORT=443 \
DC1_USER=admin \
DC1_PASS='lIZmbMVg' \
bash -c 'cat ./dc2/artemis-broker.yaml | envsubst | oc apply -n dc2 -f-'

#
# Apply the addresses to be created on the brokers.
oc apply -n dc2 -f ./dc2/artemis-addresses.yaml
```
