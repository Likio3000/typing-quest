PROJECT := TypingGame.xcodeproj
SCHEME := TypingGame
CONFIG ?= Debug
DERIVED_DATA := build
APP_NAME := Typing Quest
APP_BUNDLE := $(DERIVED_DATA)/Build/Products/$(CONFIG)/$(APP_NAME).app
APP := $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)

.PHONY: build run smoke clean levels

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) -derivedDataPath $(DERIVED_DATA) build

run: build
	"$(APP)"

smoke: build
	scripts/smoke_run.sh "$(APP)"

levels:
	python3 scripts/generate_levels.py --validate

clean:
	rm -rf $(DERIVED_DATA)
