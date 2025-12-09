#!/bin/sh
export PATH="$PATH":"$HOME/flutter/bin":"$HOME/.pub-cache/bin" &&
dart pub global activate melos &&
melos bootstrap || true &&
rm -rf /vercel/.pub-cache/_temp &&
melos bootstrap &&
melos run admin_panel:init &&
flutter build web --dart-define=BASE_URL=https://app.vibesonly.com/api/v1/
