# Capstan

Capstan is a tally keeper for several daily counts. You pin one column, then tick. The count lands on that habit instead of whichever cell you brushed.

## Why this fold

The home verb is two steps, so the model is two phases: **Bare** and **Pinned**. The grid is a fold over columns for the active day key (`YYYYMMDD`).

- **Pin** writes a `PinMark` and folds Bare into Pinned. Pin again while Pinned only moves the mark.
- **Tick** on the pinned column writes a `TickMark`, adds one (`max(0, value + 1)`), and folds back to Bare.
- **Tick** on any other column writes a `StrayMark` and stays Pinned.
- **Tick** while Bare is refused. The reducer writes a `HollowMark` and leaves the tally alone.
- **Peel** drops the latest `TickMark` or `StrayMark` for today.
- An empty column list is **Vacant**.

That is the whole product. A list of counters with a plus button would skip the pin, which is the reason to use Capstan instead of a free-for-all board. The phase is data, not a flag hidden in a view.

Day totals are counted from marks. They are not stored. When the civil day advances, each column logs the negative of yesterday's tally and the new day starts at zero.

## Persistence

One `GridChart` record (`schemaVersion` 1) holds columns, cap bands, the phase, and the mark ledger. It is encoded under `cps.grid.archive.v1` and written atomically to Application Support. Saves are debounced after each mark and flushed on demand. The screen reads `GridPresenter`, never the file.

On Simulator, `cps.demo.v1` seeds Pushups, Espresso, Pages, and Water, finishes onboarding, and leaves Pushups pinned so Tick is live.

## Architecture

The screen reads `GridPresenter`. The presenter publishes a `GridBoard` folded from `GridChart`. `GridReducer` is a pure fold over Bare and Pinned, so a tick cannot land on the wrong habit without leaving a mark. That split matches the product: the phase is the data, and the home controls only commit through the reducer.

## Art

Style: tactile 3D claymation and mixed-media brutalist sculptural objects with hand-molded matte clay surfaces, crisp chamfered architectural blocks, subtle finger-pressed textures, and studio directional lighting rendered as clean cutout subjects with transparent alpha edges.

- `cps_Onboarding1`: the same base, a person or object that is this product in one glance.
- `cps_Onboarding2`: the same base, the primary action of this product, mid-gesture.
- `cps_Onboarding3`: the same base, a later moment when the product has accumulated meaning.
- `cps_EmptyHome`: the same base, a solid closed bowl, crate or folded cloth waiting to be used.
- `cps_TwistHero`: the same base, an emblem of the pin-then-tick fold.
- `cps_EmptyGridCutout`: a brutalist 3D claymation mechanical capstan drum and brass-textured alignment pin resting on a stepped concrete-textured plinth, hand-sculpted matte clay finish, sharp geometric chamfers, isolated cutout with transparent PNG background and solid center subject.
- `cps_ReticlePinBadge`: a compact 3D claymation mixed-media targeting reticle bracket with chunky molded corners and a central calibration notch, tactile matte clay surface, isolated cutout with transparent PNG background.

## How to build

```
xcodegen generate
xcodebuild -scheme Capstan -destination 'generic/platform=iOS' build
```

## Contact

Support: https://capstan-grid.pro
