param ($InPutFile,$OutPutFile,$Date)
Function Get-FilesFromZipRecursively ($InputItem){
if($Date -eq "~")
{
    if (!$InputItem.IsFolder)
    {
        gc $InputItem.path -read 10000 | % { $nlines += $_.Length };
        if($OutPutFile -ne "~")
        {
            $InputItem.path+","+$nlines | Out-File -Append $OutPutFile -Encoding UTF8
            Write-Host $InputItem.path","$InputItem.size","$nlines
        }
        else
        {
            Write-Host $InputItem.path","$InputItem.size","$nlines
        }
    }
}
else
{
    if (!$InputItem.IsFolder -and ($InputItem.ModifyDate.ToString('MM/dd/yyyy') -eq $Date))
    {
        gc $InputItem.path -read 1000 | % { $nlines += $_.Length };      
        if($OutPutFile -ne "~")
        {
            $InputItem.path+","+$nlines | Out-File -Append $OutPutFile -Encoding UTF8
            Write-Host $InputItem.path","$InputItem.size","$nlines
        }
        else
        {
            Write-Host $InputItem.path","$InputItem.size","$nlines
        }
    }
}
    if ($InputItem.IsFolder) 
    {
        foreach ($Item in ($Shell.NameSpace($InputItem.Path)).Items()) 
        {
            Get-FilesFromZipRecursively -InputItem $Item
        }
    }
}

$shell = new-object -com shell.application
#$FolderPath = "C:\Users\rkumar699\Desktop\PS_Files"
#$OutPutFile = "C:\Users\rkumar699\Desktop\so.csv"
#$Date = "07/07/2020"
$zip = $shell.namespace("$InPutFile")
$zip.items() | ForEach-Object {
Get-FilesFromZipRecursively -InputItem $_
}
