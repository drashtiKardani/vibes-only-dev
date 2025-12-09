#!/bin/bash

# Define Firebase Project IDs
PRODUCTION_FIREBASE_PROJECT_ID="vibes-only-fbb4c"
STAGING_FIREBASE_PROJECT_ID="vibes-only---staging"

# Define configurations
CONFIGS=(
    "Debug-production"
    "Release-production"
    "Profile-production"
    "Debug-staging"
    "Release-staging"
    "Profile-staging"
)

# Firebase app details
PRODUCTION_ANDROID="com.vibesonly.live1"
PRODUCTION_IOS="com.vibesonly.app"
STAGING_ANDROID="com.vibesonly.live1.staging"
STAGING_IOS="com.vibesonly.app.staging"

# Output paths
PRODUCTION_OUT="lib/firebase_options.dart"
PRODUCTION_IOS_OUT="ios/GoogleService-Info/production/GoogleService-Info.plist"
PRODUCTION_ANDROID_OUT="android/app/google-services.json"

STAGING_OUT="lib/firebase_options_staging.dart"
STAGING_IOS_OUT="ios/GoogleService-Info/staging/GoogleService-Info.plist"
STAGING_ANDROID_OUT="android/app/src/staging/google-services.json"

# Loop through all configurations
for CONFIG in "${CONFIGS[@]}"; do
    if [[ "$CONFIG" == *"production"* ]]; then
        echo "🚀 Configuring Firebase for $CONFIG (Production)"
        flutterfire configure \
            --project="$PRODUCTION_FIREBASE_PROJECT_ID" \
            --out="$PRODUCTION_OUT" \
            --android-app-id="$PRODUCTION_ANDROID" \
            --ios-bundle-id="$PRODUCTION_IOS" \
            --ios-out="$PRODUCTION_IOS_OUT" \
            --android-out="$PRODUCTION_ANDROID_OUT" \
            --ios-build-config="$CONFIG" \
            --yes
    else
        echo "🚀 Configuring Firebase for $CONFIG (Staging)"
        flutterfire configure \
            --project="$STAGING_FIREBASE_PROJECT_ID" \
            --out="$STAGING_OUT" \
            --android-app-id="$STAGING_ANDROID" \
            --ios-bundle-id="$STAGING_IOS" \
            --ios-out="$STAGING_IOS_OUT" \
            --android-out="$STAGING_ANDROID_OUT" \
            --ios-build-config="$CONFIG" \
            --yes
    fi
    echo "✅ Firebase configuration completed for $CONFIG"
done

echo "🎉 All Firebase configurations are done!"
