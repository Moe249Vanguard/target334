# Install Iron Cadence with TestFlight (no Mac needed)

You can do every step below from your iPhone in Safari and the Apple Developer,
GitHub and TestFlight apps. GitHub's cloud Macs build, sign and upload the app for you.

Total time: about 30–45 minutes of clicking, plus up to 48 hours if Apple needs to
verify your developer enrollment.

---

## 1. Join the Apple Developer Program ($99/year)

1. Install the **Apple Developer** app from the App Store.
2. Open it → **Account** → **Enroll Now**, and sign in with your Apple ID.
3. Enroll as an **Individual**, then pay.
4. Wait for the confirmation email. This is often quick, but can take up to 48 hours.

## 2. Note your Team ID

Go to [developer.apple.com/account](https://developer.apple.com/account) → **Membership details**.
Copy the 10-character **Team ID**.

## 3. Register the app's bundle ID (with HealthKit)

1. Go to [developer.apple.com/account/resources/identifiers](https://developer.apple.com/account/resources/identifiers/list) → **+**.
2. Choose **App IDs** → **App**.
3. Description: `Iron Cadence`. **Explicit** Bundle ID: pick something unique, e.g. `com.yourname.ironcadence`.
4. Under **Capabilities**, tick **HealthKit**. Then click **Continue → Register**.

## 4. Create the app in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps** → **+** → **New App**.
2. Platform **iOS**. Name: something unique on the App Store, e.g. `Iron Cadence PT` (only you will see it in TestFlight).
3. Pick your language, select the bundle ID from step 3, and use any SKU (e.g. `ironcadence001`).

## 5. Create an App Store Connect API key

1. App Store Connect → **Users and Access** → **Integrations** → **App Store Connect API** → **Team Keys** → **+**.
2. Name: `GitHub CI`. Access: **Admin**. Admin is required so the build can create the signing certificate.
3. Note the **Key ID** and the **Issuer ID** shown above the key list.
4. Tap **Download** to get the `AuthKey_XXXX.p8` file. **You can only download it once.**
5. To copy its contents on iPhone: in the **Files** app, long-press the file → **Rename**, change `.p8` to `.txt`, open it, then select all and copy.
   The text starts with `-----BEGIN PRIVATE KEY-----`.

## 6. Add GitHub secrets

The GitHub mobile app can't edit secrets, so use Safari. Open the repository on github.com, tap **aA → Request Desktop Website**, then go to
**Settings → Secrets and variables → Actions → New repository secret** and add:

| Secret name | Value |
|---|---|
| `ASC_KEY_ID` | Key ID from step 5 |
| `ASC_ISSUER_ID` | Issuer ID from step 5 |
| `ASC_KEY_P8` | Full text of the `.p8` file, including the BEGIN/END lines |
| `APPLE_TEAM_ID` | Team ID from step 2 |
| `APP_BUNDLE_ID` | Bundle ID from step 3 |
| `MATCH_PASSWORD` | A long passphrase you make up. Save it in your password manager. |

> The signing certificate is stored **encrypted with `MATCH_PASSWORD`** on a branch called
> `fastlane-signing` in this repository. Keep the repository **private**.

## 7. Run the build

- Every push that changes `IronCadence/` triggers **TestFlight (Iron Cadence)** automatically.
- Or start it manually from **Actions → TestFlight (Iron Cadence) → Run workflow**.
  This button only appears once the workflow file is on the default branch.

A run takes about 10–20 minutes. A green check means the build was uploaded. Apple then
processes it for another 5–30 minutes.

## 8. Install on your iPhone

1. App Store Connect → your app → **TestFlight** → **Internal Testing** → **+** to create a group (e.g. `Me`).
2. Add yourself as a tester, then add the processed build to the group.
3. Install **TestFlight** from the App Store and open the invite email on your iPhone (or just open TestFlight).
4. Tap **Install**. Iron Cadence appears on your Home Screen.

Each TestFlight build works for **90 days**. Any new push uploads a fresh build, and TestFlight offers the update.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Workflow shows *"TestFlight upload skipped. Missing repository secrets"* | Add the listed secrets (step 6). |
| `match` error about permissions or certificates | Check that the API key has **Admin** access. |
| *"No suitable application records were found"* | Create the app in App Store Connect (step 4) with the **same** bundle ID. |
| Provisioning error mentioning HealthKit | Enable **HealthKit** on the identifier (step 3), then re-run. |
| *"Maximum number of certificates"* | developer.apple.com → Certificates → revoke an unused *Apple Distribution* certificate, then re-run. |
| Build fails in Swift compile | The code hasn't been compiled before. Send me the log from the failed step and I'll fix it. |
