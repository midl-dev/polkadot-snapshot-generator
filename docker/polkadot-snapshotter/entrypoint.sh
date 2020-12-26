#!/bin/sh

set -ex

if [ "${CHAIN}" == "polkadot" ]; then
    chain_dir=polkadot
else
    chain_dir=ksmcc3
fi

snapshot_name="polkadot-${BLOCK_HEIGHT}.${DATABASE}.7z"
ls /polkadot/.local/share/polkadot/chains/${chain_dir}/

rm -rvf /polkadot/.local/share/polkadot/chains/${chain_dir}/keystore
rm -rvf /polkadot/.local/share/polkadot/chains/${chain_dir}/network

7z a /mnt/snapshot-cache-volume/${snapshot_name} /polkadot/.local/share/polkadot/chains/${chain_dir}/*

snapshot_size=$(du -h /mnt/snapshot-cache-volume/${snapshot_name} | cut -f1)

BLOCK_TIMESTAMP=$(date --utc +%FT%T%Z)

mkdir -p /mnt/snapshot-cache-volume/firebase-files/
cat << EOF > /mnt/snapshot-cache-volume/firebase-files/index.md
---
# Page settings
layout: snapshot
keywords:
comments: false

# Hero section
title: $CHAIN snapshots
description: 

# Author box
author:
    title: Brought to you by MIDL.dev
    title_url: 'https://midl.dev/tezos-suite'
    external_url: true
    description: A proof-of-stake infrastructure company. We help you validate your DOT. <a href="https://MIDL.dev/polkadot" target="_blank">Learn more</a>.

# Micro navigation
micro_nav: true

# Page navigation
page_nav:
    home:
        content: Previous page
        url: 'https://polkashots.io/index.html'
---

# $CHAIN snapshot

| <!-- -->    | <!-- -->    |
|-------------|-------------|
| Chain        | ${CHAIN}         |
| Block height | $BLOCK_HEIGHT |
| Block hash | \`${BLOCK_HASH}\` |
| Creation data | $BLOCK_TIMESTAMP |
| Database format | ${DATABASE} |
| Pruning mode | Pruned |
| Compression format | 7z |
| Download link | [${snapshot_name}](${snapshot_name}) |
| Size | ${snapshot_size} |

[Verify on Polkastats](https://polkastats.io/block?blockNumber=${BLOCK_HEIGHT}){:target="_blank"} - [Verify on Polkascan](https://polkascan.io/$CHAIN/block/${BLOCK_HEIGHT}){:target="_blank"}

## How to use

Issue the following commands:

\`\`\`
wget https://${FIREBASE_SUBDOMAIN}.polkashots.io/${snapshot_name}
7z x ${snapshot_name} -o~/.local/share/polkadot/chains/${chain_dir}
rm -v ${snapshot_name}
\`\`\`

Or simply use the permalink:
\`\`\`
wget https://${FIREBASE_SUBDOMAIN}.polkashots.io/snapshot -O ${CHAIN}.${DATABASE}.7z
7z x ${CHAIN}.${DATABASE}.7z -o~/.local/share/polkadot/chains/${chain_dir}
rm -v ${CHAIN}.${DATABASE}.7z
\`\`\`

Then run the ${CHAIN} node:
\`\`\`
polkadot --chain=${CHAIN} --database=${DATABASE} --unsafe-pruning --pruning=1000
\`\`\`

### More details

[About polkashots.io](https://polkashots.io/getting-started/).

[Polkadot documentation](https://wiki.polkadot.network/docs/en/build-node-management){:target="_blank"}.


EOF

echo "**** DEBUG OUTPUT OF index.md *****"
cat /mnt/snapshot-cache-volume/firebase-files/index.md
echo "**** end debug ****"

chmod -R 777 /mnt/snapshot-cache-volume/firebase-files
