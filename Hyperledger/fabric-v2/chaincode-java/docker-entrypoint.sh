#!/usr/bin/env bash
#
# SPDX-License-Identifier: Apache-2.0
#
set -euo pipefail
: ${CORE_PEER_TLS_ENABLED:="false"}
: ${DEBUG:="false"}

if [ "${DEBUG,,}" = "true" ]; then
   exec java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:8000 -jar /app/build/libs/chaincode.jar
elif [ "${CORE_PEER_TLS_ENABLED,,}" = "true" ]; then
   exec java -jar /app/build/libs/chaincode.jar # todo
else
   exec java -jar /app/build/libs/chaincode.jar
fi