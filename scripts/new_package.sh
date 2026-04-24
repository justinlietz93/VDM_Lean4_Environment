#!/usr/bin/env bash
# new_package.sh -- scaffold a new VDM Lean package from the template.
#
# Usage:
#   scripts/new_package.sh MyNewPackage
#
# Creates packages/MyNewPackage/ with a renamed copy of _template, wires
# the module name and namespace, and commits a buildable skeleton. The
# next `git push` to main will make CI pick it up automatically.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <PackageName>"
  echo "  PackageName must be CamelCase and valid as a Lean module name."
  exit 1
fi

NAME="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/packages/_template"
DST="$ROOT/packages/$NAME"

if [[ -e "$DST" ]]; then
  echo "error: $DST already exists" >&2
  exit 1
fi

cp -r "$SRC" "$DST"

# Rename the module folder and the entry .lean file.
mv "$DST/TemplatePackage"        "$DST/$NAME"
mv "$DST/TemplatePackage.lean"   "$DST/$NAME.lean"

# Compute a conventional Lake package slug: snake_case of NAME.
SLUG=$(echo "$NAME" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]')

# Substitute identifiers.
#   - TemplatePackage     -> $NAME
#   - template_package    -> $SLUG
for f in "$DST/lakefile.toml" "$DST/$NAME.lean" "$DST/$NAME/Basic.lean"; do
  sed -i.bak "s/TemplatePackage/${NAME}/g; s/template_package/${SLUG}/g" "$f"
  rm -f "$f.bak"
done

echo "Scaffolded packages/$NAME/"
echo "  lake package slug:  $SLUG"
echo "  Lean module prefix: $NAME"
echo ""
echo "Next steps:"
echo "  1. Edit packages/$NAME/$NAME/Basic.lean with your theorems."
echo "  2. Optionally add more .lean files under packages/$NAME/$NAME/."
echo "  3. git add packages/$NAME && git commit && git push."
echo "  4. CI will build it automatically and publish a badge."
