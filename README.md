# hatchmobile

Hatchery Mobile — Flutter app.

Firebase setup and module usage are documented in [docs/firebase_setup.md](docs/firebase_setup.md).

## Requirements

- Flutter 3.35.1 (Dart SDK `^3.9.2`) — matches the version pinned in [.gitlab-ci.yml](.gitlab-ci.yml)
- Gradle 8.12, Android Gradle Plugin 8.9.1, Kotlin 2.1.0 (via wrapper, no manual install needed)
- JDK 17
- Android SDK with `compileSdk`/`targetSdk` matching your installed Flutter version's defaults

## Setup

```bash
flutter pub get
flutter run
```

Points at production API by default (`lib/core/constants/app_constants.dart`). To hit a local backend, set `useLocalBackend = true` and update `_localBaseUrl` in that file.

## Release

CI/CD build pipeline: [.gitlab-ci.yml](.gitlab-ci.yml). Not yet connected to Play Store — every tag produces a downloadable APK attached to a GitLab Release.

Push a tag to trigger a build:

```bash
git tag v1.2.3          # stable release
git tag v1.2.3-rc.1      # testing build (also accepts -beta.N / -snapshot.N)
git push origin <tag>
```

The tag (minus `v`) becomes the app's version name; the CI pipeline number becomes its build number. No need to bump `version:` in `pubspec.yaml` — it's dev-only and gets overridden at build time (see comment there).
