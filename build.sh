NAME='Google Music Player'

rm -r Release 2>/dev/null

xcodebuild archive \
	-scheme "GoogleMusicClientMacOS" \
	-archivePath Release/App.xcarchive

xcodebuild \
	-exportArchive \
	-archivePath Release/App.xcarchive \
	-exportOptionsPlist GoogleMusicClientMacOS/Resources/export-options.plist \
	-exportPath Release

	create-dmg \
	--volname "Google Music Player" \
	--window-pos 200 120 \
	--window-size 800 400 \
	--icon-size 100 \
	--icon "Google Music Player.app" 200 190 \
	--hide-extension "Google Music Player.app" \
	--app-drop-link 600 185 \
	"Google Music Player.dmg" \
	"Release"

#for tests

#xcrun altool --notarize-app --primary-bundle-id "com.AntonEfimenko.GoogleMusicClient" --username "" --password "" --file "Google Music Client.dmg"

#xcrun altool --notarization-history 0 --username "" --password ""
#xcrun stapler staple "Google Music Client.dmg"

#codesign -dv "Google Music Client.dmg"

# check app notarized
#spctl -a -v my.app
