param([string] $Folder)

$serverName = "EHPSALNDWP01SQL"
$databaseName = "DMExploration"
$tableName = "RKumar.VAPS_NTS_1_FileNames"
$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = "server='$serverName';database='$databaseName';trusted_connection=true;"
$Connection.Open()
$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $Connection

$insertQuery="TRUNCATE TABLE $tableName; " +"INSERT INTO $tableName ([Filenames]) VALUES " 

$files = get-childitem -Path $Folder -File '*NTS_1*'
foreach($file in $Files)
{
    $filenames = $file.Name
    $insertQuery+="('$filenames'),"
}

$insertQuery = $insertQuery.Substring(0,$insertQuery.Length-1)
$Command.CommandText = $insertQuery
$Command.ExecuteNonQuery()
$Connection.Close();