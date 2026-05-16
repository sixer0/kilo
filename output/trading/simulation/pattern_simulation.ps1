# Advanced Pattern-Based Trading - Target 70%+ Win Rate
# Key insight from data: High volume + Extreme RSI + Momentum reversal = High win rate

$marketDataPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\market_data_90d.json"
$outputPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\pattern_results.json"

Write-Host "Loading market data..." -ForegroundColor Cyan
$json = Get-Content $marketDataPath -Raw | ConvertFrom-Json
$coins = $json.coins

$initialCapital = 10000
$maxRiskPerTrade = 0.02

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

function Get-EMA {
    param($arr, $period)
    if ($arr.Count -lt $period) { return $null }
    $k = 2 / ($period + 1)
    $ema = $arr[0]
    for ($i = 1; $i -lt $arr.Count; $i++) { $ema = ($arr[$i] * $k) + ($ema * (1 - $k)) }
    return $ema
}

# Pattern-based strategy:
# BUY when:
#   - RSI < 45 (oversold zone)
#   - Price has bounced: 3-day return > 0% (showing reversal)
#   - Volume spike > 1.2x
# SELL when:
#   - RSI > 55 (overbought zone)
#   - Price has fallen: 3-day return < 0%
#   - Volume spike > 1.2x

$capital = $initialCapital
$trades = @()
$equityHistory = @()
$winningTrades = 0; $losingTrades = 0
$totalWins = 0; $totalLosses = 0
$signalsGenerated = 0

Write-Host "`n=== PATTERN-BASED HIGH PROBABILITY TRADING ===" -ForegroundColor Magenta

foreach ($coinName in $coins.PSObject.Properties.Name) {
    $candles = $coins.$coinName
    if ($candles.Count -lt 60) { continue }

    $prices = @($candles | ForEach-Object { $_.close })
    $highs = @($candles | ForEach-Object { $_.high })
    $lows = @($candles | ForEach-Object { $_.low })
    $vols = @($candles | ForEach-Object { $_.volume })

    Write-Host "Processing $coinName ($($candles.Count) candles)..." -ForegroundColor Cyan

    for ($i = 25; $i -lt $prices.Count - 5; $i++) {
        $rsi = Get-RSI $prices[0..$i] 14

        # Volume analysis
        $volSum = 0
        for ($j = $i - 19; $j -le $i; $j++) { $volSum += $vols[$j] }
        $volAvg = $volSum / 20
        $volRatio = if ($volAvg -gt 0) { $vols[$i] / $volAvg } else { 1 }

        # 3-day momentum (recent bounce/fall)
        $ret3 = if ($i -ge 3) { ($prices[$i] - $prices[$i-3]) / $prices[$i-3] * 100 } else { 0 }

        # 5-day momentum (confirmation)
        $ret5 = if ($i -ge 5) { ($prices[$i] - $prices[$i-5]) / $prices[$i-5] * 100 } else { 0 }

        # Previous RSI (was it more oversold?)
        $prevRsi = if ($i -ge 15) { Get-RSI $prices[0..($i-1)] 14 } else { 50 }

        # Pattern: BUY signal
        # RSI oversold + bouncing (3-day return > 0) + volume spike
        $buyPattern = $rsi -ne $null -and
                      $rsi -lt 45 -and
                      $ret3 -gt 0 -and      # Price bouncing
                      $ret5 -gt -2 -and     # Not falling further
                      $volRatio -ge 1.2

        # Pattern: SELL signal
        # RSI overbought + falling (3-day return < 0) + volume spike
        $sellPattern = $rsi -ne $null -and
                       $rsi -gt 55 -and
                       $ret3 -lt 0 -and     # Price falling
                       $ret5 -lt 2 -and     # Not rising further
                       $volRatio -ge 1.2

        if ($buyPattern -or $sellPattern) {
            $signalsGenerated++
            $signal = if ($buyPattern) { "BUY" } else { "SELL" }

            $price = $prices[$i]
            $slDist = $price * 0.015
            $tpDist = $price * 0.03

            $riskAmount = $capital * $maxRiskPerTrade
            $posSize = $riskAmount / $slDist

            # Hold 3-5 days
            $holdDays = 3 + (Get-Random -Maximum 3)
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
                if ($exitLow -le ($price - $slDist)) { $pnl = -$riskAmount; $exitPrice = $price - $slDist }
                elseif ($exitHigh -ge ($price + $tpDist)) { $pnl = $riskAmount * 2; $exitPrice = $price + $tpDist }
            } else {
                if ($exitHigh -ge ($price + $slDist)) { $pnl = -$riskAmount; $exitPrice = $price + $slDist }
                elseif ($exitLow -le ($price - $tpDist)) { $pnl = $riskAmount * 2; $exitPrice = $price - $tpDist }
            }

            $result = if ($pnl -gt 0) { "WIN" } else { "LOSS" }

            $trades += [PSCustomObject]@{
                date = $candles[$i].date
                coin = $coinName
                signal = $signal
                entryPrice = [Math]::Round($price, 4)
                exitPrice = [Math]::Round($exitPrice, 4)
                exitDate = $candles[$exitIdx].date
                pnl = [Math]::Round($pnl, 2)
                result = $result
                rsi = [Math]::Round($rsi, 1)
                volRatio = [Math]::Round($volRatio, 2)
                ret3 = [Math]::Round($ret3, 2)
            }

            $capital += $pnl
            $equityHistory += [PSCustomObject]@{ date = $candles[$i].date; equity = $capital }

            if ($pnl -gt 0) { $winningTrades++; $totalWins += $pnl }
            else { $losingTrades++; $totalLosses += [Math]::Abs($pnl) }
        }
    }
}

# Metrics
$totalTrades = $trades.Count
$winRate = if ($totalTrades -gt 0) { $winningTrades / $totalTrades } else { 0 }
$avgWin = if ($winningTrades -gt 0) { $totalWins / $winningTrades } else { 0 }
$avgLoss = if ($losingTrades -gt 0) { $totalLosses / $losingTrades } else { 0 }
$totalPnL = $capital - $initialCapital
$totalPnLPercent = ($totalPnL / $initialCapital) * 100

$coinPnL = @{}
foreach ($t in $trades) {
    if (-not $coinPnL.ContainsKey($t.coin)) { $coinPnL[$t.coin] = @{wins=0; losses=0; pnl=0} }
    if ($t.pnl -gt 0) { $coinPnL[$t.coin].wins++ } else { $coinPnL[$t.coin].losses++ }
    $coinPnL[$t.coin].pnl += $t.pnl
}
$bestCoin = "N/A"; $worstCoin = "N/A"
if ($coinPnL.Count -gt 0) {
    $byCoin = @($coinPnL.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            coin = $_.Key
            wins = $_.Value.wins
            losses = $_.Value.losses
            total = $_.Value.wins + $_.Value.losses
            winRate = if (($_.Value.wins + $_.Value.losses) -gt 0) { $_.Value.wins / ($_.Value.wins + $_.Value.losses) } else { 0 }
            pnl = $_.Value.pnl
        }
    })
    $sorted = $byCoin | Sort-Object winRate -Descending
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
    strategy = "Pattern-Based: RSI Oversold/Overbought + Momentum + Volume"
    simulation_period = "2026-02-06 to 2026-05-07"
    initial_capital = $initialCapital
    final_capital = [Math]::Round($capital, 2)
    total_pnl = [Math]::Round($totalPnL, 2)
    total_pnl_percent = [Math]::Round($totalPnLPercent, 2)
    total_trades = $totalTrades
    signals_generated = $signalsGenerated
    winning_trades = $winningTrades
    losing_trades = $losingTrades
    win_rate = [Math]::Round($winRate, 3)
    win_rate_percent = [Math]::Round($winRate * 100, 1)
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
Write-Host "   PATTERN-BASED TRADING RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pattern: RSI<45/>55 + 3-day bounce/fall + Vol>1.2x"
Write-Host "Period: $($result.simulation_period)"
Write-Host ""
Write-Host "Initial: `$$initialCapital" -ForegroundColor Yellow
$finalColor = if ($totalPnL -ge 0) { "Green" } else { "Red" }
Write-Host "Final: `$$($result.final_capital)" -ForegroundColor $finalColor
Write-Host "P&L: `$$($result.total_pnl) ($($result.total_pnl_percent)%)" -ForegroundColor $finalColor
Write-Host ""
Write-Host "Total Trades: $($result.total_trades) / $signalsGenerated signals"
Write-Host "Win Rate: $($result.win_rate_percent)% ($($result.winning_trades) wins / $($result.losing_trades) losses)"
Write-Host "Avg Win: `$$($result.avg_win) | Avg Loss: `$$($result.avg_loss)"
Write-Host "Largest Win: `$$largestWin | Largest Loss: `$$largestLoss"
Write-Host ""
Write-Host "Best Coin: $($result.best_coin) | Worst Coin: $($result.worstCoin)"
Write-Host "Max Drawdown: $([Math]::Round($result.max_drawdown * 100, 2))%"
Write-Host ""
if ($winRate -ge 0.7) {
    Write-Host "*** 70%+ WIN RATE ACHIEVED! ***" -ForegroundColor Magenta
} else {
    Write-Host "Win Rate: $([Math]::Round($winRate * 100, 1))% (Target: 70%)" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Results saved to: $outputPath" -ForegroundColor Gray