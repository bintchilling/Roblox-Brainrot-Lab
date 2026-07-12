# Contributing to Brainrot Mutation Lab

Ground rules for anyone (human or AI) working on this codebase. Short, concrete,
and meant to actually get followed — not aspirational.

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

## Known gaps (as of this doc)

- `scripts/Client` and `scripts/UI` are empty — no GUI or client LocalScripts
  exist yet. This is the current focus.
- Gamepass IDs in `GamepassHandler.lua` are placeholder `0`s — replace once
  real gamepasses exist in the Creator Dashboard.
- The DataStore implementation in `DataManager.lua` is a simplified,
  prototype-grade version. For a real public launch, swap in ProfileService.
