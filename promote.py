import argparse

from mlflow import MlflowClient
from mlflow.exceptions import MlflowException

from src.data import load_params

parser = argparse.ArgumentParser()
parser.add_argument(
    "--approve",
    action="store_true",
    help="Simule l'approbation humaine avant champion",
)
args = parser.parse_args()

params = load_params()
model_name = params["training"]["model_name"]
delta = params["quality_gate"]["max_regression"]

client = MlflowClient(tracking_uri="http://127.0.0.1:5000")
candidate = client.get_model_version_by_alias(model_name, "candidate")

status = candidate.tags.get("validation_status")

if status != "passed":
    raise RuntimeError("La version candidate n'a pas passe les Quality Gates.")

print(f"Candidate : version {candidate.version}")
print(f"validation_status = {status}")

# Regle de non-regression : F1_candidate >= F1_baseline - delta
cand_f1 = client.get_run(candidate.run_id).data.metrics["f1"]
try:
    champion = client.get_model_version_by_alias(model_name, "champion")
except MlflowException:
    champion = None

if champion is None:
    print("Pas encore de champion : pas de baseline a comparer.")
elif champion.version == candidate.version:
    print(f"La version {candidate.version} est deja champion.")
else:
    base_f1 = client.get_run(champion.run_id).data.metrics["f1"]
    if cand_f1 < base_f1 - delta:
        raise RuntimeError(
            f"Regression : F1 candidate {cand_f1:.3f} < "
            f"F1 champion {base_f1:.3f} - {delta}"
        )
    print(
        f"Non-regression OK : F1 candidate {cand_f1:.3f} >= "
        f"{base_f1:.3f} - {delta} (champion v{champion.version})"
    )

if not args.approve:
    print("Aucune approbation : le modele reste candidate.")
    raise SystemExit(0)

client.set_registered_model_alias(model_name, "champion", candidate.version)
client.set_model_version_tag(
    model_name, candidate.version, "approval_status", "approved"
)

print(f"champion -> version {candidate.version}")
