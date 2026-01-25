PROJECT := TypingGame.xcodeproj
SCHEME := TypingGame
CONFIG ?= Debug
DERIVED_DATA := build
APP := $(DERIVED_DATA)/Build/Products/$(CONFIG)/TypingGame.app/Contents/MacOS/TypingGame

.PHONY: build run smoke clean

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) -derivedDataPath $(DERIVED_DATA) build

run: build
	"$(APP)"

smoke: build
	scripts/smoke_run.sh "$(APP)"

clean:
	rm -rf $(DERIVED_DATA)
