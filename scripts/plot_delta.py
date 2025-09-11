#!/usr/bin/env python3
"""Plot delta pips from EA logs.

Expected CSV columns:
    time_msc,bid,ask,mid,delta_pips,spread_pips,event_flag

Example:
    python scripts/plot_delta.py --csv backtests/delta_sample.csv \
        --out docs/reports/delta.png
"""
from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd

REQUIRED_COLS = [
    "time_msc",
    "bid",
    "ask",
    "mid",
    "delta_pips",
    "spread_pips",
    "event_flag",
]

def main() -> None:
    parser = argparse.ArgumentParser(description="Plot delta pips over time")
    parser.add_argument("--csv", type=Path, required=True, help="Path to delta CSV")
    parser.add_argument(
        "--out",
        type=Path,
        default=Path("docs/reports/delta.png"),
        help="Path to output PNG",
    )
    args = parser.parse_args()

    df = pd.read_csv(args.csv)
    missing = [c for c in REQUIRED_COLS if c not in df.columns]
    if missing:
        raise SystemExit(f"Missing required columns: {', '.join(missing)}")

    df["time_msc"] = pd.to_datetime(df["time_msc"], unit="ms")
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(df["time_msc"], df["delta_pips"], label="delta_pips")
    ax.set_xlabel("Time")
    ax.set_ylabel("Delta (pips)")
    ax.grid(True)
    fig.autofmt_xdate()

    args.out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.out)
    print(args.out)

if __name__ == "__main__":
    main()
