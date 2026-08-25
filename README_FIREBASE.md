Firebase integration steps

1) Create a Firebase project
- Open https://console.firebase.google.com and create a new project (e.g., `katalog-project`).

2) Register Android & iOS apps
- Android: register package name from `android/app/src/main/AndroidManifest.xml` (e.g., `com.example.katalog`).
  - Download `google-services.json` and place it at `android/app/google-services.json`.
  - Update `android/build.gradle` and `android/app/build.gradle` per Firebase docs (usually the Flutter template already matches).

- iOS: register bundle id from Xcode project (Runner).
  - Download `GoogleService-Info.plist` and add it to `ios/Runner` in Xcode (or place at `ios/Runner/GoogleService-Info.plist`).

3) Install FlutterFire CLI (optional but recommended)
- Install: `dart pub global activate flutterfire_cli`
- Configure: from project root run:

```bash
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This will generate `lib/firebase_options.dart` with `DefaultFirebaseOptions.currentPlatform` containing platform-specific `FirebaseOptions`.

4) If you don't use FlutterFire CLI
- You can keep the provided stub `lib/firebase_options.dart` and manually create a `FirebaseOptions` instance and replace `DefaultFirebaseOptions.currentPlatform` with it.

5) Run `flutter pub get` and start the app

```bash
flutter pub get
flutter run
```

6) Test auth flows
- Use the UI under `Masuk` to sign in, register, reset password, or try Google Sign-In (ensure OAuth client IDs set up on Firebase).

Notes
- Android: ensure `minSdkVersion` is >= 21 for some Firebase features.
- Google Sign-In requires proper OAuth setup (Android SHA-1, iOS reversed client id).
- After `flutterfire configure` you can remove the stub `lib/firebase_options.dart` (it will be replaced by generated file).

If you want, I can:
- Run through a checklist and patch the Android/iOS build files in this repo to match Firebase docs, or
- Attempt to run `flutterfire configure` for you if you provide the Firebase project id and allow CLI usage.
