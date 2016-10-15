EXECUTABLE_NAME=motoswift

BUNDLE_PATH=./motoswift
BUNDLE_TEMPLATES_PATH=$(BUNDLE_PATH)/templates
BUNDLE_BIN_PATH=$(BUNDLE_PATH)/bin
BUNDLE_LIB_PATH=$(BUNDLE_PATH)/lib

BUILD_CONFIGURATION=debug
BUILD_PATH=./.build/$(BUILD_CONFIGURATION)/$(EXECUTABLE_NAME)

DEFAULT_RPATH=`dirname \`dirname \\\`xcrun -find swift-stdlib-tool\\\`\``/lib/swift/macosx

lint:
	cd ./Source; swiftlint

build:
	swift build --configuration $(BUILD_CONFIGURATION)

test:
	swift test

.bundle_binary: build
	mkdir -p $(BUNDLE_BIN_PATH)
	cp $(BUILD_PATH) $(BUNDLE_BIN_PATH)
	install_name_tool -delete_rpath $(DEFAULT_RPATH) $(BUNDLE_BIN_PATH)/$(EXECUTABLE_NAME) | true
	install_name_tool -add_rpath "@executable_path/../lib" $(BUNDLE_BIN_PATH)/$(EXECUTABLE_NAME)

.bundle_templates:
	mkdir -p $(BUNDLE_TEMPLATES_PATH)
	cp -r ./Templates/* $(BUNDLE_TEMPLATES_PATH)

.bundle_libraries:
	mkdir -p $(BUNDLE_LIB_PATH)
	xcrun swift-stdlib-tool --copy --verbose --Xcodesign --timestamp=none \
		--scan-executable $(BUILD_PATH) \
		--platform macosx --destination $(BUNDLE_LIB_PATH) \
		--strip-bitcode

bundle: .bundle_binary .bundle_templates .bundle_libraries