#!/bin/bash

add_to_ignore_files() {
  if [[ -n "$EXCLUDE_PATTERN_STRING" ]]; then
    IFS=',' read -ra patterns <<< "$EXCLUDE_PATTERN_STRING"
    EXCLUDE_PATTERNS+=("${patterns[@]}")
  fi

  SCRIPT_IGNORE_ENTRIES+=("copyall" "copyall/" "*.o" "*.pyc" "*.class" "*.swp" "*~")
}

load_ignored_files() {
  IGNORED_FILES=("${SCRIPT_IGNORE_ENTRIES[@]}")

  for ignore_file in "$GITIGNORE_FILE" "$COPYALLIGNORE_FILE"; do
    if [[ -f "$ignore_file" ]]; then
      while IFS= read -r line || [[ -n "$line" ]]; do
        line=$(trim "$line")
        [[ -z "$line" || "$line" == \#* ]] && continue
        IGNORED_FILES+=("$line")
      done < "$ignore_file"
    fi
  done

  # Read global git ignore file if configured
  local global_ignore
  global_ignore=$(git config --get core.excludesfile 2>/dev/null)
  if [[ -f "$global_ignore" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      line=$(trim "$line")
      [[ -z "$line" || "$line" == \#* ]] && continue
      IGNORED_FILES+=("$line")
    done < "$global_ignore"
  fi

  $IGNORE_TESTS && IGNORED_FILES+=("test" "tests")
  if $SRC_ONLY; then
    for dir in "$ROOT_DIR"/*/; do
      [[ "$(basename "$dir")" != "src" ]] && IGNORED_FILES+=("$(basename "$dir")")
    done
  fi

  if [[ -n "$FOLDERS" ]]; then
    IFS=',' read -ra FOLDER_ARRAY <<< "$FOLDERS"
    for dir in "$ROOT_DIR"/*/; do
      local base="$(basename "$dir")"
      local keep=false
      for f in "${FOLDER_ARRAY[@]}"; do
        [[ "$base" == "$f" ]] && keep=true && break
      done
      $keep || IGNORED_FILES+=("$base")
    done
  fi

  IGNORED_FILES+=("${EXCLUDE_PATTERNS[@]}")
}

is_ignored() {
  local path="$1"
  local rel_path="${path#$ROOT_DIR/}"

  if [[ -n "$FOLDERS" ]]; then
    local base="${rel_path%%/*}"
    local match=false
    for dir in "${FOLDER_ARRAY[@]}"; do
      if [[ "$base" == "$dir" ]]; then
        match=true
        break
      fi
    done
    $match || return 0
  fi

  for pattern in "${IGNORED_FILES[@]}"; do
    if [[ "$rel_path" == $pattern || "$rel_path" == $pattern/* ]]; then
      return 0
    fi
  done
  return 1
}
