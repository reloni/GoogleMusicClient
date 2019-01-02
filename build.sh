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
