# Contributing to Brainrot Mutation Lab

Ground rules for anyone (human or AI) working on this codebase. Short, concrete,
and meant to actually get followed — not aspirative.

## For AI assistants

This file is the single source of truth for how work gets done in this repo —
both for human collaborators and for AI sessions (Claude Code, Cursor, Copilot,
etc.). If you're an AI reading this:

1. **Read this entire file before writing any code.** Don't skim; the require-path
   convention, the hard rules, and the known gaps are all operational.
2. **Treat the directory structure below as a chunking map.** If you're asked to
   work on a system, the folder it lives in is the first signal of how to wire
   it. New systems get a new folder, not a new file in `scripts/Server/`.
3. **The "Known gaps" section is your task list.** If you've been asked to "do
   the next thing," start there unless the human tells you otherwise.
4. **Follow the require-path convention exactly.** Don't reach across the tree
   with ad-hoc relative paths — it makes every script's requires predictable at
   a glance, which is how we keep two AI passes from producing inconsistent
   code in the same repo.
5. **Use the commit format specified in the "Commits" section below.** Other
   collaborators (human or AI) will read your commits cold.
6. **Do not commit unverified code.** "Verified" means `rojo serve` + Studio
   sanity-check, since there is no automated test suite. This is rule #5 in
   Hard rules below — non-negotiable.

## Project structure

```
scripts/
├── Server/              → ServerScriptService.Server
│   ├── Data/             DataManager (module), PlayerSetup
│   ├── Economy/          EconomyLoop, BuyUnitHandler
│   ├── Fusion/           FusionHandler
│   ├── Rewards/          DailyRewardHandler (daily streak + weekly chest)
│   ├── Rebirth/          RebirthHandler
│   ├── Glitch/           GlitchEventHandler (the Glitch Fragments mechanic)
│   ├── Monetization/     GamepassHandler
│   ├── Trading/          TradeManager (module), TradeHandler
│   ├── Inventory/        InventoryHandler (place/unplace units)
│   └── Autosave.server.lua
├── Shared/               → ReplicatedStorage.Shared
│   └── UnitDatabase.lua  (units, rarities, fusion recipes — the game's data table)
├── Client/               → StarterPlayer.StarterPlayerScripts (currently empty)
└── UI/                   → StarterGui (currently empty)
```

`default.project.json` also declares the full `ReplicatedStorage.Remotes` folder
(every RemoteEvent/RemoteFunction), so a fresh clone + `rojo serve` reproduces
the entire networked surface, not just the scripts.

## Architecture

This section is for AI sessions and new collaborators who need the "big picture"
before touching code. Read it once, then keep it in mind as you work.

**DataManager** (`scripts/Server/Data/DataManager.lua`) is the single source of
truth for player state. Every domain script calls `DataManager.Get(player)` to
read/mutate and `DataManager.Save(player)` to persist. It maintains an
in-memory `Cache` keyed by `UserId`, loads on `PlayerAdded`, saves on
`PlayerRemoving` + `BindToClose` + a 120-second tick (`Autosave.server.lua`).

`DataManager.Load` is `pcall`-wrapped because `GetDataStore` throws when "Studio
Access to API Services" is off (the default for unpublished places). If
unwrapped, the error takes down the entire server because every script
requires it.

**PlayerSetup** is the only place that creates the `leaderstats` folder — it
reads from the loaded data, so leaderboard values reflect persisted state from
the moment the player joins.

**EconomyLoop** is the only per-tick income source — `RunService.Heartbeat`
accumulates dt, ticks once per second, sums `BaseIncome` across
`data.PlacedUnits`, and respects the `DoubleIncome` gamepass. BuyUnitHandler
implements the standard 1.15^owned cost curve.

**Fusion** consumes duplicates of one rarity and produces a random unit of the
next tier (see `UnitDatabase.FusionRecipes`). Legendary is the cap — there is
no recipe for it.

**TradeManager** is a pure module (no Roblox services) that owns the in-memory
trade state machine. `TradeHandler` is the thin Roblox wrapper that wires
RemoteEvents to `TradeManager` calls. The anti-scam invariant lives in
`UpdateOffer`: any change to either side's offer resets **both** confirmations.

**UnitDatabase** is shared between server and (eventual) client — add new
units/recipes there, not inline in handlers.

**Glitch Fragments mechanic:** `GlitchEventHandler` runs a per-player
`task.spawn` loop with a random 3-6 minute interval. When a glitch fires, the
player has 8 seconds to click the affected unit and earns Fragments (1-3) as
reward. Fragments is the cosmetic currency — no current sink; this is on the
known-gaps list.

## Require-path convention

Scripts one level deep in `Server/<Domain>/` reach `DataManager` via:
```lua
local DataManager = require(script.Parent.Parent.Data.DataManager)
```
Scripts directly in `Server/` (like `Autosave`) use:
```lua
local DataManager = require(script.Parent.Data.DataManager)
```
Scripts inside `Server/Data/` itself (like `PlayerSetup`) use:
```lua
local DataManager = require(script.Parent.DataManager)
```
If you add a new domain folder, follow this same pattern rather than reaching
across the tree with ad-hoc relative paths — it's what keeps every script's
requires predictable at a glance.

## Hard rules

1. **Never trust client input.** Every RemoteEvent handler must validate types
   and values server-side, exactly like the existing handlers do
   (`type(unitName) ~= "string"` checks, ownership re-validation before trades
   complete, etc.). The client can send anything.
2. **Check for an existing module before writing a new one.** This repo has
   already had one duplicate-execution bug from an old and new copy of the
   same systems running side by side — it's a real failure mode, not a
   hypothetical one.
3. **Don't introduce loss-aversion or FOMO mechanics.** Daily streaks, quests,
   and rewards in this game are reward-only by design (see
   `Docs/Brainrot Game Design.pdf`) — no countdown timers, no "you lost your
   streak forever," no punishing a player for not logging in. This is both an
   ethical choice (the audience skews young) and a Roblox platform
   requirement.
4. **Monetization stays convenience-only.** Anything sellable for Robux must
   also be earnable free, just slower. Never gate content behind a purchase.
5. **Test with `rojo serve` + the Studio plugin before committing.** Don't
   commit code that hasn't been synced and sanity-checked in Studio at least
   once.
6. **Keep commits scoped and describe *why*, not just *what*,** for anything
   non-trivial — future-you (or whichever AI is helping next) will need the
   context.

## Commits

For non-trivial work (anything beyond a typo fix or a one-line tweak):

```
<scope>: <one-line summary>

<1-3 sentence why>
```

Where `<scope>` matches the new domain folder or system, e.g. `glitch:`,
`ui:`, `data:`, `scene:`, `docs:`. This keeps commits greppable and lets
collaborators read the history without context from the original session.

Do not push to `main` directly. Branch off `main` (e.g. `feat/<topic>` or
`fix/<topic>`), do the work, then hand off the branch for review and merge.

## Known gaps (as of this doc)

- `scripts/Client` and `scripts/UI` are empty — no GUI or client LocalScripts
  exist yet. This is the current focus.
- Gamepass IDs in `GamepassHandler.lua` are placeholder `0`s — replace once
  real gamepasses exist in the Creator Dashboard.
- The DataStore implementation in `DataManager.lua` is a simplified,
  prototype-grade version. For a real public launch, swap in ProfileService.
- The `Load` → `GamepassHandler` race (1s `task.wait`) is a real but non-blocking
  bug. Replace with a callback registry on `DataManager` before launch.
- The `UnplaceUnit` Remote takes a `unitName` and removes the first match —
  not indexable. Fine for prototype, swap to index-based when the UI needs
  targeted removal.
- Trade `PlayerRemoving` cleanup doesn't notify the surviving partner that the
  trade was aborted. Add a `TradeStateChanged` "Aborted" broadcast before
  launch.
- `data.Fragments` has no sink yet. A cosmetic shop is on the design doc but
  not implemented.
