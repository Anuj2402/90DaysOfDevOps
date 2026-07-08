#!/bin/bash
# Verification script for 90DaysOfDevOps repo credentials
# Run this anytime before committing or switching accounts

echo "========================================="
echo "90DaysOfDevOps Repository Verification"
echo "========================================="
echo ""

CORRECT_EMAIL="anujkumarrai007@outlook.com"
CORRECT_NAME="ANUJ KUMAR RAI"
CORRECT_ACCOUNT="Anuj2402"

echo "📋 Checking Configuration..."
echo ""

# Check local git config
LOCAL_EMAIL=$(cd /Users/anujrai/90DaysOfDevOps && git config --local user.email)
LOCAL_NAME=$(cd /Users/anujrai/90DaysOfDevOps && git config --local user.name)

echo "Local Git Config (Repository Level):"
echo "  Name: $LOCAL_NAME"
echo "  Email: $LOCAL_EMAIL"

if [ "$LOCAL_NAME" = "$CORRECT_NAME" ] && [ "$LOCAL_EMAIL" = "$CORRECT_EMAIL" ]; then
    echo "  ✅ CORRECT"
else
    echo "  ❌ WRONG - Run: cd /Users/anujrai/90DaysOfDevOps && git config user.name 'ANUJ KUMAR RAI' && git config user.email 'anujkumarrai007@outlook.com'"
fi

echo ""

# Check GitHub auth
echo "GitHub Authentication Status:"
AUTH_STATUS=$(gh auth status 2>&1 | grep "Anuj2402")
if echo "$AUTH_STATUS" | grep -q "true"; then
    echo "  ✅ Active: $CORRECT_ACCOUNT"
elif echo "$AUTH_STATUS" | grep -q "Anuj2402"; then
    echo "  ⚠️ Available but not active: $CORRECT_ACCOUNT"
    echo "     Run: gh auth switch → Select Anuj2402"
else
    echo "  ❌ Not authenticated as $CORRECT_ACCOUNT"
    echo "     Run: gh auth login → Choose GitHub.com"
fi

echo ""

# Check recent commits
echo "Recent Commits Email Check:"
RECENT_EMAIL=$(cd /Users/anujrai/90DaysOfDevOps && git log -1 --pretty=format:"%ae")
echo "  Last commit email: $RECENT_EMAIL"
if [ "$RECENT_EMAIL" = "$CORRECT_EMAIL" ]; then
    echo "  ✅ CORRECT"
else
    echo "  ❌ WRONG"
fi

echo ""

# Check all commits
echo "All Commits Status:"
ALL_EMAILS=$(cd /Users/anujrai/90DaysOfDevOps && git log --all --pretty=format:"%ae" | sort | uniq -c)
echo "$ALL_EMAILS" | while read count email; do
    if [ "$email" = "$CORRECT_EMAIL" ]; then
        echo "  ✅ $count commits with correct email"
    else
        echo "  ❌ $count commits with WRONG email: $email"
    fi
done

echo ""
echo "========================================="
echo "🔧 Quick Fix Commands:"
echo "========================================="
echo ""
echo "If config is wrong, run:"
echo "  cd /Users/anujrai/90DaysOfDevOps"
echo "  git config user.name 'ANUJ KUMAR RAI'"
echo "  git config user.email 'anujkumarrai007@outlook.com'"
echo ""
echo "If GitHub auth is wrong, run:"
echo "  gh auth switch"
echo "  # Select: Anuj2402"
echo ""
echo "========================================="
