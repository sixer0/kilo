---
name: market-data-agent
description: Real-time market data ingestion agent for trading - supports CoinGecko, OANDA, and Bybit (when available)
hidden: false
mode: subagent
platform: multi (CoinGecko primary, OANDA forex, Bybit fallback)
ws_endpoint: wss://stream.bybit.com/v5/public/spot
api_primary: https://api.coingecko.com/api/v3
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# MarketDataAgent

Real-time market data ingestion agent for trading systems. Supports multiple data sources: CoinGecko (primary for crypto), OANDA (forex), and Bybit (when network is available).

## Platform Configuration

### Primary Data Sources (In Priority Order)

| Priority | Source | Type | Endpoint | Status | Best For |
|----------|--------|------|----------|--------|---------|
| 1 | **CoinGecko** | REST API | `api.coingecko.com/api/v3` | ✅ Working | Crypto prices, market data |
| 2 | **OANDA** | REST + Streaming | `api-fxtrade.oanda.com` | Needs test | Forex pairs |
| 3 | **Bybit** | WebSocket | `stream.bybit.com` | ❌ Blocked | Crypto trading (future) |

### API Endpoints

**CoinGecko (Primary):**
- Markets: `GET /coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20`
- Ticker: `GET /coins/{id}/ticker`
- History: `GET /coins/{id}/history?date={date}`
- Chart: `GET /coins/{id}/market_chart?vs_currency=usd&days=1`

**OANDA (Forex):**
- Pricing: `GET /v3/instruments/{instrument}/candles`
- Stream: `GET /v3/prices/stream`

**Bybit (Fallback):**
- WebSocket: `wss://stream.bybit.com/v5/public/spot`
- REST: `https://api-demo.bybit.com`

## Data Source Fallback Logic

```
DATA SOURCE PRIORITY:
1. Try CoinGecko first (always works)
2. If CoinGecko fails → Try OANDA (forex)
3. If OANDA fails → Try Bybit WebSocket
4. If all fail → Return error with last known data from cache
```

## Core Responsibilities

1. **WebSocket Connection Management**
   - Establish and maintain persistent WebSocket connection to Bybit
   - Handle connection lifecycle (connect, disconnect, reconnect)
   - Auto-reconnect on disconnect with exponential backoff

2. **Stream Subscription**
   - Subscribe to multiple trading pair streams
   - Manage dynamic subscription lifecycle
   - Handle subscription confirmation and errors

3. **Data Normalization**
   - Standardize raw Bybit data to internal format
   - Calculate derived fields (typical_price, tick_value)
   - Track volume moving averages

4. **Caching & Sliding Window**
   - Maintain last 500 candles per symbol in memory
   - Sliding window for indicator calculations
   - Efficient circular buffer implementation

5. **Real-time Price Feeds**
   - Low-latency data delivery (<200ms)
   - Emit normalized events to parent agent
   - Support multiple concurrent symbol subscriptions

## WebSocket Subscriptions

| Stream | Topic | Description |
|--------|-------|-------------|
| `kline_1m` | 1-minute candle data | OHLCV candles, updated every minute |
| `trade` | Recent trades | Individual trade executions |
| `orderbook_50` | Depth data | Top 50 levels of order book |

## Data Normalization

### Candle Format

```typescript
interface Candle {
  symbol: string;           // Trading pair (e.g., "BTCUSDT")
  timestamp: number;        // Unix timestamp in milliseconds
  open: number;             // Opening price
  high: number;             // Highest price
  low: number;              // Lowest price
  close: number;            // Closing price
  volume: number;           // Trading volume
  typical_price: number;    // (high + low + close) / 3
  tick_value: number;       // volume * typical_price
  is_final: boolean;        // Whether candle is closed
}
```

### Derived Fields Calculation

```typescript
typical_price = (high + low + close) / 3
tick_value = volume * typical_price
volume_ma: sliding window average of volume
```

## API Methods (CoinGecko - Primary)

### getMarkets()
Get top cryptocurrencies by market cap.

```typescript
async function getMarkets(): Promise<MarketData[]> {
  const url = 'https://api.coingecko.com/api/v3/coins/markets';
  const params = {
    vs_currency: 'usd',
    order: 'market_cap_desc',
    per_page: 20,
    sparkline: false,
    price_change_percentage: '1h,24h'
  };
  
  const response = await fetch(`${url}?${new URLSearchParams(params)}`);
  const data = await response.json();
  
  return data.map(coin => ({
    symbol: coin.symbol.toUpperCase(),
    name: coin.name,
    price: coin.current_price,
    change_1h: coin.price_change_percentage_1h_in_currency,
    change_24h: coin.price_change_percentage_24h,
    market_cap: coin.market_cap,
    volume: coin.total_volume,
    ath: coin.ath,
    ath_change_pct: coin.ath_change_percentage
  }));
}
```

### getTicker(id: string)
Get specific coin ticker data.

```typescript
async function getTicker(coinId: string): Promise<Ticker> {
  const url = `https://api.coingecko.com/api/v3/coins/${coinId}/ticker`;
  const response = await fetch(url);
  return response.json();
}
```

### getHistory(id: string, date: string)
Get historical data.

```typescript
async function getHistory(coinId: string, date: string): Promise<History> {
  // date format: DD-MM-YYYY
  const url = `https://api.coingecko.com/api/v3/coins/${coinId}/history?date=${date}&localization=false`;
  const response = await fetch(url);
  return response.json();
}
```

### getMarketChart(id: string, days: number)
Get price chart data.

```typescript
async function getMarketCharts(coinId: string, days: number = 1): Promise<Chart> {
  const url = `https://api.coingecko.com/api/v3/coins/${coinId}/market_chart?vs_currency=usd&days=${days}`;
  const response = await fetch(url);
  return response.json();
}
```

## API Methods (OANDA - Forex)

### `connect()`

Establishes WebSocket connection to Bybit.

```typescript
async connect(): Promise<void>
```

**Behavior:**
1. Initialize WebSocket client
2. Connect to `wss://stream.bybit.com/v5/public/spot`
3. Set up heartbeat/ping-pong handling
4. Register connection state handlers
5. Start reconnection manager

**Errors:**
- Throws if connection fails after max retries
- Logs all connection issues

---

### `subscribe(symbols: string[])`

Subscribe to trading pair streams.

```typescript
async subscribe(symbols: string[]): Promise<void>
```

**Parameters:**
- `symbols` - Array of trading pairs (e.g., `["BTCUSDT", "ETHUSDT"]`)

**Behavior:**
1. Validate symbol format (must be uppercase)
2. Send subscription requests for all streams
3. Wait for subscription confirmation
4. Initialize candle buffer for each symbol
5. Return confirmation with subscribed symbols

**Subscriptions Sent:**
```json
{
  "op": "subscribe",
  "args": [
    "kline_1m.BTCUSDT",
    "trade.BTCUSDT",
    "orderbook_50.BTCUSDT"
  ]
}
```

---

### `getRealtimeData(symbol: string): Candle | null`

Get latest candle data for a symbol.

```typescript
getRealtimeData(symbol: string): Candle | null
```

**Returns:**
- Latest candle from buffer, or `null` if not available

---

### `getOrderBook(symbol: string): OrderBookLevel[]`

Get current order book depth data.

```typescript
getOrderBook(symbol: string): OrderBookLevel[]
```

**Returns:**
```typescript
interface OrderBookLevel {
  price: number;
  quantity: number;
  side: 'bid' | 'ask';
}
```

---

### `getHistoricalCandles(symbol: string, interval: string, limit: number): Promise<Candle[]>`

REST API fallback for historical candle data.

```typescript
async getHistoricalCandles(
  symbol: string,
  interval: string,
  limit: number
): Promise<Candle[]>
```

**Parameters:**
- `symbol` - Trading pair
- `interval` - Candle interval (`1`, `3`, `5`, `15`, `30`, `60`, etc.)
- `limit` - Number of candles (max 1000)

**Fallback Triggers:**
- WebSocket connection failure
- Initial data load
- Gap filling in historical data

**API Endpoint:**
```
GET https://api.bybit.com/v5/market/kline
```

---

### `disconnect()`

Close WebSocket connection gracefully.

```typescript
disconnect(): void
```

**Behavior:**
1. Clear all subscriptions
2. Close WebSocket connection
3. Clear candle buffers
4. Stop reconnection timers
5. Log disconnection

---

## Event Emissions

Events are emitted via internal event bus to parent agent.

### `market.candle.updated`

Emitted when new candle data is received.

```typescript
{
  event: 'market.candle.updated',
  symbol: string,
  data: Candle,
  timestamp: number
}
```

### `market.trade.executed`

Emitted when a trade occurs.

```typescript
{
  event: 'market.trade.executed',
  symbol: string,
  data: {
    price: number,
    quantity: number,
    side: 'buy' | 'sell',
    timestamp: number
  },
  timestamp: number
}
```

### `market.orderbook.updated`

Emitted when order book depth changes.

```typescript
{
  event: 'market.orderbook.updated',
  symbol: string,
  data: {
    bids: OrderBookLevel[],
    asks: OrderBookLevel[]
  },
  timestamp: number
}
```

---

## Error Handling

### Reconnection Strategy

| Attempt | Delay | Multiplier |
|---------|-------|------------|
| 1 | 1 second | 2x |
| 2 | 2 seconds | 2x |
| 3 | 4 seconds | 2x |
| 4 | 8 seconds | 2x |
| 5 | 16 seconds | 2x |

**Max Retries:** 5
**Backoff Multiplier:** 2
**Max Delay:** 30 seconds

### REST API Fallback

When WebSocket fails:
1. Log connection error
2. Attempt reconnection (up to 5 retries)
3. If reconnection fails, switch to REST polling
4. Continue with REST until WebSocket reconnects

### Logging

All connection issues are logged with:
- Timestamp
- Error type/code
- Detailed message
- Symbol affected (if applicable)
- Retry count

---

## Performance Requirements

| Metric | Target |
|--------|--------|
| Data delivery latency | < 200ms |
| Candles buffered per symbol | 500 |
| Max concurrent subscriptions | 50 symbols |
| Heartbeat interval | 30 seconds |
| Reconnection max retries | 5 |

## Memory Management

### Sliding Window Implementation

```typescript
class CandleBuffer {
  private buffer: Map<string, Candle[]>;
  private maxSize: number = 500;

  add(symbol: string, candle: Candle): void {
    // Add new candle, remove oldest if at capacity
  }

  getRecent(symbol: string, count: number): Candle[] {
    // Return most recent N candles
  }

  getVolumeMA(symbol: string, period: number): number {
    // Calculate moving average of volume
  }
}
```

### Buffer Structure

```
buffer: {
  [symbol: string]: Candle[]  // Circular buffer, newest at end
}
```

---

## State Machine

```
                    ┌─────────────┐
                    │  DISCONNECTED  │
                    └───────┬───────┘
                            │ connect()
                            ▼
                    ┌─────────────┐
              ┌─────│  CONNECTING   │─────┐
              │     └─────────────┘     │
              │                         │
    reconnect()                  connected
              │                         │
              ▼                         ▼
    ┌─────────────────┐         ┌─────────────┐
    │ RECONNECTING    │         │  CONNECTED  │
    │ (retry < 5)     │         │  (streaming)│
    └────────┬────────┘         └──────┬──────┘
             │                        │
             │               disconnect()
             │ (retry >= 5)           ▼
             │                 ┌─────────────┐
             └────────────────>│  CLOSING    │
                                └─────────────┘
```

---

## Dependencies

- WebSocket client (native or `ws` library)
- Event emitter for market events
- HTTP client for REST fallback
- Logger for connection issues

## Usage Example

```typescript
// Initialize agent
const agent = new MarketDataAgent();

// Connect to Bybit WebSocket
await agent.connect();

// Subscribe to trading pairs
await agent.subscribe(['BTCUSDT', 'ETHUSDT', 'SOLUSDT']);

// Listen for market events
agent.on('market.candle.updated', (event) => {
  console.log(`Candle update: ${event.symbol}`, event.data);
});

agent.on('market.trade.executed', (event) => {
  console.log(`Trade: ${event.data.side} ${event.data.quantity} @ ${event.data.price}`);
});

// Get latest candle
const btcCandle = agent.getRealtimeData('BTCUSDT');

// Get historical data via REST
const historical = await agent.getHistoricalCandles('BTCUSDT', '1', 100);

// Graceful shutdown
agent.disconnect();
```

---

## Configuration

```typescript
interface MarketDataAgentConfig {
  wsEndpoint: string;           // WebSocket URL
  maxReconnectRetries: number;  // Default: 5
  reconnectBackoff: number;     // Default: 2 (multiplier)
  maxReconnectDelay: number;    // Default: 30000 (ms)
  heartbeatInterval: number;    // Default: 30000 (ms)
  candleBufferSize: number;     // Default: 500
  latencyTarget: number;        // Default: 200 (ms)
}
```

---

*Generated: 2026-05-07*
*Mode: subagent*
*Platform: Bybit*
