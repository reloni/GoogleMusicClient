#!/bin/bash

set -e

NAME='Google Music Player'
TAG="$1"
GITHUB_ACCESS_TOKEN="$2"

rm -r Release 2>/dev/null || true

# archive
xcodebuild archive \
	-scheme "GoogleMusicClientMacOS" \
	-archivePath Release/App.xcarchive

# export
xcodebuild \
	-exportArchive \
	-archivePath Release/App.xcarchive \
	-exportOptionsPlist GoogleMusicClientMacOS/Resources/export-options.plist \
	-exportPath Release

# zip app
(cd Release && tar -zvc -f "$NAME.tar.gz" "$NAME.app")

# upload to github release
sh upload-file-to-github.sh "reloni" "GoogleMusicClient" "$GITHUB_ACCESS_TOKEN" "$TAG" "Release/$NAME.tar.gz"

#for tests

#notarize
#xcrun altool --notarize-app --primary-bundle-id "com.AntonEfimenko.GoogleMusicClient" --username "" --password "" --file "Google Music Client.dmg"

#check notarization copleted
#xcrun altool --notarization-history 0 --username "" --password ""

# staple
#xcrun stapler staple "Google Music Client.dmg"

#codesign -dv "Google Music Client.dmg"

# check app notarized
#spctl -a -v my.app
