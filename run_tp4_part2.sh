#!/bin/bash
# Partie 3 (correction G6) et Partie 6 (push GitHub)
cd "$(dirname "$0")"
source .venv/bin/activate
OUT=captures_cr
step() { local f="$OUT/$1.txt"; shift; echo ""; echo "================ $* ================"
  { echo "(.venv) $(whoami)@$(hostname -s) mlops-tp4-cictcd % $*"; "$@" 2>&1; echo "[code retour : $?]"; } | tee "$f"; }

pip install -q -r requirements.txt
step 10_pip_audit_apres_correction pip-audit
step 11_pytest_apres_correction env PYTHONPATH=. pytest tests/ -q
git add .
git commit -q -m "feat: add mlops quality pipeline"
step 12_git_push git push origin main
echo ""; echo "TERMINE (partie 2)."
