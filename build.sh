#!/bin/bash

set -e

NAME='Google Music Player'

rm -r Release 2>/dev/null || true

xcodebuild archive \
	-scheme "GoogleMusicClientMacOS" \
	-archivePath Release/App.xcarchive

xcodebuild \
	-exportArchive \
	-archivePath Release/App.xcarchive \
	-exportOptionsPlist GoogleMusicClientMacOS/Resources/export-options.plist \
	-exportPath Release

	find ./Release -mindepth 1 -maxdepth 1 ! -regex "^./Release/$NAME.app" -exec rm -r "{}" +

# 	create-dmg \
# 	--volname "$NAME" \
# 	--window-pos 200 120 \
# 	--window-size 800 400 \
# 	--icon-size 100 \
# 	--icon "$NAME.app" 200 190 \
# 	--hide-extension "$NAME.app" \
# 	--app-drop-link 600 185 \
# 	"$NAME.dmg" \
# 	"Release"
#
# find ./Release -mindepth 1 -maxdepth 1 ! -regex "^./Release/$NAME.dmg" -exec rm -r "{}" +

#for tests

#xcrun altool --notarize-app --primary-bundle-id "com.AntonEfimenko.GoogleMusicClient" --username "" --password "" --file "Google Music Client.dmg"

#xcrun altool --notarization-history 0 --username "" --password ""
#xcrun stapler staple "Google Music Client.dmg"

#codesign -dv "Google Music Client.dmg"

# check app notarized
#spctl -a -v my.app
