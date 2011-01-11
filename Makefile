
all:
	xcodebuild -activeconfiguration -project SupaView.xcodeproj build

clean:
	xcodebuild -activeconfiguration -project SupaView.xcodeproj clean

run:
	open build/Debug/SupaView.app

	
