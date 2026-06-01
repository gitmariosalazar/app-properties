#!/bin/bash

# ==============================================================
# push.sh — Bump de versión + push en un solo paso
# Uso: git pv [remote] [branch]
#      git pv origin develop
# ==============================================================

REPO_ROOT=$(git rev-parse --show-toplevel)
PUBSPEC="$REPO_ROOT/pubspec.yaml"

# Argumentos (por defecto: origin y rama actual)
REMOTE="${1:-origin}"
BRANCH="${2:-$(git rev-parse --abbrev-ref HEAD)}"

# ── 1. Leer versión actual ─────────────────────────────────────
CURRENT=$(grep '^version:' "$PUBSPEC" | sed 's/version: //' | tr -d ' ')
VERSION_NAME=$(echo "$CURRENT" | cut -d'+' -f1)
BUILD=$(echo "$CURRENT" | cut -d'+' -f2)

MAJOR=$(echo "$VERSION_NAME" | cut -d'.' -f1)
MINOR=$(echo "$VERSION_NAME" | cut -d'.' -f2)

NEW_MINOR=$((MINOR + 1))
NEW_BUILD=$((BUILD + 1))
NEW_VERSION="$MAJOR.$NEW_MINOR.0+$NEW_BUILD"

echo ""
echo "🚀 Auto-versionado..."
echo "   Versión anterior: $CURRENT"
echo "   Nueva versión:    $NEW_VERSION"
echo ""

# ── 2. Actualizar pubspec.yaml ─────────────────────────────────
sed -i "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"

# ── 3. Commit del bump ─────────────────────────────────────────
cd "$REPO_ROOT" || exit 1
git add pubspec.yaml
git commit -m "chore: bump version $CURRENT → $NEW_VERSION [skip ci]"

echo "✅ Versión $NEW_VERSION commiteada"
echo ""

# ── 4. Push único (con todos los commits incluyendo el bump) ───
echo "📤 Enviando a $REMOTE/$BRANCH..."
git push "$REMOTE" "$BRANCH"
EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo "🎉 Push completado — versión $NEW_VERSION en GitHub"
else
  echo "❌ Error en el push (código $EXIT_CODE)"
fi
echo ""

exit $EXIT_CODE
