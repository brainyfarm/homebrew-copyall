#!/bin/bash

log_info() {
  $VERBOSE && echo "[INFO] $1"
}

log_error() {
  echo "[ERROR] $1" >&2
}

trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  echo -n "$var"
}

print_help() {
  cat << EOF
Usage: copyall [options]

Options:
  -f, --folders            Comma-separated list of folders to include.
  --file-types             Comma-separated list of file types to include.
  --exclude                Comma-separated list of additional ignore patterns.
  --output-file <path>     Write output to a custom file path.
  --dry-run                Preview actions without writing output.
  --ignore-tests           Exclude test files and directories.
  --src-only               Only include the 'src' folder.
  --remove-comments        Remove comments from code files.
  --summary-lines <number> Number of lines for file summaries (0 for full).
  --max-file-size <bytes>  Maximum file size in bytes for processing.
  --include-hidden         Include hidden files and directories.
  --max-depth <number>     Maximum depth for directory traversal.
  --verbose                Enable verbose output.
  -h, --help               Display help.
EOF
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--folders)
        FOLDERS="$2"
        shift 2
        ;;
      --file-types)
        FILE_TYPES="$2"
        shift 2
        ;;
      --exclude)
        EXCLUDE_PATTERN_STRING="$2"
        shift 2
        ;;
      --output-file)
        OUTPUT_FILE="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --ignore-tests)
        IGNORE_TESTS=true
        shift
        ;;
      --src-only)
        SRC_ONLY=true
        shift
        ;;
      --remove-comments)
        REMOVE_COMMENTS=true
        shift
        ;;
      --summary-lines)
        SUMMARY_LINES="$2"
        shift 2
        ;;
      --max-file-size)
        MAX_FILE_SIZE="$2"
        shift 2
        ;;
      --include-hidden)
        INCLUDE_HIDDEN=true
        shift
        ;;
      --max-depth)
        MAX_DEPTH="$2"
        shift 2
        ;;
      --verbose)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        print_help
        exit 1
        ;;
    esac
  done
}

setup_environment() {
  local out_dir
  out_dir=$(dirname "$OUTPUT_FILE")
  mkdir -p "$out_dir"
  : > "$OUTPUT_FILE"
  log_info "Environment setup completed."

  if [[ "$OUTPUT_FILE" == "$COPYALL_DIR/copyall.txt" ]]; then
    if [[ -f "$GITIGNORE_FILE" ]]; then
      if ! grep -qxF "copyall/" "$GITIGNORE_FILE"; then
        echo -e "\ncopyall/" >> "$GITIGNORE_FILE"
        log_info "Added 'copyall/' to .gitignore."
      fi
    else
      echo "copyall/" > "$GITIGNORE_FILE"
      log_info "Created .gitignore and added 'copyall/'."
    fi
  fi
}

finalize_execution() {
  local end_time
  end_time=$(date +%s)
  local duration=$((end_time - START_TIME))
  log_info "CopyAll process completed in $duration seconds."

  if $DRY_RUN; then
    log_info "Dry-run mode - output not copied to clipboard."
  else
    if [[ -n "$CLIP_CMD" ]]; then
      cat "$OUTPUT_FILE" | eval "$CLIP_CMD"
      log_info "Output copied to clipboard."
    else
      log_info "Clipboard command not found. Output not copied to clipboard."
    fi
  fi

  local file_count
  if [[ -f "$OUTPUT_FILE" ]]; then
    file_count=$(grep -c "^--- Contents of " "$OUTPUT_FILE")
  else
    file_count=0
  fi
  echo "Processed $file_count files in $duration seconds."
}
