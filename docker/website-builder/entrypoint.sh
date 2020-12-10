#!/bin/bash
set -e

mkdir -p /srv/jekyll/vendor/bundle
chmod -R 777 /srv/jekyll/vendor/bundle
bundle  config set path /srv/jekyll/vendor/bundle
cd /mnt/snapshot-cache-volume/firebase-files

cp /home/jekyll/snapshot-website-base/* .
bundle install
bundle exec jekyll build

find

echo "now uploading site to firebase"

cat << EOF > .firebaserc
{
      "projects": {
          "default": "$FIREBASE_PROJECT"
      }
}
EOF
/createFirebaseJson.py > firebase.json
echo "Firebase json:"
cat firebase.json

/home/jekyll/.npm-global/bin/firebase deploy --token "$FIREBASE_TOKEN"
