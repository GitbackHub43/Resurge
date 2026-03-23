# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LoopRoot (codebase still named "Resurge" internally) is an iOS habit & addiction recovery app built with SwiftUI, Core Data, and MVVM architecture. It supports 10 recovery programs (smoking, alcohol, porn, phone, social media, gaming, sugar, emotional eating, shopping, gambling). NO custom habits. Bundle ID: `com.looproot.app`. Deployment target: iOS 15+. Fully offline — no servers, no accounts, no internet required. Tagline: "Escape the loop. Find your root."

## Build & Run

- **Open in Xcode**: `open Resurge.xcodeproj`
- **Regenerate project** (when adding new files): `xcodegen generate` (requires XcodeGen via Homebrew). Scheme is defined in `project.yml`.
- **Build**: `xcodebuild -project Resurge.xcodeproj -scheme Resurge -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO build`
- **Build for simulator**: `xcodebuild -project Resurge.xcodeproj -scheme Resurge -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' build`
- If `xcodebuild` fails with "tool requires Xcode", prefix with: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
- **StoreKit testing**: Set StoreKit Configuration to `Resurge/Resources/Resurge.storekit` in Xcode scheme → Run → Options
- **Tests**: All test files have been deleted. No test target exists.

## Architecture

**MVVM + Protocol-Based Services + Core Data**

- `App/ResurgeApp.swift` — Entry point, routes between onboarding and main tabs. Stamps `onboardingCompletedDate` for day-1 unlock.
- `App/AppEnvironment.swift` — DI container holding all repositories and services. Uses `StoreKit2Provider` for real IAP. Injected via `.environmentObject()`
- `CoreData/` — NSManagedObject subclasses (CD-prefixed: CDHabit, CDDailyLogEntry, etc.) + CoreDataStack. `CDHabit.safeDisplayName` always returns "Quit [Program]" if name is empty or matches raw program name.
- `Models/` — Domain enums/structs (ProgramType, MilestoneBadge, CravingToolKind, ShardEconomy, QuoteBank, ProgramSetupField, HealthTimeline, GoalMode, PremiumFeature, etc.)
- `Repositories/` — 5 protocol + CoreData implementations (Habit, Log, Craving, Journal, Achievement)
- `Services/` — Business logic:
  - `IAP/` — StoreKit2Provider (real purchases), MockIAPProvider (testing), EntitlementManager (feature gating)
  - `RewardService.swift` — Surge (currency) awarding and spending
  - `EncryptedBackupService.swift` — AES-256-GCM backup export/import with passphrase
  - `NotificationScheduler.swift` — Schedules daily loop + quote notifications, per-habit, stealth-aware
  - `MetricsEngine.swift` — bestStreak, rolling7dFrequency, resilienceRate, improvementVsBaseline
  - `CorrelationEngine.swift` — Spearman correlations between daily check-in fields
  - `AchievementEvaluationService.swift` — Badge unlock evaluation with popup queue
  - `CoachingPlanService.swift` — 14-day coaching plan (9 universal + 5 per-program tasks)
- `Features/` — UI screens organized by feature:
  - `Onboarding/` — WelcomeView (logo), TimezoneSetupView, AddHabitOnboardingView, ProgramSetupView, WhyGoalsView, NotificationSetupView, SubscriptionOfferView, PrivacyInfoView, SurgesIntroView
  - `Home/` — HomeView (sobriety counter with program color tint, time-locked daily loop, scoreboard, goal card, "Did You Know?" insight cards, "Your Why" with inline edit), CoachingPlanView, MorningPlanView, QuickCheckInView, EveningReviewView, GoalCompleteView, AddEditHabitView
  - `Progress/` — ProgressDashboardView (streaks, time reclaimed, badges, journal stats, recovery calendar with lapse markers)
  - `Library/` — LibraryHomeView, RecoveryLibraryView (CBT/ACT/SMART/MBRP), ArticleReaderView
  - `Profile/` — VaultShopView (celebrations, watch skins, themes, pets, accessories)
  - `CravingTools/` — CravingModeView (per-habit triggers + tools), GroundingExerciseView, individual tools (Breathing, FocusShift, NumberPuzzle, ValuesCompass, TimePortal, CopingSimulator, BodyOverride, UrgeDefusion)
  - `Journal/` — JournalView, JournalEditorView (handles journal + gratitude + craving journal entries)
  - `Achievements/` — AchievementsView (surge balance, vault shop, per-habit badge vault), BadgeEmblemView, WatchFaceView
  - `Companion/` — CompanionPetViews (Pup, Kitten, Nibbles, Owlet)
  - `ActivityLog/` — ActivityLogView (swipe-to-delete, per-habit filtering, date stamps)
  - `Analytics/` — AdvancedAnalyticsView, WeekOverWeekView, ToolEffectivenessView, TriggerEffectivenessView
  - `Settings/` — NotificationSettingsView, StealthSettingsView, SubscriptionStatusView, BackupView, SuggestionBoxView, PrivacyPolicyView, TermsOfServiceView
- `ProgramTemplates/` — 10 program templates with triggers, coping tools, metrics, insight cards
- `Views/` — Shared: MainTabView (Home/Plan/Toolkit/Insights/Settings), ActivePetView (with show/hide toggle), SobrietyCounterView (program-color tinted, watch skin support), EmergencyButton
- `Theme/` — ThemeColors (cached singleton), 5 themes (Default, Midnight, Neon Jungle, Ultraviolet, Ocean). Typography, AppStyle, NeonCardModifier, RainbowButtonStyle

## Key Conventions

- Core Data entity classes are prefixed with `CD` (e.g., `CDHabit`, `CDDailyLogEntry`)
- Use `NSFetchRequest<CDEntity>(entityName: "CDEntity")` instead of `CDEntity.fetchRequest()` to avoid type mismatch
- iOS 15+ compatibility: use `Font.xxx.weight(.bold)` instead of `.fontWeight(.bold)` (iOS 16+ only)
- Always use `habit.safeDisplayName` for display — NEVER `habit.name` directly in UI Text views
- `ThemeColors.shared` caches theme colors — call `.refreshIfNeeded()` automatically on access
- App is fully offline — no servers, no accounts, no tracking, no network calls
- Premium gating via `EntitlementManager`:
  - **Free**: 1 habit, daily loop (3 check-ins), 1 daily quote, journal, craving tools, basic badges, earn Surges (15/day)
  - **Premium**: Unlimited habits, advanced analytics, 5x daily quotes, daily coaching, all badges unlockable, premium vault items
- Pricing: Monthly $4.99, Yearly $39.99, Lifetime $99.99 (StoreKit IDs: `com.looproot.premium.*`)

## Tab Structure

1. **Home** — Date + pet in nav bar, program-colored sobriety counter with watch skin, time-locked daily loop (6hr gaps from wake time), scoreboard (days/cravings/lapses/activity log), "Your Why" with pencil edit, "Did You Know?" insight card, craving protocol button. Long-press habit pill to delete.
2. **Plan** — Weekly dot calendar, If-Then plans with per-habit suggested templates, new day/week prompts, high-risk windows
3. **Toolkit** — "Best for Quit [Habit]" recommended tools (top 3 per program), Workbook (journal, gratitude, coaching), craving tools (breathing, grounding, focus shift, urge defusion, body override, coping simulator, time portal, values compass), crisis helplines. All tools reset on reopen. "Did this help resist?" popup after every tool. Gave-in triggers full lapse reset with comfort message.
4. **Insights** — Per-habit streak calendar (green = clean, red X = lapse), time reclaimed, per-habit badge count, journal stats, recent activity with dates
5. **Settings** — Notifications (daily loop 6hrs apart + motivational boosts 3hrs apart from wake+1), stealth mode (auto-reschedules notifications), show/hide companion (from vault), subscription, emergency contacts, encrypted backup, suggestion box (emails LoopRootAssist@gmail.com), privacy policy, terms of service

## Surge Economy

- Currency: "Surges" (internal code uses "shard" variable names)
- Earning: 15/day ONLY when ALL 3 daily loops complete for the SAME habit. Not awarded individually. Capped at 15/day across all habits.
- Time-locked: Morning at wake time, Afternoon at wake+6, Evening at wake+12. Day 1 (onboarding day) all unlocked. Future start date habits fully locked.
- Spending: Vault Shop items (celebrations, watch skins, themes, pets, accessories)
- Storage: `CDRewardWallet` (Core Data) + `@AppStorage("shardBalance")` synced on award and vault open
- Premium-locked vault items: celebrations, pets, accessories, premium watch skins, premium themes

## Lapse System

- Lapse detected in: QuickCheckInView, EveningReviewView, CravingModeView (didResist=false), ALL toolkit tools (trackToolCompletion with didResist=false)
- On lapse: `habit.resetOnLapse()` moves `startDate` to `DebugDate.now`
- Resets: days, streak, timer, health milestones, time reclaimed, goal progress
- Keeps: badges earned, analytics/history, journal entries, Surges balance, lapse counter goes up
- Comforting message shown on ALL lapse screens including toolkit tools
- Recovery calendar shows red X on lapse days

## Badge System (per-habit count, ~39-44 per habit)

- **Streak badges** (8): 3d → 365d, flame shape with animated gradient colors
- **Time Reclaimed badges** (10): 5h → 1000h (Timeless Legend), watch faces
- **Health badges** (dynamic per habit): generated from HealthTimeline milestones, capped at 1 year
- **Journal badges** (6): 1, 10, 50, 100, 250, 500 entries
- **Program badges** (5 per habit): 7d, 30d, 90d, 180d, 365d — filtered to show only selected habit
- **Behavior badges**: craving crushers, week warrior, tool explorer
- Badge count shown per-habit (not total across all habits), deduplicated by key
- Vault purchases NOT included in badge count (shown separately in "Vault Purchases")
- Evaluation runs on app foreground
- `BadgeUnlockManager.shared.enqueue()` shows popup immediately

## Habit Individualization (18 touchpoints per program)

- Program-specific triggers in craving mode (not generic)
- Program-colored sobriety counter (tint, glow, clock icon)
- Program-specific daily loop prompts (pledge, reflection, check-in)
- Rotating "Did You Know?" insight cards from ProgramTemplates
- "Best for Quit [Habit]" recommended tools (top 3 per program)
- Pre-written If-Then plan suggestions per program
- Per-program coaching tasks (days 10-14)
- Per-program motivational quotes and daily tips
- Per-program health milestones and crisis helplines
- Per-program setup fields in onboarding
- Trigger icons contextual per trigger type (fork.knife for meals, moon for night, etc.)

## Companion Pets

- 4 pets: Pup (dog), Kitten (cat), Nibbles (hamster), Owlet (white owl with galaxy eyes)
- Purchased from Vault Shop (500-800 Surges), premium-only
- Activate/deactivate from vault (not settings)
- `ActivePetView` shows on all 5 tab nav bars with equipped accessories
- Accessories: Tiny Hat, Cool Glasses, Bowtie, Royal Crown — activate/deactivate from vault
- Watch Skins: Classic (free), Digital, Luxury, Holographic — equip/remove from vault

## Habit Management

- Add habit: + button on home (premium only for 2+) → habit selection → Customize Plan → Your Why
- Delete habit: long-press habit pill → confirmation → cascade deletes all logs, cravings, journals, plans, UserDefaults keys
- Tooltip shown once when adding second habit about long-press delete
- All habits named "Quit [Program]" — `safeDisplayName` enforces this

## Notifications

- Daily loop: 3 notifications at wake time, wake+6, wake+12 (6hr intervals)
- Motivational quotes: wake+1, wake+4, wake+7, wake+10, wake+13 (3hr intervals, premium gets 5, free gets 1)
- Per-habit: each habit gets its own notifications with habit-specific content
- Only scheduled for habits that have started (startDate <= now)
- Stealth mode: auto-reschedules with redacted content when toggled
- All local notifications — no push notification server

## Legal & Support

- Privacy Policy + Terms of Service: in-app views + hosted on GitHub Pages
- Company: Thryvenex Holdings LLC
- Support: LoopRootAssist@gmail.com
- Suggestion Box in Settings (opens email compose with fallback to clipboard)
- App is fully offline — `ITSAppUsesNonExemptEncryption = NO` in Info.plist

## SPM Dependencies

DGCharts, Lottie, Swift Collections (configured in `project.yml`)
