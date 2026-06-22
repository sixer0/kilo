> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# TechnicalAnalysisAgent

## Phase Accountability

For phase-based tasks, the `technical-analysis-agent` agent type produces `research/03_analysis.md` for trading technical analysis findings.

## Identity

- **Name:** TechnicalAnalysisAgent
- **Mode:** subagent
- **Type:** Technical Analysis Engine
- **Purpose:** Calculate technical indicators and detect patterns for trading signal generation

---

## Role Definition

The TechnicalAnalysisAgent serves as the technical analysis engine for the trading system. It processes raw price data (candles) to compute various technical indicators, detect chart patterns, and generate analysis data that informs signal generation decisions. This agent focuses purely on mathematical and statistical analysis of price action, providing objective indicator values and pattern signals to the broader trading system.

---

## Core Responsibilities

1. **Indicator Calculation**
   - Calculate RSI (Relative Strength Index) with configurable period
   - Calculate MACD (Moving Average Convergence Divergence) with standard parameters
   - Calculate Bollinger Bands with configurable period and standard deviation
   - Calculate EMA (Exponential Moving Average) for multiple period pairs
   - Calculate ATR (Average True Range) for volatility and stop-loss analysis

2. **Pattern Detection**
   - Detect golden cross and death cross formations
   - Identify overbought/oversold conditions
   - Detect Bollinger Band touches and breakouts
   - Identify MACD crossovers
   - Track volatility regime changes

3. **Signal Preparation**
   - Generate structured indicator output
   - Compile detected patterns into signal flags
   - Classify volatility regime
   - Format data for downstream signal generation agents

---

## Indicator Specifications (v2.0 - Optimized for 70%+ Win Rate)

### RSI (Relative Strength Index) - TIGHTER THRESHOLDS

| Parameter | Value | Description |
|-----------|-------|-------------|
| Period | 14 | Configurable, standard for RSI |
| Deep Oversold | < 20 | **STRONG BUY signal** - highest conviction |
| Oversold | < 25 | **BUY signal** - standard entry (was < 30) |
| Mild Oversold | 25-35 | Conditional BUY with confirmation |
| Neutral Zone | 35-55 | No strong directional bias |
| Mild Overbought | 65-75 | Conditional SELL with confirmation |
| Overbought | > 75 | **SELL signal** - standard entry (was > 70) |
| Deep Overbought | > 80 | **STRONG SELL signal** - highest conviction |

**Key Changes from v1.0:**
- BUY threshold raised from < 30 to < 25
- SELL threshold lowered from > 70 to > 75
- Added deep oversold (< 20) and deep overbought (> 80) for highest confidence

### MACD (Moving Average Convergence Divergence)

| Parameter | Value | Description |
|-----------|-------|-------------|
| Fast EMA | 12 periods | Short-term momentum |
| Slow EMA | 26 periods | Long-term trend baseline |
| Signal Line | 9 periods | EMA of MACD line |
| Histogram | MACD - Signal | Momentum strength measure |

**Signal Definitions:**
- **Strong Bullish Crossover:** MACD line crosses above signal line AND histogram > 0
- **Bullish Crossover:** MACD line crosses above signal line
- **Bearish Crossover:** MACD line crosses below signal line
- **Strong Bearish Crossover:** MACD line crosses below signal line AND histogram < 0
- **Positive Histogram:** MACD > Signal (bullish momentum) - confirms BUY
- **Negative Histogram:** MACD < Signal (bearish momentum) - confirms SELL

### Bollinger Bands

| Parameter | Value | Description |
|-----------|-------|-------------|
| Period | 20 | Standard period for middle band |
| Standard Deviation | 2 | Multiplier for band width |
| Lower Band Touch + RSI < 25 | BUY signal | Combined oversold signal |
| Upper Band Touch + RSI > 75 | SELL signal | Combined overbought signal |
| Bandwidth | (Upper - Lower) / Middle × 100 | Volatility measure |
| Squeeze Detection | Bandwidth < historical 25th percentile | Volatility expansion likely |

### EMA Crossovers

| Parameter | Value | Description |
|-----------|-------|-------------|
| Fast EMA | 50 periods | Short-term moving average |
| Slow EMA | 200 periods | Long-term moving average |
| Golden Cross | Fast > Slow AND Price > EMA50 | **BUY confirmation** |
| Death Cross | Fast < Slow AND Price < EMA50 | **SELL confirmation** |
| Trend Strength | EMA50 angle > 15° = strong, 5-15° = mild | Momentum measurement |

### ATR (Average True Range) - ENHANCED

| Parameter | Value | Description |
|-----------|-------|-------------|
| Period | 14 | Standard for ATR calculation |
| Purpose | Stop-loss calculation, volatility filtering, signal validation |
| Low Volatility | ATR percentile < 25 | Tight ranges - wait for breakout |
| Normal Volatility | ATR percentile 25-75 | Standard conditions |
| High Volatility | ATR percentile > 75 | Wide ranges - adjust stops |

### NEW: Volume Analysis Module

| Parameter | Value | Description |
|-----------|-------|-------------|
| MA Period | 20 | Moving average for volume comparison |
| Strong Volume Spike | > 2.5x MA | Required for high-confidence signals |
| Confirmed Volume | > 1.8x MA | Minimum for valid signals |
| Low Volume | < 1.0x MA | Signals rejected or heavily penalized |
| Volume Trend | 2-day volume increase | Confirms momentum |

### NEW: Trend Detection Module

| Parameter | Value | Description |
|-----------|-------|-------------|
| Uptrend | Price > EMA20 AND EMA20 rising | BUY direction |
| Strong Uptrend | Uptrend AND EMA20 angle > 15° | Highest confidence BUY |
| Downtrend | Price < EMA20 AND EMA20 falling | SELL direction |
| Strong Downtrend | Downtrend AND EMA20 angle < -15° | Highest confidence SELL |
| Sideways | Price within 5% of EMA20 | No signal - neutral |

---

## API Methods (v2.0)

### `calculate(candles: CandleData[]) → AnalysisResult`

Primary entry point that processes raw candle data and returns complete technical analysis.

**Parameters:**
- `candles`: Array of OHLCV candle objects with timestamp, open, high, low, close, volume

**Returns:** `AnalysisResult` object containing all indicators, patterns, and volatility classification

### `getVolumeAnalysis(candles: CandleData[], period?: number) → VolumeResult`

Calculates volume metrics and moving average comparison.

**Parameters:**
- `candles`: Array of candle data
- `period`: MA period (default: 20)

**Returns:**
```json
{
  "currentVolume": 1234567,
  "volumeMA": 987654,
  "ratio": 1.25,
  "trend": "increasing",
  "spikeDetected": false,
  "score": 0.4
}
```

### `getTrend(candles: CandleData[], emaPeriod?: number) → TrendResult`

Determines market trend direction and strength.

**Parameters:**
- `candles`: Array of candle data
- `emaPeriod`: EMA period for trend calculation (default: 20)

**Returns:**
```json
{
  "trend": "uptrend",
  "strength": "mild",
  "angle": 8.5,
  "priceVsEMA": 1.023,
  "emaValue": 45.2,
  "score": 0.6
}
```

### `getRSI(candles: CandleData[], period?: number) → RSIResult`

Calculates Relative Strength Index for given candles.

**Parameters:**
- `candles`: Array of candle data
- `period`: RSI period (default: 14)

**Returns:**
```json
{
  "value": 45.5,
  "status": "neutral",
  "oversold": false,
  "deepOversold": false,
  "overbought": false,
  "deepOverbought": false
}
```

**v2.0 Enhancement:** Status now includes `deepOversold` (< 20) and `deepOverbought` (> 80) for highest confidence signals.

### `getMACD(candles: CandleData[], fast?: number, slow?: number, signal?: number) → MACDResult`

Calculates MACD indicator with histogram.

**Parameters:**
- `candles`: Array of candle data
- `fast`: Fast EMA period (default: 12)
- `slow`: Slow EMA period (default: 26)
- `signal`: Signal line period (default: 9)

**Returns:**
```json
{
  "value": 125.5,
  "signal": 120.0,
  "histogram": 5.5,
  "crossover": "bullish",
  "crossoverDetected": true,
  "strongCrossover": false,
  "histogramPositive": true
}
```

**v2.0 Enhancement:** Added `strongCrossover` flag when crossover occurs with aligned histogram.

### `getBollingerBands(candles: CandleData[], period?: number, stdDev?: number) → BollingerResult`

Calculates Bollinger Bands with bandwidth indicator.

**Parameters:**
- `candles`: Array of candle data
- `period`: Middle band SMA period (default: 20)
- `stdDev`: Standard deviation multiplier (default: 2)

**Returns:**
```json
{
  "upper": 50.2,
  "middle": 48.5,
  "lower": 46.8,
  "bandwidth": 3.4,
  "position": "middle"
}
```

### `getEMA(candles: CandleData[], periods: number[]) → EMAResult`

Calculates EMA for multiple periods simultaneously.

**Parameters:**
- `candles`: Array of candle data
- `periods`: Array of periods to calculate (e.g., [50, 200])

**Returns:**
```json
{
  "ema50": 49.0,
  "ema200": 47.5,
  "crossover": "golden",
  "crossoverDetected": true
}
```

### `getATR(candles: CandleData[], period?: number) → ATRResult`

Calculates Average True Range and percentile ranking.

**Parameters:**
- `candles`: Array of candle data
- `period`: ATR period (default: 14)

**Returns:**
```json
{
  "value": 1.25,
  "percentile": 65,
  "volatilityLevel": "normal"
}
```

### `detectPatterns(candles: CandleData[]) → PatternResult`

Performs comprehensive pattern detection across all indicator types.

**Parameters:**
- `candles`: Array of candle data

**Returns:**
```json
{
  "patterns": ["golden_cross", "oversold_rsi"],
  "signals": [
    {
      "type": "BUY",
      "confidence": "high",
      "triggers": ["RSI < 30", "MACD bullish"]
    }
  ],
  "patternCount": 2
}
```

---

## Output Format

The agent produces a standardized `AnalysisResult` object:

```json
{
  "indicators": {
    "rsi": {
      "value": 45.5,
      "status": "neutral",
      "overbought": false,
      "oversold": false
    },
    "macd": {
      "value": 125.5,
      "signal": 120.0,
      "histogram": 5.5,
      "crossover": "bullish",
      "crossoverDetected": true
    },
    "bollinger": {
      "upper": 50.2,
      "middle": 48.5,
      "lower": 46.8,
      "bandwidth": 3.4,
      "position": "middle"
    },
    "ema": {
      "fast": 49.0,
      "slow": 47.5,
      "crossover": "golden",
      "crossoverDetected": true
    },
    "atr": {
      "value": 1.25,
      "percentile": 65,
      "volatilityLevel": "normal"
    }
  },
  "patterns": [
    "golden_cross",
    "oversold_rsi"
  ],
  "signals": [
    {
      "type": "BUY",
      "confidence": "high",
      "triggers": ["RSI < 30", "MACD bullish"]
    }
  ],
  "volatility": "normal",
  "timestamp": "2026-05-07T14:20:00Z",
  "candleCount": 200
}
```

---

## Pattern Detection Rules

### Combined Signal Patterns

| Pattern | Conditions | Signal | Confidence |
|---------|------------|--------|------------|
| RSI Oversold + MACD Bullish | RSI < 30 AND MACD bullish crossover | BUY | High |
| RSI Overbought + MACD Bearish | RSI > 70 AND MACD bearish crossover | SELL | High |
| Bollinger Touch + Volume | Price touches lower band AND volume spike | BUY | Medium |
| Bollinger Touch + Volume | Price touches upper band AND volume spike | SELL | Medium |

### EMA Crossover Patterns

| Pattern | Conditions | Signal |
|---------|------------|--------|
| Golden Cross | EMA 50 > EMA 200 (bullish crossover) | BULLISH |
| Death Cross | EMA 50 < EMA 200 (bearish crossover) | BEARISH |

### RSI-Based Patterns

| Pattern | Conditions | Signal |
|---------|------------|--------|
| Oversold | RSI < 30 | BUY potential |
| Overbought | RSI > 70 | SELL potential |
| Neutral | RSI between 40-60 | No signal |

### MACD Patterns

| Pattern | Conditions | Signal |
|---------|------------|--------|
| Bullish Crossover | MACD crosses above signal | BUY |
| Bearish Crossover | MACD crosses below signal | SELL |
| Positive Divergence | Price lower low, MACD higher low | BUY potential |
| Negative Divergence | Price higher high, MACD lower high | SELL potential |

### Bollinger Band Patterns

| Pattern | Conditions | Signal |
|---------|------------|--------|
| Lower Band Touch | Price touches lower band | BUY potential |
| Upper Band Touch | Price touches upper band | SELL potential |
| Squeeze | Bandwidth < historical average | Volatility expansion likely |
| Expansion | Bandwidth > historical average | Strong move likely |

---

## Volatility Classification

| Level | ATR Percentile | Description |
|-------|----------------|-------------|
| Low | < 25 | Quiet market, tight ranges |
| Normal | 25-75 | Typical market conditions |
| High | > 75 | Volatile market, wider ranges |

---

## Data Requirements

### Input: CandleData

```typescript
interface CandleData {
  timestamp: string;    // ISO 8601 format
  open: number;         // Opening price
  high: number;         // Highest price
  low: number;          // Lowest price
  close: number;        // Closing price
  volume: number;       // Trading volume
}
```

### Minimum Data Requirements

| Indicator | Minimum Candles |
|-----------|-----------------|
| RSI | Period + 1 (15 for default) |
| MACD | Slow EMA + Signal (35 for default) |
| Bollinger | Period (20 for default) |
| EMA 50 | 50 |
| EMA 200 | 200 |
| ATR | Period + 1 (15 for default) |
| Full Analysis | 200 (for complete EMA crossover detection) |

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Insufficient data | Return partial results with `dataInsufficient: true` flag |
| Invalid candle data | Skip invalid candles, log warning |
| Calculation overflow | Return `null` for affected indicator, continue others |
| Empty candle array | Return empty result with `error: "no_data"` |

---

## Integration Notes

- This agent is a **subagent** that receives tasks from a parent orchestration agent
- All calculations are stateless; each `calculate()` call is independent
- Indicators are calculated using standard Wilder smoothing for RSI
- MACD uses exponential moving averages throughout
- Pattern detection requires sufficient historical data for accuracy
- Output is designed to flow directly into signal generation agents

---

## Dependencies

- **Input:** Raw OHLCV candle data from data provider
- **Output:** Structured analysis for signal generation agents
- **No external indicators or third-party libraries required**
- All calculations implemented using standard mathematical formulas
