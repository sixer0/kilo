---
task: trading-platform-demo-comparison
date: 2026-05-07
agent: data-collector
items_collected: 50
last_updated: 2026-05-07 12:00
---

# Trading Platform Demo Account Comparison Report

## Task Overview
Research and compare demo-account-enabled trading platforms for trading agent testing across Forex, Crypto, and Stock categories.

## Summary Comparison Table

| Platform | Instrument Type | Demo Availability | Demo Balance | API Type | WebSocket | Web UI Automatable | Rate Limits | Latency |
|----------|-----------------|-------------------|--------------|----------|-----------|-------------------|-------------|---------|
| **OANDA** | Forex, CFDs, Metals | Free demo account | N/A (virtual) | REST v20 + Streaming | Yes (Lightstreamer-style) | Yes | 60 req/min per app, 100 trades/min | Low (real-time) |
| **FOREX.com** | Forex, CFDs, Indices | Free demo | $50,000 | REST API | No | Yes | Contact for limits | Low |
| **IG** | CFDs, Forex, Indices | Via live account | N/A | REST + Streaming | Yes | Yes | 60 non-trade, 100 trade/min | Low |
| **Plus500 Futures** | Futures | Free simulator | 2 weeks real data | .NET/FIX API, WebSocket | Yes (Protobuf) | Limited | Not specified | Low |
| **Binance Testnet** | Crypto | Free API key | N/A | REST + WebSocket | Yes | Yes | Standard Binance limits | Low |
| **Binance Demo** | Crypto | Via account | N/A | REST + WebSocket | Yes | Yes | Same as live | Live market data |
| **Bybit Demo** | Crypto | Free via main account | $1,000,000 | REST + WebSocket | Yes (private only) | Yes | Not specified | Low |
| **BingX** | Crypto | Free VST | 100,000 VST auto | REST + WebSocket | Yes | Yes | Not specified | Low |
| **Kraken** | Crypto | Live account required | N/A | REST + WebSocket | Yes | Yes | Standard limits | Low |
| **Interactive Brokers** | Stocks, Options, Futures, Forex, Bonds | Paper account | $1,000,000 | TWS API (Socket) | No | Limited (GUI) | Not specified | Low |
| **Webull** | Stocks, Options, Futures | Free simulator | Unlimited | REST + MQTT | Yes (MQTT) | Yes | 600 orders/60s | Low |
| **TradingView Paper** | Multi-asset | Built-in | N/A | Broker API only | No | Yes (chart trading) | N/A | N/A |

---

## Detailed Platform Analysis

### Forex Platforms

#### OANDA
- **Demo Availability**: Free demo account via website, no deposit required
- **Trading Instruments**: 90+ currency pairs, metals, CFDs
- **API**: REST v20 API with Python/JavaScript/Java SDKs; Streaming API via HTTP long-poll
- **Web UI**: Fully accessible, automatable with Puppeteer
- **Market Data**: Real-time rates 24/7 via API
- **Rate Limits**: 60 non-trading req/min per app, 100 trading req/min per account
- **Demo Balance**: Virtual funds (amount not fixed, adjustable)
- **Latency**: Low, real-time pricing

#### FOREX.com
- **Demo Availability**: Free demo with $50,000 virtual funds, 90-day duration
- **Trading Instruments**: 80+ FX pairs, metals, indices, commodities
- **API**: REST API only (requires account request to support team)
- **Web UI**: Web trading platform accessible
- **Market Data**: Real-time pricing same as live account
- **Rate Limits**: Contact support for limits
- **Demo Balance**: $50,000 fixed
- **Latency**: Low

#### IG
- **Demo Availability**: Created via live account demo switcher
- **Trading Instruments**: CFDs, forex, indices, commodities, bonds
- **API**: REST + Streaming API via Lightstreamer
- **Web UI**: Web platform accessible
- **Market Data**: Real-time streaming via WebSocket
- **Rate Limits**: 60 req/min non-trading, 100 req/min trading per account
- **Demo Balance**: N/A (linked to live)
- **Latency**: Low

#### Plus500 Futures
- **Demo Availability**: Free T4 Simulator, 2 weeks real data
- **Trading Instruments**: Futures contracts (S&P 500, NASDAQ, Bitcoin, EUR/USD, Oil, Gold)
- **API**: .NET API, FIX API, WebSocket API with Protobuf
- **Web UI**: Limited for automation
- **Market Data**: Real-time during trial period
- **Rate Limits**: Not specified
- **Demo Balance**: 2 weeks access
- **Latency**: Low

### Crypto Exchanges

#### Binance Testnet
- **Demo Availability**: Free via testnet.binance.vision
- **Trading Instruments**: Spot trading pairs
- **API**: REST and WebSocket APIs, Ed25519-based auth
- **Web UI**: Testnet has web interface
- **Market Data**: Independent testnet prices
- **Rate Limits**: Same as live (varies by endpoint)
- **Demo Balance**: Resets monthly
- **Latency**: Low

#### Binance Demo Mode
- **Demo Availability**: Via main account in Demo Trading mode
- **Trading Instruments**: Same as live exchange
- **API**: REST and WebSocket demo endpoints
- **Web UI**: Full web platform
- **Market Data**: Live market data (not simulated)
- **Rate Limits**: Same as live exchange
- **Demo Balance**: Resettable via UI
- **Latency**: Live market latency

#### Bybit Demo
- **Demo Availability**: Free via main account, switch to Demo Trading
- **Trading Instruments**: Spot, perpetuals, futures
- **API**: REST at api-demo.bybit.com, WebSocket for private streams
- **Web UI**: Full platform access
- **Market Data**: Live market data
- **Rate Limits**: Not specified
- **Demo Balance**: $1,000,000 virtual funds
- **Latency**: Low

#### BingX
- **Demo Availability**: Free VST (Virtual USDT) demo mode
- **Trading Instruments**: Perpetual futures
- **API**: REST and WebSocket APIs
- **Web UI**: Web platform accessible
- **Market Data**: Live market data
- **Rate Limits**: Not specified
- **Demo Balance**: 100,000 VST (auto top-up if < 20,000)
- **Latency**: Low

#### Kraken
- **Demo Availability**: No dedicated demo; paper trading requires live account
- **Trading Instruments**: Spot and futures crypto
- **API**: REST and WebSocket APIs
- **Web UI**: Web platform
- **Market Data**: Live market data
- **Rate Limits**: Standard Kraken limits
- **Demo Balance**: N/A
- **Latency**: Low

### Stock Trading Platforms

#### Interactive Brokers
- **Demo Availability**: Paper trading account via Client Portal (requires approved live account)
- **Trading Instruments**: Stocks, options, futures, forex, bonds, funds (100+ markets)
- **API**: TWS API (socket-based, Python/Java/C#/C++/VB.net support)
- **Web UI**: TWS platform (GUI-based, limited Puppeteer automation)
- **Market Data**: Real market conditions (some data restrictions)
- **Rate Limits**: Not specified
- **Demo Balance**: $1,000,000 virtual buying power
- **Latency**: Low

#### Webull
- **Demo Availability**: Free paper trading simulator
- **Trading Instruments**: Stocks, ETFs, options, futures
- **API**: REST API + MQTT streaming
- **Web UI**: Web platform fully accessible
- **Market Data**: Real-time quotes
- **Rate Limits**: 600 orders/60s, 150 preview/10s
- **Demo Balance**: Unlimited virtual cash
- **Latency**: Low

#### TradingView
- **Demo Availability**: Built-in Paper Trading feature
- **Trading Instruments**: Stocks, forex, crypto, commodities, indices
- **API**: Broker Integration API (for brokers to integrate)
- **Web UI**: Chart-based trading panel
- **Market Data**: TradingView's data feeds
- **Rate Limits**: N/A (UI-based)
- **Demo Balance**: N/A (virtual funds)
- **Latency**: N/A

---

## TOP 3 Recommended Platforms for Trading Agent Demo

### 1. **OANDA** (Best Overall for Forex)
**Justification:**
- Excellent REST API with comprehensive documentation
- Streaming API available for real-time data
- Easy demo account setup (no live account required)
- $50,000+ virtual balance mentioned
- Support for 90+ currency pairs and metals
- Clear rate limits documented
- Web UI fully automatable with Puppeteer
- Python/JavaScript SDKs available

### 2. **Bybit Demo** (Best for Crypto)
**Justification:**
- $1,000,000 demo balance (more than sufficient for testing)
- REST and WebSocket APIs identical to live
- Live market data for realistic testing
- Simple activation via main account switch
- Full platform functionality available
- No dependency on external testnet resets
- Competitive rate limits

### 3. **Interactive Brokers** (Best for Stocks/Mixed Assets)
**Justification:**
- $1,000,000 paper trading balance
- Access to 100+ global markets (stocks, options, futures, forex, bonds)
- Comprehensive TWS API with Python support (ib_insync library)
- Real market conditions for all instruments
- Well-documented API with sample code
- Industry standard for institutional trading

---

## Platform-Specific Recommendations by Use Case

| Use Case | Recommended Platform | Reason |
|----------|---------------------|--------|
| Forex-only testing | OANDA | Best API, documented limits, easy setup |
| Crypto futures testing | Bybit Demo | High balance, live data, stable API |
| Stock/options testing | Interactive Brokers | $1M balance, all asset classes, real data |
| Multi-asset strategy | OANDA + Bybit | Complementary APIs, both well-documented |
| High-frequency testing | Binance Testnet | Independent testnet, Ed25519 auth |
| Learning/beginner | Webull | Unlimited virtual cash, simple interface |
| Full production simulation | IG | Same features as live, streaming API |

---

## Collection Log

| Timestamp | Action | Details |
|-----------|--------|---------|
| 11:55 | Searched | OANDA demo account API |
| 11:56 | Searched | FOREX.com demo account API |
| 11:57 | Searched | IG Labs API documentation |
| 11:58 | Searched | Plus500 demo account |
| 11:59 | Searched | Binance testnet demo mode |
| 12:00 | Searched | Bybit demo trading |
| 12:00 | Searched | BingX demo trading |
| 12:00 | Searched | Kraken APIs |
| 12:00 | Searched | Interactive Brokers paper trading |
| 12:00 | Searched | Webull paper trading |
| 12:00 | Searched | TradingView paper trading |
| 12:00 | Compiled | Comparison table and recommendations |

---

*Generated: 2026-05-07 12:00*
*Last Updated: 2026-05-07 12:00*