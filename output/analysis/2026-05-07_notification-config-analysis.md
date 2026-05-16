# Notification System & User Configuration Plan

## 1. User Configuration File Structure

### Storage Location
`agent/trading/user-config.yaml` (centralized, human-readable YAML format)

### Full Configuration Fields
```yaml
# Broker Accounts (multiple supported)
broker_accounts:
  - name: "Bybit"
    market_type: "crypto"  # crypto, forex, stocks, polymarket
    demo_mode: true  # true = demo, false = live
    credentials:
      api_key: "your-bybit-api-key"
      api_secret: "your-bybit-api-secret"
    enabled: true  # enable/disable this broker

  - name: "OANDA"
    market_type: "forex"
    demo_mode: false
    credentials:
      account_id: "your-oanda-account-id"
      api_key: "your-oanda-api-key"
    enabled: true

# Risk Parameters
risk_parameters:
  risk_level: "moderate"  # conservative, moderate, aggressive
  max_risk_per_trade: 0.01  # 1% of account balance per trade
  max_drawdown: 0.05  # 5% maximum total drawdown
  max_open_positions: 5  # maximum concurrent open positions

# Email Notification Settings
email_settings:
  smtp_server: "smtp.gmail.com"
  smtp_port: 587  # TLS port
  sender_email: "trading-alerts@example.com"
  sender_password: "app-specific-password"
  recipient_emails: ["user@example.com"]
  use_api: false  # false = SMTP, true = SendGrid/other API
  api_key: ""  # only required if use_api = true

# Trading Pairs to Watch
trading_pairs:
  - "BTC/USDT"
  - "ETH/USDT"
  - "EUR/USD"
  - "GBP/USD"

# Enabled/Disabled Features
enabled_features:
  notifications: true
  multi_signal_verification: true
  daily_pnl_summary: true
  signal_alerts: true
```

## 2. Notification System

### Notification Types & Triggers
| Notification Type | Trigger | Priority |
|-------------------|---------|----------|
| Trade Executed | Entry/exit order filled (success/failure) | High |
| Risk Warning | Max drawdown exceeded, max positions reached, risk per trade exceeded | High |
| Daily P&L Summary | Scheduled daily at 23:59 UTC | Medium |
| Signal Alert | New verified trading signal generated | Medium |
| Platform Error | Unhandled exception, API connection failure, invalid credentials | High |

### Implementation
- **SMTP**: For simple setups using existing email providers (Gmail, Outlook, etc.)
  - Configured via `email_settings.smtp_*` fields
  - Uses TLS encryption (port 587)
- **SendGrid API**: For scalable, high-deliverability email
  - Configured via `email_settings.use_api = true` and `email_settings.api_key`
  - Supports templates, tracking, and bulk sending

## 3. Multi-Market Integration

### Market Adapter Architecture
Uses the **Adapter Pattern** with a common `IMarketAdapter` interface to standardize market interactions:

```typescript
interface IMarketAdapter {
  // Fetch latest market data for a symbol
  getMarketData(symbol: string): Promise<MarketData>;
  
  // Execute a trade order
  executeTrade(order: Order): Promise<TradeResult>;
  
  // Fetch current account balance
  getAccountBalance(): Promise<Balance>;
  
  // Validate broker credentials
  validateCredentials(): Promise<boolean>;
}
```

### Market-Specific Adapters
| Market | Data Source | Execution Broker | Adapter Class |
|--------|------------|-----------------|---------------|
| Crypto | CoinGecko | Bybit/Binance | `CryptoAdapter` |
| Forex | OANDA | OANDA | `ForexAdapter` |
| Stocks | Alpha Vantage | Alpaca | `StocksAdapter` |
| Polymarket | Polymarket API | Polymarket | `PolymarketAdapter` |

### Market Switching
- Adapters are instantiated based on `broker_accounts[].market_type`
- Users switch markets by adding/modifying entries in `broker_accounts` with the desired `market_type`
- All adapters implement the same interface, so the core trading logic is market-agnostic

## 4. Multi-Signal Verification Flow

### Process Steps
1. **Signal Collection**: Gather signals from multiple sources (technical indicators, sentiment analysis, news APIs, etc.)
2. **Confidence Scoring**: Assign a 0-100 confidence score to each signal based on:
   - Source historical accuracy
   - Signal strength (e.g., RSI value, moving average crossover distance)
   - Market volatility context
3. **Agreement Check**: Count how many signals agree on the trade direction (buy/sell/hold)
   - Threshold: Minimum 2/3 signals must agree for further consideration
4. **Weighted Confidence Calculation**: Combine individual confidence scores weighted by source accuracy
5. **Execution Threshold**: Only execute a trade if the weighted confidence score exceeds 70/100
6. **Audit Logging**: Log all signal data, confidence scores, and verification steps for post-trade analysis

### Example Flow
```
Signal 1 (RSI): Sell, Confidence 85 (Source accuracy 80%)
Signal 2 (News): Sell, Confidence 70 (Source accuracy 60%)
Signal 3 (Sentiment): Hold, Confidence 60 (Source accuracy 70%)

Agreement: 2/3 signals agree (Sell)
Weighted Confidence: (85*0.8 + 70*0.6) / (0.8 + 0.6) = 79.28
Threshold (70) exceeded → Execute Sell order
```

## 5. Next Steps
1. Implement `user-config.yaml` schema validation
2. Build email notification service with SMTP and SendGrid support
3. Develop market adapter interfaces and crypto/forex adapters first
4. Implement multi-signal verifier with confidence scoring
5. Integrate all modules with the core trading engine
