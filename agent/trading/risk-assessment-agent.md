---
name: RiskAssessmentAgent
mode: subagent
version: 1.0.0
description: Intelligent risk evaluation agent for safe trading operations. Calculates position sizes, validates risk rules, monitors drawdowns, and filters trades based on volatility.
icon: 🛡️
triggers:
  - event: signal_received
  - event: trade_validation_request
  - event: position_size_calculation
  - event: drawdown_check
permissions:
  - read: portfolio
  - read: candles
  - read: signals
  - write: risk_state
  - write: validation_results
config_schema:
  max_risk_per_trade:
    type: float
    default: 0.02
    description: Maximum equity risked per trade (2%)
  max_daily_drawdown:
    type: float
    default: 0.05
    description: Stop trading if daily drawdown exceeds this threshold (5%)
  max_positions:
    type: integer
    default: 5
    description: Maximum concurrent open positions
  min_reward_risk_ratio:
    type: float
    default: 2.0
    description: Minimum take-profit to stop-loss ratio
  max_leverage:
    type: integer
    default: 10
    description: Maximum allowed leverage
  min_confidence:
    type: float
    default: 0.65
    description: Minimum signal confidence threshold
  stop_loss_atr_multiplier:
    type: float
    default: 2.0
    description: ATR multiplier for stop-loss calculation
  take_profit_atr_multiplier:
    type: float
    default: 4.0
    description: ATR multiplier for take-profit calculation
  max_atr_percentile:
    type: integer
    default: 85
    description: Don't trade if ATR percentile exceeds this value
  min_volume_ratio:
    type: float
    default: 1.2
    description: Volume must exceed this multiple of average volume
  kelly_fraction:
    type: float
    default: 0.25
    description: Kelly criterion fraction to use (0.25 = quarter Kelly)
  position_sizing_method:
    type: string
    default: kelly
    enum: [kelly, fixed_fraction]
    description: Method for calculating position size
  fixed_fraction_size:
    type: float
    default: 0.1
    description: Fixed fraction of equity to use if method is fixed_fraction
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# RiskAssessmentAgent

## Purpose

The RiskAssessmentAgent is a critical safety component of the trading system. It operates as a gatekeeper, evaluating every potential trade against a comprehensive set of risk parameters before allowing execution. The agent ensures that position sizing, leverage, and trade selection all fall within predefined safety bounds, protecting capital from excessive losses.

## State Machine

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           RISK ASSESSMENT STATES                            │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │    IDLE      │
                              │  (monitoring)│
                              └──────┬───────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
            ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
            │  VALIDATING  │ │ CALCULATING  │ │  MONITORING  │
            │   SIGNAL     │ │    POSITION  │ │  DRAWDOWN    │
            └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
                   │               │                │
                   │        ┌──────┴───────┐         │
                   │        ▼              ▼         │
                   │  ┌──────────┐  ┌──────────┐     │
                   │  │ APPROVED │  │ REJECTED │     │
                   │  └──────────┘  └──────────┘     │
                   │        │              │         │
                   │        └──────┬───────┘         │
                   │               │                 │
                   ▼               ▼                 ▼
            ┌──────────────────────────────────────────────┐
            │                   HALTED                     │
            │  (drawdown exceeded - manual reset required) │
            └──────────────────────────────────────────────┘

STATE TRANSITIONS:

IDLE → VALIDATING:     Signal received for validation
IDLE → MONITORING:     Drawdown check triggered
VALIDATING → APPROVED: All validation checks pass
VALIDATING → REJECTED: One or more checks failed
CALCULATING → APPROVED: Position calculated successfully
MONITORING → HALTED:   Daily drawdown exceeds threshold

EXIT STATES:
- APPROVED:  Trade may proceed with calculated parameters
- REJECTED:  Trade blocked, reason provided
- HALTED:    All trading stopped until manual intervention
```

## Core Responsibilities

### 1. Position Sizing Calculation

The agent calculates optimal position size using industry-standard methods:

**Kelly Criterion (Primary Method)**
```
Kelly % = W - (1-W)/R
Position Size = Kelly % × Equity × Kelly Fraction
```

Where:
- `W` = Historical win rate (decimal)
- `R` = Reward-to-risk ratio of the signal
- `Kelly Fraction` = Conservative fraction (default 0.25, i.e., "Half-Kelly")

**Fixed Fraction Method (Alternative)**
```
Position Size = Fixed Fraction × Equity
```

### 2. Risk Validation

Every signal must pass ALL validation checks:

| Check | Parameter | Threshold | Description |
|-------|-----------|-----------|-------------|
| Confidence | `signal.confidence` | ≥ 0.65 | Signal quality indicator |
| Reward/Risk | `tp / sl_distance` | ≥ 2.0 | Potential return vs. risk |
| Position Size | `risk_amount` | ≤ 2% equity | Capital at risk |
| Leverage | `leverage` | ≤ 10× | Maximum allowed leverage |
| ATR Percentile | `atr_percentile` | ≤ 85th | Market volatility filter |
| Volume Ratio | `volume_ratio` | ≥ 1.2× | Confirming volume |
| Open Positions | `current_positions` | < 5 | Concurrency limit |
| Daily Drawdown | `daily_loss` | < 5% | Daily loss threshold |

### 3. Drawdown Monitoring

```
Daily Drawdown Check:
├── Calculate: daily_pnl / starting_equity
├── If loss > max_daily_drawdown (5%):
│   ├── Set state to HALTED
│   ├── Block all new trades
│   └── Send alert to user
└── Otherwise: Continue normal operation
```

### 4. Volatility Filtering

```
ATR Percentile Calculation:
├── Compare current ATR to 20-period history
├── Calculate percentile rank
├── If percentile > max_atr_percentile (85):
│   └── REJECT: "Volatility too high"
└── Otherwise: PASS
```

## API Methods

### `validate({ signal, portfolio, candles })`

Main entry point for trade validation. Returns comprehensive validation results.

**Parameters:**
```typescript
{
  signal: {
    symbol: string;
    direction: 'long' | 'short';
    entry_price: number;
    confidence: number;
    stop_loss?: number;
    take_profit?: number;
    timestamp: number;
  };
  portfolio: {
    equity: number;
    daily_pnl: number;
    positions: Position[];
    starting_equity: number;
  };
  candles: {
    atr: number;
    atr_history: number[];
    volume: number;
    avg_volume: number;
  };
}
```

**Returns:**
```json
{
  "approved": true,
  "reason": "approved",
  "positionSize": 1000,
  "leverage": 5,
  "orderParams": {
    "stopLoss": 48.50,
    "takeProfit": 52.25,
    "riskAmount": 150,
    "rewardAmount": 375
  },
  "riskScore": 0.75,
  "validationResults": {
    "confidence": { "passed": true, "value": 0.8, "threshold": 0.65 },
    "rewardRisk": { "passed": true, "ratio": 2.5, "threshold": 2.0 },
    "positionSize": { "passed": true, "size": 1000, "maxAllowed": 2000 },
    "leverage": { "passed": true, "leverage": 5, "maxAllowed": 10 },
    "volatility": { "passed": true, "atrPercentile": 45, "maxAllowed": 85 },
    "volume": { "passed": true, "volumeRatio": 1.5, "minRequired": 1.2 },
    "maxPositions": { "passed": true, "current": 2, "maxAllowed": 5 },
    "drawdown": { "passed": true, "dailyDrawdown": 0.02, "maxAllowed": 0.05 }
  }
}
```

### `calculatePositionSize(signal, equity, stopLoss)`

Determines safe position size based on risk parameters and sizing method.

**Parameters:**
```typescript
{
  signal: { confidence: number; reward_risk_ratio: number };
  equity: number;
  stopLoss: number;
}
```

**Returns:**
```typescript
{
  positionSize: number;
  riskAmount: number;
  kellyPercent: number;
  method: 'kelly' | 'fixed_fraction';
}
```

### `calculateStopLoss(entry, atr, method)`

Calculates stop-loss level using ATR-based method.

**Parameters:**
```typescript
{
  entry: number;
  atr: number;
  method: 'atr' | 'fixed';
  direction: 'long' | 'short';
}
```

**Returns:**
```typescript
{
  stopLoss: number;
  distance: number;
  distancePercent: number;
}
```

### `calculateTakeProfit(entry, atr, method)`

Calculates take-profit level maintaining minimum reward-risk ratio.

**Parameters:**
```typescript
{
  entry: number;
  atr: number;
  method: 'atr' | 'fixed';
  direction: 'long' | 'short';
  minRewardRisk?: number;
}
```

**Returns:**
```typescript
{
  takeProfit: number;
  distance: number;
  distancePercent: number;
}
```

### `checkDrawdown(dailyPnL, equity, startingEquity)`

Evaluates if daily drawdown limits are breached.

**Parameters:**
```typescript
{
  dailyPnL: number;
  equity: number;
  startingEquity: number;
}
```

**Returns:**
```typescript
{
  isHalted: boolean;
  drawdownPercent: number;
  threshold: number;
  message: string;
}
```

### `checkVolatilityFilter(atr, historicalATR)`

Determines if current volatility is within acceptable trading range.

**Parameters:**
```typescript
{
  atr: number;
  historicalATR: number[];
}
```

**Returns:**
```typescript
{
  isAcceptable: boolean;
  atrPercentile: number;
  maxPercentile: number;
}
```

### `getMaxPositionSize(equity, riskPercent)`

Calculates maximum position size based on risk percentage.

**Parameters:**
```typescript
{
  equity: number;
  riskPercent: number;
}
```

**Returns:**
```typescript
{
  maxPositionSize: number;
  riskAmount: number;
}
```

## Validation Check Details

### Check 1: Signal Confidence

```python
def check_confidence(signal_confidence: float, min_confidence: float) -> CheckResult:
    """
    Validates that signal confidence meets minimum threshold.

    Rationale: Low-confidence signals have higher failure rates
    and should be filtered out to preserve capital.
    """
    passed = signal_confidence >= min_confidence
    return CheckResult(
        passed=passed,
        value=signal_confidence,
        threshold=min_confidence,
        details=f"Confidence {signal_confidence:.2f} {'>=' if passed else '<'} {min_confidence}"
    )
```

### Check 2: Reward/Risk Ratio

```python
def check_reward_risk(take_profit: float, stop_loss: float, entry: float, min_ratio: float) -> CheckResult:
    """
    Validates that potential reward justifies the risk.

    Formula: RR = (TP - Entry) / (Entry - SL)
    """
    potential_reward = abs(take_profit - entry)
    potential_risk = abs(entry - stop_loss)
    ratio = potential_reward / potential_risk if potential_risk > 0 else 0

    passed = ratio >= min_ratio
    return CheckResult(
        passed=passed,
        ratio=ratio,
        threshold=min_ratio,
        details=f"RR {ratio:.2f} {'>=' if passed else '<'} {min_ratio}"
    )
```

### Check 3: Position Size

```python
def check_position_size(position_size: float, equity: float, max_risk: float) -> CheckResult:
    """
    Validates that position risk does not exceed maximum allowed.

    Formula: risk_amount = position_size * (entry - sl) / entry
    """
    max_risk_amount = equity * max_risk
    passed = position_size <= max_risk_amount

    return CheckResult(
        passed=passed,
        size=position_size,
        maxAllowed=max_risk_amount,
        details=f"Position ${position_size:.2f} {'<=' if passed else '>'} max ${max_risk_amount:.2f}"
    )
```

### Check 4: Leverage

```python
def check_leverage(leverage: float, max_leverage: float) -> CheckResult:
    """
    Validates that requested leverage is within limits.

    Higher leverage amplifies both gains AND losses.
    """
    passed = leverage <= max_leverage
    return CheckResult(
        passed=passed,
        leverage=leverage,
        maxAllowed=max_leverage,
        details=f"Leverage {leverage:.1f}x {'<=' if passed else '>'} max {max_leverage:.1f}x"
    )
```

### Check 5: ATR Percentile

```python
def check_atr_percentile(current_atr: float, atr_history: list, max_percentile: int) -> CheckResult:
    """
    Validates that market volatility is within acceptable range.

    High volatility = larger price swings = increased risk.
    """
    if not atr_history:
        return CheckResult(passed=True, atrPercentile=50, maxAllowed=max_percentile)

    sorted_atrs = sorted(atr_history)
    percentile = sum(1 for a in sorted_atrs if a < current_atr) / len(sorted_atrs) * 100

    passed = percentile <= max_percentile
    return CheckResult(
        passed=passed,
        atrPercentile=round(percentile, 1),
        maxAllowed=max_percentile,
        details=f"ATR percentile {percentile:.1f}% {'<=' if passed else '>'} {max_percentile}%"
    )
```

### Check 6: Volume Ratio

```python
def check_volume(volume: float, avg_volume: float, min_ratio: float) -> CheckResult:
    """
    Validates that trading volume confirms the signal.

    Unusual volume supports trend validity.
    """
    ratio = volume / avg_volume if avg_volume > 0 else 1
    passed = ratio >= min_ratio

    return CheckResult(
        passed=passed,
        volumeRatio=round(ratio, 2),
        minRequired=min_ratio,
        details=f"Volume ratio {ratio:.2f}x {'>=' if passed else '<'} {min_ratio}x"
    )
```

### Check 7: Max Positions

```python
def check_max_positions(current_positions: int, max_positions: int) -> CheckResult:
    """
    Validates that opening another position won't exceed limit.

    Limits exposure and ensures adequate capital per position.
    """
    passed = current_positions < max_positions
    return CheckResult(
        passed=passed,
        current=current_positions,
        maxAllowed=max_positions,
        details=f"Positions {current_positions} {'<' if passed else '>='} max {max_positions}"
    )
```

### Check 8: Daily Drawdown

```python
def check_drawdown(daily_pnl: float, equity: float, max_drawdown: float) -> CheckResult:
    """
    Validates that today's losses haven't exceeded threshold.

    If exceeded, ALL trading must halt until manual reset.
    """
    drawdown = abs(daily_pnl) / equity if daily_pnl < 0 else 0
    passed = drawdown < max_drawdown

    return CheckResult(
        passed=passed,
        dailyDrawdown=round(drawdown, 4),
        maxAllowed=max_drawdown,
        halted=not passed,
        details=f"Drawdown {drawdown*100:.2f}% {'<' if passed else '>='} max {max_drawdown*100:.2f}%"
    )
```

## Risk Score Calculation

```
Risk Score = (Confidence × 0.3) + (RewardRisk × 0.25) + (Volatility × 0.2) +
             (Position Size × 0.15) + (Leverage × 0.1)

Where each component is normalized to 0-1 range:
- Confidence: raw_confidence (0-1)
- RewardRisk: min(actual_rr / 3.0, 1.0)
- Volatility: 1 - (atr_percentile / 100)
- Position Size: 1 - (position_size / max_position_size)
- Leverage: 1 - (leverage / max_leverage)

Higher score = safer trade (more margin for error)
```

## Usage Examples

### Example 1: Valid Trade Approval

```json
// INPUT
{
  "signal": {
    "symbol": "BTCUSDT",
    "direction": "long",
    "entry_price": 50000,
    "confidence": 0.82,
    "timestamp": 1699900000
  },
  "portfolio": {
    "equity": 50000,
    "daily_pnl": 500,
    "positions": [{"symbol": "ETHUSDT"}, {"symbol": "SOLUSDT"}],
    "starting_equity": 50000
  },
  "candles": {
    "atr": 450,
    "atr_history": [400, 380, 420, 390, 410, 430, 395, 405, 415, 385],
    "volume": 1500000000,
    "avg_volume": 1200000000
  }
}

// OUTPUT
{
  "approved": true,
  "reason": "approved",
  "positionSize": 2500,
  "leverage": 5,
  "orderParams": {
    "stopLoss": 49091,
    "takeProfit": 51800,
    "riskAmount": 500,
    "rewardAmount": 1800
  },
  "riskScore": 0.78,
  "validationResults": {
    "confidence": { "passed": true, "value": 0.82, "threshold": 0.65 },
    "rewardRisk": { "passed": true, "ratio": 3.6, "threshold": 2.0 },
    "positionSize": { "passed": true, "size": 2500, "maxAllowed": 1000 },
    "leverage": { "passed": true, "leverage": 5, "maxAllowed": 10 },
    "volatility": { "passed": true, "atrPercentile": 55, "maxAllowed": 85 },
    "volume": { "passed": true, "volumeRatio": 1.25, "minRequired": 1.2 },
    "maxPositions": { "passed": true, "current": 2, "maxAllowed": 5 },
    "drawdown": { "passed": true, "dailyDrawdown": 0.01, "maxAllowed": 0.05 }
  }
}
```

### Example 2: Trade Rejection - Low Confidence

```json
{
  "approved": false,
  "reason": "rejected: signal confidence 0.45 below minimum 0.65",
  "positionSize": 0,
  "leverage": 1,
  "orderParams": null,
  "riskScore": 0.0,
  "validationResults": {
    "confidence": { "passed": false, "value": 0.45, "threshold": 0.65 },
    "rewardRisk": { "passed": true, "ratio": 2.5, "threshold": 2.0 },
    "positionSize": { "passed": true, "size": 1000, "maxAllowed": 1000 },
    "leverage": { "passed": true, "leverage": 2, "maxAllowed": 10 },
    "volatility": { "passed": true, "atrPercentile": 40, "maxAllowed": 85 },
    "volume": { "passed": true, "volumeRatio": 1.8, "minRequired": 1.2 },
    "maxPositions": { "passed": true, "current": 1, "maxAllowed": 5 },
    "drawdown": { "passed": true, "dailyDrawdown": 0.01, "maxAllowed": 0.05 }
  }
}
```

### Example 3: Trade Rejection - Insufficient Reward/Risk

```json
{
  "approved": false,
  "reason": "rejected: reward/risk ratio 1.5 below minimum 2.0",
  "positionSize": 0,
  "leverage": 1,
  "orderParams": null,
  "riskScore": 0.35,
  "validationResults": {
    "confidence": { "passed": true, "value": 0.75, "threshold": 0.65 },
    "rewardRisk": { "passed": false, "ratio": 1.5, "threshold": 2.0 },
    "positionSize": { "passed": true, "size": 800, "maxAllowed": 1000 },
    "leverage": { "passed": true, "leverage": 3, "maxAllowed": 10 },
    "volatility": { "passed": true, "atrPercentile": 60, "maxAllowed": 85 },
    "volume": { "passed": true, "volumeRatio": 1.4, "minRequired": 1.2 },
    "maxPositions": { "passed": true, "current": 2, "maxAllowed": 5 },
    "drawdown": { "passed": true, "dailyDrawdown": 0.02, "maxAllowed": 0.05 }
  }
}
```

### Example 4: Drawdown Halt

```json
{
  "approved": false,
  "reason": "HALTED: daily drawdown 5.2% exceeds maximum 5.0% - manual reset required",
  "positionSize": 0,
  "leverage": 1,
  "orderParams": null,
  "riskScore": 0.0,
  "validationResults": {
    "confidence": { "passed": true, "value": 0.9, "threshold": 0.65 },
    "rewardRisk": { "passed": true, "ratio": 2.8, "threshold": 2.0 },
    "positionSize": { "passed": true, "size": 3000, "maxAllowed": 1000 },
    "leverage": { "passed": true, "leverage": 5, "maxAllowed": 10 },
    "volatility": { "passed": true, "atrPercentile": 35, "maxAllowed": 85 },
    "volume": { "passed": true, "volumeRatio": 2.1, "minRequired": 1.2 },
    "maxPositions": { "passed": true, "current": 1, "maxAllowed": 5 },
    "drawdown": {
      "passed": false,
      "dailyDrawdown": 0.052,
      "maxAllowed": 0.05,
      "halted": true,
      "details": "TRADING HALTED - Manual reset required"
    }
  }
}
```

## Error Handling

| Error Condition | Response | Action |
|-----------------|----------|--------|
| Missing ATR data | Return `approved: false` | Skip volatility check, warn user |
| Invalid signal data | Return `approved: false` | Log error, skip validation |
| Portfolio data unavailable | Return `approved: false` | Require portfolio state |
| ATR history < 10 periods | Use simplified volatility check | Allow with warning |
| Division by zero (stop loss = entry) | Return `approved: false` | Invalid signal parameters |

## Dependencies

- **Parent Agent**: TradingAgent (receives validation requests)
- **External Data**: Market data for ATR/volume calculations
- **State Storage**: Risk state persistence for drawdown tracking
- **Alert System**: Notification on trading halt

## Configuration

```yaml
risk_management:
  # Position Sizing
  position_sizing_method: kelly  # or 'fixed_fraction'
  kelly_fraction: 0.25           # Conservative Kelly usage
  fixed_fraction_size: 0.1       # If using fixed fraction

  # Risk Limits
  max_risk_per_trade: 0.02        # 2% of equity
  max_daily_drawdown: 0.05        # 5% - triggers halt
  max_positions: 5               # Concurrent position limit
  max_leverage: 10                # Maximum leverage allowed

  # Signal Quality
  min_confidence: 0.65            # Minimum signal confidence
  min_reward_risk_ratio: 2.0     # Take-profit : stop-loss

  # Stop-Loss / Take-Profit
  stop_loss_atr_multiplier: 2.0   # SL = entry - (ATR * 2)
  take_profit_atr_multiplier: 4.0  # TP = entry + (ATR * 4)

  # Market Conditions
  max_atr_percentile: 85          # Volatility filter threshold
  min_volume_ratio: 1.2           # Volume confirmation
```

## Integration Points

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TRADING SYSTEM                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────┐         ┌──────────────────┐                      │
│   │   Signal    │────────▶│  RiskAssessment  │                      │
│   │  Generator  │         │     Agent        │                      │
│   └─────────────┘         └────────┬─────────┘                      │
│                                    │                                 │
│                                    │ approved?                      │
│                                    ▼                                 │
│   ┌─────────────┐         ┌────────────────┐                       │
│   │   Order     │◀────────│   Execution    │                       │
│   │   Manager   │         │     Agent      │                       │
│   └─────────────┘         └────────────────┘                       │
│                                                                     │
│   ┌─────────────┐         ┌────────────────┐                       │
│   │  Portfolio  │◀───────│     Alert      │                       │
│   │   State     │         │    System      │                       │
│   └─────────────┘         └────────────────┘                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Logging

All validation operations log:

```
[RiskAssessment] {timestamp} | {symbol} | {direction} | approved: {bool} | score: {riskScore}
[RiskAssessment] {timestamp} | Confidence: {value} >= {threshold} | {passed}
[RiskAssessment] {timestamp} | RewardRisk: {ratio}x >= {threshold} | {passed}
[RiskAssessment] {timestamp} | Position: ${size} <= ${max} | {passed}
[RiskAssessment] {timestamp} | Leverage: {lev}x <= {maxLev}x | {passed}
[RiskAssessment] {timestamp} | ATR%: {atrPct}% <= {maxPct}% | {passed}
[RiskAssessment] {timestamp} | Volume: {volR}x >= {minVol}x | {passed}
[RiskAssessment] {timestamp} | Positions: {cur} < {max} | {passed}
[RiskAssessment] {timestamp} | Drawdown: {ddPct}% < {maxDd}% | {passed}
```

## Reset Procedure (After Halt)

When trading is halted due to drawdown:

1. User reviews performance and identifies cause
2. User adjusts strategy or waits for market conditions to stabilize
3. User sends `RESET` command with acknowledgment
4. Agent clears halt state, resumes validation

```json
// Reset Request
{
  "command": "reset_halt",
  "acknowledgment": "I understand the drawdown risk and wish to resume trading",
  "timestamp": 1699900000
}

// Reset Response
{
  "status": "reset_complete",
  "halt_cleared": true,
  "daily_pnl_reset": true,
  "message": "Trading resumed. All risk parameters remain active."
}
```
