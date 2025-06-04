#!/bin/bash

export LC_ALL=C
ROOT_DIR=${ROOT_DIR:-$(pwd)}
COPYALL_DIR="$ROOT_DIR/copyall"
OUTPUT_FILE="$COPYALL_DIR/copyall.txt"
GITIGNORE_FILE="$ROOT_DIR/.gitignore"
COPYALLIGNORE_FILE="$ROOT_DIR/.copyallignore"


START_TIME=$(date +%s)

MAX_FILE_SIZE=50000
SUMMARY_LINES=0
INCLUDE_HIDDEN=false
MAX_DEPTH=0
VERBOSE=false
REMOVE_COMMENTS=false
IGNORE_TESTS=false
SRC_ONLY=false
FOLDERS=""
EXCLUDE_PATTERN_STRING=""
DRY_RUN=false

SYM_TEE="├──"
SYM_ELBOW="└──"

IGNORED_FILES=()
EXCLUDE_PATTERNS=()
SCRIPT_IGNORE_ENTRIES=()

if [[ "$OSTYPE" == "darwin"* ]]; then
  CLIP_CMD="pbcopy"
elif command -v xclip >/dev/null 2>&1; then
  CLIP_CMD="xclip -selection clipboard"
elif command -v xsel >/dev/null 2>&1; then
  CLIP_CMD="xsel --clipboard --input"
else
  CLIP_CMD=""
fi
