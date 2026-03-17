# Resurge — Setup Checklist

Complete each section before building and submitting the app.

---

## 1. XcodeGen Installation & Project Generation

- [ ] Install XcodeGen: `brew install xcodegen`
- [ ] Verify `project.yml` is in the project root (`/Resurge/project.yml`)
- [ ] Run `xcodegen generate` to produce `Resurge.xcodeproj`
- [ ] Open `Resurge.xcodeproj` in Xcode (not the folder)
- [ ] Confirm the build target is set to **iOS 15.0** minimum deployment
- [ ] Confirm both targets exist: `Resurge` (app) and `ResurgeTests` (unit tests)

---

## 2. SPM Package Resolution

- [ ] Open project in Xcode and wait for automatic package resolution
- [ ] Verify all 5 packages resolve without errors:
  - **RevenueCat** — `https://github.com/RevenueCat/purchases-ios-spm.git` (product: `RevenueCat`)
  - **Supabase** — `https://github.com/supabase/supabase-swift` (product: `Supabase`)
  - **DGCharts** — `https://github.com/ChartsOrg/Charts` (product: `DGCharts`)
  - **Lottie** — `https://github.com/airbnb/lottie-spm.git` (product: `Lottie`)
  - **Swift Collections** — `https://github.com/apple/swift-collections` (product: `Collections`)
- [ ] Build the project to confirm all imports compile (`Cmd+B`)
- [ ] If resolution fails, try: File > Packages > Reset Package Caches

---

## 3. App Store Connect Setup

- [ ] Create App ID in Apple Developer portal
- [ ] **Bundle ID:** `com.resurge.app`
- [ ] Create the app record in App Store Connect
- [ ] Enable **In-App Purchase** capability in the App ID
- [ ] Enable **Keychain Sharing** capability
- [ ] Set primary category: **Health & Fitness**
- [ ] Set secondary category: **Lifestyle**
- [ ] Upload app icon (1024x1024, no alpha, no rounded corners)

---

## 4. RevenueCat Configuration

- [ ] Create a RevenueCat account at https://app.revenuecat.com
- [ ] Create a new project for Resurge
- [ ] Add the Apple App Store as a platform
- [ ] Copy the **API Key** into `Info.plist` under `REVENUECAT_API_KEY`
- [ ] Set `USE_REVENUECAT = YES` in `Info.plist` (or `NO` to use native StoreKit 2)

### Products to Create in App Store Connect

| Product ID | Type | Price | Display Name |
|---|---|---|---|
| `com.resurge.monthly` | Auto-Renewable Subscription | $4.99/mo | Resurge Premium Monthly |
| `com.resurge.yearly` | Auto-Renewable Subscription | $29.99/yr | Resurge Premium Yearly |
| `com.resurge.lifetime` | Non-Consumable | $79.99 | Resurge Premium Lifetime |
| `com.resurge.motivation_pack_*` | Consumable | $0.99 each | Motivation Pack |

### RevenueCat Entitlements

- [ ] Create entitlement: `premium` — grants access to all premium features
- [ ] Create offering: `default` — attach monthly, yearly, and lifetime products
- [ ] Create offering: `motivation_packs` — attach motivation pack consumables
- [ ] Map all App Store Connect products to RevenueCat products
- [ ] Test sandbox purchases on a physical device

### Subscription Group

- [ ] Create subscription group: **Resurge Premium**
- [ ] Add monthly and yearly subscriptions to the group
- [ ] Set upgrade/downgrade/crossgrade order: Yearly > Monthly
- [ ] Configure free trial if desired (e.g., 7-day trial on yearly plan)

---

## 5. Supabase Project Setup

- [ ] Create a Supabase project at https://supabase.com/dashboard
- [ ] Copy the **Project URL** into `Info.plist` under `SUPABASE_URL`
- [ ] Copy the **Anon (public) Key** into `Info.plist` under `SUPABASE_ANON_KEY`
- [ ] Set `USE_SUPABASE_SYNC = YES` in `Info.plist`
- [ ] Run the full schema from `Docs/supabase_schema.sql` in the SQL Editor
- [ ] Verify all 13 tables were created in Table Editor
- [ ] Verify RLS is enabled on all tables (green shield icon)

### Storage Bucket

- [ ] Confirm `user-images` bucket was created by the schema
- [ ] Verify bucket is set to **public** (for image URL access)
- [ ] Verify file size limit is 5 MB
- [ ] Verify allowed MIME types: `image/jpeg`, `image/png`, `image/webp`, `image/gif`
- [ ] Storage path convention: `{user_id}/{filename}` (enforced by RLS policy)

### Authentication

- [ ] Enable **Email** auth provider (for account creation)
- [ ] Enable **Apple** auth provider (for Sign in with Apple, future phase)
- [ ] Enable **Anonymous** sign-in (for community browsing without account)
- [ ] Set site URL to app deep link: `resurge://auth-callback`
- [ ] Add redirect URL: `resurge://auth-callback`

### Realtime

- [ ] Verify realtime is enabled for: `community_posts`, `community_comments`, `post_likes`, `chat_messages`, `group_memberships`
- [ ] Test realtime subscriptions from the Supabase client

---

## 6. APNs / Push Notification Setup

- [ ] Generate an APNs Key in Apple Developer portal (Keys section)
- [ ] Download the `.p8` key file and note the Key ID and Team ID
- [ ] (Optional) Upload APNs key to Supabase if using Supabase push notifications
- [ ] Local notifications are used initially (no server push required for Phase 1-6)
- [ ] Add `UNUserNotificationCenter` permission request in onboarding flow
- [ ] Configure default notification times:
  - Morning pledge reminder (configurable, default 8:00 AM)
  - Evening reflection reminder (configurable, default 9:00 PM)
  - Milestone celebration notifications

---

## 7. Age Rating & Content

- [ ] **Age Rating: 17+**
- [ ] Reason: App references alcohol, gambling, and sexual content in the context of addiction/habit recovery
- [ ] In the App Store Connect age rating questionnaire, mark:
  - [x] Alcohol, Tobacco, or Drug Use or References — **Frequent/Intense**
  - [x] Sexual Content or Nudity — **Infrequent/Mild** (references only)
  - [x] Gambling or Contests — **Simulated Gambling** (references only)
  - [x] Unrestricted Web Access — **No**
- [ ] Do NOT select "Made for Kids" — this app is 17+

---

## 8. Privacy Policy

- [ ] **A privacy policy URL is REQUIRED** for apps with:
  - User accounts / authentication
  - Community features (posts, comments, chat)
  - Cloud data sync
  - Health-related data collection
- [ ] Host privacy policy at a public URL (e.g., `https://resurge.app/privacy`)
- [ ] Enter the URL in App Store Connect under App Information > Privacy Policy URL
- [ ] Privacy policy must cover:
  - What data is collected (habit data, journal entries, community posts)
  - How data is stored (on-device Core Data + optional Supabase cloud)
  - Data deletion rights (user can delete account and all data)
  - Third-party services (RevenueCat, Supabase, optional Firebase)
  - No data is sold to third parties

### App Privacy Nutrition Labels

- [ ] Complete App Store Connect privacy questionnaire:
  - **Data Linked to You:** Display name, email (if account created)
  - **Data Not Linked to You:** Analytics (if Firebase enabled), crash data
  - **Data Used to Track You:** None
  - Health & fitness data is stored locally and optionally synced (user-controlled)

---

## 9. Compliance — Language & Medical Claims

- [ ] Use **"habit change / wellness"** language throughout the app
- [ ] **NEVER** use medical terminology or make medical claims:
  - Do NOT say: "treatment", "therapy", "cure", "medical", "clinical", "diagnosis"
  - DO say: "habit change", "recovery journey", "wellness", "personal growth", "support"
- [ ] App description must include disclaimer: "This app is not a substitute for professional medical advice, diagnosis, or treatment."
- [ ] Ensure community moderation tools are **visible and functional** (App Review will check)
  - Report content button on every post/comment
  - Block user functionality
  - Content filtering (ProfanityFilter)
- [ ] No user-generated content should appear unmoderated in screenshots

---

## 10. StoreKit Testing Configuration

- [ ] Create a StoreKit Configuration file: `Resurge/StoreKitConfiguration.storekit`
- [ ] Add test products matching App Store Connect IDs:
  - `com.resurge.monthly` — Auto-Renewable, $4.99
  - `com.resurge.yearly` — Auto-Renewable, $29.99
  - `com.resurge.lifetime` — Non-Consumable, $79.99
  - `com.resurge.motivation_pack_strength` — Consumable, $0.99
  - `com.resurge.motivation_pack_courage` — Consumable, $0.99
  - `com.resurge.motivation_pack_wisdom` — Consumable, $0.99
- [ ] In Xcode scheme, set StoreKit Configuration to the `.storekit` file
- [ ] Test purchase flows in the simulator with StoreKit testing
- [ ] Test restore purchases flow
- [ ] Test subscription expiration and renewal in sandbox
- [ ] Create a Sandbox tester account in App Store Connect for device testing

---

## 11. Bundle ID & Signing

- [ ] **Bundle ID:** `com.resurge.app`
- [ ] Select your Apple Developer Team in Xcode > Signing & Capabilities
- [ ] Enable automatic signing for development
- [ ] For release, configure a distribution provisioning profile
- [ ] Verify entitlements file includes:
  - `com.apple.developer.in-app-purchases`
  - `keychain-access-groups`

---

## 12. Pre-Submission Checklist

- [ ] App compiles with zero warnings (treat warnings as errors if possible)
- [ ] All unit tests pass: `xcodebuild test -scheme ResurgeTests`
- [ ] Test on multiple simulator sizes (iPhone SE, iPhone 16, iPhone 16 Pro Max)
- [ ] Test dark mode appearance
- [ ] Test with Dynamic Type (accessibility font sizes)
- [ ] Test VoiceOver accessibility
- [ ] Test offline mode (airplane mode) — app must be fully functional
- [ ] Test community features with Supabase connected
- [ ] Test IAP sandbox purchases on a physical device
- [ ] Prepare App Store screenshots (6.7", 6.5", 5.5" sizes minimum)
- [ ] Write App Store description emphasizing wellness/habit-change (no medical claims)
- [ ] Set up app preview video (optional but recommended)
- [ ] Archive and upload build via Xcode Organizer
- [ ] Submit for App Review
