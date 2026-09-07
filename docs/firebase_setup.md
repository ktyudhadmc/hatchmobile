# Firebase setup

The Firebase layer is ready for Android and iOS, but the Firebase project
identity is intentionally not invented or committed with the app.

1. Create/register Android package `com.example.hatchmobile` and the iOS bundle
   identifier in your Firebase project (replace the example identifiers before
   production).
2. Download `google-services.json` to `android/app/google-services.json`.
   The Android Gradle plugin activates automatically when this file exists.
3. Download `GoogleService-Info.plist` and add it to the Runner target in
   Xcode.
4. For iOS FCM, upload an APNs authentication key in Firebase Console and turn
   on Push Notifications plus Background Modes > Remote notifications in Xcode.

FCM permission is deliberately requested on demand, not at launch. Request it
from a contextual screen through `pushMessagingServiceProvider`. Subscribe to
`onTokenRefresh` and send the latest token to the backend; subscribe to
`onMessageOpenedApp`/`getInitialMessage` to route notification taps.

Remote Config defaults should be passed to `FirebaseRemoteConfigService` (or a
small feature-specific module) so an offline first launch is deterministic.
Features only depend on the domain contracts/providers, never Firebase SDK
classes directly.
