#!/bin/zsh
set -eu
task_root="$(cd "$(dirname "$0")/.." && pwd)"
task_build="$(mktemp -d "${TMPDIR:-/tmp}/lab4-checks.XXXXXX")"
trap 'rm -rf "$task_build"' EXIT
xcrun swiftc -parse-as-library \
    "$task_root/Flashcard/Flashcard/StudyDeck.swift" \
    "$task_root/Flashcard/Flashcard/CardStore.swift" \
    "$task_root/Tests/DeckChecks.swift" \
    -o "$task_build/deck-checks"
"$task_build/deck-checks"
