#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0

setup() {
    export TEST_HOME="$(mktemp -d)"
    export HOME="$TEST_HOME"
    export CCSWAP_DIR="$HOME/.ccswap"
    export CONFIG_FILE="$CCSWAP_DIR/config.json"

    # Create fake ~/.claude
    mkdir -p "$HOME/.claude"

    # Create fake ~/.agents/skills with two test skills
    mkdir -p "$HOME/.agents/skills/skill-alpha"
    echo "name: skill-alpha" > "$HOME/.agents/skills/skill-alpha/skill.md"
    mkdir -p "$HOME/.agents/skills/skill-beta"
    echo "name: skill-beta" > "$HOME/.agents/skills/skill-beta/skill.md"
}

teardown() {
    rm -rf "$TEST_HOME"
}

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo "  PASS: $desc"
        ((PASS++))
    else
        echo "  FAIL: $desc"
        echo "    expected: $expected"
        echo "    actual:   $actual"
        ((FAIL++))
    fi
}

assert_contains() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$actual" == *"$expected"* ]]; then
        echo "  PASS: $desc"
        ((PASS++))
    else
        echo "  FAIL: $desc"
        echo "    expected to contain: $expected"
        echo "    actual: $actual"
        ((FAIL++))
    fi
}

assert_link() {
    local desc="$1" path="$2" target="$3"
    if [[ -L "$path" ]]; then
        local actual_target
        actual_target=$(readlink "$path")
        if [[ "$actual_target" == "$target" ]]; then
            echo "  PASS: $desc"
            ((PASS++))
        else
            echo "  FAIL: $desc (wrong target)"
            echo "    expected: $target"
            echo "    actual:   $actual_target"
            ((FAIL++))
        fi
    else
        echo "  FAIL: $desc (not a symlink)"
        ((FAIL++))
    fi
}

assert_not_exists() {
    local desc="$1" path="$2"
    if [[ ! -e "$path" ]] && [[ ! -L "$path" ]]; then
        echo "  PASS: $desc"
        ((PASS++))
    else
        echo "  FAIL: $desc (path exists)"
        ((FAIL++))
    fi
}

# Initialize ccswap and add test accounts (helper)
init_with_accounts() {
    "$PROJECT_DIR/bin/ccswap" init > /dev/null 2>&1
    # Add accounts non-interactively (pipe 'n' to skip prompts)
    echo -e "n\nn" | "$PROJECT_DIR/bin/ccswap" add work > /dev/null 2>&1
    echo -e "n\nn" | "$PROJECT_DIR/bin/ccswap" add thinkode > /dev/null 2>&1
    # Ensure skills dirs exist
    mkdir -p "$CCSWAP_DIR/accounts/work/skills"
    mkdir -p "$CCSWAP_DIR/accounts/thinkode/skills"
}

# Tests go here (added in subsequent tasks)
run_tests() {
    echo ""
}

# Run
setup
run_tests
teardown

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
