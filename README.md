# Target 334 🎯

An interactive **UK 11+ preparation app** for the Trafford Consortium GL Assessment format — the name is a nod to the Altrincham Grammar School for Girls pass mark.

Built with **React 18, strict TypeScript, Tailwind CSS v4 and Vite**.

## Features

- **Study Mode** — untimed practice with instant feedback and step-by-step tutor explanations for every question.
- **Test Mode** — strict GL exam simulation: countdown timer (60-minute full mock), skip / change / flag answers, auto-submit and lock when time runs out.
- **OMR bubble sheet** — a digital optical-mark-reader answer grid to build muscle memory for the real exam format.
- **62-question original bank** — 35 Mathematics (including 20 advanced ratio & multi-step word problems), 15 Verbal Reasoning, 12 Non-Verbal Reasoning with Unicode/SVG visuals.
- **Performance Review** — raw score, percentage, time spent, subject-by-subject breakdown, weakest-topic focus areas and a filterable question-by-question review.
- **Score history** — results persist in localStorage across sessions, with best score and running average.

## Getting started

```bash
npm install
npm run dev      # dev server on http://localhost:5173
npm run build    # typecheck (strict) + production bundle in dist/
```

## Project structure

```
src/
  types.ts                       # strict domain types (Question, TestResult, …)
  data/questions.ts              # the 62-question bank
  hooks/useLocalStorage.ts       # persistent state hook
  components/
    Target334Main.tsx            # top-level container & state
    Dashboard.tsx                # mode/subject picker + score history
    QuizEngine.tsx               # question workspace (both modes)
    BubbleSheet.tsx              # OMR-style answer sheet
    Timer.tsx                    # drift-proof countdown with alert states
    PerformanceReview.tsx        # analytics & review dashboard
    MarkdownText.tsx, LShape.tsx # small presentational helpers
```

All questions are original, written in the GL style. Keyboard shortcuts in the quiz: **A–E** or **1–5** to answer, **←/→** to navigate, **F** to flag.
