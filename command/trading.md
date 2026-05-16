---
description: Real-time market analysis and trading execution with intelligent risk management
agent: trading-controller
model: kilo/minimax/minimax-m2.7
subtask: false
---

Real-time market analysis and trading execution with intelligent risk management: $ARGUMENTS

## Command Definition

**Command:** `/trading`
**Purpose:** Trading system management with real-time market analysis, automated execution, and risk-controlled portfolio management

## Architecture Overview

```
User Input (/trading command)
       ↓
TradingController (orchestrates all trading activities)
       ↓
┌─────────────────────────────────────────────────────────┐
│  Sub-Agents (delegated via Task())                      │
├─────────────────────────────────────────────────────────┤
│  market-data-agent      - Real-time price feeds         │
│  technical-analysis-agent - Chart patterns, indicators  │
│  signal-generator-agent  - Buy/sell signals             │
│  trade-executor-agent    - Order execution              │
│  portfolio-monitor-agent  - Position tracking            │
│  risk-assessment-agent   - Risk calculations            │
│  demo-tester-agent       - Demo validation              │
└─────────────────────────────────────────────────────────┘
       ↓
User Approval Gate (required before any trade)
       ↓
Execution → Monitoring → Reporting
```

## Sub-Commands

| Sub-command | Description |
|-------------|-------------|
| `start [symbol]` | Start trading session (default: all pairs or specified pair) |
| `stop` | Emergency halt - closes all positions immediately |
| `status` | Display portfolio overview and open positions |
| `stats` | Show daily/weekly/monthly performance statistics |
| `risk` | Risk parameter management and display |
| `test` | Run demo account validation suite |
| `demo` | Switch to demo trading mode |
| `live` | Switch to live trading mode |
| `profit [target]` | Set monthly profit target |
| `help` | Show all available commands |

## Usage Examples

```
/trading start           - Start trading session with default settings
/trading start BTCUSDT   - Start trading on specific pair (BTC/USDT)
/trading start ETHUSDT   - Start trading on ETH/USDT pair
/trading stop            - Halt all trading immediately
/trading status          - Show current portfolio and open positions
/trading stats           - Show daily performance statistics
/trading risk            - Show current risk parameters
/trading risk set max_drawdown=3%  - Update risk parameters
/trading test            - Run full demo account validation suite
/trading test order      - Test single order execution
/trading demo            - Switch to demo trading mode
/trading live            - Switch to live trading mode
/trading profit 10%      - Set monthly profit target (10%)
/trading help            - Show all available commands
```

## Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `symbol` | string | Trading pair (e.g., BTCUSDT, ETHUSDT) | All pairs |
| `mode` | string | Trading mode: `demo` or `live` | demo |
| `risk_profile` | string | Risk tolerance: `conservative`, `moderate`, `aggressive` | moderate |

### Valid Trading Pairs

```
Major Pairs:     BTCUSDT, ETHUSDT, BNBUSDT, SOLUSDT, XRPUSDT
Alt Pairs:       ADAUSDT, DOGEUSDT, DOTUSDT, MATICUSDT, LTCUSDT
```

## Workflow Integration

### TradingController Responsibilities

1. **Session Management** - Initialize and maintain trading sessions
2. **Agent Orchestration** - Delegate to sub-agents via `Task()`
3. **User Approval Gate** - Always enforce user approval before trade execution
4. **Risk Monitoring** - Continuous risk assessment during trading
5. **Error Recovery** - Handle failures with appropriate fallback strategies

### Delegation Flow

```
TradingController
    ├── Task(market-data-agent)     → Fetch real-time prices
    ├── Task(technical-analysis-agent) → Analyze charts/patterns
    ├── Task(signal-generator-agent) → Generate trading signals
    ├── Task(risk-assessment-agent)  → Validate risk parameters
    ├── Task(trade-executor-agent)   → Execute approved trades
    └── Task(portfolio-monitor-agent) → Track positions/PnL
```

### User Approval Requirement

**MANDATORY:** No trade is executed without explicit user approval.

```
Signal Generated → Risk Assessment → Approval Request → User Confirms → Execute
                                         ↓
                                   User Rejects → Log and Skip
```

## Error Handling

### Error Scenarios and Responses

| Error | Response |
|-------|----------|
| **Invalid symbol** | List available trading pairs and prompt for valid symbol |
| **Risk parameter out of range** | Display valid parameter ranges and current settings |
| **Connection failure** | Retry with exponential backoff (1s, 2s, 4s, 8s, max 30s) |
| **Insufficient balance** | Show current balance and required amount |
| **Market closed** | Display market hours and next opening time |
| **Rate limit exceeded** | Queue requests with appropriate delay |
| **Demo mode required** | Prompt to switch to demo mode for testing |

### Retry Strategy

```
Attempt 1: Immediate
Attempt 2: Wait 1 second
Attempt 3: Wait 2 seconds
Attempt 4: Wait 4 seconds
Attempt 5: Wait 8 seconds
After 5 failures: Report failure with diagnostic information
```

## Command Workflows

### `/trading start [symbol]`

```
1. Validate symbol (if provided)
2. Check current trading mode (demo/live)
3. Verify account has sufficient balance
4. Initialize MarketDataAgent for real-time feeds
5. Start trading loop:
   a. Fetch current market data
   b. Run technical analysis
   c. Generate signals
   d. Assess risk
   e. Request user approval (if signal actionable)
   f. Execute trade (if approved)
   g. Update portfolio
   h. Log transaction
6. Return session ID and status
```

### `/trading stop`

```
1. Log stop request with timestamp
2. Close all open positions at market price
3. Cancel all pending orders
4. Halt trading loop
5. Final portfolio snapshot
6. Generate stop report (positions closed,PnL impact)
7. Log stop reason (user request / risk limit / error)
```

### `/trading status`

```
1. Query portfolio for all positions
2. Get real-time prices for open positions
3. Calculate unrealized PnL per position
4. Calculate total portfolio value
5. Display:
   - Total balance
   - Open positions with entry price, current price, PnL
   - Margin used (if leveraged)
   - Available balance
   - Current mode (demo/live)
```

### `/trading stats`

```
1. Fetch trade history for specified period (default: today)
2. Calculate:
   - Total trades executed
   - Win rate (profitable trades / total trades)
   - Average profit per trade
   - Largest win / largest loss
   - Current streak (winning/losing)
   - Monthly return percentage
3. Display performance chart (if applicable)
4. Compare with benchmark (if set)
```

### `/trading risk set max_drawdown=X%`

```
1. Parse risk parameter and value
2. Validate against allowed ranges:
   - max_drawdown: 1% - 10% (default: 5%)
   - max_position_size: 1% - 25% of portfolio (default: 10%)
   - max_daily_loss: 1% - 15% (default: 8%)
   - stop_loss: 0.5% - 5% per trade (default: 2%)
3. Update risk parameters
4. Display confirmation with new settings
5. Log parameter change
```

### `/trading test`

```
1. Launch DemoTesterAgent
2. Run full validation suite:
   a. API connectivity test
   b. Order placement test (paper)
   c. Order cancellation test
   d. Balance update test
   e. Price feed test
   f. Risk calculation test
3. Generate test report:
   - Tests passed / failed
   - Latency measurements
   - Error details (if any)
4. Recommend next steps
```

### `/trading test order`

```
1. Launch DemoTesterAgent with single-order focus
2. Execute test order (paper, no real fund)
3. Verify:
   - Order acknowledgment received
   - Order status updates correctly
   - Balance is updated correctly
   - Confirmation displayed
4. Report single-order test results
```

### `/trading demo` / `/trading live`

```
1. Confirm mode switch
2. For live mode:
   a. Display risk warning
   b. Require explicit acknowledgment
   c. Verify API keys configured
   d. Switch to live trading
3. For demo mode:
   a. Switch to paper trading
   b. Maintain separate demo balance
4. Log mode change with timestamp
5. Update all agent configurations
```

### `/trading profit 10%`

```
1. Parse profit target percentage
2. Validate range (1% - 50% monthly)
3. Store as trading objective
4. Adjust risk parameters if needed to match target
5. Display updated settings and timeline
6. Log profit target
```

## Output Format Examples

### Trading Started

```
TRADING_SESSION_STARTED

Session ID: [uuid]
Symbol: BTCUSDT
Mode: demo
Started: [timestamp]
Risk Profile: moderate
Profit Target: 10%/month

Monitoring active. You will be asked to approve each trade.
```

### Trading Stopped

```
TRADING_SESSION_STOPPED

Reason: user_request
Timestamp: [timestamp]

Closed Positions: [count]
Cancelled Orders: [count]
Session PnL: [amount]
Duration: [time]

Run /trading status for final portfolio details.
```

### Position Status

```
PORTFOLIO_STATUS

Balance: $10,000.00 USDT
Mode: demo

Open Positions:
| Symbol   | Side | Entry    | Current  | PnL   | PnL % |
|----------|------|----------|----------|-------|-------|
| BTCUSDT  | LONG | 67,500   | 68,200   | +$70  | +1.0% |
| ETHUSDT  | LONG | 3,800    | 3,750    | -$10  | -0.3% |

Total PnL: +$60.00
Available: $9,890.00
```

### Risk Parameters

```
RISK_PARAMETERS

Profile: moderate
├── max_drawdown: 5%
├── max_position_size: 10%
├── max_daily_loss: 8%
├── stop_loss: 2%
└── take_profit: 5%

Current Exposure: 3.2%
Daily Loss: 0.8%
Risk Status: ✅ WITHIN LIMITS
```

### Test Report

```
DEMO_TEST_COMPLETE

Test Suite Results:
✅ API Connectivity          - 45ms latency
✅ Order Placement           - 120ms
✅ Order Cancellation        - 95ms
✅ Balance Updates           - Verified
✅ Price Feed                - Live
✅ Risk Calculations         - Verified

Status: ALL TESTS PASSED
Demo account validated successfully.
Ready for paper trading.
```

## Safety Features

### Automatic Protections

1. **Maximum Drawdown Limit** - Auto-stop if losses exceed threshold
2. **Position Size Limits** - Prevent over-concentration
3. **Daily Loss Limit** - Halt if daily losses exceed limit
4. **Emergency Stop** - Instant halt capability via `/trading stop`
5. **Approval Gates** - All trades require user confirmation

### Risk Warnings

- Displayed when switching to live mode
- Displayed when profit target exceeds reasonable limits
- Displayed when risk parameters are modified

## Notes

- Trading execution is simulated in demo mode with paper money
- All real trades require explicit user approval
- Risk parameters are enforced across all trading sessions
- Connection failures trigger automatic retry with backoff