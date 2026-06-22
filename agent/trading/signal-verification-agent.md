---
name: signal-verification-agent
description: Multi-signal verification - validates signals from technical analysis, market trends, and pattern detection before execution
hidden: false
mode: subagent
platform: multi-source
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# SignalVerificationAgent

Verifies trading signals from multiple independent sources before allowing execution. Increases confidence through agreement verification.

## Phase Accountability

For phase-based tasks, the `signal-verification-agent` agent type produces `verification/01_verification.md` for trade signal validation and risk-limit checks.

## Purpose

Trading signals from a single source can be unreliable. By verifying signals from multiple independent sources, we reduce false signals and improve trade quality.

```
Signal Generation → Multi-Source Verification → Risk Check → Execution
                                        ↑
                              (must pass verification)
```

## Verification Flow

```
┌─────────────────────────────────────────────────────────────┐
│              SIGNAL VERIFICATION                           │
├─────────────────────────────────────────────────────────────┤
│  1. Technical Analysis RSI, MACD, Bollinger           │
│         ↓                                             │
│  2. CoinGecko Market Trends (volume, momentum)         │
│         ↓                                             │
│  3. Pattern Detection (chart patterns)             │
│         ↓                                             │
│  4. Agreement Check (do sources agree?)         │
│         ↓                                             │
│  5. Confidence Score Calculation               │
│         ↓                                             │
│  6. Pass/Fail Decision                         │
└─────────────────────────────────────────────────────────────┘
```

## Verification Sources

### 1. Technical Analysis
- **Indicators:** RSI, MACD, Bollinger Bands, EMA crossovers
- **Signal:** Buy/Sell/Hold based on indicator values
- **Weight:** 40%

### 2. Market Trends (CoinGecko)
- **Indicators:** Price momentum, volume trend, market cap growth
- **Signal:** Bullish/Bearish/Neutral
- **Weight:** 30%

### 3. Pattern Detection
- **Patterns:** Golden cross, death cross, breakout, support/resistance
- **Signal:** Continuation/Reversal/Neutral
- **Weight:** 30%

## Signal Agreement Matrix

| Source 1 | Source 2 | Source 3 | Result | Confidence |
|-----------|----------|----------|--------|------------|
| BUY | BUY | BUY | ✅ STRONG BUY | 0.95 |
| BUY | BUY | HOLD | ✅ BUY | 0.80 |
| BUY | HOLD | HOLD | ⚠️ WEAK | 0.55 |
| HOLD | HOLD | HOLD | ⏸️ HOLD | 0.50 |
| SELL | SELL | SELL | ✅ STRONG SELL | 0.95 |
| SELL | SELL | HOLD | ✅ SELL | 0.80 |
| SELL | HOLD | HOLD | ⚠️ WEAK | 0.55 |

## Configuration

```yaml
signals:
  verification_enabled: true
  min_source_agreement: 2    # Minimum sources that must agree
  sources:
    technical_analysis: true    # Our indicators
    coingecko_trends: true     # Market data
    pattern_detection: true   # Chart patterns
  weights:
    technical: 0.4
    trends: 0.3
    patterns: 0.3
```

## Source 1: Technical Analysis Verification

### Indicator Signals

```python
def verify_technical(candles: Candle[]) -> SignalResult:
    """
    Analyze using RSI, MACD, Bollinger, EMA
    
    Returns:
    {
        'signal': 'BUY' | 'SELL' | 'HOLD',
        'confidence': 0.0-1.0,
        'indicators': {
            'rsi': {'value': 35, 'signal': 'BUY'},
            'macd': {'crossover': 'bullish', 'signal': 'BUY'},
            'bollinger': {'position': 'lower_band', 'signal': 'BUY'},
            'ema': {'alignment': 'bullish', 'signal': 'BUY'}
        },
        'reason': ['rsi_oversold', 'macd_bullish_crossover']
    }
    """
```

### RSI Signal

| RSI Value | Signal |
|----------|-------|
| < 30 | BUY (oversold) |
| 30-40 | BUY (potential) |
| 40-60 | HOLD (neutral) |
| 60-70 | SELL (potential) |
| > 70 | SELL (overbought) |

### MACD Signal

| MACD vs Signal Line | Signal |
|-------------------|-------|
| MACD crosses above | BUY |
| MACD below, rising | HOLD |
| MACD crosses below | SELL |
| MACD above, falling | HOLD |

## Source 2: Market Trends Verification

### CoinGecko Signals

```python
def verify_trends(symbol: str) -> SignalResult:
    """
    Analyze market trends from CoinGecko data
    
    Returns:
    {
        'signal': 'BUY' | 'SELL' | 'HOLD',
        'confidence': 0.0-1.0,
        'indicators': {
            'price_momentum': 'bullish',
            'volume_trend': 'increasing',
            'market_cap_growth': 5.2
        }
    }
    """
```

### Trend Signals

| Indicator | Bullish | Bearish | Neutral |
|-----------|--------|--------|---------|
| Price 24h | > +3% | < -3% | -3% to +3% |
| Volume 24h | > +20% | < -20% | -20% to +20% |
| Market Cap 7d | > +10% | < -10% | -10% to +10% |
| Rank Change | Up | Down | Same |

## Source 3: Pattern Detection

### Chart Patterns

```python
def verify_patterns(candles: Candle[]) -> PatternResult:
    """
    Detect chart patterns
    
    Returns:
    {
        'signal': 'BUY' | 'SELL' | 'HOLD',
        'confidence': 0.0-1.0,
        'patterns': [
            {'name': 'golden_cross', 'signal': 'BUY', 'confidence': 0.85},
            {'name': 'support_bounce', 'signal': 'BUY', 'confidence': 0.70}
        ]
    }
    """
```

### Pattern Signals

| Pattern | Signal | Confidence |
|---------|--------|-----------|
| Golden Cross (EMA50 > EMA200) | BUY | 0.85 |
| Death Cross (EMA50 < EMA200) | SELL | 0.85 |
| Support Bounce | BUY | 0.75 |
| Resistance Break | BUY | 0.80 |
| Double Bottom | BUY | 0.70 |
| Double Top | SELL | 0.70 |
| Ascending Triangle | BUY | 0.65 |

## Agreement Algorithm

```python
async def verify_signal(
    symbol: str,
    sources: dict
) -> VerificationResult:
    """
    Main verification function
    
    Returns:
    {
        'symbol': 'BTC/USDT',
        'verified': true/false,
        'signal': 'BUY',
        'confidence': 0.82,
        'sources': {
            'technical': {'signal': 'BUY', 'confidence': 0.75},
            'trends': {'signal': 'BUY', 'confidence': 0.90},
            'patterns': {'signal': 'BUY', 'confidence': 0.80}
        },
        'agreement': 'unanimous',  # unanimous, majority, split
        'score': 2.45,
        'threshold': 2.0,
        'reasons': ['rsi_oversold', 'volume_spike', 'support_bounce']
    }
    """
    
    # Get signals from each source
    technical = await verify_technical(symbol)
    trends = await verify_trends(symbol)
    patterns = await verify_patterns(symbol)
    
    # Calculate agreement
    signals = [technical.signal, trends.signal, patterns.signal]
    agreement = check_agreement(signals)
    
    # Calculate weighted confidence
    score = (
        technical.confidence * 0.4 +
        trends.confidence * 0.3 +
        patterns.confidence * 0.3
    )
    
    # Determine if verified
    verified = (
        agreement in ['unanimous', 'majority'] and
        score >= threshold
    )
    
    return {
        'symbol': symbol,
        'verified': verified,
        'signal': get_consensus_signal(signals),
        'confidence': score,
        'sources': {
            'technical': technical,
            'trends': trends,
            'patterns': patterns
        },
        'agreement': agreement,
        'score': score,
        'threshold': sources.get('min_agreement', 2.0)
    }
```

### Agreement Check

```python
def check_agreement(signals: list) -> str:
    """Determine signal agreement level"""
    
    buy_count = signals.count('BUY')
    sell_count = signals.count('SELL')
    hold_count = signals.count('HOLD')
    
    if buy_count == 3 or (buy_count == 2 and hold_count == 1):
        return 'unanimous'
    if sell_count == 3 or (sell_count == 2 and hold_count == 1):
        return 'unanimous'
    if buy_count >= 2 or sell_count >= 2:
        return 'majority'
    if buy_count == 1 and sell_count == 1:
        return 'split'
    
    return 'no_consensus'
```

## Confidence Scoring

### Base Confidence Calculation

```
Final Confidence = (Technical × 0.4) + (Trends × 0.3) + (Patterns × 0.3)
```

### Adjustments

| Condition | Adjustment |
|----------|-----------|
| Unanimous agreement | +0.15 |
| Majority agreement | +0.05 |
| Split decision | -0.20 |
| No consensus | -0.30 |
| High volume confirmation | +0.10 |
| Trend alignment | +0.05 |

### Confidence Thresholds

| Confidence | Action |
|------------|--------|
| >= 0.85 | ✅ STRONG BUY/SELL - Execute |
| >= 0.65 | ✅ BUY/SELL - Execute |
| >= 0.50 | ⚠️ HOLD - Low confidence |
| < 0.50 | ⏸️ HOLD - Reject |

## Verification Result

```python
# Example output
{
    'symbol': 'BTC/USDT',
    'verified': True,
    'signal': 'BUY',
    'confidence': 0.82,
    'decision': 'EXECUTE',
    
    'sources': {
        'technical': {
            'signal': 'BUY',
            'confidence': 0.80,
            'rsi': 28,
            'macd': 'bullish_crossover'
        },
        'trends': {
            'signal': 'BUY',
            'confidence': 0.85,
            'volume_change': 45
        },
        'patterns': {
            'signal': 'BUY',
            'confidence': 0.80,
            'patterns': ['golden_cross', 'support_bounce']
        }
    },
    
    'agreement': 'unanimous',
    'score': 2.45,
    'threshold': 2.0,
    
    'explanation': [
        'RSI oversold (28 < 30)',
        'MACD bullish crossover',
        'Volume spike (+45%)',
        'Golden cross detected',
        'Price bouncing from support'
    ],
    
    'timestamp': 1700000000
}
```

## Usage

```python
# Initialize
verifier = SignalVerificationAgent(config)

# Verify a signal
result = await verifier.verify('BTC/USDT')

# Check result
if result.verified:
    print(f"Signal verified: {result.signal}")
    print(f"Confidence: {result.confidence}")
    print(f"Sources: {result.sources}")
    # Proceed to RiskAssessmentAgent
else:
    print(f"Signal rejected: {result.decision}")
    print(f"Reason: {result.explanation}")
    # Do NOT execute trade
```

## API Methods

### verify()
Main verification entry point.

```python
async def verify(symbol: str) -> VerificationResult
```

### verify_technical()
Technical analysis verification.

```python
async def verify_technical(symbol: str) -> SignalResult
```

### verify_trends()
Market trends verification.

```python
async def verify_trends(symbol: str) -> SignalResult
```

### verify_patterns()
Pattern detection verification.

```python
async def verify_patterns(symbol: str) -> PatternResult
```

### get_consensus()
Get overall consensus.

```python
def get_consensus(results: list) -> dict
```

---

## Notes

- All 3 sources must be enabled for full verification
- Can be run with 2 sources if one data source unavailable
- Verification adds ~500ms latency (acceptable)
- Significantly reduces false signals