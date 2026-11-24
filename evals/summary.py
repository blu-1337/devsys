"""Print a compact summary of a `claude plugin eval --json` result file."""
import json, sys
d = json.load(open(sys.argv[1] if len(sys.argv) > 1 else 'evals/last.json', encoding='utf-8'))
print('aggregates:', d['aggregates'], 'cost:', round(d.get('costUsd') or 0, 3))
for c in d['cases']:
    for arm, runs in c['arms'].items():
        for r in runs:
            gs = ' '.join(f"{g['name']}={'P' if g['passed'] else 'F'}{'' if g.get('scored', True) else '(ind)'}" for g in r['graders'])
            print(f"{c.get('name', '?'):28} {arm:7} score={r['score']:.2f} turns={r['turns']} ${r['costUsd']:.3f} {gs} {r.get('error') or ''}")
            if len(sys.argv) > 2:
                for g in r['graders']:
                    if g.get('evidence'): print('   evidence:', g['evidence'][:600].replace('\n', ' ')); break
