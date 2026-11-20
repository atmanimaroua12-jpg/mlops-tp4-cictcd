# Sentiment Model

## Use case
Classification binaire de sentiment (avis clients en francais : 1 = positif, 0 = negatif).

## Version
sentiment-model version 2 (MLflow Model Registry), alias `champion`.
Version 1 : premiere version promue champion, remplacee par la version 2 apres controle de non-regression.

## Dataset
reviews.csv -- jeu pedagogique de 20 avis (10 positifs, 10 negatifs).
Decoupage stratifie : 75 % entrainement / 25 % test (random_state = 42).

## Method
TF-IDF + Logistic Regression (Pipeline scikit-learn).

## Parameters
C = 10.0
max_features = 5000
ngram_range = [1, 1]
max_iter = 1000

## Metrics
Accuracy = 0.60
F1 = 0.50

## Quality Gates
Unit tests = passed (3/3)
Data tests = passed (4/4)
Model tests = passed (2/2, accuracy >= 0.60 et F1 >= 0.50)
Coverage = 100 % (seuil 70 %)
Security checks = Bandit : aucun probleme ; pip-audit : vulnerabilite detectee sur pytest 8.4.2 (PYSEC-2026-1845), corrigee en passant a pytest >= 9.0.3
Non-regression = passed (F1 candidate 0.50 >= F1 champion 0.50 - 0.05)

## Known limitations
- Petit jeu de donnees pedagogique.
- Langue principalement francaise.
- Evaluation non representative d'un contexte industriel (5 exemples de test seulement).
- Metriques exactement au niveau des seuils : resultat fragile.

## Governance
validation_status = passed
approval_status = approved
alias = candidate / champion (version 2)

## Deployment decision
Version 2 acceptee : toutes les Quality Gates passent, pas de regression par rapport au champion precedent, approbation humaine donnee (promote.py --approve).
Deploiement simule en staging puis en production via GitHub Actions.
A reevaluer avec un jeu de donnees plus grand avant tout usage reel.
