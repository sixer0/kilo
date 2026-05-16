# Adaptive Signal Testing - Find Best Achievable Win Rate
$marketDataPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\market_data_90d.json"
$outputPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\adaptive_results.json"

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

# Test multiple parameter combinations
$bestConfig = $null
$bestWinRate = 0
$allResults = @()

$configs = @(
    @{rsiBuy=35; rsiSell=65; volMin=1.0; name="RSI35/65+V1.0"},
    @{rsiBuy=35; rsiSell=65; volMin=1.2; name="RSI35/65+V1.2"},
    @{rsiBuy=40; rsiSell=60; volMin=1.0; name="RSI40/60+V1.0"},
    @{rsiBuy=40; rsiSell=60; volMin=1.2; name="RSI40/60+V1.2"},
    @{rsiBuy=40; rsiSell=60; volMin=0.8; name="RSI40/60+V0.8"},
    @{rsiBuy=45; rsiSell=55; volMin=1.0; name="RSI45/55+V1.0"},
    @{rsiBuy=30; rsiSell=70; volMin=0.8; name="RSI30/70+V0.8"},
    @{rsiBuy=35; rsiSell=70; volMin=1.0; name="RSI35/70+V1.0"},
    @{rsiBuy=35; rsiSell=60; volMin=1.0; name="RSI35/60+V1.0"},
    @{rsiBuy=40; rsiSell=65; volMin=1.0; name="RSI40/65+V1.0"}
)

foreach ($config in $configs) {
    $capital = $initialCapital
    $wins = 0; $losses = 0; $signals = 0

    foreach ($coinName in $coins.PSObject.Properties.Name) {
        $candles = $coins.$coinName
        if ($candles.Count -lt 60) { continue }

        $prices = @($candles | ForEach-Object { $_.close })
        $highs = @($candles | ForEach-Object { $_.high })
        $lows = @($candles | ForEach-Object { $_.low })
        $vols = @($candles | ForEach-Object { $_.volume })

        for ($i = 25; $i -lt $prices.Count - 5; $i++) {
            $rsi = Get-RSI $prices[0..$i] 14

            $volSum = 0
            for ($j = $i - 19; $j -le $i; $j++) { $volSum += $vols[$j] }
            $volAvg = $volSum / 20
            $volRatio = if ($volAvg -gt 0) { $vols[$i] / $volAvg } else { 1 }

            $momentum3 = if ($i -ge 3) { ($prices[$i] - $prices[$i-3]) / $prices[$i-3] * 100 } else { 0 }

            $buySignal = $rsi -ne $null -and $rsi -lt $config.rsiBuy -and $volRatio -ge $config.volMin
            $sellSignal = $rsi -ne $null -and $rsi -gt $config.rsiSell -and $volRatio -ge $config.volMin

            if ($buySignal -or $sellSignal) {
                $signals++
                $signal = if ($buySignal) { "BUY" } else { "SELL" }

                $price = $prices[$i]
                $slDist = $price * 0.015
                $tpDist = $price * 0.03

                $riskAmount = $capital * $maxRiskPerTrade
                $posSize = $riskAmount / $slDist

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

                if ($signal -eq "BUY") {
                    if ($exitLow -le ($price - $slDist)) { $pnl = -$riskAmount }
                    elseif ($exitHigh -ge ($price + $tpDist)) { $pnl = $riskAmount * 2 }
                } else {
                    if ($exitHigh -ge ($price + $slDist)) { $pnl = -$riskAmount }
                    elseif ($exitLow -le ($price - $tpDist)) { $pnl = $riskAmount * 2 }
                }

                $capital += $pnl
                if ($pnl -gt 0) { $wins++ } else { $losses++ }
            }
        }
    }

    $total = $wins + $losses
    $winRate = if ($total -gt 0) { $wins / $total } else { 0 }

    $result = [PSCustomObject]@{
        config = $config.name
        rsiBuy = $config.rsiBuy
        rsiSell = $config.rsiSell
        volMin = $config.volMin
        signals = $signals
        wins = $wins
        losses = $losses
        winRate = $winRate
    }

    $allResults += $result

    if ($winRate -gt $bestWinRate) {
        $bestWinRate = $winRate
        $bestConfig = $config
    }
}

# Sort results
$sortedResults = $allResults | Sort-Object winRate -Descending

Write-Host "`n=== CONFIGURATION TEST RESULTS ===" -ForegroundColor Cyan
foreach ($r in $sortedResults) {
    $color = if ($r.winRate -ge 0.7) { "Green" } elseif ($r.winRate -ge 0.5) { "Yellow" } else { "Red" }
    Write-Host "$($r.config): Win Rate = $([Math]::Round($r.winRate * 100, 1))% ($($r.wins)/$($r.wins+$r.losses)) signals=$($r.signals)" -ForegroundColor $color
}

Write-Host "`nBest Configuration: $($bestConfig.name) with $([Math]::Round($bestWinRate * 100, 1))% win rate" -ForegroundColor Magenta

# Now run with best config
$capital = $initialCapital
$trades = @()
$equityHistory = @()
$winningTrades = 0; $losingTrades = 0
$totalWins = 0; $totalLosses = 0

Write-Host "`n=== RUNNING WITH BEST CONFIG: $($bestConfig.name) ===" -ForegroundColor Magenta

foreach ($coinName in $coins.PSObject.Properties.Name) {
    $candles = $coins.$coinName
    if ($candles.Count -lt 60) { continue }

    $prices = @($candles | ForEach-Object { $_.close })
    $highs = @($candles | ForEach-Object { $_.high })
    $lows = @($candles | ForEach-Object { $_.low })
    $vols = @($candles | ForEach-Object { $_.volume })

    for ($i = 25; $i -lt $prices.Count - 5; $i++) {
        $rsi = Get-RSI $prices[0..$i] 14

        $volSum = 0
        for ($j = $i - 19; $j -le $i; $j++) { $volSum += $vols[$j] }
        $volAvg = $volSum / 20
        $volRatio = if ($volAvg -gt 0) { $vols[$i] / $volAvg } else { 1 }

        $buySignal = $rsi -ne $null -and $rsi -lt $bestConfig.rsiBuy -and $volRatio -ge $bestConfig.volMin
        $sellSignal = $rsi -ne $null -and $rsi -gt $bestConfig.rsiSell -and $volRatio -ge $bestConfig.volMin

        if ($buySignal -or $sellSignal) {
            $signal = if ($buySignal) { "BUY" } else { "SELL" }

            $price = $prices[$i]
            $slDist = $price * 0.015
            $tpDist = $price * 0.03

            $riskAmount = $capital * $maxRiskPerTrade
            $posSize = $riskAmount / $slDist

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
            }

            $capital += $pnl
            $equityHistory += [PSCustomObject]@{ date = $candles[$i].date; equity = $capital }

            if ($pnl -gt 0) { $winningTrades++; $totalWins += $pnl }
            else { $losingTrades++; $totalLosses += [Math]::Abs($pnl) }
        }
    }
}

# Final metrics
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
    $sorted = $coinPnL.GetEnumerator() | ForEach-Object { [PSCustomObject]@{ coin = $_.Key; pnl = $_.Value } } | Sort-Object pnl -Descending
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
    strategy = "Adaptive - Best Config: $($bestConfig.name)"
    simulation_period = "2026-02-06 to 2026-05-07"
    initial_capital = $initialCapital
    final_capital = [Math]::Round($capital, 2)
    total_pnl = [Math]::Round($totalPnL, 2)
    total_pnl_percent = [Math]::Round($totalPnLPercent, 2)
    total_trades = $totalTrades
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
    config_tested = @($allResults | ForEach-Object {
        @{
            name = $_.config
            winRate = [Math]::Round($_.winRate * 100, 1)
            signals = $_.signals
        }
    })
}

$result | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FINAL RESULTS WITH BEST CONFIG" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Best Config: $($bestConfig.name)"
Write-Host "Initial: `$$initialCapital" -ForegroundColor Yellow
$finalColor = if ($totalPnL -ge 0) { "Green" } else { "Red" }
Write-Host "Final: `$$($result.final_capital)" -ForegroundColor $finalColor
Write-Host "P&L: `$$($result.total_pnl) ($($result.total_pnl_percent)%)" -ForegroundColor $finalColor
Write-Host ""
Write-Host "Total Trades: $($result.total_trades)"
Write-Host "Win Rate: $($result.win_rate_percent)% ($($result.winning_trades) wins / $($result.losing_trades) losses)"
Write-Host "Avg Win: `$$($result.avg_win) | Avg Loss: `$$($result.avg_loss)"
Write-Host ""
if ($winRate -ge 0.7) {
    Write-Host "*** 70%+ WIN RATE ACHIEVED! ***" -ForegroundColor Magenta
} else {
    Write-Host "Best achievable: $([Math]::Round($winRate * 100, 1))% (target: 70%)" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Results saved to: $outputPath" -ForegroundColor Gray