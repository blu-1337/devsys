"""Write a baseline CSV (per case and arm: mean score, runs, mean cost, mean turns) from a `claude plugin eval --json` file.
Usage: python evals/baseline.py evals/last.json evals/baselines/<date>.csv [note]"""
import csv, json, sys
d = json.load(open(sys.argv[1], encoding='utf-8'))
rows = []
for c in d['cases']:
    for arm, runs in c['arms'].items():
        n = len(runs) or 1
        rows.append([c['name'], arm, round(sum(r['score'] for r in runs) / n, 2), len(runs),
                     round(sum(r['costUsd'] for r in runs) / n, 3), round(sum(r['turns'] for r in runs) / n, 1)])
with open(sys.argv[2], 'w', newline='', encoding='utf-8') as f:
    w = csv.writer(f)
    w.writerow(['case', 'arm', 'mean_score', 'runs', 'mean_cost_usd', 'mean_turns'])
    w.writerows(rows)
    w.writerow([])
    w.writerow(['# claude', d.get('claudeVersion'), 'aggregates', json.dumps(d['aggregates']), 'total_cost', round(d.get('costUsd') or 0, 3)] + sys.argv[3:])
print(open(sys.argv[2], encoding='utf-8').read())
