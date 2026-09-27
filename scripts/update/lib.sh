#!/usr/bin/env bash
# =============================================================================
# Kus' modded Counter Strike 2 (CS2) Dedicated Server
# https://github.com/kus/cs2-modded-server/
#
# scripts/update/lib.sh - shared functions for the plugin (mod) update tool.
#
# Sourced by scripts/update/update.sh. Plugin scripts (scripts/update/plugins/*.sh)
# are sourced *after* this file and may use everything defined here.
# Not meant to be executed directly.
#
# Compatibility: bash 3.2+ (macOS /bin/bash) - no associative arrays, no mapfile,
# no ${var,,}. Works with macOS openrsync and GNU rsync.
# =============================================================================

UPDATE_LIB_LOADED=1

# All human-readable output goes to fd 3 so helpers can `echo` a value on stdout
# and be captured with $(...) without the log lines leaking into the value.
{ true >&3; } 2>/dev/null || exec 3>&1

if [ -t 1 ]; then
    C_RED=$'\033[0;31m'; C_GRN=$'\033[0;32m'; C_YEL=$'\033[0;33m'
    C_BLU=$'\033[0;34m'; C_DIM=$'\033[2m';    C_OFF=$'\033[0m'
else
    C_RED=''; C_GRN=''; C_YEL=''; C_BLU=''; C_DIM=''; C_OFF=''
fi

DRY_RUN="${DRY_RUN:-0}"

# ----------------------------------------------------------------------------- logging
log()  { printf '%s\n' "$*" >&3; }
info() { log "    $*"; }
step() { log "    ${C_BLU}>${C_OFF} $*"; }
warn() { log "    ${C_YEL}!  $*${C_OFF}"; }
err()  { log "    ${C_RED}X  $*${C_OFF}"; }
dry()  { log "    ${C_DIM}[dry-run] would $*${C_OFF}"; }
# die: abort the current unit of work. Inside plugin_apply/plugin_preflight (which
# run in an isolated subshell, see run_isolated) this aborts just that plugin.
die()  { err "$@"; exit 1; }

is_dry() { [ "$DRY_RUN" = 1 ]; }

# ----------------------------------------------------------------------------- flags / results
# FLAGS collects everything that needs a human to look at it (shown in the summary).
FLAGS=()
add_flag() { FLAGS+=("$*"); }

# ----------------------------------------------------------------------------- generic helpers
require_tools() {
    local t missing=""
    for t in "$@"; do
        command -v "$t" >/dev/null 2>&1 || missing="$missing $t"
    done
    [ -z "$missing" ] || die "missing required tools:$missing"
}

# Mirrors the tag normalisation in scripts/check-updates.sh (fetch_latest_release):
# strip leading non-digits, then drop anything that is not [0-9A-Za-z.-].
normalize_version() {
    printf '%s' "$1" | sed 's/^[^0-9]*//' | sed 's/[^0-9A-Za-z.-]//g'
}

# "Metamod:Source" -> "metamod-source", "Inventory Simulator" -> "inventory-simulator"
slugify() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

file_size() {
    stat -f%z "$1" 2>/dev/null || stat -c%s "$1"
}

# --- path guards -------------------------------------------------------------
_norm_path() { local p="$1"; p="${p#./}"; p="${p%/}"; printf '%s' "$p"; }

# true if $1 == $2 or $1 is inside directory $2
path_within() {
    local p b
    p=$(_norm_path "$1"); b=$(_norm_path "$2")
    [ "$p" = "$b" ] || [[ "$p" == "$b"/* ]]
}

check_repo_relative() {
    local p="$1"
    [[ "$p" != /* ]]      || { err "path must be relative to the repo root: $p"; return 1; }
    [[ "$p" != *..* ]]    || { err "path must not contain '..': $p"; return 1; }
    [ -n "$(_norm_path "$p")" ] || { err "empty path"; return 1; }
}

_owned_paths_str() { printf '%s' "${PLUGIN_PATHS[*]}"; }

# Deletes are only allowed strictly inside a PLUGIN_PATHS entry.
assert_delete_target() {
    check_repo_relative "$1" || exit 1
    local o
    for o in "${PLUGIN_PATHS[@]}"; do
        path_within "$1" "$o" && return 0
    done
    die "refusing to delete '$1': not inside any PLUGIN_PATHS ($(_owned_paths_str))"
}

# Writes are allowed inside a PLUGIN_PATHS entry, or to an ancestor of one
# (e.g. rsync of <archive>/addons/ into game/csgo/addons/). Anything that lands
# outside PLUGIN_PATHS is still caught afterwards by verify_containment.
assert_write_target() {
    check_repo_relative "$1" || exit 1
    local o
    for o in "${PLUGIN_PATHS[@]}"; do
        if path_within "$1" "$o" || path_within "$o" "$1"; then return 0; fi
    done
    die "refusing to write to '$1': unrelated to PLUGIN_PATHS ($(_owned_paths_str))"
}

_is_extract_path() { [ -n "${EXTRACT_DIR:-}" ] && path_within "$1" "$EXTRACT_DIR"; }

# ----------------------------------------------------------------------------- checks usable in plugin scripts
# In dry-run nothing is extracted, so checks on extracted paths are reported, not run.
require_dir() {
    local d="$1"
    if is_dry && _is_extract_path "$d"; then dry "verify directory exists: $d"; return 0; fi
    [ -d "$d" ] || die "expected directory does not exist: $d"
}

require_file() {
    local f="$1"
    if is_dry && _is_extract_path "$f"; then dry "verify file exists: $f"; return 0; fi
    [ -f "$f" ] || die "expected file does not exist: $f"
}

# ----------------------------------------------------------------------------- GitHub / sources
github_api() {
    local path="$1" url="https://api.github.com/$1" body token
    local -a hdr
    hdr=(-H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28")
    token="${GITHUB_TOKEN:-}"
    if [ -z "$token" ] && command -v gh >/dev/null 2>&1; then
        token=$(gh auth token 2>/dev/null || true)
    fi
    [ -z "$token" ] || hdr+=(-H "Authorization: Bearer $token")
    body=$(curl -sSL "${hdr[@]}" "$url") || { err "GitHub API request failed: $url"; return 1; }
    if printf '%s' "$body" | jq -e 'type=="object" and has("message")' >/dev/null 2>&1; then
        err "GitHub API error for $url: $(printf '%s' "$body" | jq -r '.message')"
        return 1
    fi
    printf '%s' "$body"
}

github_repo_from_url() {
    printf '%s' "$1" | sed -E 's#^https?://(www\.)?github\.com/##; s#/+$##; s#\.git$##'
}

# Prints "name<TAB>url<TAB>size" for every asset of the release whose tag
# normalises to $2 (the version detected by check-updates.sh).
github_release_assets() {
    local repo want="$2" json tag match=""
    repo=$(github_repo_from_url "$1")
    json=$(github_api "repos/$repo/releases?per_page=30") || return 1
    while IFS= read -r tag; do
        [ -n "$tag" ] || continue
        if [ "$(normalize_version "$tag")" = "$want" ]; then match="$tag"; break; fi
    done < <(printf '%s' "$json" | jq -r '.[] | select(.draft|not) | .tag_name')
    if [ -z "$match" ]; then
        err "no release in $repo has a tag matching version '$want' (tags seen: $(printf '%s' "$json" | jq -r '[.[] | .tag_name] | join(", ")'))"
        return 1
    fi
    info "GitHub release: $repo tag $match"
    printf '%s' "$json" | jq -r --arg t "$match" \
        '.[] | select(.tag_name==$t) | .assets[] | [.name, .browser_download_url, (.size|tostring)] | @tsv'
}

# Same output format, for https://www.metamodsource.net/downloads.php?branch=dev
# Uses the two "quick-download" links (the pinned/latest build), the same links
# check-updates.sh derives the version from.
metamod_release_assets() {
    local url="$1" want="$2" html links l name ver
    html=$(curl -sSL "$url") || { err "could not fetch $url"; return 1; }
    links=$(printf '%s' "$html" \
        | grep -E "class=['\"]quick-download download-link['\"]" \
        | grep -oE "href=['\"][^'\"]+['\"]" \
        | sed -E "s/^href=['\"]//; s/['\"]$//") || true
    [ -n "$links" ] || { err "could not find the quick-download links on $url (page layout changed?)"; return 1; }
    while IFS= read -r l; do
        [ -n "$l" ] || continue
        name=$(basename "$l")
        ver=$(printf '%s' "$name" | sed -E 's/^mmsource-([0-9.]+)-git([0-9]+)-.*$/\1-\2/')
        if [ "$ver" != "$want" ]; then
            err "Metamod asset $name is version '$ver' but check-updates reported '$want'"
            return 1
        fi
        printf '%s\t%s\t0\n' "$name" "$l"
    done <<< "$links"
}

# Fills ASSET_NAMES / ASSET_URLS / ASSET_SIZES with every asset of the new release.
resolve_assets() {
    ASSET_NAMES=(); ASSET_URLS=(); ASSET_SIZES=()
    local lines n u s
    if declare -F plugin_resolve_assets >/dev/null; then
        lines=$(plugin_resolve_assets) || return 1
    elif [[ "$PLUGIN_URL" == *github.com* ]]; then
        lines=$(github_release_assets "$PLUGIN_URL" "$NEW_VERSION") || return 1
    elif [[ "$PLUGIN_URL" == *metamodsource.net* ]]; then
        lines=$(metamod_release_assets "$PLUGIN_URL" "$NEW_VERSION") || return 1
    else
        err "unsupported source URL '$PLUGIN_URL' - define plugin_resolve_assets() in the plugin script"
        return 1
    fi
    while IFS=$'\t' read -r n u s; do
        [ -n "$n" ] || continue
        ASSET_NAMES+=("$n"); ASSET_URLS+=("$u"); ASSET_SIZES+=("${s:-0}")
    done <<< "$lines"
    [ "${#ASSET_NAMES[@]}" -gt 0 ] || { err "release has no downloadable assets"; return 1; }
    info "release assets: ${ASSET_NAMES[*]}"
}

# Matches each glob printed by plugin_assets() against ASSET_NAMES. Every glob must
# match exactly one asset. Fills MATCHED_NAMES / MATCHED_URLS / MATCHED_SIZES / MATCHED_FILES.
match_assets() {
    MATCHED_NAMES=(); MATCHED_URLS=(); MATCHED_SIZES=(); MATCHED_FILES=()
    local pats pat i n count idx
    pats=$(plugin_assets) || { err "plugin_assets() failed"; return 1; }
    while IFS= read -r pat; do
        [ -n "$pat" ] || continue
        count=0; idx=-1; i=0
        while [ "$i" -lt "${#ASSET_NAMES[@]}" ]; do
            n="${ASSET_NAMES[$i]}"
            # shellcheck disable=SC2053
            if [[ "$n" == $pat ]]; then count=$((count + 1)); idx=$i; fi
            i=$((i + 1))
        done
        if [ "$count" -ne 1 ]; then
            err "asset pattern '$pat' matched $count assets, expected exactly 1. Available: ${ASSET_NAMES[*]}"
            return 1
        fi
        MATCHED_NAMES+=("${ASSET_NAMES[$idx]}")
        MATCHED_URLS+=("${ASSET_URLS[$idx]}")
        MATCHED_SIZES+=("${ASSET_SIZES[$idx]}")
        MATCHED_FILES+=("$DOWNLOAD_DIR/${ASSET_NAMES[$idx]}")
    done <<< "$pats"
    [ "${#MATCHED_NAMES[@]}" -gt 0 ] || { err "plugin_assets() printed no patterns"; return 1; }
}

_matched_index() {
    local pat="$1" i=0
    while [ "$i" -lt "${#MATCHED_NAMES[@]}" ]; do
        # shellcheck disable=SC2053
        if [[ "${MATCHED_NAMES[$i]}" == $pat ]]; then printf '%s' "$i"; return 0; fi
        i=$((i + 1))
    done
    return 1
}

archive_ok() {
    local f="$1" size="${2:-0}"
    if [ "$size" -gt 0 ] 2>/dev/null; then
        [ "$(file_size "$f")" = "$size" ] || return 1
    fi
    case "$f" in
        *.zip)          unzip -tqq "$f" >/dev/null 2>&1 ;;
        *.tar.gz|*.tgz) tar -tzf "$f" >/dev/null 2>&1 ;;
        *)              return 0 ;;
    esac
}

# Downloads every matched asset into DOWNLOAD_DIR (cached: an existing, valid
# archive of the right size is reused, so re-runs do not re-download).
download_assets() {
    local i=0 name url size dest
    while [ "$i" -lt "${#MATCHED_NAMES[@]}" ]; do
        name="${MATCHED_NAMES[$i]}"; url="${MATCHED_URLS[$i]}"
        size="${MATCHED_SIZES[$i]}"; dest="${MATCHED_FILES[$i]}"
        if is_dry; then
            dry "download $url -> $dest"
        else
            mkdir -p "$DOWNLOAD_DIR"
            if [ -f "$dest" ] && archive_ok "$dest" "$size"; then
                step "using cached download $dest"
            else
                step "downloading $name"
                rm -f "$dest" "$dest.part"
                curl -fSL --retry 3 --progress-bar -o "$dest.part" "$url" 2>&3 || die "download failed: $url"
                mv "$dest.part" "$dest"
                archive_ok "$dest" "$size" || die "downloaded archive failed verification (size/integrity): $dest"
            fi
        fi
        i=$((i + 1))
    done
}

# ----------------------------------------------------------------------------- helpers for plugin_apply()
# Path of the downloaded archive matching a glob.
asset_path() {
    local i
    i=$(_matched_index "$1") || die "no matched asset for pattern '$1'"
    printf '%s\n' "${MATCHED_FILES[$i]}"
}

# Extracts the archive matching a glob into EXTRACT_DIR/<archive name without extension>
# and prints that directory. Always starts from an empty directory.
extract_asset() {
    local i file name stem dir
    i=$(_matched_index "$1") || die "no matched asset for pattern '$1'"
    file="${MATCHED_FILES[$i]}"; name="${MATCHED_NAMES[$i]}"
    stem="${name%.tar.gz}"; stem="${stem%.tgz}"; stem="${stem%.zip}"
    dir="$EXTRACT_DIR/$stem"
    if is_dry; then
        dry "extract $name -> $dir/"
        printf '%s\n' "$dir"
        return 0
    fi
    step "extracting $name -> $dir/"
    rm -rf "$dir"
    mkdir -p "$dir"
    case "$file" in
        *.zip)          unzip -qo "$file" -d "$dir" >&3 2>&3 || die "unzip failed: $file" ;;
        *.tar.gz|*.tgz) tar -xzf "$file" -C "$dir" >&3 2>&3 || die "tar failed: $file" ;;
        *)              die "unsupported archive type: $file" ;;
    esac
    printf '%s\n' "$dir"
}

# Deletes a directory produced by extract_asset.
remove_extracted() {
    local d="$1"
    _is_extract_path "$d" || die "refusing to remove '$d': not under $EXTRACT_DIR"
    if is_dry; then dry "delete extracted folder $d/"; return 0; fi
    step "deleting extracted folder $d/"
    rm -rf "$d"
}

RSYNC_FLAGS=(-rhavz --exclude "._*" --exclude ".DS_Store" --partial --stats)

# rsync <src>/ -> <dest>/ (merge; never deletes files at the destination).
sync_dir() {
    local src="$1" dest="$2"
    src="${src%/}/"; dest="${dest%/}/"
    assert_write_target "$dest"
    if is_dry; then dry "rsync ${RSYNC_FLAGS[*]} $src -> $dest"; return 0; fi
    require_dir "$src"
    require_dir "$dest"
    step "rsync $src -> $dest"
    rsync "${RSYNC_FLAGS[@]}" "$src" "$dest" >&3 2>&3 || die "rsync failed: $src -> $dest"
}

# Copy directory <src> to <dest> (dest is the directory itself, created if missing).
# Implemented with the same rsync flags so ._* / .DS_Store junk is never copied.
copy_dir() {
    local src="$1" dest="$2"
    src="${src%/}/"; dest="${dest%/}/"
    assert_write_target "$dest"
    if is_dry; then dry "copy directory $src -> $dest"; return 0; fi
    require_dir "$src"
    step "copying directory $src -> $dest"
    mkdir -p "$dest"
    rsync "${RSYNC_FLAGS[@]}" "$src" "$dest" >&3 2>&3 || die "copy failed: $src -> $dest"
}

copy_file() {
    local src="$1" dest="$2"
    assert_write_target "$dest"
    if is_dry; then dry "copy file $src -> $dest"; return 0; fi
    require_file "$src"
    step "copying file $src -> $dest"
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest" || die "copy failed: $src -> $dest"
}

# Delete everything inside <dir> but keep the directory.
empty_dir() {
    local d="$1"
    assert_delete_target "$d"
    if is_dry; then dry "empty directory $d/ (delete its contents)"; return 0; fi
    require_dir "$d"
    step "emptying $d/"
    find "$d" -mindepth 1 -maxdepth 1 -exec rm -rf {} + || die "failed to empty $d"
}

# Delete a file or directory (no error if already absent - keeps re-runs idempotent).
remove_path() {
    local p="$1"
    assert_delete_target "$p"
    if is_dry; then dry "delete $p"; return 0; fi
    if [ -e "$p" ]; then
        step "deleting $p"
        rm -rf "$p" || die "failed to delete $p"
    else
        info "(already absent) $p"
    fi
}

# ----------------------------------------------------------------------------- config-file helpers
# Keys (first token of each non-comment line; JSON keys) of a .cfg/.json file.
_setting_keys() {
    sed -E 's/^[[:space:]]+//; s#^//.*##; s/^"([^"]+)".*/\1/' "$1" \
        | awk 'NF && $1 !~ /^[{}\[\],]+$/ { print $1 }' | sort -u
}

# Keys listed in scripts/update/plugins/<slug>.ignore (one per line, '#' comments) are
# never reported: add a key there once it has been reviewed (ported, or removed on purpose).
_ignored_setting_keys() {
    local f="${PLUGIN_SCRIPT_DIR:-scripts/update/plugins}/${PLUGIN_SLUG:-}.ignore"
    [ -f "$f" ] || return 0
    sed -E 's/#.*//; s/^[[:space:]]+//; s/[[:space:]]+$//' "$f" | awk 'NF' | sort -u
}

# Heads-up only (never edits anything): reports settings present in the release's
# copy of a config file but absent from the repo's customised copy, so new upstream
# settings can be merged by hand. $1 = file in the extracted archive, $2 = repo file.
warn_new_settings() {
    local src="$1" dest="$2" missing
    if is_dry; then dry "report settings in $src that are missing from $dest (manual merge)"; return 0; fi
    require_file "$src"
    [ -f "$dest" ] || { warn "$dest does not exist (release ships $(basename "$src")) - add it by hand if wanted (NOT copied)"; return 0; }
    missing=$(comm -23 <(_setting_keys "$src") <(_setting_keys "$dest") | comm -23 - <(_ignored_setting_keys))
    if [ -n "$missing" ]; then
        warn "new upstream settings in $src not present in $dest - merge by hand:"
        printf '%s\n' "$missing" | sed 's/^/          /' >&3
    else
        info "no new upstream settings in $(basename "$dest")"
    fi
}

# Report-only check of a whole config directory the release ships against the repo's
# customised copy. NOTHING is written or deleted: new upstream files, files upstream no
# longer ships, and new settings inside files present on both sides are listed so they
# can be ported by hand. $1 = directory in the extracted archive, $2 = repo directory,
# $3 = "existing-only" to skip the new/removed-file checks (for partial mirrors such as
# custom_files_example/).
warn_cfg_dir_changes() {
    local src="$1" dest="$2" mode="${3:-}" f
    src="${src%/}"; dest="${dest%/}"
    if is_dry; then dry "report new files / removed files / new settings in $src/ vs $dest/ (manual port, nothing written)"; return 0; fi
    require_dir "$src"
    [ -d "$dest" ] || { warn "$dest/ does not exist (release ships $src/) - nothing compared"; return 0; }
    while IFS= read -r f; do
        if [ -f "$dest/$f" ]; then
            warn_new_settings "$src/$f" "$dest/$f"
        elif [ "$mode" != "existing-only" ]; then
            warn "release ships a new config file $f that is not in $dest/ - add it by hand if wanted (NOT copied)"
        fi
    done < <(cd "$src" && find . -type f ! -name '.DS_Store' ! -name '._*' | sed 's#^\./##' | sort)
    if [ "$mode" != "existing-only" ]; then
        while IFS= read -r f; do
            [ -e "$src/$f" ] || warn "$dest/$f is not shipped by this release any more - delete it by hand if it was an upstream leftover (NOT deleted)"
        done < <(cd "$dest" && find . -type f ! -name '.DS_Store' ! -name '._*' | sed 's#^\./##' | sort)
    fi
}

# ----------------------------------------------------------------------------- git / README
# Runs "$@" in a subshell with errexit so the first failing helper aborts the whole
# unit. Result in ISOLATED_RC.
# IMPORTANT: never call this (or a function that calls it) inside `if`, `||`, `&&`
# or `!` - bash then ignores `set -e` all the way down and a failed step would NOT
# stop the plugin (this was verified empirically on bash 3.2 and 5.2).
run_isolated() {
    set +e
    ( set -e; "$@" )
    ISOLATED_RC=$?
    set -e
}

tree_is_clean() { [ -z "$(git status --porcelain=v1 -uall)" ]; }

# Prints every changed/untracked path (one per line), unquoting git's "quoted" form.
changed_paths() {
    git status --porcelain=v1 -uall | cut -c4- | sed -E 's/^"(.*)"$/\1/; s/^.* -> //'
}

# Every change in the tree must be README.md or inside PLUGIN_PATHS.
verify_containment() {
    local p o ok bad=0
    while IFS= read -r p; do
        [ -n "$p" ] || continue
        [ "$p" = "README.md" ] && continue
        ok=0
        for o in "${PLUGIN_PATHS[@]}"; do
            if path_within "$p" "$o"; then ok=1; break; fi
        done
        if [ "$ok" = 0 ]; then err "unexpected change outside the plugin's paths: $p"; bad=1; fi
    done < <(changed_paths)
    return "$bad"
}

# True if at least one changed path is inside PLUGIN_PATHS (i.e. the update changed files).
plugin_files_changed() {
    local p o
    while IFS= read -r p; do
        [ -n "$p" ] || continue
        for o in "${PLUGIN_PATHS[@]}"; do
            if path_within "$p" "$o"; then return 0; fi
        done
    done < <(changed_paths)
    return 1
}

# Line number of the mod's row in the README "Mod | Version | Why" table. Only the
# table region is searched (header to first blank line) and the row must START with
# the link, because the same link can appear again in prose elsewhere in the README.
readme_line_number() {   # $1 name, $2 url -> prints the single matching line number
    local nums count
    nums=$(awk -v link="[$1]($2)" '
        $0 == "Mod | Version | Why" { inside = 1; next }
        inside && $0 ~ /^$/          { exit }
        inside && index($0, link) == 1 && substr($0, length(link) + 1) ~ /^ *\|/ { print NR }
    ' README.md)
    count=$(printf '%s\n' "$nums" | grep -c . || true)
    [ "$count" = 1 ] || die "expected exactly one row in the README.md mod table starting with [$1]($2), found $count"
    printf '%s' "$nums"
}

# Replace `old` with `new` on the mod's line of the README version table.
readme_set_version() {   # $1 name, $2 url, $3 old, $4 new
    local n line occurrences
    n=$(readme_line_number "$1" "$2")
    line=$(sed -n "${n}p" README.md)
    occurrences=$(printf '%s' "$line" | awk -v tok="\`$3\`" '{ print gsub(tok, "") }')
    [ "$occurrences" = 1 ] || die "README.md line $n does not contain \`$3\` exactly once (found $occurrences): $line"
    if is_dry; then dry "update README.md line $n: \`$3\` -> \`$4\`"; return 0; fi
    step "updating README.md line $n: \`$3\` -> \`$4\`"
    awk -v n="$n" -v old="\`$3\`" -v new="\`$4\`" '
        NR == n { i = index($0, old); if (i > 0) $0 = substr($0, 1, i - 1) new substr($0, i + length(old)) }
        { print }
    ' README.md > README.md.update-tmp || die "failed to rewrite README.md"
    mv README.md.update-tmp README.md
}

verify_readme_diff() {   # exactly one line replaced
    local stat
    stat=$(git diff --numstat -- README.md | awk '{print $1"/"$2}')
    [ "$stat" = "1/1" ] || { err "README.md diff is not a single-line change (added/removed: ${stat:-0/0})"; return 1; }
}

commit_update() {
    local msg="- UPDATED: $PLUGIN_NAME $OLD_VERSION > $NEW_VERSION" p hash
    local -a paths
    paths=()
    while IFS= read -r p; do
        [ -n "$p" ] && paths+=("$p")
    done < <(changed_paths)
    if is_dry; then
        dry "git add -A -- ${PLUGIN_PATHS[*]} README.md"
        dry "git commit -m \"$msg\""
        return 0
    fi
    [ "${#paths[@]}" -gt 0 ] || die "nothing to commit"
    git add -A -- "${paths[@]}" || die "git add failed"
    git diff --cached --quiet && die "nothing staged to commit"
    git commit -q -m "$msg" || die "git commit failed"
    hash=$(git rev-parse --short HEAD)
    log "    ${C_GRN}OK committed $hash: $msg${C_OFF}"
}
