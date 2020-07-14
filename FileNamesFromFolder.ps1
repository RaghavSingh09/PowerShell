$Folder="C:\Users\rkumar498\Desktop\GY-PS"
$MyReport="C:\Users\rkumar498\Desktop\MyReport.txt"
#dir $Folder|?{!$_.PSIsContainer}|select -ExpandProperty Name >$MyReport

'FileNames'|out-file $MyReport
$files = get-childitem -Path $Folder -Recurse -File
foreach($file in $Files)
{
$file.Name| out-file -FilePath $MyReport -Append
}