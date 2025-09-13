# Gold_TickMomentum_EA

This repository contains the Gold Tick Momentum Expert Advisor and utilities.

## Analysis workflow
1. In MT5, open the **History** tab and save deals to CSV.
2. Analyze trades:
   ```bash
   python scripts/analyze_trades.py --csv sample_data/trades_sample.csv \
       --out docs/reports/summary.md
   ```
3. Plot tick deltas:
   ```bash
   python scripts/plot_delta.py --csv path/to/delta.csv \
       --out docs/reports/delta.png
   ```
Outputs are written under `docs/reports/`.

## Acceptance notes
- `python scripts/analyze_trades.py --help` works
- Example commands run locally
- CI passes
