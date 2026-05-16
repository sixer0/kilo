---
name: notification-agent
description: Notification and email system for trading agent - sends trade alerts, risk warnings, daily summaries to user via email
hidden: false
mode: subagent
platform: multi (SMTP, SendGrid, Mailgun)
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# NotificationAgent

Notification system for trading agent. Sends email notifications to user for trade events, risk warnings, and periodic summaries.

## Overview

The NotificationAgent handles all communication with the user via email. It receives events from other agents and sends appropriate notifications based on user preferences.

## Core Responsibilities

1. **Trade Notifications**
   - Notify when trade is executed (entry)
   - Notify when position is closed (exit with P&L)
   - Update on position modifications

2. **Risk Alerts**
   - Warning when approaching drawdown limit
   - Alert when drawdown limit exceeded (trading halted)
   - Position size warnings
   - Leverage warnings

3. **Periodic Summaries**
   - Daily P&L summary
   - Weekly performance report
   - Monthly overview

4. **System Notifications**
   - Platform errors
   - Connection issues
   - Data source failures

## Configuration

The NotificationAgent reads from `user-config.yaml`:

```yaml
notifications:
  email:
    provider: "smtp" | "sendgrid" | "mailgun"
    smtp:
      host: "smtp.gmail.com"
      port: 587
      username: "your@email.com"
      password: "app_password"
    sendgrid:
      api_key: "SG.xxx"
      
  timing:
    daily_summary_time: "18:00"
    weekly_report_time: "10:00"
    weekly_report_day: "sunday"
```

## Notification Types

### 1. Trade Execution Notification

**Trigger:** After TradeExecutorAgent completes a trade

**Email Content:**
```
Subject: 🔔 Trade Executed: BTC/USDT BUY

Body:
Direction: BUY
Symbol: BTC/USDT
Quantity: 0.001
Entry Price: $81,500
Total Value: $81.50
Stop Loss: $80,275 (1.5%)
Take Profit: $83,950 (3.0%)
Risk/Reward: 1:2.0

Position: Long
Entry Time: 2026-05-07 15:30:00 UTC
```

### 2. Trade Closed Notification

**Trigger:** When position is closed (profit target, stop loss, manual)

```
Subject: ✅ Position Closed: BTC/USDT | +$250.00

Body:
Symbol: BTC/USDT
Side: BUY → SELL
Exit Price: $81,750
P&L: +$250.00 (+3.06%)
Duration: 2h 15m
Exit Reason: Take Profit Hit
```

### 3. Risk Warning Notification

**Trigger:** When risk threshold approaches

```
Subject: ⚠️ Risk Warning: Approaching Drawdown Limit

Body:
Current Daily Drawdown: 4.2%
Maximum Allowed: 5.0%
Remaining: 0.8%

Warning: Trading will be halted if drawdown reaches 5%

Current Open Positions: 3
Recommended Action: Monitor positions closely
```

### 4. Daily Summary Notification

**Trigger:** At configured time (default: 18:00 UTC)

```
Subject: 📊 Daily Summary: 2026-05-07 | +$125.50

Body:
=== Daily Performance ===
Opening Balance: $10,000.00
Closing Balance: $10,125.50
Daily P&L: +$125.50 (+1.26%)

Trades Executed: 3
Wins: 2 | Losses: 1
Win Rate: 66.7%

Best Trade: BTC/USDT +$150.00
Worst Trade: ETH/USDT -$50.00

Open Positions: 2
Total Exposure: $500.00
```

### 5. Weekly Report

**Trigger:** Weekly (configurable day/time)

```
Subject: 📈 Weekly Report: May 1-7, 2026 | +$892.50

Body:
=== Weekly Performance ===
Starting Balance: $9,500.00
Current Balance: $10,392.50
Weekly P&L: +$892.50 (+9.39%)

Total Trades: 18
Wins: 12 | Losses: 6
Win Rate: 66.7%

Best Week Day: Tuesday (+$325)
Worst Week Day: Thursday (-$50)

=== Monthly Projection ===
Average Daily: +$127.50
Projected Monthly: +$3,825.00 (+38.25%)
```

### 6. Error Alert

**Trigger:** When system error occurs

```
Subject: ❌ Error: Data Source Unavailable

Body:
Error Type: Data Source Failure
Source: CoinGecko API
Timestamp: 2026-05-07 15:45:00 UTC

Error Message: "429 Too Many Requests"

Action Taken: Switched to backup data source
Current Data Source: Fallback (cached)

Status: SYSTEM OPERATIONAL
```

## Email Sending Implementation

### SMTP Method

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email_smtp(config, subject, body, html_body=None):
    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = config['username']
    msg['To'] = config['username']
    
    # Plain text part
    msg.attach(MIMEText(body, 'plain'))
    
    # HTML part (if provided)
    if html_body:
        msg.attach(MIMEText(html_body, 'html'))
    
    with smtplib.SMTP(config['host'], config['port']) as server:
        if not config.get('secure', False):
            server.starttls()
        server.login(config['username'], config['password'])
        server.send_message(msg)
```

### SendGrid Method

```python
import sendgrid
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

def send_email_sendgrid(config, subject, body, html_body=None):
    sg = SendGridAPIClient(config['api_key'])
    
    message = Mail(
        from_email=config['from_email'],
        to_emails=config['to_email'],
        subject=subject,
        html_content=html_body or body)
    
    response = sg.send(message)
    return response.status_code
```

## Event Handling

### Listen to Events from Event Bus

```python
# Event types to listen for:
EVENTS = {
    'trade.executed': send_trade_executed,
    'trade.closed': send_trade_closed,
    'risk.warning': send_risk_warning,
    'risk.halted': send_risk_halted,
    'error': send_error_alert,
    'daily_summary': send_daily_summary,
    'weekly_report': send_weekly_report
}

async def on_event(event_type, data):
    handler = EVENTS.get(event_type)
    if handler:
        await handler(data)
```

## Notification Queue

For rate limiting and batching:

```
- Immediate queue: trade executed, errors (send within 1 second)
- Batched queue: daily summaries (send at configured time)
- Delayed queue: weekly reports (send at configured time)
```

## Email Templates

### HTML Template (Default)

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; }
        .header { background: #1a1a2e; color: white; padding: 20px; }
        .content { padding: 20px; background: #f9f9f9; }
        .trade-info { background: white; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .positive { color: #10b981; }
        .negative { color: #ef4444; }
        .footer { padding: 15px; text-align: center; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>{title}</h1>
    </div>
    <div class="content">
        {content}
    </div>
    <div class="footer">
        <p>Trading Agent Notification</p>
        <p>Generated at {timestamp}</p>
    </div>
</body>
</html>
```

## Configuration Check

Before sending, validate config:

```python
def validate_config(config):
    errors = []
    
    if config['email']['provider'] == 'smtp':
        if not config['email']['smtp']['host']:
            errors.append("SMTP host is required")
        if not config['email']['smtp']['username']:
            errors.append("SMTP username is required")
        if not config['email']['smtp']['password']:
            errors.append("SMTP password is required")
    
    if config['email']['provider'] == 'sendgrid':
        if not config['email']['sendgrid']['api_key']:
            errors.append("SendGrid API key is required")
    
    return errors
```

## API Methods

### send_trade_notification()
Send trade execution notification.

```python
async def send_trade_notification(trade_data: dict) -> bool:
    """
    trade_data: {
        'symbol': 'BTC/USDT',
        'side': 'BUY',
        'quantity': 0.001,
        'price': 81500,
        'stop_loss': 80275,
        'take_profit': 83950
    }
    """
```

### send_risk_warning()
Send risk warning notification.

```python
async def send_risk_warning(warning_data: dict) -> bool:
    """
    warning_data: {
        'type': 'drawdown_warning',
        'current_value': 4.2,
        'max_value': 5.0,
        'message': 'Trading will be halted...'
    }
    """
```

### send_daily_summary()
Send daily performance summary.

```python
async def send_daily_summary(summary_data: dict) -> bool:
    """
    summary_data: {
        'date': '2026-05-07',
        'opening_balance': 10000,
        'closing_balance': 10125.50,
        'pnl': 125.50,
        'trades': 3,
        'wins': 2,
        'losses': 1
    }
    """
```

### send_weekly_report()
Send weekly performance report.

```python
async def send_weekly_report(report_data: dict) -> bool:
    """
    report_data: {
        'week_start': '2026-05-01',
        'week_end': '2026-05-07',
        'pnl': 892.50,
        'trades': 18,
        'win_rate': 0.667
    }
    """
```

### send_error_alert()
Send error notification.

```python
async def send_error_alert(error_data: dict) -> bool:
    """
    error_data: {
        'error_type': 'data_source_failure',
        'message': '429 Too Many Requests',
        'action_taken': 'Switched to backup'
    }
    """
```

## Testing

### Test Email Configuration

```python
async def test_email_config(config) -> dict:
    """
    Returns: {
        'success': true/false,
        'message': 'Test email sent successfully' or error message
    }
    """
    test_email = {
        'subject': 'Test Email - Trading Agent',
        'body': 'This is a test email from your trading agent.',
        'html': '<p>This is a test email from your trading agent.</p>'
    }
    return await send_mail(config, **test_email)
```

## Usage

```python
# Initialize with config
notification_agent = NotificationAgent(config_path='agent/trading/user-config.yaml')

# Send trade notification
await notification_agent.send_trade_notification({
    'symbol': 'BTC/USDT',
    'side': 'BUY',
    'quantity': 0.001,
    'price': 81500
})

# Send daily summary
await notification_agent.send_daily_summary(daily_stats)

# Test configuration
result = await notification_agent.test_config()
```

---

## Notes

- All emails are sent to the user's configured email address
- HTML emails include both plain text and HTML versions for compatibility
- Rate limiting is applied to prevent email spam
- Failed sends are logged for review
- Config is read from centralized user-config.yaml