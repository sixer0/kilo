# Wide-Range Multi-Configuration Trading Simulation
$marketDataPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\market_data_90d.json"
$outputPath = "C:\Users\sixer\.config\kilo\output\trading\simulation\wide_simulation_results.json"

Write-Host "Loading market data..." -ForegroundColor Cyan
$json = Get-Content $marketDataPath -Raw | ConvertFrom-Json
$coins = $json.coins

$initialCapital = 10000
$maxRiskPerTrade = 0.02

$rsiLevels = @(30, 35, 40, 45, 50)
$volMultipliers = @(0.8, 1.0, 1.2, 1.5)
$stopLosses = @(0.01, 0.015, 0.02)
$takeProfits = @(0.02, 0.03, 0.04, 0.05)

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

function Run-Simulation {
    param($rsiThreshold, $volMult, $stopLoss, $takeProfit)

    $capital = $initialCapital
    $winningTrades = 0; $losingTrades = 0
    $totalWins = 0; $totalLosses = 0

    foreach ($coinName in $coins.PSObject.Properties.Name) {
        $candles = $coins.$coinName
        if ($candles.Count -lt 60) { continue }

        $prices = @($candles | ForEach-Object { $_.close })
        $highs = @($candles | ForEach-Object { $_.high })
        $lows = @($candles | ForEach-Object { $_.low })
        $vols = @($candles | ForEach-Object { $_.volume })

        for ($i = 25; $i -lt $prices.Count - 7; $i++) {
            $rsi = Get-RSI $prices[0..$i] 14
            if ($rsi -eq $null) { continue }

            $volSum = 0
            for ($j = [Math]::Max(0, $i - 19); $j -le $i; $j++) { $volSum += $vols[$j] }
            $volAvg = $volSum / [Math]::Min(20, $i + 1)
            $volRatio = if ($volAvg -gt 0) { $vols[$i] / $volAvg } else { 1 }

            $momentum3 = if ($i -ge 3) { ($prices[$i] - $prices[$i-3]) / $prices[$i-3] * 100 } else { 0 }

            $ema50 = Get-EMA $prices[0..$i] 50
            $ema200 = Get-EMA $prices[0..$i] 200
            $uptrend = ($ema50 -and $ema200 -and $ema50 -gt $ema200)

            $buySignal = $rsi -lt $rsiThreshold -and $volRatio -ge $volMult -and $momentum3 -ge 0 -and $uptrend
            $sellSignal = $rsi -gt (100 - $rsiThreshold) -and $volRatio -ge $volMult -and $momentum3 -le 0 -and -not $uptrend

            if (-not ($buySignal -or $sellSignal)) { continue }

            $signal = if ($buySignal) { "BUY" } else { "SELL" }
            $price = $prices[$i]
            $slDist = $price * $stopLoss
            $tpDist = $price * $takeProfit

            $riskAmount = $capital * $maxRiskPerTrade
            $posSize = $riskAmount / $slDist

            $holdDays = 3 + (Get-Random -Maximum 3)
            $exitIdx = [Math]::Min($i + $holdDays, $prices.Count - 1)
            $exitPrice = $prices[$exitIdx]
            $exitHigh = $highs[$exitIdx]
            $exitLow = $lows[$exitIdx]

            $pnl = if ($signal -eq "BUY") {
                ($exitPrice - $price) * $posSize
            } else {
                ($price - $exitPrice) * $posSize
            }

            if ($signal -eq "BUY") {
                if ($exitLow -le ($price - $slDist)) { $pnl = -$riskAmount }
                elseif ($exitHigh -ge ($price + $tpDist)) { $pnl = $riskAmount * ($takeProfit / $stopLoss) }
            } else {
                if ($exitHigh -ge ($price + $slDist)) { $pnl = -$riskAmount }
                elseif ($exitLow -le ($price - $tpDist)) { $pnl = $riskAmount * ($takeProfit / $stopLoss) }
            }

            $capital += $pnl
            if ($pnl -gt 0) { $winningTrades++; $totalWins += $pnl }
            else { $losingTrades++; $totalLosses += [Math]::Abs($pnl) }
        }
    }

    $totalTrades = $winningTrades + $losingTrades
    $winRate = if ($totalTrades -gt 0) { $winningTrades / $totalTrades } else { 0 }

    return @{
        totalTrades = $totalTrades
        winningTrades = $winningTrades
        losingTrades = $losingTrades
        winRate = $winRate
        winRatePercent = [Math]::Round($winRate * 100, 1)
        totalPnL = [Math]::Round($capital - $initialCapital, 2)
        totalPnLPercent = [Math]::Round((($capital - $initialCapital) / $initialCapital) * 100, 2)
        avgWin = if ($winningTrades -gt 0) { [Math]::Round($totalWins / $winningTrades, 2) } else { 0 }
        avgLoss = if ($losingTrades -gt 0) { [Math]::Round($totalLosses / $losingTrades, 2) } else { 0 }
        finalCapital = [Math]::Round($capital, 2)
    }
}

$allResults = @()
$totalConfigs = $rsiLevels.Count * $volMultipliers.Count * $stopLosses.Count * $takeProfits.Count
$configNum = 0

Write-Host "`n=== WIDE-RANGE CONFIGURATION TESTING ===" -ForegroundColor Magenta
Write-Host "Testing $totalConfigs configurations" -ForegroundColor Cyan
Write-Host "RSI: $($rsiLevels -join ', ')" -ForegroundColor Gray
Write-Host "Vol Mult: $($volMultipliers -join ', ')" -ForegroundColor Gray
Write-Host "SL: $($stopLosses -join ', ')" -ForegroundColor Gray
Write-Host "TP: $($takeProfits -join ', ')" -ForegroundColor Gray
Write-Host ""

foreach ($rsi in $rsiLevels) {
    foreach ($vol in $volMultipliers) {
        foreach ($sl in $stopLosses) {
            foreach ($tp in $takeProfits) {
                $configNum++
                Write-Host "[$configNum/$totalConfigs] RSI<$rsi Vol>$($vol)x SL=$($sl*100)% TP=$($tp*100)%" -ForegroundColor DarkGray

                $result = Run-Simulation $rsi $vol $sl $tp

                $allResults += [PSCustomObject]@{
                    configNum = $configNum
                    rsiThreshold = $rsi
                    volMultiplier = $vol
                    stopLoss = $sl
                    takeProfit = $tp
                    totalTrades = $result.totalTrades
                    winningTrades = $result.winningTrades
                    losingTrades = $result.losingTrades
                    winRate = $result.winRate
                    winRatePercent = $result.winRatePercent
                    totalPnL = $result.totalPnL
                    totalPnLPercent = $result.totalPnLPercent
                    avgWin = $result.avgWin
                    avgLoss = $result.avgLoss
                    finalCapital = $result.finalCapital
                }
            }
        }
    }
}

$sortedByWinRate = $allResults | Sort-Object winRate -Descending
$topByWinRate = $sortedByWinRate | Select-Object -First 10

$qualifiedConfigs = $allResults | Where-Object { $_.winRate -ge 0.70 -and $_.totalTrades -ge 10 } | Sort-Object winRate -Descending

$bestConfig = $sortedByWinRate[0]

$output = @{
    totalConfigurationsTested = $totalConfigs
    simulation_period = "2026-02-06 to 2026-05-07"
    qualifiedConfigurations = $qualifiedConfigs
    bestConfiguration = $bestConfig
    topTenByWinRate = $topByWinRate
    allResults = $allResults
}

$output | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   WIDE-RANGE SIMULATION RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total configurations tested: $totalConfigs" -ForegroundColor Yellow
Write-Host ""

if ($qualifiedConfigs.Count -gt 0) {
    Write-Host "=== 70%+ WIN RATE WITH 10+ TRADES ===" -ForegroundColor Magenta
    Write-Host ""
    foreach ($q in $qualifiedConfigs) {
        Write-Host "Config #$($q.configNum): RSI<$($q.rsiThreshold) Vol>$($q.volMultiplier)x SL=$($q.stopLoss*100)% TP=$($q.takeProfit*100)%" -ForegroundColor Green
        Write-Host "  Trades: $($q.totalTrades) | Win Rate: $($q.winRatePercent)% | P&L: `$$($q.totalPnL) ($($q.totalPnLPercent)%)" -ForegroundColor Green
        Write-Host "  Avg Win: `$$($q.avgWin) | Avg Loss: `$$($q.avgLoss)" -ForegroundColor Gray
        Write-Host ""
    }
} else {
    Write-Host "NO CONFIGURATIONS MET 70%+ WIN RATE WITH 10+ TRADES" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Top 3 by Win Rate:" -ForegroundColor Cyan
    $sortedByWinRate | Select-Object -First 3 | ForEach-Object {
        Write-Host "  RSI<$($_.rsiThreshold) Vol>$($_.volMultiplier)x SL=$($_.stopLoss*100)% TP=$($_.takeProfit*100)% - $($_.totalTrades) trades, $($_.winRatePercent)% win rate, `$$($_.totalPnL) P&L" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "=== BEST CONFIGURATION ===" -ForegroundColor Cyan
Write-Host "RSI<$($bestConfig.rsiThreshold) Vol>$($bestConfig.volMultiplier)x SL=$($bestConfig.stopLoss*100)% TP=$($bestConfig.takeProfit*100)%" -ForegroundColor Green
Write-Host "Trades: $($bestConfig.totalTrades)" -ForegroundColor White
Write-Host "Win Rate: $($bestConfig.winRatePercent)%" -ForegroundColor $(if ($bestConfig.winRate -ge 0.7) { "Green" } else { "Yellow" })
Write-Host "Total P&L: `$$($bestConfig.totalPnL) ($($bestConfig.totalPnLPercent)%)" -ForegroundColor $(if ($bestConfig.totalPnL -ge 0) { "Green" } else { "Red" })
Write-Host "Final Capital: `$$($bestConfig.finalCapital)" -ForegroundColor White
Write-Host ""

Write-Host "=== RECOMMENDATIONS FOR NEXT TEST ===" -ForegroundColor Cyan
$highWinConfigs = $sortedByWinRate | Where-Object { $_.winRate -ge 0.5 } | Select-Object -First 5
if ($highWinConfigs.Count -gt 0) {
    $avgWinRate = ($highWinConfigs | Measure-Object winRate -Average).Average
    Write-Host "Focus on RSI range $($highWinConfigs[0].rsiThreshold)-$($highWinConfigs[-1].rsiThreshold) based on $("{0:N0}" -f ($highWinConfigs.Count)) configs with 50%+ win rate" -ForegroundColor Gray
    Write-Host "Average win rate in top configs: $($avgWinRate.ToString('P1'))" -ForegroundColor Gray

    $commonRSI = ($highWinConfigs | Group-Object rsiThreshold | Sort-Object Count -Descending | Select-Object -First 1).Name
    $commonVol = ($highWinConfigs | Group-Object volMultiplier | Sort-Object Count -Descending | Select-Object -First 1).Name
    $commonSL = ($highWinConfigs | Group-Object stopLoss | Sort-Object Count -Descending | Select-Object -First 1).Name
    $commonTP = ($highWinConfigs | Group-Object takeProfit | Sort-Object Count -Descending | Select-Object -First 1).Name

    Write-Host ""
    Write-Host "Most common parameters in top performers:" -ForegroundColor Gray
    Write-Host "  RSI: $commonRSI" -ForegroundColor Gray
    Write-Host "  Volume Multiplier: $commonVol" -ForegroundColor Gray
    Write-Host "  Stop Loss: $($commonSL*100)%" -ForegroundColor Gray
    Write-Host "  Take Profit: $($commonTP*100)%" -ForegroundColor Gray

    Write-Host ""
    Write-Host "Suggested next tests:" -ForegroundColor Cyan
    $testRSI = @($commonRSI - 5, $commonRSI + 5) | Where-Object { $_ -ge 20 -and $_ -le 60 }
    $testVol = @($commonVol - 0.2, $commonVol + 0.2) | Where-Object { $_ -ge 0.5 -and $_ -le 2.0 }
    $testSL = @($commonSL - 0.005, $commonSL + 0.005) | Where-Object { $_ -ge 0.005 -and $_ -le 0.03 }
    $testTP = @($commonTP - 0.01, $commonTP + 0.01) | Where-Object { $_ -ge 0.015 -and $_ -le 0.08 }

    foreach ($r in $testRSI) {
        foreach ($v in $testVol) {
            foreach ($s in $testSL) {
                foreach ($t in $testTP) {
                    if ($r -gt 0 -and $v -gt 0 -and $s -gt 0 -and $t -gt 0) {
                        Write-Host "  RSI=$r, Vol=$([Math]::Round($v,1))x, SL=$([Math]::Round($s*100,1))%, TP=$([Math]::Round($t*100,1))%" -ForegroundColor DarkYellow
                    }
                }
            }
        }
    }
}

Write-Host ""
Write-Host "Results saved to: $outputPath" -ForegroundColor Gray
