# AdMob Store Linking And app-ads.txt

This project now includes [web/app-ads.txt](/Users/michele/gymbro_flutter_new/web/app-ads.txt).

Assumptions used here:
- Public website domain: `https://fitlogpro.it/`
- iOS bundle ID: `com.michele.gymbro.flutter`
- Android application ID: `com.micheleferrero93.GymProgressAppNew`
- AdMob publisher ID: `pub-5716120224398761`

If your App Store / Play Store developer website still points to a different domain, update either the store listing or the deployed `app-ads.txt` location so they match exactly.

## 1. Deploy app-ads.txt

Deploy this file at:

`https://fitlogpro.it/app-ads.txt`

Expected content:

```txt
google.com, pub-5716120224398761, DIRECT, f08c47fec0942fa0
```

## 2. Link apps in AdMob

In AdMob:

1. Open `Apps`
2. Select the iOS app and link the App Store listing
3. Select the Android app and link the Play Store listing

Use these identifiers:

- iOS bundle ID: `com.michele.gymbro.flutter`
- Android package: `com.micheleferrero93.GymProgressAppNew`

## 3. Verify app-ads.txt

For each app in AdMob:

1. Open the app details
2. Open the `app-ads.txt` section
3. Click `Verify app`
4. Click `Check for updates` after the file is live

## 4. Ready status

Ad serving may remain limited until:

- the app is linked to the store
- `app-ads.txt` is verified
- AdMob app status becomes `Ready`

## 5. Quick validation

Run these checks after deploy:

```sh
curl -I https://fitlogpro.it/app-ads.txt
curl https://fitlogpro.it/app-ads.txt
```

The response should be `200 OK`, and the file body should contain the Google seller line above.
