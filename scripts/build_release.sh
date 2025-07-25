#!/bin/bash

echo "Building Farmer Friends Release..."

# Clean previous builds
flutter clean
flutter pub get

# Generate necessary files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build Android APK
echo "Building Android APK..."
flutter build apk --release --split-per-abi

# Build Android App Bundle
echo "Building Android App Bundle..."
flutter build appbundle --release

# Build iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building iOS..."
    flutter build ios --release
fi

echo "Build complete!"
echo "APK location: build/app/outputs/flutter-apk/"
echo "AAB location: build/app/outputs/bundle/release/"