#!/bin/sh

NETWORK="goerli"
VALIDATOR_PORT=3500

# MEVBOOST: https://github.com/ChainSafe/lodestar/blob/unstable/docs/usage/mev-integration.md
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_PRATER" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_PRATER" == "true" ]; then
    echo "MEVBOOST is enabled"
    MEVBOOST_URL="http://mev-boost.mev-boost-goerli.dappnode:18550"
    if curl --retry 5 --retry-delay 5 --retry-all-errors "${MEVBOOST_URL}"; then
        EXTRA_OPTS="--builder ${EXTRA_OPTS}"
    else
        echo "MEVBOOST is enabled but ${MEVBOOST_URL} is not reachable"
        curl -X POST -G 'http://my.dappnode/notification-send' --data-urlencode 'type=danger' --data-urlencode title="${MEVBOOST_URL} is not available" --data-urlencode 'body=Make sure the mevboost is available and running'
    fi
fi

#Handle Graffiti Character Limit
oLang=$LANG oLcAll=$LC_ALL
LANG=C LC_ALL=C 
graffitiString=${GRAFFITI:0:32}
LANG=$oLang LC_ALL=$oLcAll

exec node /usr/app/node_modules/.bin/lodestar \
    validator \
    --network=${NETWORK} \
    --suggestedFeeRecipient=${FEE_RECIPIENT_ADDRESS} \
    --graffiti=${graffitiString} \
    --dataDir /var/lib/data \
    --keymanager true \
    --keymanager.authEnabled true \
    --keymanager.port 3500 \
    --keymanager.address 0.0.0.0 \
    --metrics \
    --metrics.port 5064 \
    --metrics.address 0.0.0.0 \
    --externalSigner.url=${HTTP_WEB3SIGNER} \
    --doppelgangerProtectionEnabled \
    --beaconNodes=${BEACON_NODE_ADDR} \
    --logLevel=${DEBUG_LEVEL} \
    --logFileLevel=${DEBUG_LEVEL} \
    --logFileDailyRotate 5 \
    --logFile /var/lib/data/validator.log \
    $EXTRA_OPTS
