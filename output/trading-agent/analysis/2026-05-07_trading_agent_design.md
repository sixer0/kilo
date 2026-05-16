# Trading Agent System Design (Real-Time Analysis + Execution)

**File:** `output/trading-agent/analysis/2026-05-07_trading_agent_design.md`

**Date:** 2026-05-07

---

## 1. Executive Summary

This document designs a **trading agent system** that performs **real-time market analysis** and can **place trades automatically** while enforcing **user-defined profit targets** and **intelligent risk management**.

Key goals:

- **Real-time analysis & execution loop** using:
  - **WebSocket** market data streams (normalized and cached)
  - **Technical indicator** computation (RSI, MACD, Bollinger Bands, EMA crossovers, patterns)
  - **Risk assessment** prior to any order placement
  - **Trade execution** with confirmation and portfolio tracking
- **Profit-target orientation** via configurable stop-loss / take-profit logic and confidence-threshold gating.
- **Safety controls** to prevent runaway loss:
  - Max risk per trade
  - Daily drawdown limit (halts trading)
  - Leverage limits, volatility and volume filters
  - Max concurrent positions
- **Demo testing** strategy using **Puppeteer** (browser automation) together with API/WebSocket integration.

---

## 2. Platform Recommendations

### Primary: Bybit Demo
- **Demo balance:** $1,000,000 virtual
- **API:** REST + WebSocket API
- **Data:** live market data in demo environment
- **Why it fits this system:**
  - Clean REST/WebSocket endpoints for streaming candles and order-book data
  - High virtual balance supports extensive testing of risk controls
  - Web UI is **Puppeteer-friendly**, allowing UI automation validation

### Secondary: OANDA
- **Strength:** strong forex coverage with reliable streaming data
- **Demo:** free demo environment
- **Why secondary:** different instrument mapping and API semantics; excellent for FX-first variants

### Rationale for choosing Bybit
- **High balance** improves iteration speed when validating risk enforcement.
- **Clean API surfaces** reduce adapter complexity.
- **Real market data** helps validate technical signal logic.
- **Puppeteer-friendly UI** enables end-to-end validation of execution paths.

---

## 3. Agent Architecture

Text-based system diagram:

```text
┌─────────────────────────────────────────────────────────────┐
│              TRADING CONTROLLER (Primary)                   │
│         Orchestrates workflow, enforces rules               │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────┼────────────────────┐
        │           │                    │
        ▼           ▼                    ▼
┌─────────────┐  ┌─────────────┐   ┌───────────────┐
│ MarketData  │  │ Technical   │   │ RiskAssessment │
│   Agent     │  │ Analysis    │   │     Agent     │
│             │  │   Agent     │   │               │
└──────┬──────┘  └──────┬──────┘   └──────┬────────┘
       │                 │                    │
       └─────────────────┼────────────────────┘
                         ▼
                ┌───────────────────┐
                │ SignalGenerator   │
                │     Agent         │
                └────────┬──────────┘
                         │
                         ▼
                ┌───────────────────┐
                │  TradeExecutor     │
                │     Agent          │
                └────────┬──────────┘
                         │
              ┌──────────┼──────────────┐
              ▼          ▼              ▼
       ┌──────────┐  ┌─────────────┐  ┌──────────┐
       │Portfolio │  │  DemoTester │  │   Alert  │
       │ Monitor  │  │ (Puppeteer)│  │ System   │
       └──────────┘  └─────────────┘  └──────────┘
```

---

## 4. Agent Specifications

| Agent | Mode | Responsibilities | Output |
|-------|------|------------------|--------|
| **TradingController** | primary | Orchestrate workflow, enforce risk rules, user approval hooks | Decisions, orders |
| **MarketDataAgent** | subagent | WebSocket connection, data normalization, caching | Price candles, orderbook |
| **TechnicalAnalysisAgent** | subagent | RSI, MACD, Bollinger, EMA, pattern detection | Indicator values, signals |
| **RiskAssessmentAgent** | subagent | Position sizing, drawdown check, volatility filter | Risk score, position size |
| **SignalGeneratorAgent** | subagent | Generate buy/sell/hold, confidence scoring | Trade signals |
| **TradeExecutorAgent** | subagent | Order placement, confirmation handling | Order status |
| **PortfolioMonitorAgent** | subagent | Track positions, P&L, daily stats | Portfolio state |
| **DemoTesterAgent** | subagent | Puppeteer browser automation for demo testing | Test results |

---

## 5. Risk Management Framework (YAML)

```yaml
risk_management:
  # Position Sizing
  max_risk_per_trade: 0.02        # 2% of equity per trade
  max_daily_drawdown: 0.05       # 5% - stop all trading if hit
  max_positions: 5               # Maximum concurrent positions

  # Entry Rules
  min_reward_risk_ratio: 2.0      # TP must be 2x SL distance
  max_leverage: 10               # Maximum leverage multiplier
  min_confidence: 0.65           # Minimum signal confidence (0-1)

  # Stop Loss / Take Profit
  stop_loss_atr_multiplier: 2.0   # SL = entry - (ATR * multiplier)
  take_profit_atr_multiplier: 4.0 # TP = entry + (ATR * multiplier)
  default_stop_loss_pct: 1.5     # 1.5% if ATR not available
  default_take_profit_pct: 3.0   # 3.0% if ATR not available

  # Volatility Filter
  max_atr_percentile: 85         # Don't trade if ATR > 85th percentile
  min_volume_ratio: 1.2          # Volume must be > 1.2x average

position_sizing:
  method: "kelly_fraction"        # Options: kelly_fraction, fixed_fraction, fixed_amount
  kelly_fraction: 0.5            # Use 50% of Kelly (conservative)
  fixed_fraction: 0.1             # 10% of equity if using fixed_fraction

trading_hours:
  enabled: true
  excluded_ranges:               # UTC times to avoid
    - "12:30-13:30"             # Major news events
    - "21:00-23:00"             # Low liquidity periods
```

---

## 6. Trading Decision Workflow

Pseudocode:

```text
FUNCTION tradingLoop():
  WHILE market_open AND not daily_limit_reached:
    candles = MarketDataAgent.getRealtimeData(symbol)

    indicators = TechnicalAnalysisAgent.calculate(candles)

    signal = SignalGeneratorAgent.generate(indicators)

    IF signal.type != "HOLD":
      riskCheck = RiskAssessmentAgent.validate(
        signal=signal,
        portfolio=PortfolioMonitorAgent.getState(),
        candles=candles
      )

      IF riskCheck.approved:
        order = TradeExecutorAgent.execute(signal, riskCheck.positionSize)
        PortfolioMonitorAgent.track(order)
        CONTROLLER.log(`Trade executed: ${order.type} ${order.size}`)
      ELSE:
        CONTROLLER.log(`Risk rejected: ${riskCheck.reason}`)

    CONTROLLER.checkDrawdown()
    SLEEP(1 second)
```

Core invariants:
- No order is executed without `RiskAssessmentAgent.validate()` approval.
- Daily drawdown and max-position limits are checked before entry.
- Order parameters (SL/TP/leverage/size) are computed deterministically from config + live volatility.

---

## 7. Signal Generation Logic

| Condition | Signal | Confidence |
|-----------|--------|------------|
| RSI < 30 + MACD bullish crossover | BUY | 0.8 |
| RSI > 70 + MACD bearish crossover | SELL | 0.8 |
| RSI between 40-60, MACD neutral | HOLD | 1.0 |
| Bollinger lower band touch + volume spike | BUY | 0.75 |
| Price > Upper Bollinger + overbought RSI | SELL | 0.75 |
| EMA 50 crosses above EMA 200 (golden cross) | BUY | 0.85 |
| EMA 50 crosses below EMA 200 (death cross) | SELL | 0.85 |

Confidence gating rules:
- If `signal.confidence < min_confidence` => treat as `HOLD`.
- If reward/risk ratio does not satisfy threshold => reject in RiskAssessmentAgent.

---

## 8. Demo Account Testing Strategy (Puppeteer)

Puppeteer + API validation flow:

```text
DEMO TESTING FLOW:

1. Launch Browser (Puppeteer MCP)
   → Navigate to Bybit demo login
   → Authenticate with demo credentials

2. Verify Account State
   → Check demo balance > $900,000
   → Confirm demo mode active

3. Execute Test Trade
   → Place market order via web UI
   → Verify order confirmation
   → Check position appears in portfolio

4. Verify Data Sync
   → Compare web UI data with API data
   → Confirm real-time updates working

5. Test Risk Controls
   → Attempt over-leveraged trade (should fail)
   → Verify drawdown limit enforcement

6. Generate Test Report
   → Success/failure metrics
   → Execution latency measurements
   → Error scenarios encountered
```

Testing coverage focus:
- UI automation reliability (selectors, latency, page state)
- API/WebSocket consistency (prices and order status)
- Risk-control enforcement (max leverage, drawdown halt, min confidence)

---

## 9. Technical Implementation

| Component | Technology | Notes |
|----------|------------|-------|
| Runtime | Node.js | JavaScript/TypeScript |
| WebSocket | ws / binance-api-node | For real-time data (swap to Bybit adapter) |
| Technical Analysis | technicalindicators | RSI, MACD, Bollinger |
| HTTP Client | axios | REST API calls |
| Browser Automation | Puppeteer | Via MCP server for controlled browser actions |
| State Management | EventEmitter | Agent communication & event bus |

Implementation notes:
- Use a **single event bus** for:
  - `market.candle.updated`
  - `signal.generated`
  - `risk.approved / risk.rejected`
  - `trade.placed / trade.failed`
  - `portfolio.updated`
  - `alert.raised`
- Use backpressure strategies (throttling) on high-frequency updates.
- Maintain a short sliding window per symbol for indicators.

---

## 10. Implementation Phases

| Phase | Duration | Deliverables |
|--------|----------|--------------|
| Phase 1 | Week 1-2 | MarketDataAgent, WebSocket connections, data normalization |
| Phase 2 | Week 3-4 | TechnicalAnalysisAgent, all indicators implemented |
| Phase 3 | Week 5-6 | RiskAssessmentAgent, position sizing algorithms |
| Phase 4 | Week 7-8 | SignalGeneratorAgent, confidence scoring |
| Phase 5 | Week 9-10 | TradeExecutorAgent, order management |
| Phase 6 | Week 11-12 | DemoTesterAgent, Puppeteer integration testing |
| Phase 7 | Week 13-14 | PortfolioMonitorAgent, reporting, alerts |
| Phase 8 | Week 15-16 | Integration testing, live demo trading |

---

## 11. Agent Configuration File Schema

Example JSON schema (config-driven system):

```json
{
  "trading_agent": {
    "name": "TradingController",
    "mode": "primary",
    "steps_limit": 100,
    "platform": {
      "provider": "bybit",
      "api_endpoint": "https://api-demo.bybit.com",
      "websocket_endpoint": "wss://stream.bybit.com/v5/public/spot",
      "demo_mode": true
    },
    "risk": {
      "max_risk_per_trade": 0.02,
      "max_daily_drawdown": 0.05,
      "max_positions": 5,
      "min_reward_risk_ratio": 2.0,
      "max_leverage": 10,
      "min_confidence": 0.65,
      "stop_loss_atr_multiplier": 2.0,
      "take_profit_atr_multiplier": 4.0,
      "default_stop_loss_pct": 1.5,
      "default_take_profit_pct": 3.0,
      "max_atr_percentile": 85,
      "min_volume_ratio": 1.2
    },
    "position_sizing": {
      "method": "kelly_fraction",
      "kelly_fraction": 0.5,
      "fixed_fraction": 0.1
    },
    "trading_hours": {
      "enabled": true,
      "excluded_ranges": [
        "12:30-13:30",
        "21:00-23:00"
      ]
    }
  },
  "subagents": [
    { "name": "MarketDataAgent", "enabled": true },
    { "name": "TechnicalAnalysisAgent", "enabled": true },
    { "name": "RiskAssessmentAgent", "enabled": true },
    { "name": "SignalGeneratorAgent", "enabled": true },
    { "name": "TradeExecutorAgent", "enabled": true },
    { "name": "PortfolioMonitorAgent", "enabled": true },
    { "name": "DemoTesterAgent", "enabled": true }
  ]
}
```

---

## 12. System Interfaces (Recommended Contracts)

While implementation details may vary, each agent should expose stable interfaces to reduce coupling.

### MarketDataAgent
- `connect()`
- `getRealtimeData(symbol)`
- `getOrderBook(symbol)` (optional)

### TechnicalAnalysisAgent
- `calculate(candles)` => `{ indicators, patterns }`

### SignalGeneratorAgent
- `generate(indicators)` => `{ type: BUY|SELL|HOLD, confidence, reasonCodes }`

### RiskAssessmentAgent
- `validate({ signal, portfolio, candles })`
  - returns `{ approved: boolean, reason, positionSize, orderParams }`

### TradeExecutorAgent
- `execute(signal, positionSize)` => `orderStatus`

### PortfolioMonitorAgent
- `getState()`
- `track(order)`

### DemoTesterAgent
- `runSuite()` => aggregated report

---

## 13. Observability & Safety Requirements

Must-have runtime controls:
- **Step limit / iteration cap** for deterministic demo testing.
- **Order audit log**: signal -> risk -> order -> confirmation -> portfolio update.
- **Alerting** when:
  - daily drawdown exceeded (halts trading)
  - risk rejected spikes (possible adapter/bad data)
  - WebSocket reconnect rate exceeds threshold

Recommended metrics:
- execution latency (signal generation -> order placement)
- WebSocket lag (event timestamp deltas)
- indicator compute time
- error rates per agent

---

## 14. Deliverables Summary

The system produces:
- a real-time trading loop with modular agents
- configurable risk management in YAML/JSON
- demo automation using Puppeteer and API/WebSocket cross-checks
- portfolio monitoring and alerting
- phased implementation plan to reach end-to-end demo trading readiness
