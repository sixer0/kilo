# Signal Analysis Report
Generated: 2026-05-07 18:16

## Summary
- Total signal samples analyzed: 2765
- Win samples: 285
- Loss samples: 2480

## Key Findings

### RSI Thresholds
Best RSI zones for BUY signals:
- RSI < 30 (Very Oversold): Higher win rate
- RSI < 40 (Oversold): Moderate win rate

### Volume Requirements
- Volume spike > 1.3x average: Better win rate
- Volume spike > 1.5x: Even better

### Trend Alignment
- BULL trend (EMA50 > EMA200): Better for BUY signals
- Avoid BEAR trend for BUY signals

### Momentum
- Slight positive momentum (0-3%): Better win rate
- Negative momentum reduces win rate

## Recommended Signal Generation Rules

### For BUY Signals (High Win Rate):
1. RSI < 35 (oversold)
2. Volume ratio > 1.3x average
3. EMA50 > EMA200 (bullish trend) OR neutral
4. Momentum 3-day > 0% (price rising)
5. Bollinger position < 0 (price below middle)

### For SELL Signals:
Apply mirror logic for overbought conditions

## Optimal Parameters
- RSI Buy Threshold: 35 (not 45)
- RSI Sell Threshold: 65 (not 55)
- Volume Minimum: 1.3x
- Trend Requirement: Neutral or better
- Momentum Filter: Positive

---
End of Analysis
