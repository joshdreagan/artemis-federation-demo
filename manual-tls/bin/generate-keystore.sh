#!/usr/bin/env bash

if [[ -z "${BROKER_NAME}" ]]; then echo "'BROKER_NAME' environment variable must be set"; exit 1; fi;
if [[ -z "${BROKER_COUNT}" ]]; then echo "'BROKER_COUNT' environment variable must be set"; exit 1; fi;
if [[ -z "${DOMAIN}" ]]; then echo "'DOMAIN' environment variable must be set"; exit 1; fi;
if [[ -z "${NAMESPACE}" ]]; then echo "'NAMESPACE' environment variable must be set"; exit 1; fi;
if [[ -z "${KEYSTORE}" ]]; then echo "'KEYSTORE' environment variable must be set"; exit 1; fi;
if [[ -z "${KEYSTORE_PASS}" ]]; then echo "'KEYSTORE_PASS' environment variable must be set"; exit 1; fi;

if [[ -e "${KEYSTORE}" ]]; then echo "WARN: Key store file already exists [${KEYSTORE}]"; fi;

ADJ_BROKER_COUNT=$((${BROKER_COUNT}-1))

#
# Generate the key pair for external access
CN=${BROKER_NAME}-*-svc-rte-${NAMESPACE}.${DOMAIN}
SAN=
SAN+=$(printf "DNS:${BROKER_NAME}-core-tls-%s-svc-rte-${NAMESPACE}.${DOMAIN}," $(seq 0 ${ADJ_BROKER_COUNT}))
SAN+=$(printf "DNS:${BROKER_NAME}-amqp-tls-%s-svc-rte-${NAMESPACE}.${DOMAIN}," $(seq 0 ${ADJ_BROKER_COUNT}))
keytool -genkeypair -alias broker-external -keyalg RSA -dname "CN=${CN}" -ext "SAN=${SAN}" -keystore "${KEYSTORE}" -storepass "${KEYSTORE_PASS}"
