# Android release signing (Google Play)

Play Console **rejects** app bundles signed with the **debug** key. Release builds must use your **upload keystore**.

## One-time setup

From the project root:

```bash
chmod +x android/create_upload_keystore.sh
./android/create_upload_keystore.sh
```

This creates (gitignored):

- `android/app/upload-keystore.jks` — your signing key
- `android/key.properties` — passwords and paths for Gradle

**Back up both files and the passwords.** If you lose them, you cannot update the app on Play under the same listing.

## Build for Play

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Upload that `.aab` in Play Console.

## Play App Signing

Google Play normally uses **Play App Signing**: you upload with the **upload key** (`upload-keystore.jks`), and Google re-signs for users. Enroll when prompted in Console.

## Already uploaded a debug-signed bundle?

Upload a **new** bundle built after `key.properties` exists. The release build must not use `signingConfigs.debug`.

## Manual setup

See `android/key.properties.example` if you prefer to create the keystore with `keytool` yourself.
