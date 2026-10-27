#!/usr/bin/env bash
set -euo pipefail

# Observed upstream stable tag 3.47.8 on 2026-10-27. Pin the immutable revision;
# flutter downloads its matching artifacts only from its official sources.
flutter_revision=737ba8f885dc774b53b442759999a312c9461e4e
flutter_directory="${RUNNER_TEMP:?GitHub runner required}/bjut-flutter-sdk"
git clone --depth 1 --branch 3.47.8 https://github.com/flutter/flutter.git "$flutter_directory"
test "$(git -C "$flutter_directory" rev-parse HEAD)" = "$flutter_revision"
echo "$flutter_directory/bin" >> "${GITHUB_PATH:?GitHub runner required}"
"$flutter_directory/bin/flutter" config --no-analytics
"$flutter_directory/bin/flutter" --version
"$flutter_directory/bin/dart" --version
