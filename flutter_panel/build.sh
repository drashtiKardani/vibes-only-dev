#!/bin/bash
cd packages/harmony_log
flutter pub get
cd ..
cd harmony_auth
flutter pub get
cd ../..
flutter pub get
flutter pub run intl_utils:generate
flutter pub run build_runner build --delete-conflicting-outputs

# flutter run -d chrome