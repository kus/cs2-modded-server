# Plugin update automation

Part of **Kus' modded Counter Strike 2 (CS2) Dedicated Server**:
<https://github.com/kus/cs2-modded-server/>

Automates the manual "check releases, download, copy into the repo, bump the README,
commit" routine for the mods listed in this repo's root `README.md` version table
(`Mod | Version | Why`). No AI involved, safe to re-run, and it refuses to act when
anything looks off.

## Running it

Always run from a checkout of this repo (the script `cd`s to the repo root itself, so
relative paths work from anywhere inside the repo):

```bash
./scripts/update/update.sh --dry-run      # report only: what is outdated and exactly what would be done
./scripts/update/update.sh                # apply every available update, one commit per mod
./scripts/update/update.sh --only "Inventory Simulator" --only counterstrikesharp   # limit to some mods (name or slug)
./scripts/update/update.sh --list         # mods, current versions, slugs and which have an update script
```

Requirements: `bash` (3.2+ is fine), `git`, `curl`, `jq`, `unzip`, `tar`, `rsync`
(macOS openrsync works). A **clean working tree** is required for a real run because
the tool commits; commit or stash first. The GitHub API is used only to list release
assets of mods that need updating (one call per mod). Unauthenticated that is
limited to 60 requests/hour; set `GITHUB_TOKEN`, or be logged in with `gh auth login`
(the token is picked up automatically), to lift the limit.

Exit code is `0` when nothing failed (up to date, updated, or only "no script"
warnings) and `1` when any mod failed or the run was stopped.

## What a run does

For every row of the README version table, top to bottom, one mod at a time:

1. **Check the latest version** with the same functions as `scripts/check-updates.sh`
   (that script is sourced, not copied - the detection logic lives in one place).
   The *local* `README.md` is the source of truth for the current version, so a mod you
   just updated and committed is reported as up to date on the next run.
2. Up to date -> `OK`, next mod. No releases / not detectable -> `?`, next mod.
3. Update available and **no** `scripts/update/plugins/<slug>.sh` -> warning
   `no update script`, listed in the summary, next mod. Nothing is downloaded.
4. Update available and a script exists -> **plan phase** (nothing is changed yet):
   syntax-check and load the script, fetch the release's asset list, match every glob
   from `plugin_assets()` (each must match exactly one asset), run `plugin_preflight()`.
   Any failure -> flagged, next mod.
5. **Apply phase**: download the assets into `tmp/update/<slug>/<version>/` (cached and
   size/integrity checked, so re-runs do not re-download), run `plugin_apply()` in an
   isolated subshell where the first failing step aborts the plugin, verify that every
   changed file is inside the script's `PLUGIN_PATHS`, bump the version in the README
   table row (must be a single-line change), then
   `git commit -m "- UPDATED: <Mod> <old> > <new>"` with only those paths staged.
   Extracted folders are deleted; downloaded archives are kept in `tmp/` (git-ignored).
6. If applying fails after files were touched, the run **stops** (later mods are not
   processed) and the working tree is left as-is so you can inspect it. The message
   tells you what was wrong and how to reset.

`--dry-run` performs steps 1-4 fully (network reads only) and then prints every step
of 5 as `[dry-run] would ...` without downloading, extracting, writing or committing.
Checks against extracted archive contents cannot run in dry-run and are printed as
`would verify ...`.

## Running it automatically (GitHub Actions)

`.github/workflows/auto-update-mods.yml` runs this same script daily at 3pm
Australia/Sydney, and on demand from the Actions tab. It adds nothing of its own: it
checks out `stage`, runs `./scripts/update/update.sh`, and if that produced commits it
pushes them and opens a pull request into `master`. Adding a new plugin script here is
therefore all that is needed for the automation to pick that plugin up too.

- **No update, no noise.** If the script commits nothing, the workflow pushes nothing
  and opens no pull request.
- **A human merges.** Commits pushed with the Actions token do not trigger other
  workflows, so if the bot merged into `master` the `build and publish` workflow would
  silently not run. Merging the pull request yourself does trigger it.
- **Failures are surfaced.** If the script exits non-zero the pull request is still
  opened for the mods that succeeded, the summary is attached, and the job then fails
  so the run shows up as a failure.
- The schedule is a single cron at 04:00 UTC. GitHub cron has no timezone, so in Sydney
  that lands at 3pm during daylight saving and 2pm outside it.
- Scheduled workflows only fire from the copy of the file on the **default branch**, so
  this workflow has to be on `master` to run on its own.
- GitHub disables scheduled workflows after 60 days with no repository activity.

## Adding a plugin script

The script file name is the **slug** of the mod name in the README table: lower-case,
every run of non-alphanumerics replaced by `-`, trimmed. `--list` prints it for every
mod, e.g. `Metamod:Source` -> `metamod-source.sh`, `CS2 Retakes` -> `cs2-retakes.sh`.

Create `scripts/update/plugins/<slug>.sh` from this template. It is *sourced* by
`update.sh`, so its top level must only set `PLUGIN_PATHS` and define functions.
Before writing it, work through "Reconstructing the process for a mod from git history"
and the gotchas list below, then test it as described in "Testing a new or changed script".

```bash
#!/usr/bin/env bash
# Project:           Kus' modded Counter Strike 2 (CS2) Dedicated Server - https://github.com/kus/cs2-modded-server/
# Update script for: <Mod name exactly as in the README table>
# README row:        [<name>](<url>)
# Sourced by scripts/update/update.sh - do not run directly.
#
# Manual process this automates:
#   1. ...

# Every repo path this update may create, change or delete (files or directories).
# Used for: refusing deletes/writes elsewhere, verifying nothing else changed, git add.
PLUGIN_PATHS=(
    "game/csgo/addons/counterstrikesharp/plugins/<PluginDir>"
)

# One glob per line, matched against the release's asset file names. Each must match
# exactly one asset. $NEW_VERSION is available (e.g. "Foo-v${NEW_VERSION}.zip").
plugin_assets() {
    echo "<Plugin>-*.zip"
}

# Optional: checks on the repo before anything is downloaded or changed.
plugin_preflight() {
    require_dir "game/csgo/addons/counterstrikesharp/plugins"
}

# The steps. Use only the helpers below; each one aborts the plugin on failure.
# Pattern: extract everything, verify the archive layout, then change the repo.
plugin_apply() {
    local x
    x=$(extract_asset "<Plugin>-*.zip")
    require_dir "$x/addons/counterstrikesharp/plugins/<PluginDir>"

    remove_path "game/csgo/addons/counterstrikesharp/plugins/<PluginDir>"
    copy_dir    "$x/addons/counterstrikesharp/plugins/<PluginDir>" \
                "game/csgo/addons/counterstrikesharp/plugins/<PluginDir>"

    remove_extracted "$x"
}
```

Then test it: `./scripts/update/update.sh --dry-run --only <slug>` and, once happy,
`./scripts/update/update.sh --only <slug>`. Check the commit with `git show --stat`.

### Reconstructing the process for a mod from git history (do this BEFORE writing a script)

Every existing script was derived this way. It takes ten minutes and avoids guessing.

1. **Find the manual updates**: `git log --oneline --grep="UPDATED: <Mod name>"`, then
   `git show --name-status --format="" <sha>` for the last three. This tells you the real repo
   paths (they are often NOT where you expect - many plugins live under
   `plugins/disabled/` because they are off by default) and which files change per update.
2. **Get the release layout**: list the assets with
   `curl -s https://api.github.com/repos/<owner>/<repo>/releases/latest | jq -r '.assets[].name'`
   (or `gh api`), download the one(s) the manual updates used, and list the archive
   (`unzip -Z1 x.zip` / `tar -tzf x.tar.gz`). Note the root: `addons/...`, `csgo/addons/...`,
   `<Name>/plugins/...`, `<Name>/...` - it differs per project. Ignore junk (`README-ME.txt`,
   `logs/`, `-no-map-configs` variants, `-with-cssharp-*` bundles, `steamrt4` builds).
3. **Diff the extracted archive against the repo** (the repo is normally at the latest
   version): `diff -rq <extracted>/<dir> game/csgo/...`. Identical files = what the manual
   process copies. Differing files = what it keeps (customised configs). Files only in the repo
   = leftovers the manual process never deleted, or custom files.
4. **Check the config history**: `git log --oneline -- game/csgo/cfg/<mod>` (and
   `configs/plugins/<Mod>`). Commits that are not "UPDATED: <mod>" mean it is customised.
   Customised config paths are NEVER written by a script (see the config policy below); use
   `warn_cfg_dir_changes` / `warn_new_settings` instead.
5. **Pick the copy style** from steps 1-3: "replace whole" (`remove_path` + `copy_dir`) when the
   repo folder is byte-identical to the release; "merge" (`copy_dir` only) when the repo carries
   leftovers the manual updates kept (MatchZy, GG2) or when a file name only differs by case.
6. Write the script from the template, put the reconstructed manual process in its header
   comment (that is the documentation of record), pin asset names with `${NEW_VERSION}` where
   the name carries the version, and add `require_*` checks for the archive layout you saw.

### Gotchas seen so far (check the new mod against each)

- **Asset variants**: releases often ship several files; pin the exact one the manual updates
  used (`steamrt3` not `steamrt4`, `with-runtime`, plain `MatchZy-<v>.zip`, full
  `RetakesPlugin-<v>.zip` not `-no-map-configs`). A glob that matches 2 assets fails on purpose.
- **Version in the name**: tags are normalised like `check-updates.sh` does (`v1.6` -> `1.6`,
  `V0.5.1` -> `0.5.1`, Metamod `2.0.0.1469`/`git1469` -> `2.0.0-1469`), so `${NEW_VERSION}` is
  the bare version. Some assets carry no version at all (`Deathmatch.zip`): use the exact name.
- **Two-platform mods**: apply Windows first, then Linux, always. Both archives ship the same
  config/vdf files and the Linux copies (LF endings, Linux paths) are the ones the repo keeps.
  Only replace the binaries the manual updates replaced; the per-platform `.vdf`s in the repo
  live elsewhere (`addons/windows/`, `addons/surf/`) and are managed by hand.
- **Case-insensitive filesystem**: MatchZy ships `lang/pt-PT.json`, the repo tracks
  `lang/pt-pt.json`. On macOS (`core.ignorecase=true`) a merge-copy just updates the tracked
  file; a replace-whole would try to rename it. On Linux you would get both files.
- **Same link text elsewhere in the README**: the version bump only matches the row in the
  `Mod | Version | Why` table (anchored at line start), because e.g. the CounterStrikeSharp
  link also appears in prose.
- **Files inside plugin folders that look like config** (`map_config/`, `spawns/`, `lang/`) are
  upstream-owned and byte-identical to the release here, so "replace whole" is fine - but check
  step 3 before assuming that for a new mod.
- **A README bump done in a separate commit** (cs2-quake-sounds 26.08.1) means the manual
  commit's file set lacks `README.md`; the script always bumps it in the same commit.

### Testing a new or changed script

Never test on the real checkout; the tool commits. Use a throwaway local clone:

```bash
git clone -q --local --branch stage . /tmp/cs2-test && cd /tmp/cs2-test
git revert --no-edit <sha of the mod's last "UPDATED:" commit>   # makes the update pending again
# if the revert conflicts on README.md context, instead: git checkout <sha>~1 -- <the mod's paths>,
# set the README row back by hand with sed, and commit
./scripts/update/update.sh --dry-run --only <slug>
./scripts/update/update.sh --only <slug>
git show --name-status --format="" HEAD | sort > /tmp/new.txt
git show --name-status --format="" <sha> | sort > /tmp/old.txt && diff /tmp/old.txt /tmp/new.txt   # expect no diff
./scripts/update/update.sh --only <slug>      # second run must report "OK <mod> <version>" and change nothing
```

Downloads are cached under `tmp/update/<slug>/<version>/`; copy archives there from another
checkout to avoid re-downloading. Delete the clone afterwards.

### Variables available in a plugin script

| Variable | Meaning |
| --- | --- |
| `PLUGIN_NAME`, `PLUGIN_URL` | Name and URL from the README row |
| `OLD_VERSION`, `NEW_VERSION` | Version in the README and the detected latest version |
| `PLUGIN_SLUG` | The slug (also the script's base name) |
| `DOWNLOAD_DIR`, `EXTRACT_DIR` | `tmp/update/<slug>/<version>` and `.../extracted` |
| `DRY_RUN` | `1` in dry-run (helpers already honour it; `is_dry` is the test) |

### Helpers (all honour `--dry-run`; all abort the plugin on failure)

| Helper | Does |
| --- | --- |
| `extract_asset <glob>` | Extracts the matched archive into a fresh `EXTRACT_DIR/<archive name>/` and prints that path |
| `asset_path <glob>` | Prints the path of the downloaded archive |
| `remove_extracted <dir>` | Deletes a directory made by `extract_asset` |
| `require_dir <path>`, `require_file <path>` | Fail unless it exists (reported as `would verify` for extracted paths in dry-run) |
| `sync_dir <src> <dest>` | `rsync -rhavz --exclude "._*" --exclude ".DS_Store" --partial --stats src/ dest/` (merge, never deletes at dest) |
| `copy_dir <src> <dest>` | Copy a directory to `<dest>` (created if missing; same rsync excludes) |
| `copy_file <src> <dest>` | Copy one file (parent directory created) |
| `empty_dir <dir>` | Delete everything inside `<dir>`, keep the directory |
| `remove_path <path>` | Delete a file or directory; no error if already absent |
| `warn_cfg_dir_changes <archive dir> <repo dir> [existing-only]` | Heads-up only: lists new upstream config files, repo files upstream no longer ships, and new settings in files present on both sides. Writes nothing. |
| `plugins/<slug>.ignore` (file, optional) | One setting key per line (`#` comments allowed). Keys listed here are never reported by the two helpers above - add a key once it has been reviewed (ported, or removed from your config on purpose) so it stops showing up on every update. |
| `warn_new_settings <archive file> <repo file>` | Heads-up only: lists setting keys (`.cfg` first tokens / JSON keys) present upstream but missing from the repo's customised copy |
| `info`, `step`, `warn`, `err`, `die` | Logging; `die` aborts the plugin with a message |

Deletes (`empty_dir`, `remove_path`) are only allowed *inside* a `PLUGIN_PATHS` entry.
Writes are allowed inside an entry or to an ancestor of one (so `sync_dir "$x/addons/"
"game/csgo/addons/"` works); anything that ends up changed outside `PLUGIN_PATHS` is
caught after `plugin_apply` and blocks the commit.

Sources other than GitHub releases and the Metamod:Source download page need
`plugin_resolve_assets()` in the script, printing one `name<TAB>url<TAB>size` line per
downloadable asset (size `0` if unknown).

## Existing plugin scripts

| Mod | Script | Notes |
| --- | --- | --- |
| Metamod:Source | `plugins/metamod-source.sh` | Assets come from the dev downloads page quick-download links. Windows zip is applied before the Linux tar.gz on purpose: both ship `metamod.vdf`, `metamod_x64.vdf`, `metaplugins.ini`, `README.txt`; the Linux copies (LF endings, `linux64` server path) are what the repo keeps. |
| CounterStrikeSharp | `plugins/counterstrikesharp.sh` | Uses the `with-runtime` Windows and Linux zips. Windows first (rsync into `game/csgo/addons/`, then the special `game/csgo/addons/windows/addons/counterstrikesharp/` refresh of `api/ bin/ dotnet/`), then Linux rsync on top. |
| Inventory Simulator | `plugins/inventory-simulator.sh` | Replaces the plugin directory and the `inventory-simulator.json` gamedata file. |
| MultiAddonManager | `plugins/multiaddonmanager.sh` | Windows zip + Linux `steamrt3` tar.gz (the `steamrt4` build is ignored). Replaces only the two binaries in `game/csgo/addons/multiaddonmanager/bin/`; the `.vdf` is left alone and the customised `game/csgo/cfg/multiaddonmanager/multiaddonmanager.cfg` is never written, only compared (new settings reported). |
| ServerListPlayersFix | `plugins/serverlistplayersfix.sh` | Windows zip + Linux `steamrt3` tar.gz. Replaces only `bin/win64/*.dll` and `bin/linuxsteamrt64/*.so`; the repo's per-platform `.vdf` copies are left alone. |
| MovementUnlocker | `plugins/movementunlocker.sh` | Windows zip + Linux `steamrt3` tar.gz. Replaces only `bin/win64/*.dll` and `bin/linuxsteamrt64/*.so`; the `.vdf` copies under `addons/surf/` are left alone. |
| CS2 Retakes | `plugins/cs2-retakes.sh` | Uses the full `RetakesPlugin-<v>.zip` (not the `-no-map-configs` one). Replaces `plugins/disabled/RetakesPlugin` (the plugin is kept disabled in this repo, so it is NOT at `plugins/RetakesPlugin`) and `shared/RetakesPluginShared`. |
| MatchZy | `plugins/matchzy.sh` | Plain `MatchZy-<v>.zip` (not the `-with-cssharp-*` bundles). Merge-copies the plugin folder over `plugins/disabled/MatchZy` (nothing deleted). `game/csgo/cfg/MatchZy/` and `custom_files_example/cfg/MatchZy/` are customised and never written; new upstream files/settings are only reported for a manual port. |
| GunGame | `plugins/gungame.sh` | Merge-copies `plugins/disabled/GG2` and `shared/GunGameAPI` (old leftovers like `Dapper.dll`/`runtimes/` are kept, as the manual updates did). `game/csgo/cfg/gungame/` is customised and never written; new upstream files, removed files and new settings are reported for a manual port. |
| CS2 Deathmatch | `plugins/cs2-deathmatch.sh` | Asset is always `Deathmatch.zip`, archive root `Deathmatch/`. Replaces `plugins/disabled/Deathmatch` and `shared/DeathmatchAPI` whole. `configs/plugins/Deathmatch/` and `gamedata/Deathmatch.json` are not shipped and not touched. |
| deathrun-manager | `plugins/deathrun-manager.sh` | Replaces `plugins/disabled/DeathrunManager` whole. The shipped `configs/plugins/DeathrunManager/DeathrunManager.json` is never written, only compared (new settings reported). Archive junk (`README-ME.txt`, `logs/`) ignored. |
| RollTheDice | `plugins/rollthedice.sh` | Archive root `RollTheDice/`; replaces `plugins/disabled/RollTheDice` whole. `configs/plugins/RollTheDice/` not touched. |
| cs2-quake-sounds | `plugins/cs2-quake-sounds.sh` | Archive root `QuakeSounds/`; replaces `plugins/disabled/QuakeSounds` whole. `configs/plugins/QuakeSounds/` not touched. |

## Files

- `update.sh` - entry point: argument parsing, preflight, the per-mod loop, summary.
- `lib.sh` - all shared functions (logging, path guards, GitHub/Metamod asset
  resolution, download/extract, repo write helpers, README bump, git commit).
- `plugins/*.sh` - one script per mod (see above).
- `../check-updates.sh` - unchanged behaviour when run directly. It gained a guard so it
  can be sourced, and `CHECK_UPDATES_README=<path>` to read a local README instead of
  the one on GitHub master (that is what `update.sh` sets).

## Troubleshooting / messages you may see

- `working tree is not clean` - commit or stash, then re-run.
- `no update script for '<Mod>' - expected scripts/update/plugins/<slug>.sh` - create it (see above).
- `asset pattern '<glob>' matched N assets` - the release's file names changed; the
  message lists what is available, fix `plugin_assets()`.
- `no release in <repo> has a tag matching version '<v>'` - the version scraped from the
  GitHub releases page and the API disagree (e.g. a pre-release or a renamed tag). Look at
  the release page.
- `Metamod asset <name> is version ...` / `could not find the quick-download links` -
  the metamodsource.net page layout changed; fix `metamod_release_assets` in `lib.sh`.
- `expected directory does not exist: tmp/update/...` - the archive layout changed;
  extract it by hand, compare, and adjust the plugin script.
- `unexpected change outside the plugin's paths: <path>` - either add the path to
  `PLUGIN_PATHS` (if the update legitimately owns it) or fix the script. Nothing was
  committed; reset with `git checkout -- . && git clean -fd game/`.
- `the update did not change any tracked file under PLUGIN_PATHS` - the release ships
  identical files or the script copies to the wrong place. Nothing was committed.
- `expected exactly one row in the README.md mod table starting with [<name>](<url>)` -
  the README row was edited; the link text/URL must match the table row exactly.
- `GitHub API error ... rate limit` - set `GITHUB_TOKEN` or `gh auth login`.

## Notes for future maintenance (context for Claude / whoever comes back to this)

- Two copy styles are in use on purpose: "replace whole" (`remove_path` + `copy_dir`) where the
  repo folder is byte-identical to the release, and "merge" (`copy_dir` only) where the manual
  history shows leftovers were never removed (MatchZy, GG2).
- **Config policy: plugin scripts never write config files that can be customised.** Anything a
  release ships under `cfg/` or `configs/` (MatchZy, GunGame, MultiAddonManager, deathrun-manager)
  is only compared with `warn_cfg_dir_changes` / `warn_new_settings`, and new files, removed
  files and new settings are printed for a manual port. The files that ARE overwritten are
  upstream-owned data shipped inside the plugin/addon folders (Metamod's stock `metaplugins.ini`
  and `.vdf`s, CounterStrikeSharp's `gamedata.json`, `*.example.json` and `lang/`, Retakes'
  `map_config/`, Deathmatch's `spawns/`, Inventory Simulator's gamedata) - all byte-identical to
  upstream in this repo. If one of those ever gets customised, move it out of the script's paths
  or switch that script to a report-only check.
- The new-settings report is a key-based heuristic (first token of a `.cfg` line, JSON keys)
  on customised files, so it also lists upstream keys that were removed from the repo's copy
  on purpose and upstream example values (e.g. example SteamIDs in MatchZy's `admins.json`).
  Silence reviewed keys via `plugins/<slug>.ignore`; the file is not created automatically.
- Design decisions: versions are read from the **local** README (idempotency); mods
  without a script are only reported, nothing is downloaded for them; the run stops at
  the first failure that left the tree dirty, but continues past failures that changed
  nothing; exactly one commit per mod, message `- UPDATED: <Mod> <old> > <new>`, no
  trailer/footer.
- `run_isolated` in `lib.sh` exists because bash ignores `set -e` inside anything called
  from an `if`/`||`/`&&` condition, including subshells that re-enable it. Never call
  `process_mod`/`run_isolated` from such a context or a failing step would not abort
  the plugin. Verified on bash 3.2 and 5.2.
- Log output goes to fd 3 so helpers can print return values on stdout and be captured
  with `$(...)`.
- `extract_mods` (from `check-updates.sh`) is wrapped in `list_mods` with `pipefail` off:
  its awk exits at the end of the table and the SIGPIPE on `cat` would otherwise abort
  `update.sh` with exit 141.
- The rsync flags are the ones from the manual process minus `--progress` (pure noise
  for local copies).
- Version strings are normalised exactly like `check-updates.sh` (`normalize_version`).
  Metamod:Source `2.0.0-1469` corresponds to asset names `mmsource-2.0.0-git1469-*`.
