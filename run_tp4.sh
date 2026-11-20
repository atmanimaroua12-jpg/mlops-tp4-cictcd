#!/bin/bash
# Execute les Parties 3 a 6 du TP4 et enregistre chaque sortie dans captures_cr/
cd "$(dirname "$0")"
source .venv/bin/activate
export PYTHONPATH=.
export MLFLOW_TRACKING_URI=http://127.0.0.1:5000
export MLFLOW_DISABLE_AGENT_HINT=1
OUT=captures_cr
mkdir -p "$OUT"

step() {  # step <fichier> <commande...>
  local f="$OUT/$1.txt"; shift
  echo ""; echo "================ $* ================"
  { echo "(.venv) $(whoami)@$(hostname -s) mlops-tp4-cictcd % $*"; "$@" 2>&1; echo "[code retour : $?]"; } | tee "$f"
}

# ---------- Partie 2/3 : tests, lint, securite ----------
step 01_pytest pytest tests/ -v --cov=src --cov-report=term-missing
step 02_ruff ruff check .
step 03_bandit bandit -r src
step 04_pip_audit pip-audit

# ---------- Partie 4 : serveur MLflow ----------
code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5000/health)
if [ "$code" != "200" ] && [ "$code" != "000" ]; then
  echo "!!! Le port 5000 est pris par autre chose (souvent le Recepteur AirPlay de macOS)."
  echo "!!! Desactive-le : Reglages Systeme > General > AirDrop et Handoff > Recepteur AirPlay, puis relance ./run_tp4.sh"
  exit 1
fi
if [ "$code" = "000" ]; then
  echo "Demarrage du serveur MLflow (log : $OUT/mlflow_server.log)..."
  nohup mlflow server --host 127.0.0.1 --port 5000 > "$OUT/mlflow_server.log" 2>&1 &
  for i in $(seq 1 60); do curl -s http://127.0.0.1:5000/health >/dev/null && break; sleep 2; done
fi
curl -s http://127.0.0.1:5000/health >/dev/null || { echo "MLflow ne demarre pas, voir $OUT/mlflow_server.log"; exit 1; }
echo "Serveur MLflow OK sur http://127.0.0.1:5000"

# ---------- Partie 4 et 5 : registre et promotion ----------
step 05_train_register_v1 python train_and_register.py
step 06_promote_sans_approbation python promote.py
step 07_promote_approve python promote.py --approve
step 08_train_register_v2 python train_and_register.py
step 09_promote_v2_non_regression python promote.py --approve

echo ""
echo "TERMINE. Les sorties sont dans $OUT/. Le serveur MLflow reste ouvert sur http://127.0.0.1:5000"
