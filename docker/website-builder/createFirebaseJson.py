#!/usr/bin/python3

import json
import os

data_bucket_public_url = os.environ["DATA_BUCKET_PUBLIC_URL"]
block_height = os.environ["BLOCK_HEIGHT"]
database = os.environ["DATABASE"]
chain = os.environ["CHAIN"]

# Creates a firebase.json with the appropriate redirects.

firebase_conf = json.loads(""" {
  "hosting": {
    "public": "_site",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
""")

firebase_conf["hosting"]["redirects"] = [ { "source": f"{chain}-:block.{database}.tar.lz4", "type": 301, "destination": f"{data_bucket_public_url}/{chain}-:block.{database}.tar.lz4" },
        { "source": "snapshot", "type": 301, "destination": f"{data_bucket_public_url}/{chain}-{block_height}.{database}.tar.lz4" } ]

print(json.dumps(firebase_conf, indent=4))
