# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LoopRoot (codebase still named "Resurge" internally) is an iOS habit & addiction recovery app built with SwiftUI, Core Data, and MVVM architecture. It supports 10 recovery programs (smoking, alcohol, porn, phone, social media, gaming, sugar, emotional eating, shopping, gambling). Bundle ID: `com.looproot.app`. Deployment target: iOS 15+. Fully offline — no servers, no accounts, no internet required. Tagline: "Stay in the loop. Find your root."

## Build & Run

- **Open in Xcode**: `open Resurge.xcodeproj`
- **Regenerate project** (when adding new files): `xcodegen generate` (requires XcodeGen via Homebrew). Scheme is defined in `project.yml`.
- **Build**: `xcodebuild -project Resurge.xcodeproj -scheme Resurge -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO build`
- **Build for simulator**: `xcodebuild -project Resurge.xcodeproj -scheme Resurge -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' build`
- **Run tests**: `xcodebuild test -project Resurge.xcodeproj -scheme Resurge -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'`
- If `xcodebuild` fails with "tool requires Xcode", prefix with: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
- **StoreKit testing**: Set StoreKit Configuration to `Resurge/Resources/Resurge.storekit` in Xcode scheme → Run → Options

## Architecture

**MVVM + Protocol-Based Services + Core Data**

- `App/ResurgeApp.swift` — Entry point, routes between onboarding and main tabs based on `@AppStorage("hasCompletedOnboarding")`
- `App/AppEnvironment.swift` — DI container holding all repositories and services. Uses `StoreKit2Provider` for real IAP. Injected via `.environmentObject()`
- `CoreData/` — 14 NSManagedObject subclasses (CD-prefixed: CDHabit, CDDailyLogEntry, etc.) + CoreDataStack with persistent and in-memory preview stores
- `Models/` — Domain enums/structs (ProgramType, MilestoneBadge, CravingToolKind, ShardEconomy, RecoveryArticle, QuoteBank, ProgramSetupField, HealthTimeline, GoalMode, PremiumFeature, etc.)
- `Repositories/` — 5 protocol + CoreData implementations (Habit, Log, Craving, Journal, Achievement)
- `Services/` — Business logic:
  - `IAP/` — StoreKit2Provider (real purchases), MockIAPProvider (testing), EntitlementManager (feature gating)
  - `RewardService.swift` — Surge (currency) awarding and spending
  - `DebugDate.swift` — Global date override for time travel testing (REMOVE before App Store)
  - `MetricsEngine.swift` — bestStreak, rolling7dFrequency, resilienceRate, improvementVsBaseline
  - `CorrelationEngine.swift` — Spearman correlations between daily check-in fields
  - `AchievementEvaluationService.swift` — Badge unlock evaluation with popup queue
  - NotificationManager, CoachingPlanService, DailyChallengeService
- `ViewModels/` — One per major feature (Home, HabitDetail, CravingMode, Journal, Settings, Analytics, Onboarding)
- `Features/` — UI screens organized by feature:
  - `Onboarding/` — WelcomeView (logo + rainbow), TimezoneSetupView, AddHabitOnboardingView (animated habit cards), ProgramSetupView, WhyGoalsView, NotificationSetupView, SubscriptionOfferView, SurgesIntroView
  - `Home/` — HomeView (sobriety counter, daily loop, scoreboard, goal card), HabitDetailView, CoachingPlanView (per-habit daily tasks), MorningPlanView, QuickCheckInView, EveningReviewView, GoalCompleteView, AddEditHabitView (3-step: select → customize → why)
  - `Progress/` — ProgressDashboardView (streaks, money, time reclaimed, badges, journal stats, recovery calendar)
  - `Library/` — LibraryHomeView, RecoveryLibraryView (CBT/ACT/SMART/MBRP), ArticleReaderView
  - `Profile/` — VaultShopView (Surges shop: celebrations, power-ups, themes, pets, accessories)
  - `CravingTools/` — CravingModeView (per-habit craving protocol), EmergencyModeView, individual tools
  - `Journal/` — JournalView (date-grouped, tags, daily prompt), JournalEditorView (also handles gratitude entries)
  - `Achievements/` — AchievementsView (surge balance + vault shop squares, badge vault, category sections), BadgeEmblemView (custom shapes: flames, watches, medallions), WatchFaceView, BadgeUnlockPopup
  - `Companion/` — CompanionPetViews (4 animated pets: Pup, Kitten, Nibbles, Owlet)
  - `ActivityLog/` — ActivityLogView (swipe-to-delete, per-habit filtering, date stamps on all entries)
  - Also: Analytics/, Settings/ (DebugTimeTravelView, StealthSettingsView, NotificationSettingsView)
- `ProgramTemplates/` — 10 program templates with triggers, coping tools, metrics, insight cards
- `Views/` — Shared: MainTabView (Home/Plan/Toolkit/Insights/Settings), ActivePetView, CelebrationOverlayView, BadgeUnlockPopupView, SobrietyCounterView, EmergencyButton
- `Theme/` — ThemeColors (cached singleton with auto-refresh), 5 themes (Default, Midnight, Neon Jungle, Ultraviolet, Ocean). Typography, AppStyle, NeonCardModifier, RainbowButtonStyle

## Key Conventions

- Core Data entity classes are prefixed with `CD` (e.g., `CDHabit`, `CDDailyLogEntry`)
- Use `NSFetchRequest<CDEntity>(entityName: "CDEntity")` instead of `CDEntity.fetchRequest()` to avoid type mismatch
- iOS 15+ compatibility: use `Font.xxx.weight(.bold)` instead of `.fontWeight(.bold)` (iOS 16+ only), avoid `.scrollContentBackground`, `.italic()` standalone
- Use `DebugDate.now` instead of `Date()` for all date comparisons/calculations (supports time travel debug). Use real `Date()` only for `createdAt` timestamps.
- `ThemeColors.shared` caches theme colors — call `.refreshIfNeeded()` automatically on access. Call `.refresh()` explicitly when theme changes.
- App is fully offline — no servers, no accounts, no tracking
- Premium gating via `EntitlementManager`:
  - **Free**: 1 habit, daily loop (3 check-ins), 1 daily quote, journal, craving tools, basic badges, earn Surges (15/day)
  - **Premium**: Unlimited habits, advanced analytics, 5x daily quotes, coaching plans, all badges unlockable
- Pricing: Monthly $4.99, Yearly $29.99, Lifetime $59.99 (configured in `Resurge.storekit`)

## Tab Structure

1. **Home** — Date + pet in nav bar, sobriety counter, daily loop (morning/afternoon/evening), scoreboard (days/cravings/lapses/activity log), goal card, craving protocol button
2. **Plan** — Weekly dot calendar, If-Then plans, new day/week prompts, high-risk windows
3. **Toolkit** — Workbook (journal, gratitude, coaching), craving tools (breathing, puzzle, focus shift, urge defusion, etc.), reasons vault, emergency/crisis helplines
4. **Insights** — Streak calendar, money saved, time reclaimed, badges section, journal stats, recent activity with dates
5. **Settings** — Notifications (daily loop + motivational boosts), stealth mode, subscription, emergency contacts, privacy, backup, time travel debug

## Surge Economy

- Currency: "Surges" (internal code still uses "shard" variable names)
- Earning: 15/day ONLY from daily loop (Morning 5 + Afternoon 5 + Evening 5)
- Spending: Vault Shop items (celebrations, power-ups, themes, pets, accessories)
- Storage: `CDRewardWallet` (Core Data) + `@AppStorage("shardBalance")` for quick display
- `CelebrationManager` — triggers full-screen animations when owned packs' conditions are met
- `BadgeUnlockManager` — queues badge unlock popups one at a time

## Lapse System

- Lapse detected in: QuickCheckInView, EveningReviewView, CravingModeView (didResist=false)
- On lapse: `habit.resetOnLapse()` moves `startDate` to `DebugDate.now`
- Resets: days, streak, timer, health milestones, time reclaimed, money saved, goal progress
- Keeps: badges earned, analytics/history, journal entries, Surges balance, lapse counter goes up
- Comforting message shown on all 3 lapse screens

## Badge System

- **Streak badges** (8): 3d → 365d, flame shape with animated gradient colors
- **Time Reclaimed badges** (10): 5h → 1000h (Timeless Legend), watch faces that get more sophisticated
- **Health badges** (dynamic per habit): generated from HealthTimeline milestones, capped at 1 year
- **Journal badges** (6): 1, 10, 50, 100, 250, 500 entries
- **Program badges** (50): 7d, 30d, 90d, 180d, 365d per habit (10 habits × 5)
- **Track badges** (20): Wave Rider, Resilience Builder, Plan Streak, Urge Scientist, Values Champ (4 tiers each)
- **Behavior badges** (misc): craving crushers, week warrior, tool explorer
- Evaluation runs on app foreground and via time travel debug
- `BadgeUnlockManager.shared.enqueue()` shows popup immediately

## Companion Pets

- 4 pets: Pup (dog), Kitten (cat), Nibbles (hamster), Owlet (white owl with galaxy eyes)
- Purchased from Vault Shop (500-800 Surges)
- `ActivePetView` shows on all 5 tab nav bars with equipped accessories
- Accessories: Tiny Hat, Cool Glasses, Royal Crown, Bowtie — positioned per-pet
- Stored in `UserDefaults("activePet")` and `UserDefaults("equippedAccessories")`

## Debug Tools (REMOVE before App Store)

- `DebugDate.swift` — Global date offset for time travel
- `DebugTimeTravelView` — Settings > Time Travel, shifts app date forward
- `VaultShopView.loadPurchasedItems()` — gives 2000 Surges for testing
- These are marked with comments in code

## SPM Dependencies

DGCharts, Lottie, Swift Collections (configured in `project.yml`)

## Tests

15 test files (~170+ tests) in `ResurgeTests/`:
- **SavingsCalculatorTests** — Money/time saved calculations
- **StreakEngineTests** — Streak counting, progress to goal
- **AchievementEvaluationTests** — Badge sorting, program template coverage
- **CoachingPlanServiceTests** — Plan generation, task completion, day advancement (13 tests)
- **DailyChallengeServiceTests** — Phase detection, deterministic selection, boundaries (14 tests)
- **QuoteBankTests** — Quote of the day, randomization, program filtering (12 tests)
- **RewardSystemTests** — Point values, streak bonus, collectible unlocking (22 tests)
- **MetricsEngineTests** — Best streak, rolling frequency, resilience rate (22 tests)
- **HealthTimelineTests** — Milestones per program, sorting, descriptions (5 tests)
- **ProgramTemplateTests** — Template completeness, triggers, tools (6 tests)
- **RepositoryTests** — CRUD for habits, logs, cravings (10 tests)
- **EntitlementTests** — Free vs premium gating, habit limits (18 tests)
- **BadgeUnlockTests** — Milestone unlocking at correct days (7 tests)
- **NotificationTests** — Notification content and trigger setup (12 tests)
- **CompanionMoodTests** — Mood from recovery data, streak leveling (14 tests)
- **LapseReviewTests** — Lapse data saving, triggers, outcomes (7 tests)

All use `CoreDataStack.preview` for in-memory context where Core Data is needed.
