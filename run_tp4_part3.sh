#!/bin/bash
# Correction du pipeline CI (setuptools du runner vulnerable) et nouveau push
cd "$(dirname "$0")"
OUT=captures_cr
git add .
git commit -q -m "fix(ci): upgrade setuptools before pip-audit"
{ echo "% git push origin main"; git push origin main 2>&1; echo "[code retour : $?]"; } | tee "$OUT/13_git_push_fix.txt"
echo ""; echo "TERMINE (partie 3)."
