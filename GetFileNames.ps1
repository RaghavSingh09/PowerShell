$Folder="C:\Users\ragkumar\Desktop\TSYS_Docs"
$MyReport="C:\Users\ragkumar\Desktop\MyReport.txt"
dir $Folder|?{!$_.PSIsContainer}|select -ExpandProperty Name >$MyReport

'FileNames'|out-file $MyReport
$files = get-childitem -Path $Folder -File #'*.PNG'
foreach($file in $Files)
{
$file.Name| out-file -FilePath $MyReport -Append
}