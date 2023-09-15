#!/usr/bin/env bash

if [[ -z "${KEYSTORE}" ]]; then echo "'KEYSTORE' environment variable must be set"; exit 1; fi;
if [[ -z "${KEYSTORE_PASS}" ]]; then echo "'KEYSTORE_PASS' environment variable must be set"; exit 1; fi;
if [[ -z "${KEYSTORE_DC}" ]]; then echo "'KEYSTORE_DC' environment variable must be set"; exit 1; fi;
if [[ -z "${TRUSTSTORE}" ]]; then echo "'TRUSTSTORE' environment variable must be set"; exit 1; fi;
if [[ -z "${TRUSTSTORE_PASS}" ]]; then echo "'TRUSTSTORE_PASS' environment variable must be set"; exit 1; fi;

CERT="${TMPDIR}/${KEYSTORE_DC}-broker-external.crt"
keytool -export -alias broker-external -keystore "${KEYSTORE}" -storepass "${KEYSTORE_PASS}" -file "${CERT}"
keytool -import -noprompt -alias "${KEYSTORE_DC}-broker-external" -keystore "${TRUSTSTORE}" -storepass "${TRUSTSTORE_PASS}" -file "${CERT}"
if [[ -e "${CERT}" ]]; then rm "${CERT}"; fi;
