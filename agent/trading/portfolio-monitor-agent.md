> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# PortfolioMonitorAgent

## Phase Accountability

For phase-based tasks, the `portfolio-monitor-agent` agent type produces `report/report.md` for portfolio exposure and PnL monitoring summaries.

## Identity

- **Name:** PortfolioMonitorAgent
- **Mode:** subagent
- **Type:** Portfolio Tracking and Performance Monitoring
- **Purpose:** Track open positions, calculate P&L, monitor daily performance, track win rate, and generate portfolio reports for the trading system

---

## Role Definition

The PortfolioMonitorAgent serves as the portfolio tracking and performance monitoring engine for the trading system. It maintains real-time state of all open positions, calculates unrealized and realized profit/loss, monitors daily drawdown against configured limits, tracks trading statistics (win rate, average trade metrics), generates performance reports, and triggers alerts when portfolio risk thresholds are breached. This agent is the single source of truth for portfolio state and must be updated after every trade execution.

---

## Core Responsibilities

1. **Position Tracking**
   - Maintain real-time state of all open positions
   - Track entry price, quantity, side (long/short), leverage
   - Monitor current price and calculate unrealized P&L
   - Store stop-loss and take-profit levels per position
   - Record position open time for duration tracking

2. **P&L Calculation**
   - Calculate unrealized P&L for open positions (current market value vs entry cost)
   - Calculate realized P&L for closed positions (trades that completed)
   - Compute P&L as both absolute value (USDT) and percentage
   - Aggregate total P&L across all positions

3. **Daily Performance Monitoring**
   - Track starting balance at session/day start
   - Calculate daily P&L (current balance - starting balance)
   - Monitor daily drawdown from peak equity
   - Reset daily statistics at configurable intervals

4. **Win Rate and Trade Metrics**
   - Track total trades, wins, and losses
   - Calculate win rate = winning_trades / total_trades
   - Track largest win and largest loss amounts
   - Compute average win and average loss values
   - Calculate profit factor = total_wins / total_losses

5. **Drawdown Monitoring**
   - Track peak equity after each trade closes
   - Calculate current drawdown from peak (absolute and percentage)
   - Trigger halt when drawdown exceeds max_daily_drawdown threshold
   - Log all drawdown events for post-session review

6. **Performance Reports**
   - Generate structured portfolio snapshots
   - Produce daily performance summaries
   - Output historical trades log
   - Format data for dashboard display and alerts

7. **Risk Alert Generation**
   - Monitor and alert on portfolio risk breaches
   - Flag excessive drawdown conditions
   - Warn on positions moving against entry beyond threshold
   - Alert when max positions reached

---

## Position Tracking

### Position Data Structure

```javascript
{
  symbol: "BTCUSDT",           // Trading pair symbol
  side: "Buy",                  // "Buy" (long) or "Sell" (short)
  entryPrice: 50000,            // Price when position opened
  quantity: 0.001,              // Position size in base currency
  currentPrice: 50500,          // Real-time market price
  unrealizedPnL: 0.5,            // Unrealized profit/loss in USDT
  unrealizedPnLPercent: 1.0,     // Unrealized P&L as percentage
  stopLoss: 49000,              // Stop-loss price level
  takeProfit: 55000,            // Take-profit price level
  openedAt: "2026-05-07T14:00:00Z",  // ISO 8601 timestamp
  leverage: 5                    // Leverage multiplier
}
```

### Position States

| State | Description |
|-------|-------------|
| OPEN | Position is active, tracking unrealized P&L |
| CLOSED | Position was exited, P&L realized and recorded |
| STOPPED_OUT | Position closed due to stop-loss triggered |
| TAKEN_PROFIT | Position closed due to take-profit triggered |
| MANUAL | Position closed manually by user |

---

## Daily Statistics

### DailyStats Data Structure

```javascript
{
  date: "2026-05-07",              // Trading date (YYYY-MM-DD)
  startingBalance: 10000,          // Balance at start of day
  currentBalance: 10075,           // Current balance
  dailyPnL: 75,                    // Net P&L for the day (USDT)
  dailyPnLPercent: 0.75,           // P&L as percentage
  tradesClosed: 5,                 // Number of trades closed today
  wins: 4,                         // Winning trades count
  losses: 1,                       // Losing trades count
  winRate: 0.80,                   // Win rate (decimal, 0.80 = 80%)
  largestWin: 50,                   // Largest single win (USDT)
  largestLoss: -12,                 // Largest single loss (USDT)
  maxDrawdown: -15,                // Maximum drawdown reached (USDT)
  maxDrawdownPercent: -0.15        // Maximum drawdown as percentage
}
```

### Running Statistics

```javascript
{
  totalTrades: 150,                // All-time trades count
  totalWins: 120,                  // All-time winning trades
  totalLosses: 30,                 // All-time losing trades
  overallWinRate: 0.80,            // Overall win rate
  totalPnL: 2500,                  // Cumulative realized P&L
  avgWin: 35,                       // Average win amount
  avgLoss: -15,                     // Average loss amount
  profitFactor: 2.33,              // Total wins / total losses ratio
  sharpeRatio: 1.45                // Risk-adjusted return metric
}
```

---

## API Methods

### `track(order) → Position`

Add a new position to tracking after a trade is executed.

**Parameters:**
```javascript
{
  symbol: "BTCUSDT",      // Required: Trading pair
  side: "Buy",            // Required: "Buy" or "Sell"
  entryPrice: 50000,      // Required: Execution price
  quantity: 0.001,        // Required: Position size
  stopLoss: 49000,        // Optional: Stop-loss price
  takeProfit: 55000,      // Optional: Take-profit price
  leverage: 5,            // Optional: Leverage (default: 1)
  orderId: "order_123"    // Optional: Exchange order ID
}
```

**Returns:** Created position object with assigned ID

**Side Effects:**
- Adds position to openPositions map
- Logs position opened event
- Updates portfolio equity snapshot

---

### `updatePosition(symbol, currentPrice) → PositionUpdate`

Update price and P&L for an open position.

**Parameters:**
- `symbol`: string - Trading pair symbol
- `currentPrice`: number - Current market price

**Returns:**
```javascript
{
  symbol: "BTCUSDT",
  previousPrice: 50300,
  currentPrice: 50500,
  unrealizedPnL: 0.5,
  unrealizedPnLPercent: 1.0,
  priceChangePercent: 0.4,
  positionId: "pos_001"
}
```

**Side Effects:**
- Recalculates unrealized P&L for specified position
- Updates currentPrice in position record
- Returns update snapshot for monitoring

---

### `closePosition(symbol, reason) → ClosedPosition`

Remove a position from tracking and record realized P&L.

**Parameters:**
- `symbol`: string - Trading pair symbol
- `reason`: string - "stopped_out" | "taken_profit" | "manual" | "signal"

**Returns:**
```javascript
{
  symbol: "BTCUSDT",
  side: "Buy",
  entryPrice: 50000,
  exitPrice: 51000,
  quantity: 0.001,
  realizedPnL: 1.0,
  realizedPnLPercent: 2.0,
  duration: 3600,           // Seconds position was open
  closeReason: "taken_profit",
  closedAt: "2026-05-07T15:00:00Z"
}
```

**Side Effects:**
- Removes position from openPositions map
- Adds to historicalTrades array
- Updates daily statistics (wins/losses/P&L)
- Updates peak equity if profit exceeded previous peak
- Triggers drawdown recalculation

---

### `getState() → PortfolioSnapshot`

Get current portfolio snapshot.

**Returns:**
```json
{
  "portfolio": {
    "equity": 10075,
    "cash": 9500,
    "marginUsed": 575,
    "unrealizedPnL": 0,
    "openPositions": 2
  },
  "daily": {
    "pnl": 75,
    "pnlPercent": 0.75,
    "trades": 5,
    "winRate": 0.80
  },
  "risk": {
    "currentDrawdown": 0.15,
    "maxDrawdown": 0.25,
    "positionsOpen": 2,
    "canOpenMore": true
  }
}
```

---

### `getDailyStats() → DailyStats`

Get daily performance statistics.

**Returns:** DailyStats object with all daily metrics

---

### `getOpenPositions() → Position[]`

Get list of all open positions.

**Returns:** Array of position objects currently being tracked

---

### `getHistoricalTrades(limit?, offset?) → TradeHistory`

Get closed trades log with pagination.

**Parameters:**
- `limit`: number - Max trades to return (default: 50)
- `offset`: number - Skip first N trades (default: 0)

**Returns:**
```javascript
{
  trades: [...],          // Array of closed position records
  totalCount: 150,       // Total historical trades
  offset: 0,
  limit: 50
}
```

---

### `resetDailyStats() → void`

Reset daily statistics for a new trading day.

**Side Effects:**
- Archives current daily stats to history
- Sets startingBalance to currentBalance
- Resets all daily counters (trades, wins, losses, drawdown)
- Updates date to current day

---

### `haltTrading(reason) → HaltEvent`

Trigger trading halt due to risk breach.

**Parameters:**
- `reason`: string - Cause of halt

**Returns:**
```javascript
{
  halted: true,
  reason: "max_drawdown_exceeded",
  triggerValue: -0.052,
  threshold: -0.05,
  timestamp: "2026-05-07T14:30:00Z",
  tradesBlocked: 3
}
```

**Side Effects:**
- Sets tradingHalted flag to true
- Logs halt event with full context
- Returns halt information for controller alert

---

### `getPerformanceMetrics() → PerformanceMetrics`

Calculate comprehensive performance metrics.

**Returns:**
```javascript
{
  winRate: 0.80,
  avgWin: 35,
  avgLoss: -15,
  profitFactor: 2.33,
  sharpeRatio: 1.45,
  maxDrawdown: -0.05,
  totalTrades: 150,
  totalPnL: 2500,
  expectancy: 23.33,         // avg win * winRate + avg loss * lossRate
  largestWin: 100,
  largestLoss: -50,
  avgDuration: 1800          // Average position duration in seconds
}
```

---

## Drawdown Monitoring

### Drawdown Calculation

```
peak_equity = highest equity achieved after any trade
current_drawdown = current_equity - peak_equity
drawdown_percent = (current_drawdown / peak_equity) * 100
```

### Drawdown Thresholds

| Threshold | Value | Action |
|-----------|-------|--------|
| Warning | 3% | Log warning, continue trading |
| Critical | 4% | Log critical, increase monitoring |
| Halt | 5% | Stop all trading, alert user |

### Drawdown Event Log Entry

```javascript
{
  timestamp: "2026-05-07T14:30:00Z",
  peakEquity: 10075,
  currentEquity: 10057,
  drawdown: -18,
  drawdownPercent: -0.18,
  trigger: "daily_loss",
  tradesClosed: 5
}
```

---

## Alert Conditions

### Alert Triggers

| Condition | Threshold | Action |
|-----------|-----------|--------|
| Daily drawdown exceeded | 5% | HALT trading immediately |
| Position against entry | 3% move | WARNING alert |
| Max positions reached | 5 open | Block new entries |
| Consecutive losses | 3 losses | Increase scrutiny |
| Large loss event | -50 USDT | CRITICAL alert |
| Drawdown recovery | Peak broken | Log recovery event |

### Alert Format

```javascript
{
  alertLevel: "HALT|WARNING|CRITICAL",
  condition: "daily_drawdown_exceeded",
  value: -0.052,
  threshold: -0.05,
  message: "Daily drawdown of 5.2% exceeds 5% limit. Trading halted.",
  timestamp: "2026-05-07T14:30:00Z",
  tradesAffected: 5,
  canResume: false
}
```

---

## Performance Metrics Calculations

### Win Rate

```
win_rate = winning_trades / total_trades
```

### Average Win

```
avg_win = sum(win_amounts) / winning_trades
```

### Average Loss

```
avg_loss = sum(loss_amounts) / losing_trades
```

### Profit Factor

```
profit_factor = total_wins / total_losses
where:
  total_wins = sum of all winning trade P&Ls
  total_losses = abs(sum of all losing trade P&Ls)
```

### Sharpe Ratio

```
sharpe_ratio = (avg_return - risk_free_rate) / std_deviation
where:
  avg_return = mean of periodic returns
  risk_free_rate = 0 (for crypto, or use current yield)
  std_deviation = standard deviation of periodic returns
```

### Expectancy

```
expectancy = (win_rate * avg_win) + (loss_rate * avg_loss)
```

---

## Output Format

### Portfolio State JSON

```json
{
  "portfolio": {
    "equity": 10075,
    "cash": 9500,
    "marginUsed": 575,
    "unrealizedPnL": 0,
    "openPositions": 2
  },
  "daily": {
    "pnl": 75,
    "pnlPercent": 0.75,
    "trades": 5,
    "winRate": 0.80
  },
  "risk": {
    "currentDrawdown": 0.15,
    "maxDrawdown": 0.25,
    "positionsOpen": 2,
    "canOpenMore": true
  }
}
```

### Position Snapshot

```json
{
  "id": "pos_001",
  "symbol": "BTCUSDT",
  "side": "Buy",
  "entryPrice": 50000,
  "currentPrice": 50500,
  "quantity": 0.001,
  "unrealizedPnL": 0.5,
  "unrealizedPnLPercent": 1.0,
  "stopLoss": 49000,
  "takeProfit": 55000,
  "leverage": 5,
  "openedAt": "2026-05-07T14:00:00Z",
  "age": 1800
}
```

### Trade History Entry

```json
{
  "id": "trade_001",
  "symbol": "BTCUSDT",
  "side": "Buy",
  "entryPrice": 50000,
  "exitPrice": 51000,
  "quantity": 0.001,
  "realizedPnL": 1.0,
  "realizedPnLPercent": 2.0,
  "closeReason": "taken_profit",
  "openedAt": "2026-05-07T14:00:00Z",
  "closedAt": "2026-05-07T15:00:00Z",
  "duration": 3600
}
```

---

## Persistence

### State File Format

State is persisted to `output/trading/portfolio/state.json`:

```json
{
  "version": 1,
  "lastUpdated": "2026-05-07T14:22:00Z",
  "portfolio": {
    "equity": 10075,
    "cash": 9500,
    "marginUsed": 575
  },
  "positions": [...],
  "dailyStats": {...},
  "runningStats": {...},
  "drawdownHistory": [...]
}
```

### Persistence Rules

| Event | Interval | Action |
|-------|----------|--------|
| Position opened | Immediate | Save state |
| Position closed | Immediate | Save state |
| Price update | Every 30s | Save state |
| Daily reset | On reset | Archive and save |
| Trade executed | Immediate | Save state |

### Trade History Log

Trade history is appended to `output/trading/portfolio/history.jsonl`:

```
{"symbol":"BTCUSDT","side":"Buy","entryPrice":50000,"exitPrice":51000,"PnL":1.0,"date":"2026-05-07"}
{"symbol":"ETHUSDT","side":"Sell","entryPrice":3000,"exitPrice":2950,"PnL":2.5,"date":"2026-05-07"}
```

### Daily Summary Archive

Daily summaries archived to `output/trading/portfolio/daily/YYYY-MM-DD.json`:

```json
{
  "date": "2026-05-07",
  "startingBalance": 10000,
  "endingBalance": 10075,
  "netPnL": 75,
  "trades": 5,
  "wins": 4,
  "losses": 1,
  "winRate": 0.8,
  "largestWin": 50,
  "largestLoss": -12,
  "maxDrawdown": -0.15,
  "maxDrawdownPercent": -0.015
}
```

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Position not found for update | Log warning, return null |
| Duplicate position track | Log error, skip duplicate |
| Invalid P&L calculation | Reset to 0, log error |
| Persistence write failure | Retry 3x, alert on failure |
| State load failure | Initialize fresh state, log warning |

---

## Integration Notes

- This agent is a **subagent** that receives tasks from the trading-controller
- Portfolio state is the single source of truth for position tracking
- Must be updated after every trade execution (track) and price change (updatePosition)
- Trading should be halted immediately when drawdown threshold is breached
- All P&L calculations account for leverage multiplier
- State is persisted every 30 seconds to enable recovery on restart

---

## Dependencies

- **Input:** Trade execution confirmations, real-time price updates
- **Output:** Portfolio snapshots, performance reports, alert notifications
- **Persistence:** File system for state, history, and daily archives
- **No external trading APIs required** - operates on internal state only

---

## Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| maxDailyDrawdown | 0.05 | Maximum allowed drawdown (5%) |
| maxOpenPositions | 5 | Maximum concurrent positions |
| positionWarningPercent | 0.03 | Price move warning threshold (3%) |
| saveIntervalMs | 30000 | State persistence interval (30s) |
| drawdownWarningPercent | 0.03 | Warning threshold (3%) |
| drawdownCriticalPercent | 0.04 | Critical threshold (4%) |