#!/usr/bin/env bash

DEPLOYMENT=$(dirname "$0")/../deployment

KUBECONFIG=$DEPLOYMENT/${kubeconfig} helm "$@"
