#!/usr/bin/env bash
# =============================================================================
# Kus' modded Counter Strike 2 (CS2) Dedicated Server
# https://github.com/kus/cs2-modded-server/
#
# scripts/update/update.sh - automated plugin (mod) updater for this repo
#
#   ./scripts/update/update.sh              apply every available update (one at a time, README order)
#   ./scripts/update/update.sh --dry-run    only report what would happen (no downloads, no changes)
#   ./scripts/update/update.sh --only NAME  restrict to one mod (README name or slug; repeatable)
#   ./scripts/update/update.sh --list       list mods, slugs and whether an update script exists
#
# See scripts/update/README.md for the full description and how to add plugins.
# =============================================================================
set -euo pipefail

# Always run from the repo root so every path in this tool and in plugin scripts
# is relative to it.
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1

exec 3>&1

# --- reuse the version detection from check-updates.sh ----------------------
# (sourced, not executed: check-updates.sh only runs main() when executed directly)
# Sourced BEFORE lib.sh so lib.sh's log()/helpers take precedence over anything
# check-updates.sh defines with the same name.
CHECK_UPDATES_README="README.md"
export CHECK_UPDATES_README
set +u
# shellcheck source=scripts/check-updates.sh
. scripts/check-updates.sh
set -u

# shellcheck source=scripts/update/lib.sh
. scripts/update/lib.sh

PLUGIN_SCRIPT_DIR="scripts/update/plugins"
TMP_ROOT="tmp/update"

# extract_mods pipes the README through an awk that exits early; without pipefail
# disabled the resulting SIGPIPE on cat would abort this script (exit 141).
list_mods() { ( set +o pipefail; extract_mods ); }

# ----------------------------------------------------------------------------- args
DRY_RUN=0
LIST_ONLY=0
ONLY=()
STOP_RUN=0

usage() {
    sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=1 ;;
        --list)       LIST_ONLY=1 ;;
        --only)       [ $# -ge 2 ] || { usage; exit 2; }; ONLY+=("$2"); shift ;;
        -h|--help)    usage; exit 0 ;;
        *)            echo "unknown argument: $1" >&2; usage; exit 2 ;;
    esac
    shift
done

# ----------------------------------------------------------------------------- result tracking
RES_UPTODATE=(); RES_UPDATED=(); RES_NOSCRIPT=(); RES_FAILED=(); RES_UNKNOWN=(); RES_WOULD=()

selected() {   # $1 name, $2 slug -> true if no --only given or it matches
    [ "${#ONLY[@]}" -eq 0 ] && return 0
    local o lo
    for o in "${ONLY[@]}"; do
        lo=$(printf '%s' "$o" | tr '[:upper:]' '[:lower:]')
        [ "$lo" = "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" ] && return 0
        [ "$lo" = "$2" ] && return 0
    done
    return 1
}

# ----------------------------------------------------------------------------- preflight
preflight() {
    require_tools bash git curl jq unzip tar rsync awk sed grep find cut
    [ -f README.md ] || die "README.md not found in $(pwd)"
    grep -q '^Mod | Version | Why$' README.md || die "README.md: could not find the 'Mod | Version | Why' table header"
    [ -d "$PLUGIN_SCRIPT_DIR" ] || die "missing directory $PLUGIN_SCRIPT_DIR"
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "$(pwd) is not a git repository"
    [ "$(git rev-parse --show-toplevel)" = "$(pwd -P)" ] || die "must run from the repo root ($(git rev-parse --show-toplevel))"
    declare -F fetch_latest_release >/dev/null || die "scripts/check-updates.sh did not provide fetch_latest_release()"
    declare -F extract_mods >/dev/null || die "scripts/check-updates.sh did not provide extract_mods()"

    log "repo:   $(pwd)"
    log "branch: $(git rev-parse --abbrev-ref HEAD)"
    if is_dry; then
        log "mode:   DRY RUN (nothing will be downloaded, changed or committed)"
        tree_is_clean || warn "working tree is not clean - a real run would refuse to start:"$'\n'"$(git status --short | sed 's/^/        /')"
    else
        log "mode:   APPLY"
        tree_is_clean || die "working tree is not clean - commit or stash first:"$'\n'"$(git status --short | sed 's/^/        /')"
    fi
    log ""
}

# ----------------------------------------------------------------------------- per-mod processing
load_plugin_script() {   # $1 path
    unset -f plugin_assets plugin_apply plugin_preflight plugin_resolve_assets 2>/dev/null || true
    PLUGIN_PATHS=()
    bash -n "$1" || { err "syntax error in $1"; return 1; }
    # shellcheck disable=SC1090
    . "$1" || { err "failed to source $1"; return 1; }
    declare -F plugin_assets >/dev/null || { err "$1 must define plugin_assets()"; return 1; }
    declare -F plugin_apply  >/dev/null || { err "$1 must define plugin_apply()"; return 1; }
    [ "${#PLUGIN_PATHS[@]}" -gt 0 ]    || { err "$1 must set PLUGIN_PATHS=(...)"; return 1; }
    local p
    for p in "${PLUGIN_PATHS[@]}"; do
        check_repo_relative "$p" || return 1
    done
}

fail_mod() {   # $1 message  (records failure, adds a flag)
    err "$1"
    RES_FAILED+=("$PLUGIN_NAME $OLD_VERSION > ${NEW_VERSION:-?}: $1")
    add_flag "$PLUGIN_NAME: $1"
}

# NOTE: process_mod is deliberately called as a plain statement (never inside
# if/||/&&) so that run_isolated keeps errexit semantics. It always returns 0.
process_mod() {   # $1 name, $2 url, $3 current version
    PLUGIN_NAME="$1"; PLUGIN_URL="$2"; OLD_VERSION="$3"; NEW_VERSION=""
    PLUGIN_SLUG=$(slugify "$PLUGIN_NAME")
    local latest last_updated script

    latest=$(set +u; set +e; set +o pipefail; fetch_latest_release "$PLUGIN_URL" 2>/dev/null)
    if [ -z "$latest" ]; then
        last_updated=$(set +u; set +e; set +o pipefail; fetch_last_updated "$PLUGIN_URL" 2>/dev/null)
        if [ -n "$last_updated" ]; then
            log "${C_DIM}?  $PLUGIN_NAME $OLD_VERSION - no releases, last commit $last_updated - $PLUGIN_URL${C_OFF}"
            RES_UNKNOWN+=("$PLUGIN_NAME $OLD_VERSION (no releases; last commit $last_updated)")
        else
            log "${C_RED}?  $PLUGIN_NAME $OLD_VERSION - could not determine latest version - $PLUGIN_URL${C_OFF}"
            RES_UNKNOWN+=("$PLUGIN_NAME $OLD_VERSION (could not determine latest version)")
        fi
        return 0
    fi

    if [ "$latest" = "$OLD_VERSION" ]; then
        log "${C_GRN}OK $PLUGIN_NAME $latest${C_OFF}"
        RES_UPTODATE+=("$PLUGIN_NAME $latest")
        return 0
    fi

    NEW_VERSION="$latest"
    log "${C_YEL}UP $PLUGIN_NAME update available $OLD_VERSION > $NEW_VERSION  $PLUGIN_URL${C_OFF}"

    script="$PLUGIN_SCRIPT_DIR/$PLUGIN_SLUG.sh"
    if [ ! -f "$script" ]; then
        warn "no update script for '$PLUGIN_NAME' - expected $script - skipped"
        RES_NOSCRIPT+=("$PLUGIN_NAME $OLD_VERSION > $NEW_VERSION (create $script)")
        add_flag "$PLUGIN_NAME $OLD_VERSION > $NEW_VERSION: no update script, create $script"
        return 0
    fi
    info "script: $script"

    # ---- plan phase: nothing in the repo is touched until every check passes
    if ! load_plugin_script "$script"; then fail_mod "invalid plugin script $script"; return 0; fi
    DOWNLOAD_DIR="$TMP_ROOT/$PLUGIN_SLUG/$NEW_VERSION"
    EXTRACT_DIR="$DOWNLOAD_DIR/extracted"
    if ! resolve_assets; then fail_mod "could not resolve release assets"; return 0; fi
    if ! match_assets;   then fail_mod "asset patterns did not match the release assets"; return 0; fi
    if declare -F plugin_preflight >/dev/null; then
        run_isolated plugin_preflight
        if [ "$ISOLATED_RC" -ne 0 ]; then fail_mod "plugin_preflight failed - repo is not in the expected state"; return 0; fi
    fi

    if is_dry; then
        run_isolated download_assets
        run_isolated plugin_apply
        if [ "$ISOLATED_RC" -ne 0 ]; then fail_mod "plugin_apply failed during dry run"; return 0; fi
        run_isolated readme_set_version "$PLUGIN_NAME" "$PLUGIN_URL" "$OLD_VERSION" "$NEW_VERSION"
        if [ "$ISOLATED_RC" -ne 0 ]; then fail_mod "README.md version line check failed"; return 0; fi
        run_isolated commit_update
        RES_WOULD+=("$PLUGIN_NAME $OLD_VERSION > $NEW_VERSION")
        return 0
    fi

    # ---- apply phase
    if ! tree_is_clean; then fail_mod "working tree is not clean, refusing to apply"; STOP_RUN=1; return 0; fi

    run_isolated download_assets
    if [ "$ISOLATED_RC" -ne 0 ]; then fail_mod "download failed (nothing was changed)"; return 0; fi

    run_isolated plugin_apply
    if [ "$ISOLATED_RC" -ne 0 ]; then
        fail_mod "plugin_apply failed - the working tree may be partially updated. Inspect with 'git status'; reset with 'git checkout -- . && git clean -fd game/' and fix the plugin script."
        STOP_RUN=1; return 0
    fi

    if ! verify_containment; then
        fail_mod "the update changed files outside PLUGIN_PATHS - not committing. Inspect with 'git status', then either extend PLUGIN_PATHS in $script or reset with 'git checkout -- . && git clean -fd game/'."
        STOP_RUN=1; return 0
    fi

    if ! plugin_files_changed; then
        fail_mod "the update did not change any tracked file under PLUGIN_PATHS ($(_owned_paths_str)) - the release may ship identical files, or the plugin script copies to the wrong place. Nothing committed."
        return 0
    fi

    run_isolated readme_set_version "$PLUGIN_NAME" "$PLUGIN_URL" "$OLD_VERSION" "$NEW_VERSION"
    if [ "$ISOLATED_RC" -ne 0 ]; then
        fail_mod "README.md could not be updated - files are updated but not committed. Fix README.md line for $PLUGIN_NAME manually, then commit with: git add -A -- ${PLUGIN_PATHS[*]} README.md && git commit -m \"- UPDATED: $PLUGIN_NAME $OLD_VERSION > $NEW_VERSION\""
        STOP_RUN=1; return 0
    fi
    if ! verify_readme_diff; then
        fail_mod "README.md change is not the expected single-line version bump - not committing. Inspect with 'git diff README.md'."
        STOP_RUN=1; return 0
    fi

    run_isolated commit_update
    if [ "$ISOLATED_RC" -ne 0 ]; then fail_mod "git commit failed - inspect with 'git status'"; STOP_RUN=1; return 0; fi

    rm -rf "$EXTRACT_DIR"
    RES_UPDATED+=("$PLUGIN_NAME $OLD_VERSION > $NEW_VERSION ($(git rev-parse --short HEAD))")
    return 0
}

# ----------------------------------------------------------------------------- main
print_list() {
    local name url version slug script status
    printf '%-28s %-18s %-28s %s\n' "MOD" "VERSION" "SLUG" "UPDATE SCRIPT"
    while IFS='|' read -r name url version; do
        [ -n "$name" ] || continue
        slug=$(slugify "$name")
        script="$PLUGIN_SCRIPT_DIR/$slug.sh"
        if [ -f "$script" ]; then status="$script"; else status="(none)"; fi
        printf '%-28s %-18s %-28s %s\n' "$name" "$version" "$slug" "$status"
    done < <(list_mods)
}

print_section() {   # $1 title, rest = items
    local title="$1"; shift
    [ $# -gt 0 ] || return 0
    log "$title"
    local i
    for i in "$@"; do log "    - $i"; done
}

summary() {
    log ""
    log "================================================== summary"
    log "up to date: ${#RES_UPTODATE[@]}"
    print_section "${C_GRN}updated (committed):${C_OFF}"                 ${RES_UPDATED[@]+"${RES_UPDATED[@]}"}
    print_section "${C_GRN}would update (dry run):${C_OFF}"              ${RES_WOULD[@]+"${RES_WOULD[@]}"}
    print_section "${C_YEL}update available but no update script:${C_OFF}" ${RES_NOSCRIPT[@]+"${RES_NOSCRIPT[@]}"}
    print_section "${C_RED}failed:${C_OFF}"                              ${RES_FAILED[@]+"${RES_FAILED[@]}"}
    print_section "${C_DIM}could not check:${C_OFF}"                     ${RES_UNKNOWN[@]+"${RES_UNKNOWN[@]}"}
    if [ "$STOP_RUN" = 1 ]; then
        log ""
        log "${C_RED}The run was stopped early because of the failure above; mods after it were not processed.${C_OFF}"
    fi
}

main() {
    if [ "$LIST_ONLY" = 1 ]; then
        [ -f README.md ] || die "README.md not found in $(pwd)"
        print_list
        exit 0
    fi

    preflight

    local mods name url version slug
    mods=$(list_mods)
    [ -n "$mods" ] || die "no mods parsed from README.md"

    while IFS='|' read -r name url version; do
        [ -n "$name" ] || continue
        slug=$(slugify "$name")
        selected "$name" "$slug" || continue
        [ "$STOP_RUN" = 1 ] && { log "${C_DIM}-- $name (not processed: run stopped)${C_OFF}"; continue; }
        process_mod "$name" "$url" "$version"
    done <<< "$mods"

    summary
    [ "${#RES_FAILED[@]}" -eq 0 ] && [ "$STOP_RUN" = 0 ]
}

main
