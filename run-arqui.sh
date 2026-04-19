#!/bin/bash

set -e

cd arqui || exit 1

case "$1" in
    run)
        make run TOP=$2
        ;;
    wave)
        make wave TOP=$2
        ;;
    all)
        make run-all
        ;;
    clean)
        make clean
        ;;
    list)
        echo "📋 Testbenches disponibles:"
        ls tb/*.sv | xargs -n1 basename | sed 's/.sv//'
        ;;
    *)
        echo "Uso:"
        echo "./run.sh run <tb_name>"
        echo "./run.sh wave <tb_name>"
        echo "./run.sh all"
        echo "./run.sh list"
        echo "./run.sh clean"
        ;;
esac