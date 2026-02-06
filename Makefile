PROJECT := TypingGame.xcodeproj
SCHEME := TypingGame
CONFIG ?= Debug
DERIVED_DATA := build
APP_NAME := Typing Quest
APP_BUNDLE := $(DERIVED_DATA)/Build/Products/$(CONFIG)/$(APP_NAME).app
APP := $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
RUN_FOR ?= 20
FULLSCREEN ?= 1
FULLSCREEN_DELAY ?= 1

.PHONY: build run run-no-build run-live run-live-no-build fresh-run smoke clean levels

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIG) -derivedDataPath $(DERIVED_DATA) build

run-no-build:
	@RUN_FOR="$(RUN_FOR)"; \
	FULLSCREEN="$(FULLSCREEN)"; \
	FULLSCREEN_DELAY="$(FULLSCREEN_DELAY)"; \
	echo "Launching $(APP_NAME) for $$RUN_FOR seconds..."; \
	"$(APP)" & \
	APP_PID=$$!; \
	if [ "$$FULLSCREEN" = "1" ]; then \
		( \
			sleep "$$FULLSCREEN_DELAY"; \
			osascript -e 'tell application "System Events" to tell process "$(APP_NAME)" to set value of attribute "AXFullScreen" of window 1 to true' >/dev/null 2>&1 \
			|| echo "Warning: could not force fullscreen (check Accessibility permission)." \
		) & \
	fi; \
	SECONDS_LEFT=$$RUN_FOR; \
	while [ $$SECONDS_LEFT -gt 0 ]; do \
		if ! kill -0 $$APP_PID 2>/dev/null; then \
			echo "App exited before timeout."; \
			exit 0; \
		fi; \
		sleep 1; \
		SECONDS_LEFT=$$((SECONDS_LEFT - 1)); \
	done; \
	if kill -0 $$APP_PID 2>/dev/null; then \
		kill $$APP_PID 2>/dev/null || true; \
		wait $$APP_PID 2>/dev/null || true; \
		echo "Stopped app after $$RUN_FOR seconds."; \
	fi

run: build run-no-build

fresh-run: clean build run-no-build

run-live-no-build:
	@FULLSCREEN="$(FULLSCREEN)"; \
	FULLSCREEN_DELAY="$(FULLSCREEN_DELAY)"; \
	"$(APP)" & \
	APP_PID=$$!; \
	if [ "$$FULLSCREEN" = "1" ]; then \
		( \
			sleep "$$FULLSCREEN_DELAY"; \
			osascript -e 'tell application "System Events" to tell process "$(APP_NAME)" to set value of attribute "AXFullScreen" of window 1 to true' >/dev/null 2>&1 \
			|| echo "Warning: could not force fullscreen (check Accessibility permission)." \
		) & \
	fi; \
	wait $$APP_PID

run-live: build run-live-no-build

smoke: build
	scripts/smoke_run.sh "$(APP)"

levels:
	python3 scripts/generate_levels.py --validate

clean:
	rm -rf $(DERIVED_DATA)
