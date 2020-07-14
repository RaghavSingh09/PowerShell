$Folder="C:\Users\rkumar498\Desktop\RF"
#$MyReport="C:\Users\rkumar498\Desktop\MyReport.txt"

#'FileNames'|out-file $MyReport
$files = get-childitem -Path $Folder -Recurse -File
foreach($file in $Files)
{
$fullname = $file.FullName
$extension = $file.Extension

#Write-Host $name $fullname $extension

    if($file.Name.Contains("_"))
    {
        $sepIndex = ($file.Name.IndexOf("_"))
        $renamedFile = $file.Name.substring(0,$sepIndex)+$extension
        #$renamedFile | out-file -FilePath $MyReport -Append
        Rename-Item -Path $fullname -NewName $renamedFile
    }
}