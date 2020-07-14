#Get-Service -Name 'MSSQL$SSMS_TEST' | Where-Object {$_.Status -eq "Stopped"} | Restart-Service
Clear
$srvName = 'MSSQL$SSMS_TEST'
$servicePrior = Get-Service $srvName
if($servicePrior.Status -eq "Running")
{
Write-Host  $srvName is already running.
exit
}
Set-Service $srvName -startuptype Automatic
Start-Service $srvName
$serviceAfter = Get-Service $srvName
Write-Host  $srvName is now   $serviceAfter.status
