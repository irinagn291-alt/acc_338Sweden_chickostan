# Capstan — Build Specification

> Portfolio app 230, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Track several daily counts on named columns you choose before each tap.

| Field | Value |
| --- | --- |
| Product name | Capstan |
| Bundle identifier | `com.capstan.grid` |
| Domain | https://capstan-grid.pro |
| Contact URL | https://capstan-grid.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `cps_` |
| User-Agent | `Capstan/1.0 (iOS; +https://capstan-grid.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Capstan -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A tally keeper pins one cap column then ticks so each count lands on the intended habit, not a mis-tap on the grid.

### 2.1 User flow

1. On home, tap Pin on the column you are counting right now so the reticle locks that cap
2. Tap Tick once to add one to that column and release the pin for the next count
3. Pin a different column before the next Tick when you switch habits mid-day
4. Long-press Peel on the grid to drop the last TickMark if you fat-fingered
5. Open Stats as a sheet to read the embedded seven-day Swift Charts sparkline per column
6. From Settings, add or rename columns and set an optional daily CapBand warning threshold

### 2.2 Essential behaviour

- Cap-grid home with named columns and live pin reticle (no tab bar)
- Pin-then-tick two-phase increment with StrayMark on wrong-column Tick
- Per-column DayTally keyed by Int daykey YYYYMMDD
- Optional CapBand soft warning when today's tally crosses the configured band
- Peel undo for the latest TickMark or StrayMark today
- Stats sheet with Swift Charts mini sparklines per column
- Local-only UserDefaults+Codable persistence with debounced save
- Simulator seed pins the first column before first frame so Tick is live immediately

---

## 3. Uniqueness assignment for Capstan

| Axis | Assigned value |
| --- | --- |
| Architecture | **Capstan ADT fold (Bare | Pinned); the grid is a fold over Columns for the active daykey; Pin writes a PinMark on a Column and folds Bare to Pinned; Tick on the pinned Column writes a TickMark, increments DayTally, and folds Pinned to Bare; Tick on a non-pinned Column writes a StrayMark and keeps Pinned; Tick on Bare writes HollowMark; Pin while Pinned reassigns PinMark; Peel drops the last TickMark or StrayMark; empty grid writes Vacant** |
| UI approach | **UIKit CALayer manual drawing · realitykit-lite** |
| Naming convention | **Capstan / pin-column lexicon (Grid, Column, Reticle, PinMark, TickMark, StrayMark, HollowMark, PeelMark, DayTally, CapBand, Vacant)** |
| File organization | **By capstan role (Grid, Column, Reticle, PinMark, TickMark, StrayMark, HollowMark, PeelMark, DayTally, CapBand)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **brutalism · action-strip · mid** |
| Typography | **Helvetica Neue** |
| Navigation pattern | **Capstan-locked chrome (the cap grid and live reticle never leave; Stats and Settings arrive as sheets; pin and tick fuse on Grid; CapBand chips sit in the action strip; no tab bar)** |
| AI art style | **Claymation claymorphism 3D · mixed-media** |
| Functional twist | **Pin-then-tick (Pin folds Bare to Pinned; Tick on pinned Column writes TickMark and folds to Bare; Tick on wrong Column writes StrayMark; Tick on Bare writes HollowMark refused; seed leaves first column Pinned so Tick is live)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — multi_counter

**Core** — A tally keeper pins one cap column then ticks so each count lands on the intended habit, not a mis-tap on the grid.

**Audience** — People who track several daily counts (coffee, reps, cigarettes) and want a deliberate two-step tap instead of a free-for-all button board or a forced circuit order.

**User flow**

1. On home, tap Pin on the column you are counting right now so the reticle locks that cap
2. Tap Tick once to add one to that column and release the pin for the next count
3. Pin a different column before the next Tick when you switch habits mid-day
4. Long-press Peel on the grid to drop the last TickMark if you fat-fingered
5. Open Stats as a sheet to read the embedded seven-day Swift Charts sparkline per column
6. From Settings, add or rename columns and set an optional daily CapBand warning threshold

**Essential features**

- Cap-grid home with named columns and live pin reticle (no tab bar)
- Pin-then-tick two-phase increment with StrayMark on wrong-column Tick
- Per-column DayTally keyed by Int daykey YYYYMMDD
- Optional CapBand soft warning when today's tally crosses the configured band
- Peel undo for the latest TickMark or StrayMark today
- Stats sheet with Swift Charts mini sparklines per column
- Local-only UserDefaults+Codable persistence with debounced save
- Simulator seed pins the first column before first frame so Tick is live immediately

**Twist** — Pin-then-tick fold. Phases

**Why this is not a repeat** — Same family as generic multi-tally apps but the home verb is tick-the-pinned-column: every increment requires an explicit Pin phase, unlike Waywiser's direct rod click with trip-life registers, Soroban's fixed lantern circuit order, or Spilltile's centered-tile brim overflow routing. No food, slots, catalog, or camera.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Brutalist grid of dedicated − / + cards.
- Invariant: value = max(0, value+δ). Every tap logged. Auto-reset snaps to 0 when the period elapses (log −old). Optional goal.
- Never: Not a program. Not goals-required.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

Capstan models its state as a pure algebraic data type fold over two explicit phases, Bare | Pinned, evaluated across all active Columns for the current integer daykey in YYYYMMDD form. Tapping Pin on a Column appends a PinMark and folds the aggregate from Bare into Pinned, or reassigns the active PinMark to the newly selected Column when already Pinned without changing any tally. Tapping Tick on the pinned Column appends a TickMark, increments that Column's DayTally as max(0, value + 1), and folds the state from Pinned back to Bare. Tapping Tick on an unpinned Column while Pinned records a StrayMark and keeps the Pinned phase intact, whereas tapping Tick while Bare is refused by the reducer and writes only a HollowMark with zero tally change. Long-pressing Peel appends a PeelMark that reverses the latest TickMark or StrayMark for the active daykey, and an empty column list evaluates to Vacant.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

The primary Grid surface uses a UIViewRepresentable host backed by custom CALayer and CAShapeLayer sublayers that manually draw the brutalist column cells, thick structural rules, CapBand threshold markers, and the live Reticle lock frame. RealityKit-lite depth cues are rendered via Core Graphics bevels, crisp shadow offsets, and tactile layer elevation shifts on the pinned cap without importing heavy scene graphs. SwiftUI sheets host the seven-day Swift Charts sparklines in Stats and native form controls in Settings, while all motion obeys the quiet 180ms ease-out cross-fade or instant swap when Reduce Motion is active.

### 3.3 Naming contract

Convention: Capstan / pin-column lexicon (Grid, Column, Reticle, PinMark, TickMark, StrayMark, HollowMark, PeelMark, DayTally, CapBand, Vacant).

Examples to follow: GridReducer, ColumnRecord, ReticleLayerView, PinMarkEvent, DayTallySnapshot, CapBandThreshold

### 3.4 Dependency contract

Zero external dependencies with no Swift Package Manager entries, CocoaPods, or vendored third-party code. The binary imports only Apple system frameworks: SwiftUI, UIKit, CoreGraphics, QuartzCore, Charts, and Foundation.

### 3.5 Navigation contract

Navigation uses Capstan-locked chrome with no TabView and no root back button. The brutalist Grid and its live Reticle remain permanently mounted on the root canvas with the action-strip anchored directly beneath the active tally figure. Stats and Settings present as modal sheets with explicit Close controls on their own navigation stacks, and the Column editor pushes cleanly inside the Settings sheet.

### 3.6 Screen composition contract

Grid-root cap grid (Grid holds columns, reticle, pin and tick; Stats and Settings as sheets; column editor from Settings; maps family Counters|Stats|Settings with Grid as Counters; no TabView)

1. OnboardingView: full-screen three-card brutalist introduction explaining the Pin-then-Tick two-phase fold with a full-width bottom START button (skipped on Simulator after seed). 2. GridRootView (Counters destination, -ReviewScreen today): permanent capstan grid canvas displaying named Columns, the CALayer Reticle, CapBand status chips in the action strip, primary Pin and Tick controls, Peel undo trigger, and full-page Vacant empty state with generated cutout art and Add Column CTA when zero columns exist. 3. StatsSheetView (Stats destination, -ReviewScreen log): modal sheet rendering per-column seven-day Swift Charts sparklines, daily mark logs (TickMark, StrayMark, HollowMark, PeelMark), and period reset records. 4. SettingsSheetView (Settings destination, -ReviewScreen goals): modal sheet housing the Column editor for adding, renaming, or deleting columns, configuring optional daily CapBand warning thresholds, manual day reset, and a tappable Contact and Support link pointing to https://capstan-grid.pro.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By capstan role (Grid, Column, Reticle, PinMark, TickMark, StrayMark, HollowMark, PeelMark, DayTally, CapBand)**

```
Capstan/
  Capstan/
  App/
    CapstanApp.swift
    ReviewScreenRouter.swift
  Grid/
    GridRootView.swift
    GridReducer.swift
    CapstanGridLayerView.swift
  Column/
    ColumnRecord.swift
    ColumnEditorSheet.swift
  Reticle/
    ReticleLayer.swift
    ReticleState.swift
  Marks/
    PinMark.swift
    TickMark.swift
    StrayMark.swift
    HollowMark.swift
    PeelMark.swift
  DayTally/
    DayTally.swift
    DayKey.swift
    StatsSheetView.swift
  CapBand/
    CapBand.swift
    ActionStripView.swift
  Persistence/
    CapstanStore.swift
    SimulatorSeed.swift
  Design/
    ThemeTokens.swift
    SettingsSheetView.swift
    OnboardingView.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Counters
A first-class screen for **Counters**. Must render empty, populated and error states.

### 5.3 Stats
A first-class screen for **Stats**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Counter** — named per this app's convention.
- **CountLog** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **brutalism · action-strip · mid**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#D3E4E0` | Screen background |
| `surface` | `#EAF0EF` | Cards, rows, sheets |
| `ink` | `#0F241F` | Primary text and icons |
| `accent` | `#218D71` | Primary action, key figure, progress fill |
| `muted` | `#4A645D` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Capstan/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Helvetica Neue**

Typography is driven by Helvetica Neue paired with monospaced tabular digits for all live tallies, CapBand ratios, and YYYYMMDD daykey stamps so counts tick in place without horizontal jitter. Headlines use tight, wide 1-to-2 line brutalist blocks separated by exposed hairline and thick structural rules, while body copy stays at 17pt with @ScaledMetric scaling and vertical fixedSize so no title or numeral ever clips at AX5 Dynamic Type.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **8pt** for cards, sheets and primary surfaces; **6pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **UIKit CALayer manual drawing · realitykit-lite**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **UIKit CALayer manual drawing · realitykit-lite** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **brutal** (Brutal / tactical: visible structure, thick rules, hard contrast.)

Reference system: **brutalism** — steal rhythm and restraint, not their colours or logos.

Mood: **Raw, anti-design aesthetic inspired by concrete architecture with unadorned elements, jarring layouts, and functional minimalism.**.

Home rhythm (`action-strip`, comfortable): A strip of actions under a live figure.

Brutal / tactical: visible structure, thick rules, hard contrast. Layout `action-strip`, density comfortable. Kit 8/6, material, soft card. Palette recipe `mid`. Almost no travel. Cross-fade 180ms ease-out. Numbers tick, they do not fly. Reduce Motion: instant swap. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Tabular figures, no display face, hairline rules. Reference type feel: brutal.

Motion (`quiet`): Almost no travel. Cross-fade 180ms ease-out. Numbers tick, they do not fly. Reduce Motion: instant swap.

Voice (`editorial`): Complete sentences, no slang, no hype. Captions are real lines.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- iPhone allows portrait, landscape left, and landscape right. iPad allows all
  four orientations. Keep both lists in the Info settings, and let a rotated
  screen scroll instead of clipping.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Every headline, amount, and button title is fully visible. Do not give display
  type a fixed height shorter than the font, and do not let a sibling with
  `maxHeight: .infinity` compress it. When the column is taller than the screen,
  scroll it. `.clipped()` frames an image cell; it never wraps text.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- The root screen has no back button. `.navigationTitle` is a screen name, never
  the product name. A back control titled with the app name is a defect: it
  reads as a button that returns to this same app.
- A sheet dismisses with Close and owns its stack. Do not push it onto a stack
  whose title is the product name.
- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

All state persists locally via UserDefaults and Codable under a single root archive key ('cps.grid.archive.v1') containing the ordered Columns, CapBand configurations, active PinMark state, and the ledger of PinMark, TickMark, StrayMark, HollowMark, and PeelMark entries keyed by Int daykey in YYYYMMDD form. Writes pass through a debounced save pipeline after each committed mark and automatically snap tallies to zero when Calendar.current.startOfDay advances to a new YYYYMMDD integer. On Simulator only, 'cps.demo.v1' seeds four realistic columns (Pushups, Espresso, Pages, Water) with multi-day history, marks onboarding complete, and writes an active PinMark on the first column before the first frame.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Capstan/1.0 (iOS; +https://capstan-grid.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.
No scanner and no remote catalog in this product. Do not import AVFoundation or Vision for capture, do not add a camera usage description, and do not call a search endpoint. Ignore a leftover scanner or search axis.


---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- iPhone: portrait, landscape left, landscape right. iPad: all four orientations (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Pin-then-tick (Pin folds Bare to Pinned; Tick on pinned Column writes TickMark and folds to Bare; Tick on wrong Column writes StrayMark; Tick on Bare writes HollowMark refused; seed leaves first column Pinned so Tick is live)

The home verb is tick-the-pinned-column, enforced by a strict two-phase Pin-then-Tick fold across Bare | Pinned. In Bare, no column is armed and tapping Tick is refused by the reducer, recording only a HollowMark without altering any DayTally. Tapping Pin on a Column writes a PinMark and folds Bare into Pinned, locking the CALayer Reticle onto that cap so the subsequent Tick on the same Column writes a TickMark, increments its DayTally, fires a single commit haptic, and folds Pinned back to Bare. Tapping Tick on any unpinned Column while Pinned writes a StrayMark without incrementing and keeps the Pinned phase active, while Peel reverses the latest TickMark or StrayMark today. The Simulator seed ('cps.demo.v1') pre-populates four columns and writes an active PinMark on the first column (Pushups) before the initial render, ensuring the app opens in the Pinned phase with the primary Tick verb immediately live and testable.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Claymation claymorphism 3D · mixed-media**


Base prompt, reused and extended for every asset:

```
Tactile 3D claymation and mixed-media brutalist sculptural objects with hand-molded matte clay surfaces, crisp chamfered architectural blocks, subtle finger-pressed textures, and studio directional lighting rendered as clean cutout subjects with transparent alpha edges.
```

All 7 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `cps_` prefix.

### 13.1 App icon

Do not generate an app icon. Do not create an AppIcon image set and do not
paint icon artwork. The factory installs the icon later. Leave the empty
AppIcon.appiconset from the scaffold untouched.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `cps_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 2 | `cps_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 3 | `cps_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 4 | `cps_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 5 | `cps_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Pin-then-tick (Pin folds Bare to Pinned; Tick on pinned Column writes TickMark and folds to Bare; Tick on wrong Column writes StrayMark; Tick on Bare writes HollowMark refused; seed leaves first column Pinned so Tick is live)' feature screen. |
| 6 | `cps_EmptyGridCutout` | 1024x1024 | **required cutout** | A brutalist 3D claymation mechanical capstan drum and brass-textured alignment pin resting on a stepped concrete-textured plinth, hand-sculpted matte clay finish, sharp geometric chamfers, isolated cutout with transparent PNG background and solid center subject. |
| 7 | `cps_ReticlePinBadge` | 1024x1024 | **required cutout** | A compact 3D claymation mixed-media targeting reticle bracket with chunky molded corners and a central calibration notch, tactile matte clay surface, isolated cutout with transparent PNG background. |

### Prompt per asset

**`cps_Onboarding1`** — 1024x1536

```
Tactile 3D claymation and mixed-media brutalist sculptural objects with hand-molded matte clay surfaces, crisp chamfered architectural blocks, subtle finger-pressed textures, and studio directional lighting rendered as clean cutout subjects with transparent alpha edges., a person or object that is this product in one glance

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cps_Onboarding2`** — 1024x1536

```
Tactile 3D claymation and mixed-media brutalist sculptural objects with hand-molded matte clay surfaces, crisp chamfered architectural blocks, subtle finger-pressed textures, and studio directional lighting rendered as clean cutout subjects with transparent alpha edges., the primary action of this product, mid-gesture

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cps_Onboarding3`** — 1024x1536

```
Tactile 3D claymation and mixed-media brutalist sculptural objects with hand-molded matte clay surfaces, crisp chamfered architectural blocks, subtle finger-pressed textures, and studio directional lighting rendered as clean cutout subjects with transparent alpha edges., a later moment when the product has accumulated meaning

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cps_EmptyHome`** — 1024x1024

```
Tactile 3D claymation and mixed-media brutalist sculptural objects with hand-molded matte clay surfaces, crisp chamfered architectural blocks, subtle finger-pressed textures, and studio directional lighting rendered as clean cutout subjects with transparent alpha edges., a solid closed bowl, crate or folded cloth waiting to be used — ceramic, wood or fabric, fully opaque, not glass

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cps_TwistHero`** — 1024x1024

```
Tactile 3D claymation and mixed-media brutalist sculptural objects with hand-molded matte clay surfaces, crisp chamfered architectural blocks, subtle finger-pressed textures, and studio directional lighting rendered as clean cutout subjects with transparent alpha edges., an emblem representing this app's signature feature

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cps_EmptyGridCutout`** — 1024x1024

```
A brutalist 3D claymation mechanical capstan drum and brass-textured alignment pin resting on a stepped concrete-textured plinth, hand-sculpted matte clay finish, sharp geometric chamfers, isolated cutout with transparent PNG background and solid center subject.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`cps_ReticlePinBadge`** — 1024x1024

```
A compact 3D claymation mixed-media targeting reticle bracket with chunky molded corners and a central calibration notch, tactile matte clay surface, isolated cutout with transparent PNG background.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`cps.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `CapstanTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Capstan/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Capstan -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.
- [ ] `CapstanWatch` stays in the project. It reads `ReviewLaunch.screen` and opens the same today, log, and goals destinations, laid out for Apple Watch.

**Uniqueness**
- [ ] Architecture matches **Capstan ADT fold (Bare | Pinned); the grid is a fold over Columns for the active daykey; Pin writes a PinMark on a Column and folds Bare to Pinned; Tick on the pinned Column writes a TickMark, increments DayTally, and folds Pinned to Bare; Tick on a non-pinned Column writes a StrayMark and keeps Pinned; Tick on Bare writes HollowMark; Pin while Pinned reassigns PinMark; Peel drops the last TickMark or StrayMark; empty grid writes Vacant** with no leakage across layers.
- [ ] UI approach matches **UIKit CALayer manual drawing · realitykit-lite**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Capstan-locked chrome (the cap grid and live reticle never leave; Stats and Settings arrive as sheets; pin and tick fuse on Grid; CapBand chips sit in the action strip; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Helvetica Neue** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Capstan
xcodegen generate
xcodebuild build-for-testing -scheme Capstan -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.capstan.grid/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Capstan -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.capstan.grid/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Capstan -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.capstan.grid/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
