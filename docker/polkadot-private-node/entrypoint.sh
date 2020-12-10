#!/bin/bash

set -e
set -x

if [ -e /polkadot-node-keys/$(hostname) ]; then
    node_key_param="--node-key $(cat /polkadot-node-keys/$(hostname))"
fi

if [ ! -z "$CHAIN" ]; then
    chain_param="--chain \"$CHAIN\""
fi

if [ ! -z "$DATABASE" ]; then
    database_param="--database \"$DATABASE\""
fi

# unsafe flags are due to polkadot panic alerter needing to connect to the node with rpc
eval /usr/bin/polkadot --wasm-execution Compiled \
         --prometheus-external \
         --rpc-external \
         --rpc-cors=all \
         $node_key_param \
         $chain_param \
         $database_param
