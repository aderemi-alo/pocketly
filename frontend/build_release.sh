#!/bin/bash

# Build for Android (App Bundle)
echo "Building Android App Bundle..."
flutter build appbundle --release --dart-define-from-file=.env.json

# Build for iOS (IPA)
echo "Building iOS IPA..."
flutter build ipa --release --dart-define-from-file=.env.json

echo "Builds completed successfully."
