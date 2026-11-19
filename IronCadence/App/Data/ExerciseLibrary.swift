import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case warmup, push, pull, legs, core, conditioning, mobility
    var id: String { rawValue }

    var label: String {
        switch self {
        case .warmup: return "Warm-up"
        case .push: return "Push"
        case .pull: return "Pull"
        case .legs: return "Legs"
        case .core: return "Core"
        case .conditioning: return "Conditioning"
        case .mobility: return "Mobility & Cool-down"
        }
    }

    var icon: String {
        switch self {
        case .warmup: return "thermometer.sun"
        case .push: return "arrow.up.square"
        case .pull: return "arrow.down.square"
        case .legs: return "figure.step.training"
        case .core: return "figure.core.training"
        case .conditioning: return "heart.circle"
        case .mobility: return "figure.cooldown"
        }
    }
}

struct Exercise: Identifiable, Hashable {
    let id: String
    let name: String
    let category: ExerciseCategory
    let muscles: [String]
    let difficulty: Int            // 1 (easiest) … 5
    let highImpact: Bool
    let steps: [String]
    let cues: [String]
    let mistakes: [String]
    var easier: String? = nil      // regression exercise id
    var harder: String? = nil      // progression exercise id
    var militaryNote: String? = nil

    /// A demo video you add yourself: drop `<id>.mp4` into the app bundle and it plays in-app.
    var bundledVideoURL: URL? { Bundle.main.url(forResource: id, withExtension: "mp4") }

    /// Fallback: a YouTube search for a form tutorial of this exercise.
    var videoSearchURL: URL {
        var c = URLComponents(string: "https://www.youtube.com/results")!
        c.queryItems = [URLQueryItem(name: "search_query", value: "\(name) proper form tutorial")]
        return c.url!
    }
}

enum ExerciseLibrary {
    static func exercise(_ id: String) -> Exercise {
        byID[id] ?? all[0]
    }

    static let byID: [String: Exercise] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    static func exercises(in category: ExerciseCategory) -> [Exercise] {
        all.filter { $0.category == category }
    }

    static let all: [Exercise] = [
        // MARK: Warm-up
        Exercise(
            id: "jumping-jack", name: "Jumping Jacks", category: .warmup,
            muscles: ["Full body", "Calves", "Shoulders"], difficulty: 1, highImpact: true,
            steps: ["Stand tall, feet together, arms by your sides.",
                    "Jump feet out wider than shoulders while sweeping arms overhead.",
                    "Jump back to the start. Keep a steady rhythm."],
            cues: ["Land softly on the balls of your feet", "Arms straight, full range", "Breathe rhythmically"],
            mistakes: ["Landing flat-footed and heavy", "Half arm swings"],
            easier: "march-in-place",
            militaryNote: "A staple of military PT warm-ups, often counted in cadence."),
        Exercise(
            id: "march-in-place", name: "High March", category: .warmup,
            muscles: ["Hip flexors", "Core"], difficulty: 1, highImpact: false,
            steps: ["Stand tall with a braced core.",
                    "Drive one knee to hip height while swinging the opposite arm.",
                    "Alternate legs at a brisk pace."],
            cues: ["Tall posture, no leaning back", "Knee to hip height", "Opposite arm, opposite leg"],
            mistakes: ["Slouching", "Tiny knee lifts"],
            harder: "high-knees"),
        Exercise(
            id: "arm-circles", name: "Arm Circles", category: .warmup,
            muscles: ["Shoulders", "Upper back"], difficulty: 1, highImpact: false,
            steps: ["Arms straight out to the sides at shoulder height.",
                    "Make small circles forward, gradually getting bigger.",
                    "Reverse direction halfway through."],
            cues: ["Shoulders down, away from ears", "Controlled circles", "Squeeze the shoulder blades lightly"],
            mistakes: ["Shrugging", "Swinging wildly"]),
        Exercise(
            id: "inchworm", name: "Inchworm", category: .warmup,
            muscles: ["Hamstrings", "Shoulders", "Core"], difficulty: 2, highImpact: false,
            steps: ["Stand, hinge at the hips and place hands on the floor (bend knees if needed).",
                    "Walk hands forward to a high plank.",
                    "Walk feet toward hands, stand up. That is one rep."],
            cues: ["Brace in the plank, no sagging hips", "Small hand steps", "Feel the hamstring stretch"],
            mistakes: ["Letting the lower back sag", "Rushing"]),
        Exercise(
            id: "worlds-greatest-stretch", name: "World's Greatest Stretch", category: .warmup,
            muscles: ["Hips", "Thoracic spine", "Hamstrings"], difficulty: 2, highImpact: false,
            steps: ["Step into a long lunge, hands on the floor inside the front foot.",
                    "Drop the inside elbow toward the front ankle.",
                    "Rotate that arm up to the sky, eyes follow the hand.",
                    "Return and switch sides."],
            cues: ["Back knee off the floor, back leg active", "Rotate through the upper back", "Slow and deliberate"],
            mistakes: ["Collapsing the back leg", "Rotating only the arm, not the torso"]),

        // MARK: Push
        Exercise(
            id: "incline-push-up", name: "Incline Push-up", category: .push,
            muscles: ["Chest", "Triceps", "Shoulders"], difficulty: 1, highImpact: false,
            steps: ["Hands on a bench, table or wall, slightly wider than shoulders.",
                    "Walk feet back so your body is one straight line.",
                    "Lower chest to the edge, elbows about 45° from your body.",
                    "Press back up to straight arms."],
            cues: ["Squeeze glutes and brace abs", "Chest leads, not the chin", "Lower the surface as you get stronger"],
            mistakes: ["Hips sagging", "Elbows flared to 90°", "Partial range"],
            harder: "push-up",
            militaryNote: "The fastest route to your first full push-ups for the fitness test."),
        Exercise(
            id: "push-up", name: "Push-up", category: .push,
            muscles: ["Chest", "Triceps", "Shoulders", "Core"], difficulty: 2, highImpact: false,
            steps: ["Hands just wider than shoulders, fingers forward, body in a straight line from head to heels.",
                    "Lower as one unit until your upper arms are parallel to the floor or your chest nearly touches.",
                    "Elbows track roughly 45° from your torso.",
                    "Press the floor away until arms are fully straight."],
            cues: ["Plank position the whole time", "Screw hands into the floor", "Exhale on the way up"],
            mistakes: ["Sagging hips or piked butt", "Head dropping", "Not locking out at the top"],
            easier: "incline-push-up", harder: "diamond-push-up",
            militaryNote: "Core event in most military tests. Standards usually require full lockout and a straight body."),
        Exercise(
            id: "hand-release-push-up", name: "Hand-Release Push-up", category: .push,
            muscles: ["Chest", "Triceps", "Shoulders", "Upper back"], difficulty: 3, highImpact: false,
            steps: ["Start in a push-up position.",
                    "Lower your whole body until chest, hips and thighs touch the floor.",
                    "Lift hands off the floor briefly, extending arms out to a T (or just lifting them).",
                    "Replace hands and press up to full lockout as one straight unit."],
            cues: ["Rise as one solid plank", "Quick, controlled hand release", "Keep a steady pace you can hold"],
            mistakes: ["Worming up hips-first", "Not fully touching down", "Bent elbows at the top"],
            easier: "push-up",
            militaryNote: "Used in the US Army test. Removing momentum at the bottom makes every rep honest."),
        Exercise(
            id: "diamond-push-up", name: "Diamond Push-up", category: .push,
            muscles: ["Triceps", "Inner chest"], difficulty: 3, highImpact: false,
            steps: ["Form a diamond with thumbs and index fingers under your chest.",
                    "Keep elbows tucked close as you lower.",
                    "Touch the chest to the hands, press back up."],
            cues: ["Elbows back, not out", "Body rigid", "Full lockout"],
            mistakes: ["Flaring elbows", "Shrugging shoulders"],
            easier: "push-up", harder: "decline-push-up"),
        Exercise(
            id: "decline-push-up", name: "Decline Push-up", category: .push,
            muscles: ["Upper chest", "Shoulders", "Triceps"], difficulty: 4, highImpact: false,
            steps: ["Feet on a bench or step, hands on the floor.",
                    "Lower your chest under control toward the floor.",
                    "Press back to full lockout."],
            cues: ["Brace hard so hips don't sag", "Head neutral", "Controlled tempo"],
            mistakes: ["Hips sagging", "Shortened range"],
            easier: "push-up"),
        Exercise(
            id: "pike-push-up", name: "Pike Push-up", category: .push,
            muscles: ["Shoulders", "Triceps"], difficulty: 3, highImpact: false,
            steps: ["From a downward-dog shape, hips high, hands shoulder width.",
                    "Bend elbows to lower the top of your head toward the floor in front of your hands.",
                    "Press back up through straight arms."],
            cues: ["Head travels forward, making a tripod", "Hips stay high", "Elbows track back"],
            mistakes: ["Turning it into a regular push-up", "Flared elbows"],
            easier: "push-up"),
        Exercise(
            id: "bench-dip", name: "Bench Dip", category: .push,
            muscles: ["Triceps", "Chest", "Front shoulders"], difficulty: 2, highImpact: false,
            steps: ["Hands on the edge of a bench behind you, fingers forward.",
                    "Legs bent (easier) or straight (harder).",
                    "Lower until elbows reach about 90°, then press back up."],
            cues: ["Keep hips close to the bench", "Shoulders down and back", "Don't go deeper than comfortable"],
            mistakes: ["Dropping too deep and straining the shoulder", "Elbows flaring outward"]),

        // MARK: Pull
        Exercise(
            id: "inverted-row", name: "Inverted Row", category: .pull,
            muscles: ["Lats", "Upper back", "Biceps"], difficulty: 2, highImpact: false,
            steps: ["Lie under a sturdy bar or table edge set at waist height.",
                    "Grip slightly wider than shoulders, body straight, heels on the floor.",
                    "Pull your chest to the bar, squeezing shoulder blades together.",
                    "Lower under control to straight arms."],
            cues: ["Rigid plank body", "Lead with the chest", "Bend knees to make it easier"],
            mistakes: ["Hips sagging", "Reaching with the chin", "Dropping fast"],
            harder: "negative-pull-up",
            militaryNote: "Builds the pulling base you need before your first pull-up."),
        Exercise(
            id: "negative-pull-up", name: "Negative Pull-up", category: .pull,
            muscles: ["Lats", "Biceps", "Grip"], difficulty: 3, highImpact: false,
            steps: ["Use a box or jump to get your chin over the bar.",
                    "Lower yourself as slowly as possible (aim for 3–5 seconds).",
                    "At the bottom, step back up and repeat."],
            cues: ["Fight gravity the whole way", "Shoulders engaged, not hanging loose", "Full extension at the bottom"],
            mistakes: ["Dropping the last half", "Kicking"],
            easier: "inverted-row", harder: "pull-up"),
        Exercise(
            id: "pull-up", name: "Pull-up", category: .pull,
            muscles: ["Lats", "Biceps", "Rear shoulders", "Grip"], difficulty: 4, highImpact: false,
            steps: ["Hang from the bar with an overhand grip, slightly wider than shoulders, arms fully straight.",
                    "Pull shoulder blades down, then drive elbows toward your ribs.",
                    "Pull until your chin clears the bar.",
                    "Lower under control to a full dead hang."],
            cues: ["Start every rep from straight arms", "Chest up toward the bar", "No kipping or swinging"],
            mistakes: ["Half reps", "Kicking legs for momentum", "Craning the neck over the bar"],
            easier: "negative-pull-up", harder: "chin-up",
            militaryNote: "A scored Marine PFT event. Strict dead-hang reps are the standard."),
        Exercise(
            id: "chin-up", name: "Chin-up", category: .pull,
            muscles: ["Lats", "Biceps"], difficulty: 3, highImpact: false,
            steps: ["Hang with an underhand grip at shoulder width.",
                    "Pull until your chin is over the bar.",
                    "Lower to full extension."],
            cues: ["Elbows drive down", "Squeeze at the top", "Controlled descent"],
            mistakes: ["Partial range", "Swinging"],
            easier: "negative-pull-up"),
        Exercise(
            id: "dead-hang", name: "Dead Hang", category: .pull,
            muscles: ["Grip", "Shoulders", "Lats"], difficulty: 2, highImpact: false,
            steps: ["Grip the bar overhand, shoulder width.",
                    "Hang with straight arms and feet off the floor.",
                    "Hold for time, breathing steadily."],
            cues: ["Light shoulder engagement", "Squeeze the bar hard", "Relax the legs"],
            mistakes: ["Fully passive shoulders if they hurt", "Holding your breath"],
            harder: "flexed-arm-hang"),
        Exercise(
            id: "flexed-arm-hang", name: "Flexed-Arm Hang", category: .pull,
            muscles: ["Biceps", "Lats", "Grip"], difficulty: 3, highImpact: false,
            steps: ["Get your chin above the bar (jump or use a box).",
                    "Hold that position with elbows bent and chin over the bar.",
                    "Hold for time, then lower with control."],
            cues: ["Chest to the bar", "Don't rest the chin on the bar", "Breathe"],
            mistakes: ["Tilting the head back to cheat", "Dropping suddenly"],
            easier: "dead-hang"),

        // MARK: Legs
        Exercise(
            id: "air-squat", name: "Air Squat", category: .legs,
            muscles: ["Quads", "Glutes", "Hamstrings"], difficulty: 1, highImpact: false,
            steps: ["Feet shoulder width, toes slightly out.",
                    "Push hips back and bend knees, arms reaching forward for balance.",
                    "Descend until hips are at or below knee height.",
                    "Drive through the whole foot to stand tall."],
            cues: ["Knees track over toes", "Chest proud", "Heels stay down"],
            mistakes: ["Knees caving inward", "Heels lifting", "Rounding the back"],
            harder: "jump-squat"),
        Exercise(
            id: "jump-squat", name: "Jump Squat", category: .legs,
            muscles: ["Quads", "Glutes", "Calves"], difficulty: 3, highImpact: true,
            steps: ["Squat to a comfortable depth.",
                    "Explode upward, leaving the ground.",
                    "Land softly back into the next squat."],
            cues: ["Quiet landings", "Knees out", "Swing arms for power"],
            mistakes: ["Stiff-legged landing", "Knees caving on landing"],
            easier: "air-squat"),
        Exercise(
            id: "walking-lunge", name: "Walking Lunge", category: .legs,
            muscles: ["Quads", "Glutes", "Balance"], difficulty: 2, highImpact: false,
            steps: ["Step forward into a long stride.",
                    "Lower until the back knee nearly touches the ground.",
                    "Drive through the front heel to step forward into the next lunge."],
            cues: ["Torso upright", "Front knee over the ankle", "Controlled, no knee slamming"],
            mistakes: ["Short steps that stress the knee", "Leaning forward"],
            easier: "reverse-lunge",
            militaryNote: "Mimics loaded movement on a ruck march."),
        Exercise(
            id: "reverse-lunge", name: "Reverse Lunge", category: .legs,
            muscles: ["Quads", "Glutes"], difficulty: 1, highImpact: false,
            steps: ["Stand tall, step one foot back.",
                    "Lower until both knees reach about 90°.",
                    "Push through the front foot to return."],
            cues: ["Weight in the front heel", "Upright torso", "Knee-friendly option"],
            mistakes: ["Back knee crashing down", "Front knee caving in"],
            harder: "walking-lunge"),
        Exercise(
            id: "bulgarian-split-squat", name: "Bulgarian Split Squat", category: .legs,
            muscles: ["Quads", "Glutes"], difficulty: 3, highImpact: false,
            steps: ["Rear foot on a bench behind you, front foot about a stride ahead.",
                    "Lower the back knee straight down toward the floor.",
                    "Drive up through the front foot."],
            cues: ["Most weight on the front leg", "Slight forward lean is OK", "Control the bottom"],
            mistakes: ["Front foot too close", "Bouncing"],
            easier: "reverse-lunge"),
        Exercise(
            id: "step-up", name: "Step-up", category: .legs,
            muscles: ["Quads", "Glutes"], difficulty: 1, highImpact: false,
            steps: ["Face a sturdy step or bench at knee height or lower.",
                    "Step up driving through the lead heel until you stand tall.",
                    "Step down with control."],
            cues: ["Don't push off the back foot", "Stand fully tall on top", "Low-impact cardio and strength"],
            mistakes: ["Using a box that's too high", "Knee caving"]),
        Exercise(
            id: "wall-sit", name: "Wall Sit", category: .legs,
            muscles: ["Quads", "Glutes"], difficulty: 2, highImpact: false,
            steps: ["Back flat against a wall.",
                    "Slide down until thighs are parallel to the floor.",
                    "Hold for time."],
            cues: ["Knees over ankles", "Back flat on the wall", "Breathe through the burn"],
            mistakes: ["Hands pushing on thighs", "Sitting too high"]),
        Exercise(
            id: "glute-bridge", name: "Glute Bridge", category: .legs,
            muscles: ["Glutes", "Hamstrings", "Lower back"], difficulty: 1, highImpact: false,
            steps: ["Lie on your back, knees bent, feet flat.",
                    "Drive through heels to lift hips until body forms a line from knees to shoulders.",
                    "Squeeze glutes at the top, lower with control."],
            cues: ["Ribs down, don't arch the back", "Push through heels", "Pause at the top"],
            mistakes: ["Overarching the lower back", "Pushing through toes"]),

        // MARK: Core
        Exercise(
            id: "plank", name: "Forearm Plank", category: .core,
            muscles: ["Abs", "Shoulders", "Glutes"], difficulty: 2, highImpact: false,
            steps: ["Forearms on the floor, elbows under shoulders.",
                    "Extend legs, toes on the ground, body in one straight line.",
                    "Squeeze glutes, brace abs and hold."],
            cues: ["Tuck the pelvis slightly", "Push the floor away with forearms", "Neutral neck, eyes down"],
            mistakes: ["Sagging hips", "Hips piked too high", "Holding your breath"],
            militaryNote: "Scored for time in the Army, Marine and Navy tests. Holding a strict line is the standard."),
        Exercise(
            id: "side-plank", name: "Side Plank", category: .core,
            muscles: ["Obliques", "Glutes", "Shoulders"], difficulty: 2, highImpact: false,
            steps: ["Lie on your side, elbow under shoulder.",
                    "Lift hips so your body is a straight line from head to feet.",
                    "Hold, then switch sides."],
            cues: ["Hips high and stacked", "Top arm on hip or overhead", "Bend knees to make it easier"],
            mistakes: ["Hips sagging", "Rolling forward"]),
        Exercise(
            id: "flutter-kick", name: "Flutter Kicks", category: .core,
            muscles: ["Lower abs", "Hip flexors"], difficulty: 2, highImpact: false,
            steps: ["Lie on your back, hands under your glutes.",
                    "Lift legs a few inches off the floor.",
                    "Alternate small, quick up-and-down kicks."],
            cues: ["Lower back pressed into the floor", "Straight legs, pointed toes", "Short, fast kicks"],
            mistakes: ["Arching the lower back", "Legs too high"],
            militaryNote: "A classic PT drill, usually counted in four-count cadence."),
        Exercise(
            id: "sit-up", name: "Sit-up", category: .core,
            muscles: ["Abs", "Hip flexors"], difficulty: 2, highImpact: false,
            steps: ["Lie on your back, knees bent, feet anchored or flat.",
                    "Arms crossed on the chest.",
                    "Curl up until elbows touch the thighs, then lower under control."],
            cues: ["Exhale on the way up", "Controlled descent", "Don't yank the neck"],
            mistakes: ["Pulling on the head", "Dropping back down"]),
        Exercise(
            id: "leg-raise", name: "Lying Leg Raise", category: .core,
            muscles: ["Lower abs", "Hip flexors"], difficulty: 3, highImpact: false,
            steps: ["Lie flat, legs straight, hands by your sides.",
                    "Raise legs to vertical.",
                    "Lower slowly without letting the lower back arch."],
            cues: ["Back glued to the floor", "Slow lowering", "Bend knees to make it easier"],
            mistakes: ["Swinging", "Arched lower back"]),
        Exercise(
            id: "hollow-hold", name: "Hollow Body Hold", category: .core,
            muscles: ["Abs", "Hip flexors"], difficulty: 3, highImpact: false,
            steps: ["Lie on your back, arms overhead.",
                    "Lift shoulders and legs off the floor, pressing the lower back down.",
                    "Hold a shallow banana shape."],
            cues: ["Lower back stays down", "Long arms and legs", "Tuck knees to scale"],
            mistakes: ["Lower back lifting", "Neck strain"]),
        Exercise(
            id: "bird-dog", name: "Bird Dog", category: .core,
            muscles: ["Core", "Lower back", "Glutes"], difficulty: 1, highImpact: false,
            steps: ["On hands and knees, hands under shoulders.",
                    "Extend the opposite arm and leg until level with your body.",
                    "Pause, return, switch sides."],
            cues: ["Hips stay level", "Reach long, don't lift high", "Slow and controlled"],
            mistakes: ["Rotating the hips", "Arching the back"]),

        // MARK: Conditioning
        Exercise(
            id: "burpee", name: "Burpee", category: .conditioning,
            muscles: ["Full body"], difficulty: 3, highImpact: true,
            steps: ["From standing, squat and place hands on the floor.",
                    "Jump feet back to a plank and lower your chest to the floor.",
                    "Push up, jump feet back to the hands.",
                    "Explode up into a jump with arms overhead."],
            cues: ["Keep a steady, sustainable pace", "Soft landings", "Plank stays solid"],
            mistakes: ["Sagging hips in the plank", "Landing with locked knees"],
            easier: "step-back-burpee", harder: "eight-count-bodybuilder"),
        Exercise(
            id: "step-back-burpee", name: "Step-back Burpee", category: .conditioning,
            muscles: ["Full body"], difficulty: 2, highImpact: false,
            steps: ["Squat and place hands on the floor.",
                    "Step one foot back, then the other, into a plank.",
                    "Step feet back in one at a time and stand tall."],
            cues: ["Joint-friendly, no jumping", "Brace in the plank", "Move with purpose"],
            mistakes: ["Rounding the back", "Sloppy plank"],
            harder: "burpee"),
        Exercise(
            id: "eight-count-bodybuilder", name: "8-Count Bodybuilder", category: .conditioning,
            muscles: ["Full body"], difficulty: 4, highImpact: true,
            steps: ["1: squat, hands down. 2: kick feet back to a plank.",
                    "3–4: perform one push-up (down, up).",
                    "5–6: open legs wide, close them.",
                    "7: jump feet back to the hands. 8: stand up."],
            cues: ["Count each phase out loud", "Full push-up each rep", "Rhythm over speed"],
            mistakes: ["Skipping the push-up", "Sagging hips"],
            easier: "burpee",
            militaryNote: "A traditional military PT drill done in cadence."),
        Exercise(
            id: "mountain-climber", name: "Mountain Climbers", category: .conditioning,
            muscles: ["Core", "Shoulders", "Hip flexors"], difficulty: 2, highImpact: false,
            steps: ["Start in a high plank.",
                    "Drive one knee toward the chest, then switch legs quickly.",
                    "Keep alternating at pace."],
            cues: ["Hips level with shoulders", "Hands under shoulders", "Fast feet, still torso"],
            mistakes: ["Hips bouncing up", "Shoulders drifting behind the hands"]),
        Exercise(
            id: "high-knees", name: "High Knees", category: .conditioning,
            muscles: ["Hip flexors", "Calves", "Cardio"], difficulty: 2, highImpact: true,
            steps: ["Run in place, driving knees to hip height.",
                    "Pump arms in rhythm.",
                    "Stay light on the balls of your feet."],
            cues: ["Tall posture", "Quick ground contacts", "Knees up, not feet back"],
            mistakes: ["Leaning back", "Low knees"],
            easier: "march-in-place"),
        Exercise(
            id: "shuttle-sprint", name: "Shuttle Sprint", category: .conditioning,
            muscles: ["Legs", "Cardio", "Agility"], difficulty: 3, highImpact: true,
            steps: ["Mark two lines about 25 m (or 10 m indoors) apart.",
                    "Sprint to the far line, touch it with your hand, sprint back.",
                    "Repeat for the set time."],
            cues: ["Low hips on the turn", "Short choppy steps into the line", "Accelerate out of the turn"],
            mistakes: ["Rounding wide turns", "Standing up tall to turn"],
            easier: "high-knees",
            militaryNote: "Builds sprint-drag-carry style capacity for Army-style testing."),
        Exercise(
            id: "bear-crawl", name: "Bear Crawl", category: .conditioning,
            muscles: ["Shoulders", "Core", "Quads"], difficulty: 3, highImpact: false,
            steps: ["On hands and toes, knees hovering an inch off the floor.",
                    "Crawl forward moving the opposite hand and foot together.",
                    "Keep the back flat and hips low."],
            cues: ["Knees low", "Small steps", "Flat back, like carrying a tray"],
            mistakes: ["Hips too high", "Rushing and losing form"]),

        // MARK: Mobility / cool-down
        Exercise(
            id: "childs-pose", name: "Child's Pose", category: .mobility,
            muscles: ["Lower back", "Lats", "Hips"], difficulty: 1, highImpact: false,
            steps: ["Kneel, sit hips back toward heels.",
                    "Reach arms forward and rest your forehead down.",
                    "Breathe deeply into your back."],
            cues: ["Long exhales", "Walk hands side to side for the lats", "Relax the shoulders"],
            mistakes: ["Forcing hips down if the knees hurt"]),
        Exercise(
            id: "hip-flexor-stretch", name: "Kneeling Hip Flexor Stretch", category: .mobility,
            muscles: ["Hip flexors", "Quads"], difficulty: 1, highImpact: false,
            steps: ["Half-kneel with the back knee on a pad.",
                    "Tuck the pelvis and squeeze the back glute.",
                    "Shift gently forward until you feel the front of the hip stretch. Switch sides."],
            cues: ["Tuck the pelvis first", "Don't arch the lower back", "Hold and breathe"],
            mistakes: ["Lunging too far forward with an arched back"]),
        Exercise(
            id: "hamstring-stretch", name: "Standing Hamstring Stretch", category: .mobility,
            muscles: ["Hamstrings", "Calves"], difficulty: 1, highImpact: false,
            steps: ["Place one heel on a low step, leg straight.",
                    "Hinge forward from the hips with a flat back.",
                    "Hold, then switch legs."],
            cues: ["Hinge, don't round", "Toes up", "Gentle tension only"],
            mistakes: ["Rounding the spine to reach further"])
    ]
}
