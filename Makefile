
all:
	xcodebuild -activeconfiguration -project SupaView.xcodeproj build

clean:
	xcodebuild -project SupaView.xcodeproj clean

run:
	open build/Debug/SupaView.app
