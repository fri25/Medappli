$ErrorActionPreference = 'Stop'
$reportPath = Join-Path -Path (Get-Location) -ChildPath 'vendor_report.txt'
if (Test-Path $reportPath) { Remove-Item $reportPath -Force }
Write-Output "PWD: $(Get-Location)" | Tee-Object -FilePath $reportPath -Append

if (-Not (Test-Path -Path .\vendor)) {
    "Vendor directory not found" | Tee-Object -FilePath $reportPath -Append
    exit 0
}

$vendorSize = (Get-ChildItem -Path .\vendor -File -Recurse -Force | Measure-Object Length -Sum).Sum
"Total vendor size: $([math]::Round($vendorSize/1MB,2)) MB" | Tee-Object -FilePath $reportPath -Append

"`nTop 50 largest files in vendor (path<TAB>sizeMB):" | Tee-Object -FilePath $reportPath -Append
Get-ChildItem -Path .\vendor -File -Recurse -Force | Sort-Object Length -Descending | Select-Object -First 50 FullName,@{Name='SizeMB';Expression={[math]::Round($_.Length/1MB,2)}} | ForEach-Object { "{0}`t{1}" -f $_.FullName,$_.SizeMB } | Tee-Object -FilePath $reportPath -Append

"`nTop 30 largest directories under vendor (by aggregate size MB):" | Tee-Object -FilePath $reportPath -Append
Get-ChildItem -Path .\vendor -Directory -Recurse -Force | ForEach-Object { $size=(Get-ChildItem $_.FullName -File -Recurse -Force | Measure-Object Length -Sum).Sum; [PSCustomObject]@{Path=$_.FullName; SizeMB=[math]::Round($size/1MB,2)} } | Sort-Object SizeMB -Descending | Select-Object -First 30 | ForEach-Object { "{0}`t{1}" -f $_.Path,$_.SizeMB } | Tee-Object -FilePath $reportPath -Append

"`nDompdf fonts (if any):" | Tee-Object -FilePath $reportPath -Append
if (Test-Path -Path .\vendor\dompdf\dompdf\lib\fonts) {
    Get-ChildItem -Path .\vendor\dompdf\dompdf\lib\fonts -File | Select-Object FullName,@{Name='SizeKB';Expression={[math]::Round($_.Length/1KB,2)}} | ForEach-Object { "{0}`t{1} KB" -f $_.FullName,$_.SizeKB } | Tee-Object -FilePath $reportPath -Append
} else {
    "No dompdf fonts dir" | Tee-Object -FilePath $reportPath -Append
}

"`nGoogle apiclient-services src sizes (top 40):" | Tee-Object -FilePath $reportPath -Append
if (Test-Path -Path .\vendor\google\apiclient-services\src) {
    Get-ChildItem -Path .\vendor\google\apiclient-services\src -Directory -Force | ForEach-Object { $size=(Get-ChildItem $_.FullName -File -Recurse -Force | Measure-Object Length -Sum).Sum; [PSCustomObject]@{Path=$_.FullName; SizeMB=[math]::Round($size/1MB,2)} } | Sort-Object SizeMB -Descending | Select-Object -First 40 | ForEach-Object { "{0}`t{1}" -f $_.Path,$_.SizeMB } | Tee-Object -FilePath $reportPath -Append
} else {
    "google/apiclient-services/src not found" | Tee-Object -FilePath $reportPath -Append
}

"`nDone" | Tee-Object -FilePath $reportPath -Append
