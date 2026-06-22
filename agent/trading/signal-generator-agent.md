---
name: signal-generator-agent
description: Trade signal generation engine combining technical indicators into actionable buy/sell/hold signals with confidence scoring
hidden: false
mode: subagent
platform: Bybit
dependsOn:
  - market-data-agent
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# SignalGeneratorAgent

Trade signal generation engine for trading systems. Combines multiple technical indicators into actionable signals with confidence scoring, generates entry points, and filters low-quality signals.

## Phase Accountability

For phase-based tasks, the `signal-generator-agent` agent type produces `implementation/99_signal_report.md` for trade signal analysis and buy/sell/hold recommendations.

## Platform

**Exchange:** Bybit
**Parent Dependency:** MarketDataAgent

---

## Core Responsibilities

1. **Signal Generation**
   - Combine technical indicators into actionable buy/sell/hold signals
   - Generate entry points with precise timing
   - Calculate signal confidence scores (0-1)

2. **Indicator Combination**
   - Integrate RSI, MACD, Bollinger Bands, EMA crossovers
   - Weight indicators by reliability and market conditions
   - Require multiple confirmations for high-confidence signals

3. **Confidence Scoring**
   - Calculate base confidence from weighted indicator average
   - Apply adjustments for confirmations, volume, trend alignment
   - Clamp final confidence to [0, 1] range

4. **Signal Quality Filtering**
   - Reject signals below minimum confidence threshold (0.65)
   - Resolve conflicting signals through HOLD default
   - Require at least 2 confirmations for high-confidence trades

5. **Multi-Timeframe Analysis**
   - Analyze 4H for trend direction
   - Use 1H for entry timing
   - Confirm with 15M timeframe
   - Only trade in direction of higher timeframe trend

6. **Reason Code Generation**
   - Provide detailed explanations for each signal
   - List supporting indicators and their states
   - Track decision factors for audit trail

---

## Signal Types

| Signal | Direction | Description |
|--------|-----------|-------------|
| `BUY` | Long | Enter long position, expect price appreciation |
| `SELL` | Short | Enter short position, expect price depreciation |
| `HOLD` | Neutral | No action, waiting for better conditions |

---

## Signal Generation Rules (Improved v2.0 - 70%+ Win Rate Target)

### Primary Rules - Tightened Thresholds

| Condition | Signal | Confidence | Reason Codes |
|-----------|--------|------------|--------------|
| RSI < 20 AND MACD bullish crossover AND Volume > 2.5x MA | BUY | 0.88 | `["deep_oversold", "macd_bullish_crossover", "volume_spike"]` |
| RSI < 25 AND Volume > 1.8x MA AND Price in uptrend | BUY | 0.78 | `["oversold", "volume_confirmation", "uptrend"]` |
| RSI 20-30 AND Volume > 2x MA AND Uptrend | BUY | 0.70 | `["mild_oversold", "volume_confirmed"]` |
| RSI > 80 AND MACD bearish crossover AND Volume > 2.5x MA | SELL | 0.88 | `["deep_overbought", "macd_bearish_crossover", "volume_spike"]` |
| RSI > 75 AND Volume > 1.8x MA AND Price in downtrend | SELL | 0.78 | `["overbought", "volume_confirmation", "downtrend"]` |
| RSI 70-80 AND Volume > 2x MA AND Downtrend | SELL | 0.70 | `["mild_overbought", "volume_confirmed"]` |
| RSI 30-45 (no trend) | HOLD | 0.60 | `["weak_signal", "no_trend"]` |
| RSI 55-70 (no trend) | HOLD | 0.60 | `["weak_signal", "no_trend"]` |
| RSI < 30, no volume confirmation | HOLD | 0.50 | `["oversold_but_no_confirmation"]` |
| RSI > 70, no volume confirmation | HOLD | 0.50 | `["overbought_but_no_confirmation"]` |

### Improved Rules (v2.0) - Key Changes

1. **Tighter RSI Thresholds**: BUY only when RSI < 25 (not < 30), SELL only when RSI > 75 (not > 70)
2. **Volume Confirmation Required**: Signal only valid if volume > 1.8x moving average
3. **Trend Alignment Required**: BUY only in uptrend, SELL only in downtrend
4. **Strong Signal Bonus**: RSI < 20 or RSI > 80 with volume = highest confidence (0.88)
5. **Multi-Confirmation**: Strong signals require RSI + Volume + Trend + MACD alignment

### Coin Selection Filter

| Coin | Trading Allowed | Max Position | Notes |
|------|----------------|--------------|-------|
| BNB | YES | 10% | Primary target, 80% win rate historically |
| ETH | YES | 10% | Primary target, strong trend follower |
| LTC | YES | 10% | Primary target, reliable movements |
| XRP | CONDITIONAL | 5% | Secondary - higher risk |
| SOL | CONDITIONAL | 5% | Only if trend strongly confirms |
| BTC | NO | 0% | Only 32% win rate - AVOID |
| DOGE | NO | 0% | Only 21% win rate - AVOID |
| DOT | NO | 0% | Only 28% win rate - AVOID |
| MATIC | NO | 0% | Only 32% win rate - AVOID |
| ADA | CONDITIONAL | 3% | Only if no other options |

### Hold Period Optimization

| Signal Type | Optimal Hold | Max Hold | Rationale |
|-------------|--------------|----------|-----------|
| BUY (strong) | 3-5 days | 7 days | Best R/R ratio ~3.2 |
| BUY (normal) | 2-3 days | 5 days | Capture momentum fade |
| SELL (strong) | 2-3 days | 5 days | Higher win rate early |
| SELL (normal) | 1-2 days | 3 days | Prevent reversal |

### Stop-Loss / Take-Profit Rules

| Condition | Stop-Loss | Take-Profit | R/R Ratio |
|-----------|-----------|-------------|-----------|
| Strong Signal (0.85+) | 1.5% | 4.5% | 3.0 |
| Normal Signal (0.70-0.85) | 2.0% | 6.0% | 3.0 |
| Weak Signal (0.65-0.70) | 2.5% | 7.5% | 3.0 |

### Signal Validity Time Windows

| Strength | Valid For | Invalidation |
|----------|-----------|-------------|
| Strong (0.85+) | 4 hours | Price moves > 1.5% against direction |
| Normal (0.70-0.85) | 2 hours | Price moves > 1% against direction |
| Weak (0.65-0.70) | 30 minutes | Price moves > 0.5% against direction |

### Indicator States

```typescript
interface IndicatorState {
  value: number | string;
  favorable: boolean;
  favorable_reason?: string;
}
```

| Indicator | Values | Favorable for BUY | Favorable for SELL |
|-----------|--------|-------------------|---------------------|
| RSI | 0-100 | < 25 (deep < 20) | > 75 (deep > 80) |
| MACD | bullish/neutral/bearish | bullish crossover | bearish crossover |
| EMA | bullish/neutral/bearish | 50 > 200 AND price > EMA50 | 50 < 200 AND price < EMA50 |
| Bollinger | lower/middle/upper touch | lower touch + RSI < 25 | upper touch + RSI > 75 |
| Volume | ratio vs MA | > 1.8x MA | > 1.8x MA |
| Trend | uptrend/sideways/downtrend | uptrend required | downtrend required |

---

## Confidence Calculation (Improved v2.0)

### Base Confidence Formula - Enhanced for Selectivity

```
base_confidence = weighted_average(
  rsi_confidence:      0.25,  // Tighter thresholds
  volume_confidence:   0.20,  // Volume now more important
  momentum_confidence: 0.20,  // NEW: Trend momentum filter
  ema_confidence:      0.15,  // Reduced - was 0.25
  bollinger_confidence: 0.10,
  macd_confidence:     0.10   // Reduced - was 0.25
)
```

### Confidence Adjustments (v2.0)

| Adjustment | Delta | Condition |
|------------|-------|-----------|
| Multiple confirmations (4+) | +0.15 | 4+ indicators agree |
| Volume spike > 2.5x MA | +0.10 | Strong volume confirmation |
| Trend alignment | +0.10 | Higher timeframe confirms direction |
| Deep oversold/overbought (RSI < 20, > 80) | +0.08 | Extreme reading |
| Only 1 confirmation | -0.20 | Low conviction signal |
| No volume confirmation | -0.15 | Volume below 1.8x MA |
| Opposing trend | -0.25 | Contra-trend signal rejected |
| Low volume (< 1x MA) | -0.10 | Weak participation |

### RSI Scoring (Tighter v2.0)

```typescript
const getRSIScore = (rsi: number, isBuy: boolean): number => {
  if (isBuy) {
    if (rsi < 20) return 1.0;      // Deep oversold - strongest
    if (rsi < 25) return 0.8;      // Strong oversold
    if (rsi < 35) return 0.4;      // Mild oversold
    if (rsi < 45) return 0.1;      // Weak zone - hold
    return 0.0;                    // Not oversold
  } else {
    if (rsi > 80) return 1.0;      // Deep overbought - strongest
    if (rsi > 75) return 0.8;      // Strong overbought
    if (rsi > 65) return 0.4;      // Mild overbought
    if (rsi > 55) return 0.1;      // Weak zone - hold
    return 0.0;                    // Not overbought
  }
}
```

### Volume Scoring (NEW - Critical Filter)

```typescript
const getVolumeScore = (volumeRatio: number): number => {
  if (volumeRatio > 3.0) return 1.0;   // Extreme volume
  if (volumeRatio > 2.5) return 0.9;   // Strong volume spike
  if (volumeRatio > 2.0) return 0.8;   // Good volume
  if (volumeRatio > 1.8) return 0.7;   // Minimum for signal
  if (volumeRatio > 1.5) return 0.4;   // Suboptimal
  if (volumeRatio > 1.0) return 0.2;   // Low volume
  return 0.0;                          // Reject - no volume
}
```

### Trend Scoring (NEW - Critical Filter)

```typescript
const getTrendScore = (trend: string, isBuy: boolean): number => {
  if (isBuy) {
    if (trend === 'strong_uptrend') return 1.0;
    if (trend === 'uptrend') return 0.7;
    if (trend === 'sideways') return 0.1;  // Reject sideways for BUY
    return -0.3;                           // Downtrend = reject BUY
  } else {
    if (trend === 'strong_downtrend') return 1.0;
    if (trend === 'downtrend') return 0.7;
    if (trend === 'sideways') return 0.1; // Reject sideways for SELL
    return -0.3;                          // Uptrend = reject SELL
  }
}
```

### Final Confidence Calculation

```typescript
function calculateConfidence(indicators: IndicatorInput): number {
  let score = 0;
  let weights = 0;

  // RSI contribution (tighter thresholds)
  const rsiScore = getRSIScore(indicators.rsi, isBuySignal);
  score += rsiScore * 0.25;
  weights += 0.25;

  // Volume contribution (new scoring)
  const volScore = getVolumeScore(indicators.volume.ratio);
  score += volScore * 0.20;
  weights += 0.20;

  // Momentum/Trend contribution (new)
  const momentumScore = getTrendScore(indicators.trend, isBuySignal);
  score += momentumScore * 0.20;
  weights += 0.20;

  // EMA contribution
  const emaScore = indicators.ema.crossover === 'bullish' ? 1.0 :
                   indicators.ema.crossover === 'bearish' ? 0.0 : 0.5;
  score += emaScore * 0.15;
  weights += 0.15;

  // Bollinger contribution
  const bbScore = indicators.bollinger.position === 'lower' ? 1.0 :
                 indicators.bollinger.position === 'upper' ? 0.0 : 0.5;
  score += bbScore * 0.10;
  weights += 0.10;

  // MACD contribution
  const macdScore = indicators.macd.crossover === 'bullish' ? 1.0 :
                   indicators.macd.crossover === 'bearish' ? 0.0 : 0.5;
  score += macdScore * 0.10;
  weights += 0.10;

  // Calculate base
  let base = score / weights;

  // Apply adjustments
  const confirmations = countConfirmations(indicators);
  let adjustments = 0;
  
  if (confirmations >= 4) adjustments += 0.15;
  else if (confirmations >= 3) adjustments += 0.08;
  if (indicators.volume.ratio > 2.5) adjustments += 0.10;
  if (indicators.trend === 'strong_uptrend' || indicators.trend === 'strong_downtrend') adjustments += 0.10;
  if (indicators.rsi < 20 || indicators.rsi > 80) adjustments += 0.08;
  if (confirmations <= 1) adjustments -= 0.20;
  if (indicators.volume.ratio < 1.8) adjustments -= 0.15;
  if (indicators.trend === 'sideways') adjustments -= 0.10;

  return clamp(base + adjustments, 0, 1);
}
```

---

## Signal Quality Filter (v2.0 - Enhanced for 70%+ Win Rate)

### Filter Rules

| Rule | Action |
|------|--------|
| confidence < 0.65 | Convert signal to HOLD |
| Coin not in whitelist | Convert signal to HOLD |
| Conflicting signals | Default to HOLD |
| < 3 confirmations | Reduce confidence by 0.15 |
| Higher timeframe opposes | Convert to HOLD |
| Downtrend + BUY signal | Convert to HOLD |
| Uptrend + SELL signal | Convert to HOLD |
| Volume < 1.8x MA | Reduce confidence by 0.15 |

### Coin Whitelist Filter (NEW)

Only these coins generate active trading signals:
- Primary: BNB, ETH, LTC (high win rate coins)
- Conditional: XRP, SOL (only with strong trend)
- Excluded: DOGE, BTC, DOT, MATIC (win rate < 45%)

### Filter Process

```
┌─────────────────────────────────┐
│     Raw Signal Generated        │
└───────────────┬─────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│  Check Coin in Whitelist?        │
│  No → Convert to HOLD           │
└───────────────┬─────────────────┘
                │ Yes
                ▼
┌─────────────────────────────────┐
│  Check Confidence >= 0.65?       │
│  No → Convert to HOLD           │
└───────────────┬─────────────────┘
                │ Yes
                ▼
┌─────────────────────────────────┐
│  Check Trend Alignment?          │
│  Contra-trend → Convert to HOLD  │
└───────────────┬─────────────────┘
                │ Yes
                ▼
┌─────────────────────────────────┐
│  Check Volume >= 1.8x MA?        │
│  No → Reduce confidence          │
└───────────────┬─────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│  Check >= 3 Confirmations?      │
│  No → Apply -0.15 penalty        │
└───────────────┬─────────────────┘
                │ Yes
                ▼
┌─────────────────────────────────┐
│  Check Higher Timeframe Align?   │
│  No → Convert to HOLD           │
└───────────────┬─────────────────┘
                │ Yes
                ▼
┌─────────────────────────────────┐
│     Emit Filtered Signal         │
└─────────────────────────────────┘
```
┌─────────────────────────────────┐
│     Raw Signal Generated        │
└───────────────┬─────────────────┘
                │
                ▼
┌─────────────────────────────────┐
│  Check Confidence >= 0.65?      │
│  No → Convert to HOLD           │
└───────────────┬─────────────────┘
                │ Yes
                ▼
┌─────────────────────────────────┐
│  Check >= 2 Confirmations?       │
│  No → Apply -0.15 penalty        │
└───────────────┬─────────────────┘
                │ Yes
                ▼
┌─────────────────────────────────┐
│  Check Higher Timeframe Align?   │
│  No → Convert to HOLD           │
└───────────────┬─────────────────┘
                │ Yes
                ▼
┌─────────────────────────────────┐
│     Emit Filtered Signal         │
└─────────────────────────────────┘
```

---

## Multi-Timeframe Analysis

### Timeframe Hierarchy

| Timeframe | Purpose | Weight |
|-----------|---------|--------|
| 4H | Trend direction | 40% |
| 1H | Entry timing | 35% |
| 15M | Confirmation | 25% |

### Trend Confirmation Rules

```typescript
interface TimeframeSignal {
  timeframe: '4h' | '1h' | '15m';
  direction: 'bullish' | 'bearish' | 'neutral';
  confidence: number;
}
```

**Trading Rules:**
1. If 4H trend is bearish, only allow SELL signals on lower timeframes
2. If 4H trend is bullish, only allow BUY signals on lower timeframes
3. If 4H trend is neutral, prefer HOLD signals
4. 1H must confirm 4H direction for signal to be valid
5. 15M provides final confirmation entry timing

### Multi-Timeframe Validation

```typescript
function validateMultiTimeframe(
  primarySignal: Signal,
  timeframeSignals: TimeframeSignal[]
): { valid: boolean; adjustedConfidence: number } {
  const trend = timeframeSignals.find(t => t.timeframe === '4h');
  const entry = timeframeSignals.find(t => t.timeframe === '1h');

  // Higher timeframe must align with signal direction
  if (trend.direction !== primarySignal.type && trend.direction !== 'neutral') {
    return { valid: false, adjustedConfidence: 0 };
  }

  // Entry timeframe must confirm
  if (!entry || entry.direction !== trend.direction) {
    return { valid: false, adjustedConfidence: 0 };
  }

  // Adjust confidence based on alignment strength
  const alignmentBonus = calculateAlignmentBonus(trend, entry, primarySignal);
  return { valid: true, adjustedConfidence: primarySignal.confidence + alignmentBonus };
}
```

---

## API Methods

### `generate(indicators): Signal`

Main signal generation method combining all indicator analysis.

```typescript
interface IndicatorInput {
  rsi: number;
  macd: {
    value: number;
    signal: number;
    histogram: number;
    crossover?: 'bullish' | 'bearish' | 'neutral';
  };
  ema: {
    ema50: number;
    ema200: number;
    crossover?: 'bullish' | 'bearish' | 'neutral';
  };
  bollinger: {
    upper: number;
    middle: number;
    lower: number;
    position: 'upper' | 'middle' | 'lower';
  };
  volume: {
    current: number;
    movingAverage: number;
    ratio: number;
  };
  price: number;
}

function generate(indicators: IndicatorInput): Signal
```

**Returns:**
```json
{
  "type": "BUY",
  "confidence": 0.85,
  "entryPrice": 49.50,
  "indicatorsUsed": ["rsi", "macd", "ema_crossover"],
  "reasonCodes": ["golden_cross", "oversold_rsi"],
  "supportingIndicators": {
    "rsi": { "value": 28, "favorable": true },
    "macd": { "crossover": "bullish", "favorable": true },
    "ema": { "alignment": "bullish", "favorable": true }
  },
  "timeframe": "1h",
  "validUntil": "2026-05-07T15:00:00Z"
}
```

---

### `assessSignalQuality(signals: Signal[]): Signal[]`

Quality filter for multiple signals, resolving conflicts.

```typescript
function assessSignalQuality(signals: Signal[]): Signal[]
```

**Process:**
1. Group signals by symbol
2. Check for conflicts within same symbol
3. Apply quality filter rules
4. Return filtered signal array

**Conflict Resolution:**
- BUY and SELL for same symbol → HOLD
- Multiple BUY signals → Keep highest confidence
- All signals low confidence → Return single HOLD

---

### `calculateConfidence(indicators: IndicatorInput): number`

Calculate confidence score from raw indicator values.

```typescript
function calculateConfidence(indicators: IndicatorInput): number
```

**Algorithm:**
```typescript
function calculateConfidence(indicators: IndicatorInput): number {
  let score = 0;
  let weights = 0;

  // RSI contribution (inverted - low RSI good for BUY)
  const rsiScore = indicators.rsi < 30 ? 1.0 :
                   indicators.rsi < 40 ? 0.7 :
                   indicators.rsi < 60 ? 0.3 :
                   indicators.rsi > 70 ? 0.0 : 0.5;
  score += rsiScore * 0.25;
  weights += 0.25;

  // MACD contribution
  const macdScore = indicators.macd.crossover === 'bullish' ? 1.0 :
                    indicators.macd.crossover === 'bearish' ? 0.0 : 0.5;
  score += macdScore * 0.25;
  weights += 0.25;

  // EMA contribution
  const emaScore = indicators.ema.crossover === 'bullish' ? 1.0 :
                    indicators.ema.crossover === 'bearish' ? 0.0 : 0.5;
  score += emaScore * 0.25;
  weights += 0.25;

  // Bollinger contribution
  const bbScore = indicators.bollinger.position === 'lower' ? 1.0 :
                   indicators.bollinger.position === 'upper' ? 0.0 : 0.5;
  score += bbScore * 0.15;
  weights += 0.15;

  // Volume contribution
  const volScore = indicators.volume.ratio > 2.0 ? 1.0 :
                   indicators.volume.ratio > 1.5 ? 0.8 :
                   indicators.volume.ratio > 1.0 ? 0.6 : 0.3;
  score += volScore * 0.10;
  weights += 0.10;

  // Apply adjustments
  let adjustments = 0;
  const confirmations = countConfirmations(indicators);
  if (confirmations >= 3) adjustments += 0.10;
  if (indicators.volume.ratio > 2.0) adjustments += 0.05;
  if (confirmations === 1) adjustments -= 0.15;

  return clamp(score / weights + adjustments, 0, 1);
}
```

---

### `getReasonCodes(signal: Signal): string[]`

Get explanation codes for a generated signal.

```typescript
function getReasonCodes(signal: Signal): string[]
```

**Reason Code Definitions:**

| Code | Meaning |
|------|---------|
| `oversold_rsi` | RSI below 30 indicates bullish reversal potential |
| `overbought_rsi` | RSI above 70 indicates bearish reversal potential |
| `macd_bullish_crossover` | MACD line crossed above signal line |
| `macd_bearish_crossover` | MACD line crossed below signal line |
| `golden_cross` | EMA 50 crossed above EMA 200, strong uptrend |
| `death_cross` | EMA 50 crossed below EMA 200, strong downtrend |
| `bollinger_lower_touch` | Price touched lower Bollinger band |
| `bollinger_upper_touch` | Price touched upper Bollinger band |
| `volume_spike` | Volume significantly above average |
| `volume_confirmation` | Volume confirms signal direction |
| `ma_crossover` | Moving average crossover occurred |
| `neutral_market` | No clear directional bias |
| `no_signal` | Conditions not met for any signal |
| `oversold_but_no_confirmation` | RSI oversold but lacks other confirmations |
| `strong_uptrend` | Multiple indicators confirm uptrend |
| `strong_downtrend` | Multiple indicators confirm downtrend |

---

### `getSupportingIndicators(indicators: IndicatorInput): Record<string, IndicatorState>`

Format indicator states for signal output.

```typescript
function getSupportingIndicators(indicators: IndicatorInput): Record<string, IndicatorState>
```

---

## Signal Output Format

### Complete Signal Object

```typescript
interface Signal {
  type: 'BUY' | 'SELL' | 'HOLD';
  confidence: number;
  entryPrice: number;
  indicatorsUsed: string[];
  reasonCodes: string[];
  supportingIndicators: Record<string, IndicatorState>;
  timeframe: string;
  validUntil: string;
  metadata?: {
    symbol?: string;
    multiTimeframeValidated?: boolean;
    filterApplied?: boolean;
    originalConfidence?: number;
  };
}
```

### Example Output

```json
{
  "type": "BUY",
  "confidence": 0.85,
  "entryPrice": 49.50,
  "indicatorsUsed": ["rsi", "macd", "ema_crossover"],
  "reasonCodes": ["golden_cross", "oversold_rsi"],
  "supportingIndicators": {
    "rsi": { "value": 28, "favorable": true },
    "macd": { "crossover": "bullish", "favorable": true },
    "ema": { "alignment": "bullish", "favorable": true }
  },
  "timeframe": "1h",
  "validUntil": "2026-05-07T15:00:00Z",
  "metadata": {
    "symbol": "BTCUSDT",
    "multiTimeframeValidated": true,
    "filterApplied": true,
    "originalConfidence": 0.80
  }
}
```

---

## Signal Validity

### Time-Based Validity

| Timeframe | Signal Valid For |
|-----------|------------------|
| 1H | 30 minutes |
| 4H | 2 hours |
| 15M | 10 minutes |

### Condition-Based Invalidation

Signal immediately invalidates when:
- Price moves > 2% against signal direction
- Opposing timeframe signal generated
- RSI crosses from oversold to overbought (or vice versa)
- Volume drops to < 0.5x moving average

---

## Error Handling

### Invalid Indicator Data

```typescript
interface ValidationError {
  field: string;
  expected: string;
  received: unknown;
}
```

**Validation Rules:**
- RSI must be 0-100
- Volume must be >= 0
- Prices must be > 0
- MACD values required for crossover detection

### Fallback Behavior

| Error Condition | Behavior |
|----------------|----------|
| Missing indicator | Exclude from confidence calc, reduce max possible |
| Invalid RSI | Use 0.5 neutral value |
| Missing volume | Apply -0.05 penalty, continue |
| All indicators missing | Return HOLD with confidence 0.5 |

---

## Performance Requirements

| Metric | Target |
|--------|--------|
| Signal generation latency | < 50ms |
| Max signals per batch | 100 symbols |
| Signal validity check | Real-time |
| Multi-timeframe analysis | < 100ms total |

---

## State Management

### Internal State

```typescript
interface SignalGeneratorState {
  lastSignals: Map<string, Signal>;
  signalHistory: Signal[];
  indicatorCache: Map<string, IndicatorInput>;
  higherTimeframeCache: Map<string, TimeframeSignal>;
}
```

### Memory Management

- Cache last 1000 signals per symbol
- Clear signals older than validity period
- Maintain rolling 24-hour signal history

---

## Usage Example

```typescript
// Initialize agent
const signalGenerator = new SignalGeneratorAgent();

// Connect to market data source
await signalGenerator.connect();

// Get current indicators (from MarketDataAgent)
const indicators = await marketDataAgent.getIndicators('BTCUSDT');

// Generate signal
const signal = signalGenerator.generate(indicators);

// Check signal quality
const qualitySignals = signalGenerator.assessSignalQuality([signal]);

// Get explanation
const reasons = signalGenerator.getReasonCodes(signal);

// Output
console.log(`${signal.type} @ ${signal.entryPrice} (confidence: ${signal.confidence})`);
console.log('Reasons:', reasons);
console.log('Valid until:', signal.validUntil);
```

---

## Configuration

```typescript
interface SignalGeneratorConfig {
  minConfidence: number;           // Default: 0.65
  minConfirmations: number;       // Default: 2
  signalValidityMinutes: number;  // Default: 30
  highVolumeThreshold: number;    // Default: 2.0 (x MA)
  strongVolumeThreshold: number;  // Default: 1.5 (x MA)
  maxSignalsPerSymbol: number;    // Default: 1000
  enableMultiTimeframe: boolean;  // Default: true
  timeframeWeights: {
    '4h': number;                // Default: 0.40
    '1h': number;                // Default: 0.35
    '15m': number;               // Default: 0.25
  };
}
```

---

## Dependencies

- MarketDataAgent for indicator data
- Event bus for signal emissions
- Logger for signal decisions
- Cache manager for multi-timeframe data

---

## Signal Flow

```
┌─────────────────┐
│ Market Data     │ (from MarketDataAgent)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Calculate       │
│ Confidence      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Apply Rules     │
│ Generate Signal │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Multi-Timeframe │
│ Validation      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Quality Filter  │
│ (< 0.65 → HOLD) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Emit Signal     │
└─────────────────┘
```

---

*Generated: 2026-05-07*
*Mode: subagent*
*Platform: Bybit*
