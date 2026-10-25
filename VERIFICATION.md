# Local verification — October 24, 2026

## Build and model checks

- Xcode 26.6 (17F113), iPhone 17 Pro simulator on iOS 26.5.
- Debug simulator build: **BUILD SUCCEEDED**, with signing disabled for the simulator.
- Minimum deployment target: iOS 17.0. Older runtime versions and physical devices were not tested.
- Build log: `../build.log` (local evidence outside the repository).
- `zsh Tests/run-tests.sh`: **PASS: 20 deck and persistence checks**.
- The build emitted the standard App Intents metadata warning because this app does not use AppIntents. No compiler errors were reported.

## Simulator interaction results

| Check | Result |
| --- | --- |
| Initial study screen | Five sample cards; both reviewed counts zero; name and Z number visible at the bottom |
| Tap to reveal and return | Question changed to answer, then returned to question |
| Short horizontal drag | Remaining count unchanged |
| Full left swipe | Remaining count decreased; More Practice increased |
| Full right swipe | Remaining count decreased; Memorized increased |
| Complete a mixed round | Zero remaining; two practice and three memorized; both reset choices visible |
| More Practice | Exactly two cards returned; three memorized cards stayed categorized |
| Complete the practice round | Five memorized; zero practice; More Practice disabled |
| Reset All Cards | All five returned; reviewed counts cleared; front card on question side |
| Empty card editor | Save visibly disabled |
| Create a complete card | Save enabled; custom question appeared at front; six cards total |
| Terminate and relaunch | Custom card, order, and six-card deck restored |
| Card library | All six questions and answers listed |
| Delete confirmation | Confirmation appeared; dismissed without deleting any cards |
| Deletion model and storage | Unit checks passed for active, practice, and memorized piles and persisted deletion |

The progressive red/green swipe tint and directional labels are implemented in `CardView`. They are also visible in Diego's subsequent recording and the converted GIF. No walkthrough footage was recorded by the agent.

The initial simulator test session ended with the five sample cards plus one custom TextField demonstration card, all six unreviewed. Diego's subsequent recording adds a seventh card. These are local app data; the sample deck in source remains five cards.

## Student recording and GIF review

Diego supplied `Screen Recording 2026-10-24 at 10.39.50 PM.mov`. A byte-identical original is preserved locally at `../Review/Recording-2026-10-24/original.mov`, outside the repository. Its SHA-256 is `f850703693e97c78d19b5703e74694105bdea92c93333d2c68162fb39aa393d5`.

| Recording moment | Observed evidence |
| --- | --- |
| 0–8 seconds | Main screen and student footer; red More Practice feedback during a left swipe |
| 13–16 seconds | Question changes to its answer; a right swipe advances the deck |
| 30–31 seconds | Completed round with four practice and two memorized cards |
| 31–36 seconds | More Practice returns four cards while preserving the two memorized cards; green swipe feedback visible |
| 36–39 seconds | Six memorized, practice option disabled; Reset All Cards restores all six with both reviewed counters zero |
| 45–80 seconds | New-card sheet; Save disabled with incomplete fields; question and answer entered and saved |
| 80–84 seconds | Seventh card appears at the front and reveals its answer |

The recording covers all five required feature areas. Bonus persistence and deletion are not demonstrated in this recording; their local verification is documented above.

The complete 91.945-second video was converted without trimming or reordering to `media/walkthrough.gif`, with an 8 fps sampling rate and identical adjacent frames combined into longer holds. The GIF is 560 × 1069 pixels, 2,899,590 bytes, and loops continuously. Its decoded duration is 91.95 seconds, within GIF timing precision. All 570 encoded frames decoded successfully. Representative GIF frames were visually checked for red and green swipe feedback, the answer display, practice-only reset, full reset, and the new card's answer. The GIF is embedded in the README.

## Submission preparation

- Diego authorized publication and submission on October 24, 2026.
- Source, feature list, development description, student identification, submission date, and the student-recorded GIF are included.
- The official assigned repository is `FAU-Fall2026-iOS-Mobile-App/lab4-diegolopez2022`. It is instructor-owned and private; the student account has push access but no administration permission to change its visibility.
- A public copy at `https://github.com/bjjlops/lab4-diegolopez2022` satisfies Canvas's public-link requirement while preserving the assigned classroom copy.
- No GitHub Actions workflows are present in the starter repository or added by this work. Actions are disabled on the public copy. All builds and checks ran locally; no GitHub platform checks are claimed.

The project is based on classroom starter commit `091596c39d088789f0728a6e33f972117e415b2b`. Local screenshots and conversion evidence are stored in `../Review/`. The required student walkthrough is the GIF in `media/walkthrough.gif`. Final publication and Canvas receipts are retained locally with the review evidence.
