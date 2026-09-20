# Plugin update automation

Automates the manual "check releases, download, copy into the repo, bump the README,
commit" routine for the mods listed in the root `README.md` version table
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

## Adding a plugin script

The script file name is the **slug** of the mod name in the README table: lower-case,
every run of non-alphanumerics replaced by `-`, trimmed. `--list` prints it for every
mod, e.g. `Metamod:Source` -> `metamod-source.sh`, `CS2 Retakes` -> `cs2-retakes.sh`.

Create `scripts/update/plugins/<slug>.sh` from this template. It is *sourced* by
`update.sh`, so its top level must only set `PLUGIN_PATHS` and define functions.

```bash
#!/usr/bin/env bash
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
| MultiAddonManager | `plugins/multiaddonmanager.sh` | Windows zip + Linux `steamrt3` tar.gz (the `steamrt4` build is ignored). Replaces only the two binaries in `game/csgo/addons/multiaddonmanager/bin/`; the `.vdf` and `cfg/` the archives ship are left alone. |
| ServerListPlayersFix | `plugins/serverlistplayersfix.sh` | Windows zip + Linux `steamrt3` tar.gz. Replaces only `bin/win64/*.dll` and `bin/linuxsteamrt64/*.so`; the repo's per-platform `.vdf` copies are left alone. |
| MovementUnlocker | `plugins/movementunlocker.sh` | Windows zip + Linux `steamrt3` tar.gz. Replaces only `bin/win64/*.dll` and `bin/linuxsteamrt64/*.so`; the `.vdf` copies under `addons/surf/` are left alone. |
| CS2 Retakes | `plugins/cs2-retakes.sh` | Uses the full `RetakesPlugin-<v>.zip` (not the `-no-map-configs` one). Replaces `plugins/disabled/RetakesPlugin` (the plugin is kept disabled in this repo, so it is NOT at `plugins/RetakesPlugin`) and `shared/RetakesPluginShared`. |

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
