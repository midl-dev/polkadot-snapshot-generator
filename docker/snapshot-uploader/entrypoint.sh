#!/bin/bash -x
# workload identity allows this to work
gcloud container clusters get-credentials blockchain --region us-central1

if [ "${CHAIN}" == "polkadot" ]; then
    chain_dir=polkadot
else
    chain_dir=ksmcc3
fi

snapshot_name="${CHAIN}-${BLOCK_HEIGHT}.${DATABASE}.tar.lz4"
ls /polkadot/.local/share/polkadot/chains/${chain_dir}/

rm -rvf /polkadot/.local/share/polkadot/chains/${chain_dir}/keystore
rm -rvf /polkadot/.local/share/polkadot/chains/${chain_dir}/network

BLOCK_TIMESTAMP=$(date --utc +%FT%T%Z)

# pipe straight to bucket
tar cf - -C /polkadot/.local/share/polkadot/chains/${chain_dir} . | lz4 -1 - | gsutil cp - ${WEBSITE_BUCKET_URL}/${snapshot_name}

snapshot_size=$(gsutil du -h ${WEBSITE_BUCKET_URL}/${snapshot_name}| cut -d\  -f 1-2)

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
| Block hash | \`$(echo ${BLOCK_HASH} | cut -c1-45)...\` |
| Creation date | $BLOCK_TIMESTAMP |
| Database format | ${DATABASE} - [What is this?](https://polkashots.io/getting-started/#database-formats) |
| Pruning mode | Pruned - [What is this?](https://polkashots.io/getting-started/#pruning) |
| Compression format | [lz4](https://github.com/lz4/lz4) |
| Version used for snapshotting | \`${POLKADOT_SOFTWARE_VERSION}\` |
| Download link | [${snapshot_name}](${snapshot_name}) |
| Size | ${snapshot_size} |

[Verify on Polkastats](https://polkastats.io/block?blockNumber=${BLOCK_HEIGHT}){:target="_blank"} - [Verify on Polkascan](https://polkascan.io/$CHAIN/block/${BLOCK_HEIGHT}){:target="_blank"}

## How to use

Issue the following commands:

\`\`\`
wget https://${FIREBASE_SUBDOMAIN}.polkashots.io/${snapshot_name}
lz4 -c -d ${snapshot_name} | tar -x -C /home/polkadot/.local/share/polkadot/chains/${chain_dir}
rm -v ${snapshot_name}
\`\`\`

Or simply use the permalink:
\`\`\`
wget https://${FIREBASE_SUBDOMAIN}.polkashots.io/snapshot -O ${CHAIN}.${DATABASE}.tar.lz4
lz4 -c -d ${CHAIN}.${DATABASE}.tar.lz4 | tar -x -C /home/polkadot/.local/share/polkadot/chains/${chain_dir}
rm -v ${CHAIN}.${DATABASE}.tar.lz4
\`\`\`

Note: if applicable, replace \`/home/polkadot\` with the actual storage location.

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
cd /mnt/snapshot-cache-volume

find

echo "now rsyncing markdownfiles to $WEBSITE_BUCKET_URL"
gsutil -m rsync /mnt/snapshot-cache-volume $WEBSITE_BUCKET_URL
