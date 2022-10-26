
[string]$temlpe_network_mask = "\b([1-9]|1[0-9]|2[0-9]|3[0-2])\b"

$count_error = 0
for ($i = 1; $i -lt 33; $i++) {   
    if ($i -match $temlpe_network_mask) {
        Write-Host "True"
    }
    else {
        Write-Host "False. Value => $i." -ForegroundColor Red
        $count_error++
    }
}    
if ($count_error -eq 0){
    Write-Host "The test is passed." -ForegroundColor Green
} 
else {
    Write-Host "There is $count_error errors." -ForegroundColor Red
    Write-Host "The test isn't passed." -ForegroundColor Red
}