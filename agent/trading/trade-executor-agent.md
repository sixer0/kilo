---
name: trade-executor-agent
description: Order execution agent for trading system
hidden: false
mode: subagent
platform: Bybit
rest_endpoint: https://api-demo.bybit.com
ws_endpoint: wss://stream.bybit.com/v5/private
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# TradeExecutorAgent

Order execution agent for trading systems. Executes market and limit orders on Bybit, handles order confirmation, manages order state transitions, tracks fills via WebSocket, and maintains execution metrics.

## Phase Accountability

For phase-based tasks, the `trade-executor-agent` agent type produces `report/report.md` only when explicitly delegated for trading operations. It must include execution decisions, order outcomes, and any risk rejections.

## Platform

**Exchange:** Bybit
**REST Endpoint:** `https://api-demo.bybit.com`
**WebSocket Endpoint:** `wss://stream.bybit.com/v5/private`

---

## Core Responsibilities

1. **Order Execution**
   - Place market and limit orders via Bybit REST API
   - Calculate order parameters (size, leverage, SL/TP)
   - Validate order parameters before submission
   - Handle order confirmation and acknowledgment

2. **Order State Management**
   - Track order lifecycle (PENDING → FILLED/PARTIALLY_FILLED/FAILED/CANCELLED)
   - Monitor order status via WebSocket updates
   - Manage state transitions and persist order history

3. **Fill Tracking**
   - Subscribe to WebSocket `order.fill` stream for real-time fill data
   - Track partial fills and aggregate fill information
   - Update positions on fill confirmation

4. **Position Management**
   - Monitor open positions via REST API
   - Attach SL/TP orders to positions
   - Track position updates via WebSocket

5. **Execution Metrics**
   - Track execution latency (target < 500ms)
   - Monitor fill rate (target > 99%)
   - Track retry rate (alert if > 5%)
   - Log all order attempts with timestamps

6. **Error Handling**
   - Retry on transient failures (max 3 retries)
   - Log all order attempts with detailed context
   - Alert on persistent failures
   - Defensive validation - never execute if risk check fails

---

## API Endpoints

### REST Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v5/order/create` | Create a new order |
| GET | `/v5/order/realtime` | Get order information |
| POST | `/v5/order/cancel` | Cancel a pending order |
| GET | `/v5/position/list` | Get open positions |

### WebSocket Streams

| Stream | Topic | Description |
|--------|-------|-------------|
| `order.fill` | Order fill updates | Real-time fill notifications |
| `position.update` | Position changes | Position opened/closed/updated |

---

## Order Parameters

```typescript
interface OrderParams {
  category: 'spot' | 'linear';    // spot or linear (futures)
  symbol: string;                   // Trading pair (e.g., "BTCUSDT")
  side: 'Buy' | 'Sell';            // Order direction
  orderType: 'Market' | 'Limit';   // Order type
  qty: string;                      // Order quantity
  price?: string;                  // Required for limit orders
  stopLoss?: string;               // Optional stop loss price
  takeProfit?: string;             // Optional take profit price
  leverage?: string;                // Leverage level (for futures/margin)
}
```

---

## API Methods

### `execute(signal: TradingSignal, params: ExecutionParams): Promise<ExecutionResult>`

Execute a trading signal as an order.

```typescript
async execute(
  signal: TradingSignal,
  params: ExecutionParams
): Promise<ExecutionResult>
```

**Parameters:**
- `signal` - Trading signal with symbol, side, and optional price/qty
- `params` - Execution parameters including leverage, SL/TP, order type

**Behavior:**
1. Validate signal and calculate order parameters
2. Perform risk checks before execution
3. Call Bybit create order API
4. Store order in tracking state
5. Wait for WebSocket fill notification (timeout: 30s)
6. Return execution confirmation with fill details

**Returns:**
```typescript
interface ExecutionResult {
  success: boolean;
  orderId: string | null;
  symbol: string;
  side: 'Buy' | 'Sell';
  type: 'Market' | 'Limit';
  qty: string;
  price: number | null;
  fillPrice: number | null;
  fees: number;
  executionLatency: number;
  status: OrderStatus;
  timestamp: string;
  error?: string;
}
```

**Errors:**
- Throws `RiskCheckFailedError` if risk validation fails
- Throws `OrderRejectedError` if Bybit rejects the order
- Throws `ExecutionTimeoutError` if fill not received within timeout

---

### `placeMarketOrder(symbol: string, side: string, quantity: string, sl?: string, tp?: string): Promise<ExecutionResult>`

Place a market order with optional SL/TP.

```typescript
async placeMarketOrder(
  symbol: string,
  side: 'Buy' | 'Sell',
  quantity: string,
  sl?: string,
  tp?: string
): Promise<ExecutionResult>
```

**Parameters:**
- `symbol` - Trading pair (e.g., "BTCUSDT")
- `side` - Order direction ("Buy" or "Sell")
- `quantity` - Order quantity
- `sl` - Optional stop loss price
- `tp` - Optional take profit price

**Behavior:**
1. Validate all parameters
2. Build order payload with category detection
3. Set leverage for futures orders
4. Submit via `/v5/order/create`
5. Track order until filled or failed
6. Return execution result with fees and latency

**API Payload:**
```json
{
  "category": "spot",
  "symbol": "BTCUSDT",
  "side": "Buy",
  "orderType": "Market",
  "qty": "0.001",
  "stopLoss": "49000",
  "takeProfit": "55000"
}
```

---

### `placeLimitOrder(symbol: string, side: string, price: string, quantity: string): Promise<ExecutionResult>`

Place a limit order at specified price.

```typescript
async placeLimitOrder(
  symbol: string,
  side: 'Buy' | 'Sell',
  price: string,
  quantity: string
): Promise<ExecutionResult>
```

**Parameters:**
- `symbol` - Trading pair
- `side` - Order direction
- `price` - Limit price
- `quantity` - Order quantity

**API Payload:**
```json
{
  "category": "spot",
  "symbol": "BTCUSDT",
  "side": "Buy",
  "orderType": "Limit",
  "qty": "0.001",
  "price": "50000"
}
```

---

### `cancelOrder(orderId: string, symbol?: string): Promise<CancelResult>`

Cancel a pending order.

```typescript
async cancelOrder(orderId: string, symbol?: string): Promise<CancelResult>
```

**Parameters:**
- `orderId` - Order ID to cancel
- `symbol` - Optional symbol for faster lookup

**Returns:**
```typescript
interface CancelResult {
  success: boolean;
  orderId: string;
  timestamp: string;
  error?: string;
}
```

**Behavior:**
1. Validate order ID
2. Call Bybit cancel API
3. Update local order state
4. Return cancellation result

---

### `getOrderStatus(orderId: string): Promise<OrderInfo>`

Get current status of an order.

```typescript
async getOrderStatus(orderId: string): Promise<OrderInfo>
```

**Returns:**
```typescript
interface OrderInfo {
  orderId: string;
  symbol: string;
  side: 'Buy' | 'Sell';
  orderType: 'Market' | 'Limit';
  qty: string;
  price: string;
  avgPrice: string;
  status: OrderStatus;
  filledQty: string;
  createTime: string;
  updateTime: string;
}
```

---

### `getOpenOrders(symbol?: string): Promise<OrderInfo[]>`

List all open orders.

```typescript
async getOpenOrders(symbol?: string): Promise<OrderInfo[]>
```

**Parameters:**
- `symbol` - Optional filter by trading pair

**Returns:**
- Array of open order objects

---

### `getPositions(symbol?: string): Promise<Position[]>`

List open positions.

```typescript
async getPositions(symbol?: string): Promise<Position[]>
```

**Returns:**
```typescript
interface Position {
  symbol: string;
  side: 'Buy' | 'Sell';
  size: string;
  entryPrice: string;
  leverage: string;
  unrealizedPnl: string;
  stopLoss: string;
  takeProfit: string;
}
```

---

### `calculateFees(orderValue: number, category: 'spot' | 'linear'): number`

Estimate trading fees for an order.

```typescript
calculateFees(orderValue: number, category: 'spot' | 'linear'): number
```

**Fee Structure:**
| Category | Maker Fee | Taker Fee |
|----------|-----------|-----------|
| spot | 0.1% | 0.1% |
| linear | 0.02% | 0.05% |

---

## Order State Machine

```
                           ┌──────────────────────────────────────┐
                           │                                      │
                           ▼                                      │
┌──────────┐    submit    ┌──────────┐    fill received    ┌─────────────┐
│  PENDING │─────────────>│ SUBMITTED │──────────────────>│    FILLED   │
└──────────┘              └──────────┘                    └─────────────┘
     │                         │
     │                         │ partial fill
     │                         ▼
     │                   ┌─────────────────┐
     │                   │PARTIALLY_FILLED│──────────> (continues until FILLED)
     │                   └─────────────────┘
     │
     │                         │
     │ cancel request          │ reject
     │                         ▼
     │                   ┌──────────┐
     └──────────────────>│ CANCELLED│
                         └──────────┘
                               │
                               ▼
                         ┌──────────┐
                         │  FAILED  │
                         └──────────┘
                               │
                               │ retry (max 3)
                               ▼
                         ┌──────────┐
                         │ RETRYING │
                         └──────────┘
```

---

## Execution Flow

```
1. VALIDATE PARAMETERS
   ├── Verify symbol format (uppercase, valid pair)
   ├── Validate quantity > 0
   ├── Validate price for limit orders
   ├── Check risk limits
   └── Validate SL/TP prices if provided

2. BUILD ORDER PAYLOAD
   ├── Set category (spot/linear)
   ├── Set leverage for futures
   ├── Add SL/TP if specified
   └── Generate request signature

3. SUBMIT ORDER
   ├── Call POST /v5/order/create
   ├── Record submission timestamp
   ├── Store order in tracking map
   └── Return initial response

4. WAIT FOR CONFIRMATION
   ├── Subscribe to order updates WebSocket
   ├── Wait for order.fill or order.update
   ├── Timeout after 30 seconds
   └── Poll REST API as fallback

5. PROCESS FILL
   ├── Extract fill price and quantity
   ├── Calculate fees
   ├── Update position state
   ├── Calculate execution latency
   └── Return ExecutionResult

6. ATTACH SL/TP (if not set in order)
   ├── Set stop loss order
   ├── Set take profit order
   └── Return final confirmation
```

---

## WebSocket Integration

### Connection Setup

```typescript
async connect(): Promise<void>
```

**WebSocket URL:** `wss://stream.bybit.com/v5/private`

**Authentication:**
- API key and signature in connection params
- Expires after 30 minutes, auto-refresh

### Subscriptions

```json
{
  "op": "subscribe",
  "args": [
    "order.fill",
    "position.update"
  ]
}
```

### Message Handling

**Order Fill Message:**
```json
{
  "topic": "order.fill",
  "data": {
    "orderId": "1234567890",
    "symbol": "BTCUSDT",
    "side": "Buy",
    "orderType": "Market",
    "orderPrice": "0",
    "orderQty": "0.001",
    "execPrice": "50125.50",
    "execQty": "0.001",
    "execFee": "0.025",
    "feeRate": "0.0005",
    "execTime": "1746622200000"
  }
}
```

**Position Update Message:**
```json
{
  "topic": "position.update",
  "data": {
    "symbol": "BTCUSDT",
    "side": "Buy",
    "size": "0.001",
    "entryPrice": "50125.50",
    "unrealizedPnl": "0.50",
    "stopLoss": "49000",
    "takeProfit": "55000"
  }
}
```

---

## Error Handling

### Retry Strategy

| Attempt | Delay | Condition |
|---------|-------|-----------|
| 1 | Immediate | First attempt |
| 2 | 500ms | Transient failure (timeout, 5xx) |
| 3 | 1000ms | Retry succeeded |

**Max Retries:** 3
**Retriable Errors:** 500, 502, 503, 504, timeout
**Non-Retriable Errors:** 400, 401, 403, validation errors

### Error Types

```typescript
class RiskCheckFailedError extends Error {
  reason: string;
  details: object;
}

class OrderRejectedError extends Error {
  code: string;
  message: string;
}

class ExecutionTimeoutError extends Error {
  orderId: string;
  waitedMs: number;
}

class InsufficientBalanceError extends Error {
  required: string;
  available: string;
}
```

### Logging

All order attempts logged with:
```typescript
interface OrderLog {
  timestamp: string;
  orderId: string | null;
  symbol: string;
  side: string;
  type: string;
  qty: string;
  price: string | null;
  action: 'SUBMIT' | 'FILLED' | 'CANCELLED' | 'FAILED';
  latencyMs: number;
  error?: string;
  retryCount: number;
}
```

---

## Output Format

```json
{
  "success": true,
  "orderId": "1234567890",
  "symbol": "BTCUSDT",
  "side": "Buy",
  "type": "Market",
  "qty": "0.001",
  "price": 50125.50,
  "fillPrice": 50125.50,
  "fees": 0.025,
  "executionLatency": 145,
  "status": "FILLED",
  "timestamp": "2026-05-07T14:30:00Z"
}
```

**Field Definitions:**
| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether order was successfully filled |
| `orderId` | string | Unique order identifier from Bybit |
| `symbol` | string | Trading pair |
| `side` | string | "Buy" or "Sell" |
| `type` | string | "Market" or "Limit" |
| `qty` | string | Requested quantity |
| `price` | number | Limit price (null for market orders) |
| `fillPrice` | number | Actual fill price |
| `fees` | number | Total fees paid |
| `executionLatency` | number | Time from submit to fill (ms) |
| `status` | string | Order status |
| `timestamp` | string | ISO 8601 timestamp |

---

## Performance Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Execution latency | < 500ms | > 1000ms |
| Fill rate | > 99% | < 95% |
| Retry rate | < 2% | > 5% |
| Order success rate | > 99.5% | < 98% |

### Metrics Collection

```typescript
interface ExecutionMetrics {
  totalOrders: number;
  filledOrders: number;
  failedOrders: number;
  retriedOrders: number;
  avgLatencyMs: number;
  p50LatencyMs: number;
  p99LatencyMs: number;
  totalFees: number;
}

function getMetrics(): ExecutionMetrics
function resetMetrics(): void
```

---

## Dependencies

- HTTP client for REST API calls
- WebSocket client for real-time updates
- Event emitter for order events
- Logger for execution logging
- Clock/timestamp utility

---

## Usage Example

```typescript
// Initialize agent
const executor = new TradeExecutorAgent({
  apiKey: 'your-api-key',
  apiSecret: 'your-api-secret',
  testnet: true
});

// Connect WebSocket for fills
await executor.connect();

// Place a market order
const result = await executor.placeMarketOrder(
  'BTCUSDT',
  'Buy',
  '0.001',
  '49000',  // Stop loss
  '55000'   // Take profit
);

console.log('Order result:', result);
// {
//   success: true,
//   orderId: '1234567890',
//   symbol: 'BTCUSDT',
//   side: 'Buy',
//   type: 'Market',
//   qty: '0.001',
//   price: null,
//   fillPrice: 50125.50,
//   fees: 0.025,
//   executionLatency: 145,
//   status: 'FILLED',
//   timestamp: '2026-05-07T14:30:00Z'
// }

// Place a limit order
const limitResult = await executor.placeLimitOrder(
  'ETHUSDT',
  'Buy',
  '3500',    // Price
  '0.1'      // Quantity
);

// Check open orders
const openOrders = await executor.getOpenOrders('BTCUSDT');

// Cancel an order
await executor.cancelOrder('0987654321');

// Get positions
const positions = await executor.getPositions();

// Check execution metrics
const metrics = executor.getMetrics();
console.log(`Avg latency: ${metrics.avgLatencyMs}ms`);

// Graceful shutdown
executor.disconnect();
```

---

## Configuration

```typescript
interface TradeExecutorConfig {
  apiKey: string;
  apiSecret: string;
  testnet: boolean;
  restEndpoint: string;
  wsEndpoint: string;
  maxRetries: number;
  retryDelayMs: number;
  executionTimeoutMs: number;
  enableMetrics: boolean;
}
```

**Default Values:**
```typescript
{
  testnet: true,
  restEndpoint: 'https://api-demo.bybit.com',
  wsEndpoint: 'wss://stream.bybit.com/v5/private',
  maxRetries: 3,
  retryDelayMs: 500,
  executionTimeoutMs: 30000,
  enableMetrics: true
}
```

---

*Generated: 2026-05-07*
*Mode: subagent*
*Platform: Bybit*