$Folder="C:\Users\ragkumar\Desktop\TSYS_Docs"
[hashtable]$Return = @{} 

$files = get-childitem -Path $Folder -File #'*.PNG'
foreach($file in $Files)
{
#$file.Name| out-file -FilePath $MyReport -Append
$Return.ReturnString += [array] $file.Name+","
}
Return $Return


#$Folder="C:\Users\ragkumar\Desktop\TSYS_Docs"
#powershell.exe -ExecutionPolicy Bypass -windowstyle hidden -File "C:\Users\ragkumar\Desktop\TSYS_Docs\PS_Scripts\GetFileNamesWithParam.ps1 'C:\Users\ragkumar\Desktop\TSYS_Docs'"
#powershell.exe -ExecutionPolicy Bypass -windowstyle hidden -File "C:\Users\ragkumar\Desktop\TSYS_Docs\PS_Scripts\GetFileNamesWithReObj.ps1"