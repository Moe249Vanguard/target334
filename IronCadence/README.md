# Iron Cadence: military calisthenics coach for iPhone

A native SwiftUI iPhone app that builds and coaches a personalized military-style
bodyweight program. Garmin data comes in through Apple Health. The app also has
reminders and a full nutrition plan.

## Features

| Area | What it does |
|---|---|
| **Personalized program** | Onboarding captures age, sex, height, weight (BMI), daily activity, goal, schedule and a baseline test (max push-ups, pull-ups, plank, 1-min squats). It generates an 8-week periodized plan: 3 build weeks plus a deload, twice, with reps at about 55% of your tested max progressing about 8% per week. |
| **Age / body adaptation** | Volume drops and rest lengthens with age (35+, 45+, 55+). BMI ≥ 30 or age ≥ 55 switches on joint-friendly mode, which swaps jumping drills for low-impact versions. No pull-ups yet? You get rows and slow negatives. Under 5 push-ups? Incline progressions. |
| **Military goals** | General readiness, Army-style test (hand-release push-ups, plank, sprints), Marine-style PFT (pull-ups, plank), Navy-style PRT (push-ups, plank, intervals), fat loss, strength-endurance. |
| **Drill manual** | 40+ exercises, each with step-by-step instructions, coaching cues, common mistakes, easier/harder variations and military context. |
| **Form videos** | Every exercise has a **Watch form videos** button that opens tutorials in an in-app browser. To use your own clips, add `<exercise-id>.mp4` (e.g. `push-up.mp4`) to the app target and it plays inline. |
| **Workout player** | Guided set by set, with countdown timers for timed holds and rests, voice cues, haptics, +15 s rest, pause, and a debrief with RPE. The screen stays awake during workouts. |
| **Garmin link** | Via Apple Health: reads heart rate, resting HR, HRV, sleep, steps and weight (Garmin Connect writes these). Each session is saved as *Functional Strength Training* with avg/max heart rate from your watch. Workouts recorded on the watch are listed too. |
| **Notifications** | Training-day reminders (choose days and time), hydration every N hours, meal-time reminders, a post-workout refuel nudge and a weekly Sunday check-in. |
| **Nutrition** | Mifflin-St Jeor BMR → maintenance → goal-adjusted calories (−20% for fat loss, +10% for strength). Protein 1.8–2.2 g/kg (higher for fat loss and age 50+). Fat ≥ 0.6 g/kg, carbs fill the rest. Water at 35 ml/kg plus training extra, with a water logger. Includes a 5-meal timing plan with examples and field nutrition tips. |

## Install on your iPhone

**No Mac?** Follow [TESTFLIGHT.md](TESTFLIGHT.md): GitHub Actions builds, signs and uploads to TestFlight, and you install from the TestFlight app.

### With a Mac

You need a Mac with **Xcode 16+** and a free Apple ID. A paid developer account
is only required for TestFlight / App Store distribution.

```bash
brew install xcodegen
cd IronCadence
xcodegen generate
open IronCadence.xcodeproj
```

1. In Xcode, select the **IronCadence** target → *Signing & Capabilities* → choose your Team.
   If the bundle ID `com.ironcadence.app` is taken, change it to something unique.
2. Plug in your iPhone (enable *Developer Mode* under Settings → Privacy & Security), select it as the run destination, and press **Run**.
3. On first launch, complete onboarding, then connect Apple Health and allow notifications.

> With a free Apple ID, apps you sideload expire after 7 days. Re-run from Xcode to refresh them.
> A paid account removes this limit and lets you use TestFlight.

## Linking your Garmin watch

Garmin watches don't talk to third-party iPhone apps directly, so the supported route is through Apple Health:

1. **Garmin Connect app → More → Settings → Connected Apps → Apple Health** → enable sharing.
2. In Iron Cadence, go to **Profile → Connect Apple Health** and grant access.
3. When you train, start a **Strength** activity on your watch and follow the workout in the app.
   After Garmin Connect syncs, open **Program → History → Pull heart rate** to attach avg/max HR to your sessions.

Garmin Connect only writes to Apple Health and doesn't read from it, so sessions logged in Iron
Cadence appear in Apple Health but not in Garmin Connect. Going further, such as on-watch workouts
or a native data field, would need a separate Garmin **Connect IQ** app (Monkey C) and the Garmin
Connect IQ SDK.

## Project layout

```
IronCadence/
├── fastlane/Fastfile        CI lane: signing (match) → build → TestFlight upload
├── project.yml              XcodeGen spec (HealthKit entitlement, Info.plist privacy strings)
├── App/
│   ├── Models/              Profile, goals, workouts, logs, settings
│   ├── Data/                Exercise library (instructions, cues, mistakes, scaling)
│   ├── Engine/              ProgramGenerator, NutritionCalculator, WorkoutSequencer
│   ├── Services/            AppStore (JSON persistence), HealthKitManager, NotificationManager, Coach (voice/haptics)
│   └── Views/               Onboarding, Today, Program, Player, Drill manual, Fuel, Profile
└── Tests/                   Unit tests for program generation and nutrition math
```

CI (`.github/workflows/ios.yml`) generates the project and runs the unit tests on a macOS runner whenever `IronCadence/**` changes.

## Disclaimer

Iron Cadence is a training aid, not medical or dietetic advice. Get medical clearance before
starting a new program. Stop if you feel pain, dizziness or chest discomfort. Military test
formats change: always check the current official standards for your service.
