# 📱 In-App Purchase Setup Guide

## 🍎 iOS Setup (Xcode & App Store Connect)

### Step 1: Xcode Capabilities

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select Runner target** → **Signing & Capabilities** tab

3. **Add Capability** (+ button):
   - Search for "In-App Purchase"
   - Click to add it

4. **Verify entitlements**:
   - Check that `Runner.entitlements` now includes:
   ```xml
   <key>com.apple.developer.in-app-purchase</key>
   <array/>
   ```

### Step 2: App Store Connect Setup

1. **Go to App Store Connect** → Your App → **In-App Purchases**

2. **Create Products** (click + button):

   #### Monthly Subscription:
   - **Product ID**: `com.gymbro.premium.monthly`
   - **Reference Name**: GymBro Premium Monthly
   - **Product Type**: Auto-Renewable Subscription
   - **Price**: $4.99
   - **Duration**: 1 Month
   
   #### Yearly Subscription:
   - **Product ID**: `com.gymbro.premium.yearly`
   - **Reference Name**: GymBro Premium Yearly
   - **Product Type**: Auto-Renewable Subscription
   - **Price**: $39.99
   - **Duration**: 1 Year
   
   #### Lifetime Purchase:
   - **Product ID**: `com.gymbro.premium.lifetime`
   - **Reference Name**: GymBro Premium Lifetime
   - **Product Type**: Non-Consumable
   - **Price**: $99.99

3. **Create Subscription Group**:
   - Name: `GymBro Premium`
   - Add Monthly and Yearly subscriptions to this group

4. **Add Localization** for each product:
   - Display Name
   - Description
   - Add for both English and Italian

5. **Review Information**:
   - Add screenshots (required)
   - Add review notes

### Step 3: Sandbox Testing

1. **Create Sandbox Tester**:
   - App Store Connect → Users and Access → Sandbox Testers
   - Create new tester with fake email

2. **Sign out of App Store** on test device:
   - Settings → App Store → Sign Out

3. **Don't sign in with sandbox account** in Settings
   - Only sign in when prompted during purchase

---

## 🤖 Android Setup (Google Play Console)

### Step 1: Google Play Console

1. **Go to Google Play Console** → Your App

2. **Monetization** → **In-app products** → **Subscriptions**

3. **Create Subscriptions**:

   #### Monthly:
   - **Product ID**: `premium_monthly`
   - **Name**: GymBro Premium Monthly
   - **Default Price**: $4.99
   - **Billing Period**: Monthly
   
   #### Yearly:
   - **Product ID**: `premium_yearly`
   - **Name**: GymBro Premium Yearly
   - **Default Price**: $39.99
   - **Billing Period**: Yearly

4. **One-time products** (for Lifetime):
   - **Product ID**: `premium_lifetime`
   - **Name**: GymBro Premium Lifetime
   - **Default Price**: $99.99

5. **Activate** all products

### Step 2: Android Manifest

Verify `android/app/src/main/AndroidManifest.xml` has:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### Step 3: Upload Signed APK

**IMPORTANT**: Products won't be available until you upload a signed APK/AAB with billing permission to a track (Internal Testing, Closed Testing, or Production).

### Step 4: Test Accounts

1. **Add License Testers**:
   - Play Console → Setup → License Testing
   - Add tester emails

2. **Join testing program**:
   - Testers must join via opt-in URL

---

## 🔥 Firebase Cloud Functions Setup

### Backend Verification Function

Create `functions/src/verifyPremiumPurchase.ts`:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { google } from 'googleapis';
import * as appleReceiptVerify from 'node-apple-receipt-verify';

export const verifyPremiumPurchase = functions.https.onCall(async (data, context) => {
  const { userId, productId, purchaseToken, platform, purchaseId } = data;
  
  if (!context.auth || context.auth.uid !== userId) {
    throw new functions.https.HttpsError('unauthenticated', 'User not authenticated');
  }
  
  try {
    let verified = false;
    
    if (platform === 'ios') {
      // Apple verification
      appleReceiptVerify.config({
        secret: functions.config().apple.shared_secret,
        environment: ['sandbox', 'production'],
      });
      
      const products = await appleReceiptVerify.validate({
        receipt: purchaseToken,
      });
      
      verified = products.some(p => p.productId === productId);
      
    } else if (platform === 'android') {
      // Google Play verification
      const auth = new google.auth.GoogleAuth({
        keyFile: 'path/to/service-account.json',
        scopes: ['https://www.googleapis.com/auth/androidpublisher'],
      });
      
      const androidPublisher = google.androidpublisher({
        version: 'v3',
        auth,
      });
      
      const packageName = 'com.michele.gymbro.flutter';
      
      if (productId.includes('lifetime')) {
        // One-time purchase
        const response = await androidPublisher.purchases.products.get({
          packageName,
          productId,
          token: purchaseToken,
        });
        verified = response.data.purchaseState === 0; // 0 = purchased
      } else {
        // Subscription
        const response = await androidPublisher.purchases.subscriptions.get({
          packageName,
          subscriptionId: productId,
          token: purchaseToken,
        });
        verified = !!response.data.expiryTimeMillis;
      }
    }
    
    if (verified) {
      // Update user profile to premium
      const tier = productId.includes('lifetime') ? 'pro' : 'premium';
      
      await admin.firestore()
        .collection('users')
        .doc(userId)
        .update({
          accountTier: tier,
          premiumPurchaseId: purchaseId,
          premiumPurchaseDate: admin.firestore.FieldValue.serverTimestamp(),
          premiumProductId: productId,
        });
      
      // Log purchase
      await admin.firestore()
        .collection('purchases')
        .add({
          userId,
          productId,
          platform,
          purchaseId,
          verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      
      return { success: true, tier };
    }
    
    return { success: false, error: 'Purchase verification failed' };
    
  } catch (error) {
    console.error('Purchase verification error:', error);
    throw new functions.https.HttpsError('internal', 'Verification failed');
  }
});
```

### Deploy Function:
```bash
cd functions
npm install node-apple-receipt-verify googleapis
firebase deploy --only functions:verifyPremiumPurchase
```

---

## 🧪 Testing Checklist

### iOS Testing:
- [ ] Capability added in Xcode
- [ ] Products created in App Store Connect
- [ ] Sandbox tester created
- [ ] Sign out of real App Store account
- [ ] Test purchase flow
- [ ] Test restore purchases
- [ ] Verify premium features unlock

### Android Testing:
- [ ] Products created in Play Console
- [ ] Billing permission in manifest
- [ ] Signed APK uploaded to testing track
- [ ] License tester added
- [ ] Test purchase flow
- [ ] Test restore purchases
- [ ] Verify premium features unlock

### Backend Testing:
- [ ] Cloud function deployed
- [ ] Receipt verification working
- [ ] Firestore updates correctly
- [ ] Purchase logging working

---

## 🚨 Common Issues & Solutions

### iOS Issues:

**"Cannot connect to iTunes Store"**
- Check internet connection
- Verify products are "Ready to Submit" in App Store Connect
- Wait 24 hours after creating products

**"Invalid Product IDs"**
- Ensure product IDs match exactly
- Check bundle ID matches
- Verify agreements are signed in App Store Connect

### Android Issues:

**"The item you requested is not available for purchase"**
- Upload signed APK to testing track
- Wait 2-3 hours for propagation
- Ensure tester is added to license testing

**"Authentication is required"**
- Clear Google Play Store cache
- Re-add test account

### General Issues:

**Products not loading**
```dart
// Debug code to check products
final products = state.availableProducts;
print('Loaded products: ${products.map((p) => p.id).join(', ')}');
```

**Purchase not completing**
- Check Cloud Function logs
- Verify Firebase authentication
- Check Firestore rules allow user updates

---

## 📝 Revenue Configuration

### Apple:
1. **Agreements** → Sign all agreements
2. **Banking** → Add bank information
3. **Tax Forms** → Complete tax forms

### Google:
1. **Payments profile** → Complete setup
2. **Tax information** → Submit forms
3. **Payment methods** → Add bank account

---

## 🎉 Go Live Checklist

- [ ] All products approved (iOS)
- [ ] All products active (Android)
- [ ] Cloud functions deployed
- [ ] Receipt verification tested
- [ ] Restore purchases working
- [ ] Error handling implemented
- [ ] Analytics tracking added
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] App review notes prepared

---

## 📧 Support Contact

For IAP issues:
- iOS: https://developer.apple.com/contact/
- Android: https://support.google.com/googleplay/android-developer/

---

*Last Updated: 2025*