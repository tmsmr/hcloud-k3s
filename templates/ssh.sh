#!/usr/bin/env bash

DEPLOYMENT=$(dirname "$0")/../deployment

ssh -i "$DEPLOYMENT/id_ecdsa" -o UserKnownHostsFile="$DEPLOYMENT/known_hosts" root@${node_ip} "$@"
