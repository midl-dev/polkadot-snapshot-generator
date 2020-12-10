#!/usr/bin/python3

import json
import os

website_bucket_url = os.environ["WEBSITE_BUCKET_URL"].replace("gs://", "")
block_height = os.environ["BLOCK_HEIGHT"]
database = os.environ["DATABASE"]

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

firebase_conf["hosting"]["redirects"] = [ { "source": f"polkadot-:block.{database}.7z", "type": 301, "destination": f"https://storage.googleapis.com/{website_bucket_url}/polkadot-:block.{database}.7z" },
        { "source": "snapshot", "type": 301, "destination": f"https://storage.googleapis.com/{website_bucket_url}/polkadot-{block_height}.{database}.7z" } ]

print(json.dumps(firebase_conf, indent=4))
