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
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc"
        echo "    expected: $expected"
        echo "    actual:   $actual"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$actual" == *"$expected"* ]]; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc"
        echo "    expected to contain: $expected"
        echo "    actual: $actual"
        FAIL=$((FAIL + 1))
    fi
}

assert_link() {
    local desc="$1" path="$2" target="$3"
    if [[ -L "$path" ]]; then
        local actual_target
        actual_target=$(readlink "$path")
        if [[ "$actual_target" == "$target" ]]; then
            echo "  PASS: $desc"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: $desc (wrong target)"
            echo "    expected: $target"
            echo "    actual:   $actual_target"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  FAIL: $desc (not a symlink)"
        FAIL=$((FAIL + 1))
    fi
}

assert_not_exists() {
    local desc="$1" path="$2"
    if [[ ! -e "$path" ]] && [[ ! -L "$path" ]]; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc (path exists)"
        FAIL=$((FAIL + 1))
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
    echo "=== link skill: defaults to active account ==="
    setup
    init_with_accounts
    "$PROJECT_DIR/bin/ccswap" use work > /dev/null 2>&1
    output=$("$PROJECT_DIR/bin/ccswap" link skill skill-alpha 2>&1 || true)
    assert_link "symlink created" \
        "$CCSWAP_DIR/accounts/work/skills/skill-alpha" \
        "$HOME/.agents/skills/skill-alpha"
    assert_contains "success message" "Linked 'skill-alpha' to 'work'" "$output"
    assert_not_exists "not in thinkode" "$CCSWAP_DIR/accounts/thinkode/skills/skill-alpha"
    teardown

    echo "=== link skill: --account flag ==="
    setup
    init_with_accounts
    output=$("$PROJECT_DIR/bin/ccswap" link skill skill-alpha --account=thinkode 2>&1 || true)
    assert_link "symlink created in thinkode" \
        "$CCSWAP_DIR/accounts/thinkode/skills/skill-alpha" \
        "$HOME/.agents/skills/skill-alpha"
    assert_not_exists "not in work" "$CCSWAP_DIR/accounts/work/skills/skill-alpha"
    teardown

    echo "=== link skill: --accounts flag (multiple) ==="
    setup
    init_with_accounts
    output=$("$PROJECT_DIR/bin/ccswap" link skill skill-beta --accounts=work,thinkode 2>&1 || true)
    assert_link "symlink in work" \
        "$CCSWAP_DIR/accounts/work/skills/skill-beta" \
        "$HOME/.agents/skills/skill-beta"
    assert_link "symlink in thinkode" \
        "$CCSWAP_DIR/accounts/thinkode/skills/skill-beta" \
        "$HOME/.agents/skills/skill-beta"
    teardown

    echo "=== link skill: --all flag ==="
    setup
    init_with_accounts
    output=$("$PROJECT_DIR/bin/ccswap" link skill skill-alpha --all 2>&1 || true)
    assert_link "symlink in work" \
        "$CCSWAP_DIR/accounts/work/skills/skill-alpha" \
        "$HOME/.agents/skills/skill-alpha"
    assert_link "symlink in thinkode" \
        "$CCSWAP_DIR/accounts/thinkode/skills/skill-alpha" \
        "$HOME/.agents/skills/skill-alpha"
    teardown

    echo "=== link skill: skill already exists (skip with warning) ==="
    setup
    init_with_accounts
    mkdir -p "$CCSWAP_DIR/accounts/work/skills/skill-alpha"
    "$PROJECT_DIR/bin/ccswap" use work > /dev/null 2>&1
    output=$("$PROJECT_DIR/bin/ccswap" link skill skill-alpha 2>&1 || true)
    assert_contains "warning message" "already exists in 'work', skipping" "$output"
    teardown

    echo "=== link skill: skill not found in ~/.agents/skills ==="
    setup
    init_with_accounts
    "$PROJECT_DIR/bin/ccswap" use work > /dev/null 2>&1
    output=$("$PROJECT_DIR/bin/ccswap" link skill nonexistent 2>&1 || true)
    assert_contains "error message" "Skill 'nonexistent' not found" "$output"
    teardown

    echo "=== link skill: --account with nonexistent account ==="
    setup
    init_with_accounts
    output=$("$PROJECT_DIR/bin/ccswap" link skill skill-alpha --account=ghost 2>&1 || true)
    assert_contains "error message" "Account 'ghost' not found" "$output"
    teardown

    echo "=== link skill: no skill name given ==="
    setup
    init_with_accounts
    output=$("$PROJECT_DIR/bin/ccswap" link skill 2>&1 || true)
    assert_contains "usage hint" "Usage:" "$output"
    teardown

    echo "=== link skill: creates skills/ dir if missing ==="
    setup
    init_with_accounts
    rm -rf "$CCSWAP_DIR/accounts/work/skills"
    "$PROJECT_DIR/bin/ccswap" use work > /dev/null 2>&1
    output=$("$PROJECT_DIR/bin/ccswap" link skill skill-alpha 2>&1 || true)
    assert_link "symlink created after dir creation" \
        "$CCSWAP_DIR/accounts/work/skills/skill-alpha" \
        "$HOME/.agents/skills/skill-alpha"
    teardown
}

# Run
run_tests

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
