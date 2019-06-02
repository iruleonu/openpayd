#!/bin/bash

# **** Update me when new Xcode versions are released! ****
PLATFORM="platform=iOS Simulator,OS=12.1,name=iPhone XS"
SDK="iphonesimulator"

# It is pitch black.
set -e
function trap_handler() {
    echo -e "\n\nOh no! You walked directly into the slavering fangs of a lurking grue!"
    echo "**** You have died ****"
    exit 255
}
trap trap_handler INT TERM EXIT

MODE="$1"

if type xcpretty-travis-formatter &> /dev/null; then
    FORMATTER="-f $(xcpretty-travis-formatter)"
  else
    FORMATTER="-s"
fi

if [ "$MODE" = "tests" ]; then
    echo "Building & testing IRShowcase."
    xcodebuild \
        -project IRShowcase.xcodeproj \
        -scheme IRShowcaseTests \
        -sdk "$SDK" \
        -destination "$PLATFORM" \
        test | xcpretty $FORMATTER
    trap - EXIT
    exit 0
fi

if [ "$MODE" = "build" ]; then
    echo "Building IRShowcase."
    set -o pipefail && xcodebuild \
        -project IRShowcase.xcodeproj \
        -scheme IRShowcase \
        -sdk "$SDK" \
        -destination "$PLATFORM" \
        build | xcpretty $FORMATTER
    trap - EXIT
    exit 0
fi

if [ "$MODE" = "carthage" -o "$MODE" = "all" ]; then
    echo "Verifying carthage works."

    set -o pipefail && carthage update && carthage build --no-skip-current
fi

if [ "$success" = "1" ]; then
  trap - EXIT
  exit 0
fi

echo "Unrecognised mode '$MODE'."
