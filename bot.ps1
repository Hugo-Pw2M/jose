# Copy Trading Bot By Hugo Dev | Hug_DEV@proton.me | 06/12/2022
Import-Module BurntToast
$startTS = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

while (1 -eq 1){
    $get = Invoke-WebRequest -UseBasicParsing -Uri "https://www.binance.com/bapi/futures/v3/public/future/leaderboard/getLeaderboardRank" `
        -Method "POST" `
        -ContentType "application/json" `
        -Body "{`"tradeType`":`"PERPETUAL`",`"statisticsType`":`"PNL`",`"periodType`":`"DAILY`",`"isShared`":true,`"isTrader`":false}"
    $Res = $get.Content
    $Res = $Res | ConvertFrom-Json
    $Res = $Res.data
    foreach ($user in ($Res | Select-Object -First 20)){
        $getpos = Invoke-WebRequest -UseBasicParsing -Uri "https://www.binance.com/bapi/futures/v1/public/future/leaderboard/getOtherPosition" `
            -Method "POST" `
            -ContentType "application/json" `
            -Body "{`"encryptedUid`":`"$($user.encryptedUid)`",`"tradeType`":`"PERPETUAL`"}"
        $Respos = $getpos.Content
        $Respos = $Respos | ConvertFrom-Json
        $Respos = $Respos.data.otherPositionRetList
        foreach ($val in $Respos){
            if ($startTS -lt $val.updateTimeStamp){
                write-host '{"updateTimeStamp": "'$($val.updateTimeStamp)'","nickname": "'$($user.nickname)'","encryptedUid": "'$($user.encryptedUid)'","positionShared": "'$($user.positionShared)'","position": {"symbol": "'$($val.symbol)'","entryPrice": "'$($val.entryPrice)'","markPrice": "'$($val.markPrice)'","leverage": "'$($val.leverage)'"}}'
                $notif = '🤵Trader🤵:' , $user.nickname , '
💸Crypto💸:' , $val.symbol , '
📈Levier📉:' , $val.leverage , '
🏧Prix🏧: ' , $val.markPrice
                New-BurntToastNotification -Text 'Nouvelle position', $notif -AppLogo 'C:\Copy Trade Bot\logo.png'
            }
        }
    }
}