#!/bin/bash

set -e

cd arqui || exit 1

case "$1" in
    run)
        VVP_FLAGS="${*:3}"
        if [ "$2" = "tb_general_dump" ] && [ -n "$3" ] && [[ "$3" != +* ]]; then
            ROM_ARG="$3"
            if [[ "$ROM_ARG" != */* ]]; then
                ROM_ARG="programs/$ROM_ARG"
            fi
            OUT_NAME="$(basename "$ROM_ARG" .hex)"
            VVP_FLAGS="+ROM=$ROM_ARG +OUT=$OUT_NAME ${*:4}"
        fi
        make run TOP=$2 VVP_FLAGS="$VVP_FLAGS"
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
        echo "./run.sh run tb_general_dump factorial.hex"
        echo "./run.sh run <tb_name> \"+ROM=programs/demo.hex +OUT=demo\""
        echo "./run.sh wave <tb_name>"
        echo "./run.sh all"
        echo "./run.sh list"
        echo "./run.sh clean"
        ;;
esac
