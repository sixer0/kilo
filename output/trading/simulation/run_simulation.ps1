# Trading Simulation - Simple RSI Divergence
$marketDataPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\market_data_90d.json"
$outputPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\simulation_results.json"

Write-Host "Loading market data..." -ForegroundColor Cyan
$json = Get-Content $marketDataPath -Raw | ConvertFrom-Json
$coins = $json.coins

$initialCapital = 10000
$maxRiskPerTrade = 0.02

$capital = $initialCapital
$trades = @()
$equityHistory = @()
$winningTrades = 0; $losingTrades = 0
$totalWins = 0; $totalLosses = 0

function Get-RSI {
    param($prices, $period = 14)
    if ($prices.Count -lt $period + 1) { return $null }
    $gains = 0; $losses = 0
    for ($i = 1; $i -lt $prices.Count; $i++) {
        $diff = $prices[$i] - $prices[$i-1]
        if ($diff -gt 0) { $gains += $diff } else { $losses += [Math]::Abs($diff) }
    }
    $avgGain = $gains / $period
    $avgLoss = $losses / $period
    if ($avgLoss -eq 0) { return 50 }
    $rs = $avgGain / $avgLoss
    return 100 - (100 / (1 + $rs))
}

foreach ($coinName in $coins.PSObject.Properties.Name) {
    $candles = $coins.$coinName
    if ($candles.Count -lt 30) { continue }

    $prices = @($candles | ForEach-Object { $_.close })
    $highs = @($candles | ForEach-Object { $_.high })
    $lows = @($candles | ForEach-Object { $_.low })
    $vols = @($candles | ForEach-Object { $_.volume })

    Write-Host "Processing $coinName ($($candles.Count) candles)..."

    for ($i = 20; $i -lt $prices.Count; $i++) {
        $rsi = Get-RSI $prices[0..$i] 14

        # Volume avg
        $volSum = 0
        for ($j = $i - 19; $j -le $i; $j++) { $volSum += $vols[$j] }
        $volAvg = $volSum / 20
        $volRatio = if ($volAvg -gt 0) { $vols[$i] / $volAvg } else { 1 }

        # Signal: RSI divergence + volume
        $signal = $null
        if ($rsi -ne $null) {
            # Simple RSI zone detection
            if ($rsi -lt 45) { $signal = "BUY" }  # RSI below 45 = oversold zone
            elseif ($rsi -gt 55) { $signal = "SELL" }  # RSI above 55 = overbought zone
        }

        if ($signal) {
            $price = $prices[$i]
            $slDist = $price * 0.015
            $tpDist = $price * 0.03

            $riskAmount = $capital * $maxRiskPerTrade
            $posSize = $riskAmount / $slDist

            $holdDays = 2 + (Get-Random -Maximum 4)
            $exitIdx = [Math]::Min($i + $holdDays, $prices.Count - 1)
            $exitPrice = $prices[$exitIdx]
            $exitLow = $lows[$exitIdx]
            $exitHigh = $highs[$exitIdx]

            $pnl = if ($signal -eq "BUY") {
                ($exitPrice - $price) * $posSize
            } else {
                ($price - $exitPrice) * $posSize
            }

            # SL/TP check
            if ($signal -eq "BUY") {
                if ($exitLow -le ($price - $slDist)) { $pnl = -$riskAmount }
                elseif ($exitHigh -ge ($price + $tpDist)) { $pnl = $riskAmount * 2 }
            } else {
                if ($exitHigh -ge ($price + $slDist)) { $pnl = -$riskAmount }
                elseif ($exitLow -le ($price - $tpDist)) { $pnl = $riskAmount * 2 }
            }

            $result = if ($pnl -gt 0) { "WIN" } else { "LOSS" }

            $trades += [PSCustomObject]@{
                date = $candles[$i].date
                coin = $coinName
                signal = $signal
                entryPrice = [Math]::Round($price, 4)
                exitPrice = [Math]::Round($exitPrice, 4)
                pnl = [Math]::Round($pnl, 2)
                result = $result
                rsi = [Math]::Round($rsi, 1)
            }

            $capital += $pnl
            [void]$equityHistory.Add([PSCustomObject]@{ date = $candles[$i].date; equity = $capital })

            if ($pnl -gt 0) { $winningTrades++; $totalWins += $pnl }
            else { $losingTrades++; $totalLosses += [Math]::Abs($pnl) }
        }
    }
}

Write-Host "`nTotal trades: $($trades.Count)" -ForegroundColor Yellow

# Metrics
$totalTrades = $trades.Count
$winRate = if ($totalTrades -gt 0) { $winningTrades / $totalTrades } else { 0 }
$avgWin = if ($winningTrades -gt 0) { $totalWins / $winningTrades } else { 0 }
$avgLoss = if ($losingTrades -gt 0) { $totalLosses / $losingTrades } else { 0 }
$totalPnL = $capital - $initialCapital
$totalPnLPercent = ($totalPnL / $initialCapital) * 100

$coinPnL = @{}
foreach ($t in $trades) {
    if (-not $coinPnL.ContainsKey($t.coin)) { $coinPnL[$t.coin] = 0 }
    $coinPnL[$t.coin] += $t.pnl
}

$bestCoin = "N/A"; $worstCoin = "N/A"
if ($coinPnL.Count -gt 0) {
    $byCoin = @($coinPnL.GetEnumerator() | ForEach-Object { [PSCustomObject]@{ coin = $_.Key; pnl = $_.Value } })
    $sorted = $byCoin | Sort-Object pnl -Descending
    $bestCoin = $sorted[0].coin
    $worstCoin = ($sorted | Select-Object -Last 1).coin
}

$peak = $initialCapital; $maxDD = 0
foreach ($e in $equityHistory) {
    if ($e.equity -gt $peak) { $peak = $e.equity }
    $dd = ($peak - $e.equity) / $peak
    if ($dd -gt $maxDD) { $maxDD = $dd }
}

$tradesByCoin = @{}
foreach ($t in $trades) {
    if (-not $tradesByCoin.ContainsKey($t.coin)) { $tradesByCoin[$t.coin] = @{trades=0; wins=0; losses=0; pnl=0} }
    $tradesByCoin[$t.coin].trades++
    if ($t.pnl -gt 0) { $tradesByCoin[$t.coin].wins++ } else { $tradesByCoin[$t.coin].losses++ }
    $tradesByCoin[$t.coin].pnl += $t.pnl
}

$largestWin = if ($trades.Count -gt 0) { ($trades | Sort-Object pnl -Descending)[0].pnl } else { 0 }
$largestLoss = if ($trades.Count -gt 0) { ($trades | Sort-Object pnl)[0].pnl } else { 0 }

$result = @{
    simulation_period = "2026-02-06 to 2026-05-07"
    initial_capital = $initialCapital
    final_capital = [Math]::Round($capital, 2)
    total_pnl = [Math]::Round($totalPnL, 2)
    total_pnl_percent = [Math]::Round($totalPnLPercent, 2)
    total_trades = $totalTrades
    winning_trades = $winningTrades
    losing_trades = $losingTrades
    win_rate = [Math]::Round($winRate, 3)
    avg_win = [Math]::Round($avgWin, 2)
    avg_loss = [Math]::Round($avgLoss, 2)
    largest_win = $largestWin
    largest_loss = $largestLoss
    max_drawdown = [Math]::Round($maxDD, 3)
    best_coin = $bestCoin
    worst_coin = $worstCoin
    trades_by_coin = $tradesByCoin
}

$result | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   TRADING SIMULATION RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Period: $($result.simulation_period)"
Write-Host "Initial: `$$initialCapital" -ForegroundColor Yellow
$finalColor = if ($totalPnL -ge 0) { "Green" } else { "Red" }
Write-Host "Final: `$$($result.final_capital)" -ForegroundColor $finalColor
Write-Host "P&L: `$$($result.total_pnl) ($($result.total_pnl_percent)%)" -ForegroundColor $finalColor
Write-Host ""
Write-Host "Total Trades: $($result.total_trades)"
Write-Host "Win Rate: $([Math]::Round($result.win_rate * 100, 1))% ($($result.winning_trades) wins / $($result.losing_trades) losses)"
Write-Host "Avg Win: `$$($result.avg_win) | Avg Loss: `$$($result.avg_loss)"
Write-Host "Largest Win: `$$largestWin | Largest Loss: `$$largestLoss"
Write-Host ""
Write-Host "Best Coin: $($result.best_coin) | Worst Coin: $($result.worst_coin)"
Write-Host "Max Drawdown: $([Math]::Round($result.max_drawdown * 100, 2))%"
Write-Host ""
Write-Host "Results saved to: $outputPath" -ForegroundColor Gray

# Save email notification
$emailBody = @"
TRADING SIMULATION RESULTS
==========================

Period: $($result.simulation_period)
Initial Capital: `$$initialCapital
Final Capital: `$$($result.final_capital)
Total P&L: `$$($result.total_pnl) ($($result.total_pnl_percent)%)

Total Trades: $($result.total_trades)
Win Rate: $([Math]::Round($result.win_rate * 100, 1))% ($($result.winning_trades) wins / $($result.losing_trades) losses)
Avg Win: `$$($result.avg_win) | Avg Loss: `$$($result.avg_loss)
Largest Win: `$$largestWin | Largest Loss: `$$largestLoss

Best Coin: $($result.best_coin)
Worst Coin: $($result.worst_coin)
Max Drawdown: $([Math]::Round($result.max_drawdown * 100, 2))%

---
Generated by Kilo Trading Agent System
"@

$emailPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\email_notification.txt"
$emailBody | Set-Content $emailPath -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   EMAIL NOTIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host $emailBody

# Save to send
$emailJsonPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\email_send.json"
@{
    to = "sixer0.bk@gmail.com"
    subject = "Trading Simulation Results - Win Rate: $([Math]::Round($result.win_rate * 100, 1))%"
    body = $emailBody
} | ConvertTo-Json | Set-Content $emailJsonPath -Encoding UTF8

Write-Host "`nEmail data saved to: $emailJsonPath" -ForegroundColor Gray