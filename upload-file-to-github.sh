#!/bin/bash

set -e

# Define variables.
OWNER="$1"
REPO="$2"
GITHUB_ACCESS_TOKEN="$3"
TAG="$4"
FILE="$5"

GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/$OWNER/$REPO"
GH_TAGS="$GH_REPO/releases/tags/$TAG"
AUTH="Authorization: token $GITHUB_ACCESS_TOKEN"

# Validate token.
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

# Read asset tags.
response=$(curl -sH "$AUTH" $GH_TAGS)

# Get ID of the asset based on given filename.
eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
[ "$id" ] || { echo "Error: Failed to get release id for tag: $tag"; echo "$response" | awk 'length($0)<100' >&2; exit 1; }

FILEESCAPED=$(echo "$FILE" | sed 's/ /%20/g')
GH_ASSET="https://uploads.github.com/repos/$OWNER/$REPO/releases/$id/assets?name=$FILEESCAPED"

curl \
  --data-binary @"$FILE" \
  -H "$AUTH" \
  -H "Content-Type: application/octet-stream" \
  $GH_ASSET
