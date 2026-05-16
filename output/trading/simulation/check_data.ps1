$json = Get-Content 'C:\Users\sixer\.config\kilo\output\trading\simulation\market_data_90d.json' -Raw | ConvertFrom-Json
$coinNames = $json.coins.PSObject.Properties.Name
foreach ($name in $coinNames) {
    $candles = $json.coins.$name
    Write-Output "$name : $($candles.Count) candles"
}