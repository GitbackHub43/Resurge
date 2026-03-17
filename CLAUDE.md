# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Resurge is an iOS habit & addiction recovery app built with SwiftUI, Core Data, and MVVM architecture. It supports 12 recovery programs (smoking, alcohol, porn, phone, social media, gaming, procrastination, sugar, emotional eating, shopping, gambling, sleep). Bundle ID: `com.resurge.app`. Deployment target: iOS 15+. Fully offline — no servers, no accounts, no internet required.

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
- `Models/` — Domain enums/structs (ProgramType, MilestoneBadge, CravingToolKind, RewardSystem, RecoveryArticle, QuoteBank, ProgramSetupField, HealthTimeline, GoalMode, PremiumFeature, etc.)
- `Repositories/` — 5 protocol + CoreData implementations (Habit, Log, Craving, Journal, Achievement)
- `Services/` — Business logic:
  - `IAP/` — StoreKit2Provider (real purchases), MockIAPProvider (testing), EntitlementManager (feature gating)
  - `Companion/` — VirtualCompanionService (mood from recovery data, streak-based leveling)
  - `MetricsEngine.swift` — bestStreak, rolling7dFrequency, resilienceRate, improvementVsBaseline
  - `CorrelationEngine.swift` — Spearman correlations between daily check-in fields
  - NotificationManager, CoachingPlanService, DailyChallengeService
- `ViewModels/` — One per major feature (Home, HabitDetail, CravingMode, Journal, Settings, Analytics, Onboarding)
- `Features/` — UI screens organized by feature:
  - `Onboarding/` — WelcomeView (sparkle particles + rainbow), AddHabitOnboardingView (animated habit cards), ProgramSetupView (dropdown pickers + start date), SeverityAssessmentView, WhyGoalsView, NotificationSetupView, SubscriptionOfferView
  - `Home/` — HomeView (hero sobriety counter, stat pills, quick actions, next milestone), HabitDetailView, HabitCardView, CoachingPlanView, DailyChallengeView, DailyCheckInView, QuickCheckInView, LapseReviewView (6-step flow), CompanionView (Recovery Guardian with contextual messages)
  - `Progress/` — ProgressDashboardView (6 sections: streaks, money, time, badges, journal stats, recovery points)
  - `Library/` — LibraryHomeView, RecoveryLibraryView (CBT/ACT/SMART/MBRP), ArticleReaderView, ArticleDetailView
  - `Profile/` — RewardsView (collectibles + Recovery Points)
  - `CravingTools/` — CravingModeView, EmergencyModeView, CravingToolsView, RememberWhyView
  - `Journal/` — JournalView (date-grouped, tags, daily prompt), JournalEditorView (tags, shuffle prompts)
  - `Achievements/` — AchievementsView, GoalLadderView, ConfettiView
  - Also: Analytics/, Settings/, ProgramTools/ (12 program-specific tools), ActivityLog/
- `ProgramTemplates/` — 12 program templates with triggers, coping tools, metrics, insight cards, and setup fields
- `Views/` — Shared: MainTabView (Home/Journal/Progress/More), ProgressRingView, PremiumGateView, SobrietyCounterView, DailyQuoteCard, EmergencyButton
- `Theme/` — Rainbow gradient theme matching logo (cyan→blue→purple→magenta→orange→gold on deep navy #05051A). Typography, AppStyle, NeonCardModifier, RainbowCardModifier, RainbowButtonStyle, RainbowTextModifier, SparkleParticlesView, RainbowDivider

## Key Conventions

- Core Data entity classes are prefixed with `CD` (e.g., `CDHabit`, `CDDailyLogEntry`)
- Use `NSFetchRequest<CDEntity>(entityName: "CDEntity")` instead of `CDEntity.fetchRequest()` to avoid type mismatch
- iOS 15+ compatibility: use `Font.xxx.weight(.bold)` instead of `.fontWeight(.bold)` (iOS 16+ only)
- Optional SDK imports guarded with `#if canImport(RevenueCat)`, `#if canImport(FirebaseAnalytics)` — all currently inactive
- App is fully offline — no servers, no accounts, no tracking
- Premium gating via `EntitlementManager`:
  - **Free**: 1 habit, daily motivation quotes, companion (basic mood), daily challenges, basic badges, journal, craving tools, lapse review
  - **Premium**: Unlimited habits, advanced analytics, recovery library, coaching plans, reward collectibles, biometric lock, companion evolution
- Pricing: Monthly $4.99, Yearly $29.99, Lifetime $59.99 (configured in `Resurge.storekit`)

## Tab Structure

1. **Home** — Hero sobriety counter, daily action card, stat pills, quick actions, next milestone
2. **Journal** — Date-grouped entries, tags (gratitude/trigger/reflection/win/struggle), daily prompts
3. **Progress** — Streaks, money saved, time reclaimed, badges, journal stats, recovery points
4. **More** — Settings, notifications, privacy, subscription, emergency contacts, export, privacy policy, terms

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
