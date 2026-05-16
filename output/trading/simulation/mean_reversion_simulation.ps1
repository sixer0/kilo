# Mean Reversion + Trend Confirmation Strategy
# Target: 70%+ win rate by only taking highest probability setups

$marketDataPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\market_data_90d.json"
$outputPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\mean_reversion_results.json"

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

function Get-SMA {
    param($arr, $period)
    if ($arr.Count -lt $period) { return $null }
    $sum = 0
    for ($i = $arr.Count - $period; $i -lt $arr.Count; $i++) { $sum += $arr[$i] }
    return $sum / $period
}

function Get-EMA {
    param($arr, $period)
    if ($arr.Count -lt $period) { return $null }
    $k = 2 / ($period + 1)
    $ema = $arr[0]
    for ($i = 1; $i -lt $arr.Count; $i++) { $ema = ($arr[$i] * $k) + ($ema * (1 - $k)) }
    return $ema
}

$capital = $initialCapital
$trades = @()
$equityHistory = @()
$winningTrades = 0; $losingTrades = 0
$totalWins = 0; $totalLosses = 0
$signalsGenerated = 0

Write-Host "`n=== MEAN REVERSION + TREND CONFIRMATION ===" -ForegroundColor Magenta
Write-Host "Strict: Only extreme RSI + trend alignment + volume" -ForegroundColor Gray

# Parameters - VERY strict to filter for high probability
$minRSIBuy = 35      # Very oversold
$maxRSIBuy = 45      # But not extreme
$minRSISell = 55     # Very overbought
$maxRSISell = 65     # But not extreme
$minVolRatio = 1.3   # Above average volume
$minTrendStrength = 0.001  # Price above/below EMA

foreach ($coinName in $coins.PSObject.Properties.Name) {
    $candles = $coins.$coinName
    if ($candles.Count -lt 60) { continue }

    $prices = @($candles | ForEach-Object { $_.close })
    $highs = @($candles | ForEach-Object { $_.high })
    $lows = @($candles | ForEach-Object { $_.low })
    $vols = @($candles | ForEach-Object { $_.volume })

    Write-Host "Processing $coinName ($($candles.Count) candles)..." -ForegroundColor Cyan

    for ($i = 30; $i -lt $prices.Count - 5; $i++) {
        $rsi = Get-RSI $prices[0..$i] 14
        if ($null -eq $rsi) { continue }

        # Volume
        $volSum = 0
        for ($j = $i - 19; $j -le $i; $j++) { $volSum += $vols[$j] }
        $volAvg = $volSum / 20
        $volRatio = if ($volAvg -gt 0) { $vols[$i] / $volAvg } else { 1 }

        # EMA 20 for short-term trend
        $ema20 = Get-EMA $prices[0..$i] 20
        $ema50 = Get-EMA $prices[0..$i] 50

        # Price relative to EMA
        $priceAboveEma20 = if ($ema20) { $prices[$i] -gt $ema20 } else { $false }
        $priceAboveEma50 = if ($ema50) { $prices[$i] -gt $ema50 } else { $false }

        # 5-day return for momentum
        $ret5 = if ($i -ge 5) { ($prices[$i] - $prices[$i-5]) / $prices[$i-5] * 100 } else { 0 }

        # Bollinger band position
        $sma20 = Get-SMA $prices[0..$i] 20
        $sumSq = 0
        for ($j = $i - 19; $j -le $i; $j++) { $sumSq += [Math]::Pow($prices[$j] - $sma20, 2) }
        $std = [Math]::Sqrt($sumSq / 20)
        $bbLower = $sma20 - (2 * $std)
        $bbUpper = $sma20 + (2 * $std)
        $bbPos = if ($std -gt 0) { ($prices[$i] - $sma20) / $std } else { 0 }

        # BUY: RSI oversold zone + price near lower band + positive momentum
        $buySignal = $rsi -lt $minRSIBuy -and
                     $bbPos -lt -1.5 -and     # Price well below lower band
                     $ret5 -gt 0 -and         # Price recovering (5-day positive)
                     $volRatio -ge $minVolRatio -and
                     ($ema20 -eq $null -or $prices[$i] -gt $ema20)  # Above short-term EMA

        # SELL: RSI overbought zone + price near upper band + negative momentum
        $sellSignal = $rsi -gt $minRSISell -and
                      $bbPos -gt 1.5 -and      # Price well above upper band
                      $ret5 -lt 0 -and        # Price falling (5-day negative)
                      $volRatio -ge $minVolRatio -and
                      ($ema20 -eq $null -or $prices[$i] -lt $ema20)  # Below short-term EMA

        if ($buySignal -or $sellSignal) {
            $signalsGenerated++
            $signal = if ($buySignal) { "BUY" } else { "SELL" }

            $price = $prices[$i]
            # Tighter stop loss for better risk/reward
            $slDist = $price * 0.012  # 1.2% stop loss
            $tpDist = $price * 0.024  # 2.4% take profit (2:1)

            $riskAmount = $capital * $maxRiskPerTrade
            $posSize = $riskAmount / $slDist

            # Hold 3-4 days
            $holdDays = 3 + (Get-Random -Maximum 2)
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
                pnl = [Math]::Round($pnl, 2)
                result = $result
                rsi = [Math]::Round($rsi, 1)
                bbPos = [Math]::Round($bbPos, 2)
                ret5 = [Math]::Round($ret5, 2)
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
    strategy = "Mean Reversion: Extreme RSI + Bollinger + Momentum + Volume"
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
Write-Host "   MEAN REVERSION STRATEGY RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pattern: RSI<35 + BB<-1.5 + 5dRet>0 + Vol>1.3 | RSI>55 + BB>+1.5 + 5dRet<0 + Vol>1.3"
Write-Host ""
Write-Host "Initial: `$$initialCapital" -ForegroundColor Yellow
$finalColor = if ($totalPnL -ge 0) { "Green" } else { "Red" }
Write-Host "Final: `$$($result.final_capital)" -ForegroundColor $finalColor
Write-Host "P&L: `$$($result.total_pnl) ($($result.total_pnl_percent)%)" -ForegroundColor $finalColor
Write-Host ""
Write-Host "Total Trades: $($result.total_trades) / $signalsGenerated signals"
Write-Host "Win Rate: $($result.win_rate_percent)% ($($result.winning_trades) wins / $($result.losing_trades) losses)"
Write-Host "Avg Win: `$$($result.avg_win) | Avg Loss: `$$($result.avg_loss)"
Write-Host ""
if ($winRate -ge 0.7) {
    Write-Host "*** 70%+ WIN RATE ACHIEVED! ***" -ForegroundColor Magenta
} else {
    Write-Host "Win Rate: $([Math]::Round($winRate * 100, 1))% (Target: 70%)" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Results saved to: $outputPath" -ForegroundColor Gray

# Show trade sample
if ($trades.Count -gt 0) {
    Write-Host "`n=== TRADE SAMPLE ===" -ForegroundColor Gray
    $sample = $trades | Select-Object -First 5
    foreach ($t in $sample) {
        Write-Host "$($t.date) $($t.coin) $($t.signal) @ $($t.entryPrice) -> $($t.exitPrice) = $($t.pnl) ($($t.result)) RSI=$($t.rsi) BB=$($t.bbPos)"
    }
}