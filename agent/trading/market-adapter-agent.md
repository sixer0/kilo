---
name: market-adapter-agent
description: Multi-market data adapter - supports CoinGecko (crypto), OANDA (forex), Polymarket (prediction), with unified API
hidden: false
mode: subagent
platform: multi-source
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# MarketAdapterAgent

Unified market data adapter that provides consistent API across multiple market types and data sources.

## Supported Markets

| Market | Data Source | Status | Best For |
|--------|------------|--------|---------|
| **Crypto** | CoinGecko | ✅ Working | Real-time prices, market data |
| **Forex** | OANDA | ⏳ Needs API | Currency pairs, streaming |
| **Polymarket** | Polymarket API | ⏳ Needs setup | Prediction markets |
| **Stocks** | Alpha Vantage | ⏳ Needs API | US equities |

## Architecture

### Unified Interface

All market adapters implement the same interface:

```typescript
interface MarketAdapter {
    // Get current price
    getPrice(symbol: string): Promise<PriceData>
    
    // Get historical data
    getHistorical(symbol: string, days: number): Promise<OHLCV[]>
    
    // Get market info
    getMarketInfo(symbol: string): Promise<MarketInfo>
    
    // Stream prices (if supported)
    subscribe(symbols: string[], callback): void
}
```

### Data Source Priority

```yaml
market_data:
  priority:
    - source: "coingecko"
      enabled: true
      priority: 1
    - source: "oanda"
      enabled: false
      priority: 2
```

## Crypto Adapter (CoinGecko - Primary)

### Supported Pairs

```javascript
const CRYPTO_PAIRS = {
    // Major
    'BTC/USDT': 'bitcoin',
    'ETH/USDT': 'ethereum',
    'BNB/USDT': 'binancecoin',
    'XRP/USDT': 'ripple',
    'SOL/USDT': 'solana',
    // Altcoins
    'DOGE/USDT': 'dogecoin',
    'ADA/USDT': 'cardano',
    'DOT/USDT': 'polkadot',
    'AVAX/USDT': 'avalanche-2',
    'LINK/USD': 'chainlink'
}
```

### API Methods

#### getPrice()
```python
async def get_price(symbol: str) -> PriceData:
    """
    Returns:
    {
        'symbol': 'BTC/USDT',
        'price': 81500.00,
        'change_1h': 0.25,
        'change_24h': 2.5,
        'volume_24h': 41000000000,
        'market_cap': 1630000000000,
        'timestamp': 1700000000
    }
    """
```

#### getMarkets()
```python
async def get_markets(limit: int = 20) -> MarketData[]:
    """
    Returns top cryptocurrencies by market cap
    """
```

#### getHistorical()
```python
async def get_historical(symbol: str, days: int = 1) -> OHLCV[]:
    """
    Returns price history
    [
        {
            'timestamp': 1700000000,
            'open': 81000,
            'high': 82500,
            'low': 80500,
            'close': 81500,
            'volume': 4100000
        }
    ]
    """
```

### CoinGecko API Endpoints

```python
BASE_URL = "https://api.coingecko.com/api/v3"

# Markets
"/coins/markets?vs_currency=usd&order=market_cap_desc&per_page={limit}"

# Ticker
"/coins/{id}/ticker"

# History
"/coins/{id}/history?date={date}"

# Market Chart
"/coins/{id}/market_chart?vs_currency=usd&days={days}"

# Simple Price
"/simple/price?ids={ids}&vs_currencies=usd"
```

## Forex Adapter (OANDA)

### Supported Pairs

```javascript
const FOREX_PAIRS = [
    'EUR/USD', 'GBP/USD', 'USD/JPY', 'USD/CHF',
    'AUD/USD', 'USD/CAD', 'NZD/USD',
    'EUR/GBP', 'EUR/JPY', 'GBP/JPY'
]
```

### API Methods

#### getPrice()
```python
async def get_price(symbol: str) -> PriceData:
    """
    Returns:
    {
        'symbol': 'EUR/USD',
        'bid': 1.0852,
        'ask': 1.0854,
        'spread': 0.0002,
        'timestamp': 1700000000
    }
    """
```

#### getCandles()
```python
async def get_candles(
    symbol: str,
    timeframe: str = 'M5',  # M1, M5, M15, H1, H4, D1
    count: int = 100
) -> Candle[]:
    """
    Returns OHLC candles
    """
```

### OANDA API Endpoints

```python
BASE_URL = "https://api-fxtrade.oanda.com"
STREAM_URL = "https://stream-fxtrade.oanda.com"

# REST
"/v3/instruments/{instrument}/candles"
"/v3/instruments/{instrument}/orderBook"
"/v3/instruments/{instrument}/positionBook"

# Streaming
GET "/v3/prices/stream?instruments={instruments}"
```

## Polymarket Adapter

### Overview

Polymarket is a prediction market platform. Trades are binary outcomes (Yes/No).

### Supported Markets

```javascript
const POLYMARKET_CATEGORIES = [
    'politics',
    'crypto',
    'sports',
    'business',
    'science',
    'entertainment'
]
```

### API Methods

#### getMarkets()
```python
async def get_markets(
    category: str = None,
    limit: int = 20
) -> Market[]:
    """
    Returns prediction markets
    [
        {
            'id': 'will-btc-be-above-120k-on-june-30',
            'question': 'Will BTC be above $120,000 on June 30, 2026?',
            'outcome': 'Yes',
            'price': 0.65,      # 65% probability
            'volume': 250000,
            'end_date': '2026-06-30'
        }
    ]
    """
```

#### getOrderBook()
```python
async def get_order_book(market_slug: str) -> OrderBook:
    """
    Returns order book for a market
    {
        'yes': {
            'bids': [{'price': 0.64, 'size': 1000}],
            'asks': [{'price': 0.66, 'size': 500}]
        },
        'no': {
            'bids': [{'price': 0.34, 'size': 500}],
            'asks': [{'price': 0.36, 'size': 1000}]
        }
    }
    """
```

### Polymarket API

```python
BASE_URL = "https://clob.polymarket.com"

# Markets
"/markets?filter={filter}"

# Order Book
"/markets/{condition_id}/orderbook"

# Fills
"/fills?market={market_slug}"

# Historical Prices
"/markets/{condition_id}/history"
```

## Stock Adapter (Alpha Vantage)

### Supported

- US Equities via Alpha Vantage API
- Real-time and delayed data

### API Methods

```python
async def get_quote(symbol: str) -> QuoteData:
    """
    Returns stock quote
    {
        'symbol': 'AAPL',
        'price': 287.51,
        'change': 3.32,
        'change_pct': 1.17,
        'volume': 45000000
    }
    """
```

### Alpha Vantage Endpoints

```python
BASE_URL = "https://www.alphavantage.co/query"

# Quote
"GLOBAL_QUOTE&symbol={symbol}"

# Intraday
"TIME_SERIES_INTRADAY&symbol={symbol}&interval=5min"

# Daily
"TIME_SERIES_DAILY&symbol={symbol}"
```

## Unified API (Use This)

### get_market_data()

Instead of calling adapters directly, use the unified method:

```python
async def get_market_data(
    symbol: str,
    market_type: str = None  # auto-detect from symbol
) -> MarketData:
    """
    Auto-detects market type and returns data
    """
    # Detect market from symbol
    if market_type is None:
        market_type = detect_market(symbol)
    
    # Route to appropriate adapter
    if market_type == 'crypto':
        return await crypto_adapter.get_price(symbol)
    elif market_type == 'forex':
        return await forex_adapter.get_price(symbol)
    elif market_type == 'polymarket':
        return await polymarket_adapter.get_markets(symbol)
    elif market_type == 'stock':
        return await stock_adapter.get_quote(symbol)
```

### Symbol Detection

```python
def detect_market(symbol: str) -> str:
    """Detect market type from symbol"""
    
    # Crypto patterns
    if '/' in symbol:
        base, quote = symbol.split('/')
        if quote in ['USDT', 'USD', 'BTC', 'ETH']:
            return 'crypto'
    
    # Forex patterns
    if symbol in FOREX_PAIRS:
        return 'forex'
    
    # Stock patterns (uppercase, no slash)
    if symbol.isupper() and '/' not in symbol:
        return 'stock'
    
    # Default
    return 'crypto'
```

## Data Normalization

All adapters return standardized format:

```typescript
interface MarketData {
    // Identification
    symbol: string;          // "BTC/USDT"
    market_type: string;    // "crypto", "forex", "stock", "polymarket"
    
    // Price Data
    price: number;         // Current price
    bid: number;         // Best bid (forex)
    ask: number;         // Best ask (forex)
    spread: number;       // Spread (forex)
    
    // Changes
    change_1h: number;   // 1 hour change %
    change_24h: number;  // 24 hour change %
    
    // Volume & Liquidity
    volume_24h: number;   // 24h volume
    market_cap: number;  // Market cap
    
    // Metadata
    timestamp: number;    // Unix timestamp
    source: string;     // Data source
}
```

## Usage Example

```python
# Initialize market adapter
market = MarketAdapterAgent(config)

# Get any market data (auto-detected)
btc_data = await market.get_market_data('BTC/USDT')
# Returns: {symbol: 'BTC/USDT', price: 81500, change_24h: 2.5, ...}

eur_data = await market.get_market_data('EUR/USD')
# Returns: {symbol: 'EUR/USD', bid: 1.0852, ask: 1.0854, ...}

# Get multiple
data = await market.get_multiple(['BTC/USDT', 'ETH/USDT', 'SOL/USDT'])

# Get historical
history = await market.get_historical('BTC/USDT', days=7)

# Stream (if supported)
market.subscribe(['BTC/USDT', 'ETH/USDT'], callback=on_price_update)
```

## Configuration

```yaml
# user-config.yaml
market_data:
  priority:
    - source: "coingecko"
      enabled: true
      priority: 1
      api_key: ""  # Optional for premium
    - source: "oanda"
      enabled: false
      priority: 2
      api_key: ""
    - source: "polymarket"
      enabled: false
      priority: 3
```

---

## Notes

- Crypto (CoinGecko) is primary - works reliably
- Other markets require API keys (configurable)
- Unified interface makes switching markets seamless
- All data normalized to standard format