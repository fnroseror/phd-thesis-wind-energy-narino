#!/usr/bin/env python3
from pathlib import Path
import csv, hashlib, sys
root=Path(__file__).resolve().parent
errors=[]

def rows(path):
    with path.open(encoding="utf-8",newline="") as f: return list(csv.DictReader(f))
figs=rows(root/"00_CANONICAL_INDEX/figures_index.csv")
tabs=rows(root/"00_CANONICAL_INDEX/tables_index.csv")
if len(figs)!=31: errors.append(f"Expected 31 figures, found {len(figs)}")
if len(tabs)!=25: errors.append(f"Expected 25 tables, found {len(tabs)}")
if len({r['figure_id'] for r in figs})!=31: errors.append("Duplicate figure IDs")
if len({r['table_id'] for r in tabs})!=25: errors.append("Duplicate table IDs")
for r in figs:
    if not (root/r['evidence_file']).is_file(): errors.append(f"Missing figure evidence: {r['figure_id']}")
for r in tabs:
    for rel in r['evidence_files'].split(' | '):
        if not (root/rel).is_file(): errors.append(f"Missing table evidence: {r['table_id']} -> {rel}")
manifest=root/'_manifest_sha256.csv'
if manifest.exists():
    for r in rows(manifest):
        p=root/r['relative_path']
        if not p.is_file(): errors.append(f"Manifest missing file: {r['relative_path']}")
        elif hashlib.sha256(p.read_bytes()).hexdigest()!=r['sha256']: errors.append(f"Hash mismatch: {r['relative_path']}")
for p in root.rglob('*'):
    if p.is_file() and p.stat().st_size>100*1024*1024: errors.append(f"File exceeds 100 MiB: {p.relative_to(root)}")
if errors:
    print('RESULTS VALIDATION FAILED')
    for e in errors: print('-',e)
    sys.exit(1)
print('RESULTS VALIDATION PASSED')
print(f'Figures: {len(figs)}/31')
print(f'Tables: {len(tabs)}/25')
