#!/usr/bin/env python3
"""Analyze MT5 trade exports.

Expected CSV columns:
    time_open,time_close,symbol,side,volume,entry_price,exit_price,
    commission,swap,profit[,sl_price|sl_pips][,mfe,mae|high,low]

Example:
    python scripts/analyze_trades.py --csv sample_data/trades_sample.csv \
        --out docs/reports/summary.md
"""
from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd

REQUIRED_COLS = [
    "time_open",
    "time_close",
    "symbol",
    "side",
    "volume",
    "entry_price",
    "exit_price",
    "commission",
    "swap",
    "profit",
]

def compute_metrics(df: pd.DataFrame) -> dict[str, float | str]:
    metrics: dict[str, float | str] = {}
    metrics["total_trades"] = len(df)
    wins = df[df["profit"] > 0]["profit"]
    losses = df[df["profit"] <= 0]["profit"]
    metrics["win_rate"] = (len(wins) / len(df) * 100) if len(df) else 0
    metrics["expectancy"] = df["profit"].mean() if len(df) else 0
    metrics["avg_win"] = wins.mean() if len(wins) else 0
    metrics["avg_loss"] = losses.mean() if len(losses) else 0
    metrics["profit_factor"] = (
        wins.sum() / abs(losses.sum()) if losses.sum() != 0 else float("inf")
    )

    metrics["avg_R"] = "n/a"
    if "sl_pips" in df.columns or "sl_price" in df.columns:
        if "sl_pips" in df.columns:
            risk = df["sl_pips"].abs()
        else:
            risk = (df["entry_price"] - df["sl_price"]).abs()
        risk = risk.replace(0, pd.NA).dropna()
        if not risk.empty:
            metrics["avg_R"] = (df.loc[risk.index, "profit"] / risk).mean()

    metrics["avg_mfe"] = "n/a"
    metrics["avg_mae"] = "n/a"
    if {"mfe", "mae"}.issubset(df.columns):
        metrics["avg_mfe"] = df["mfe"].mean()
        metrics["avg_mae"] = df["mae"].mean()
    elif {"high", "low"}.issubset(df.columns):
        metrics["avg_mfe"] = (df["high"] - df["entry_price"]).mean()
        metrics["avg_mae"] = (df["low"] - df["entry_price"]).mean()

    df["time_open"] = pd.to_datetime(df["time_open"])
    df["time_close"] = pd.to_datetime(df["time_close"])
    metrics["avg_time_in_trade"] = (
        (df["time_close"] - df["time_open"]).mean().total_seconds()
    )

    return metrics

def main() -> None:
    parser = argparse.ArgumentParser(description="Analyze trades from MT5 CSV")
    parser.add_argument("--csv", type=Path, required=True, help="Path to trades CSV")
    parser.add_argument("--out", type=Path, help="Write summary Markdown here")
    args = parser.parse_args()

    df = pd.read_csv(args.csv)
    missing = [c for c in REQUIRED_COLS if c not in df.columns]
    if missing:
        raise SystemExit(f"Missing required columns: {', '.join(missing)}")

    metrics = compute_metrics(df)

    lines = [
        f"total_trades: {metrics['total_trades']}",
        f"win_rate: {metrics['win_rate']:.2f}",
        f"expectancy: {metrics['expectancy']:.2f}",
        f"avg_win: {metrics['avg_win']:.2f}",
        f"avg_loss: {metrics['avg_loss']:.2f}",
        f"profit_factor: {metrics['profit_factor']:.2f}",
        (
            "avg_R: n/a"
            if isinstance(metrics["avg_R"], str)
            else f"avg_R: {metrics['avg_R']:.2f}"
        ),
        (
            "avg_mfe: n/a"
            if isinstance(metrics["avg_mfe"], str)
            else f"avg_mfe: {metrics['avg_mfe']:.2f}"
        ),
        (
            "avg_mae: n/a"
            if isinstance(metrics["avg_mae"], str)
            else f"avg_mae: {metrics['avg_mae']:.2f}"
        ),
        f"avg_time_in_trade: {metrics['avg_time_in_trade']:.2f} seconds",
    ]

    print("\n".join(lines))

    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        with args.out.open("w", encoding="utf-8") as fh:
            fh.write("# Trade Analysis Summary\n\n")
            for line in lines:
                fh.write(f"- {line}\n")
        print(f"Wrote summary to {args.out}")


if __name__ == "__main__":
    main()
