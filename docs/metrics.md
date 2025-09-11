# Metrics

## Trade metrics
- **total_trades** – number of rows in the trade CSV.
- **win_rate** – percentage of trades with positive profit.
- **expectancy** – mean of the `profit` column.
- **avg_win** – average profit of winning trades.
- **avg_loss** – average profit of losing trades.
- **profit_factor** – sum of positive profits divided by absolute sum of negative profits.
- **avg_R** – mean of `profit / abs(SL)` when stop-loss info is available.
- **avg_mfe** – mean of the `mfe` column or high minus entry when provided.
- **avg_mae** – mean of the `mae` column or low minus entry when provided.
- **avg_time_in_trade** – average of `time_close - time_open` in seconds.

## Trade CSV schema
`time_open,time_close,symbol,side,volume,entry_price,exit_price,commission,swap,profit[,sl_price|sl_pips][,mfe,mae|high,low]`

## Delta CSV schema
`time_msc,bid,ask,mid,delta_pips,spread_pips,event_flag`

## Exporting history from MT5
1. In MT5, open the **History** tab.
2. Right‑click and choose **Save as Report**.
3. Save the report, then open it and export the deals table to CSV.
