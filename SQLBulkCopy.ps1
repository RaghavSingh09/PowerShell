Set-StrictMode -Version Latest

trap
{
    Write-Error $_.Exception
    Write-Error $_.Exception.GetBaseException()
}

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended")

$sourceServerName = ''
$sourceDbName = ''
#$sourceUserName = ''
#$sourcePassword = ''

$targetServerName = ''
$targetDbName = ''
$targetUserName = ''
$targetPassword = ''

$connectionStringUsernamePassword = "Server={0};Database={1};User ID={2};Password={3};Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;"
$connectionStringIntegratedSecurity = "Server={0};Database={1};Integrated Security=True;Encrypt=True;TrustServerCertificate=True;Connection Timeout=60;"

$sourceConnection = new-object System.Data.SqlClient.SqlConnection (($connectionStringIntegratedSecurity -f $sourceServerName, $sourceDbName, $sourceUserName, $sourcePassword))
$targetConnection = new-object System.Data.SqlClient.SqlConnection (($connectionStringUsernamePassword -f $targetServerName, $targetDbName, $targetUserName, $targetPassword))

$sourceServer = new-object Microsoft.SqlServer.Management.Smo.Server $sourceConnection
$targetServer = new-object Microsoft.SqlServer.Management.Smo.Server $targetConnection

$dbSource = $sourceServer.Databases[$sourceDbName]
$dbTarget = $targetServer.Databases[$targetDbName]

Write-Output (Get-Date -format 'yyyy-MM-dd HH:mm:ss')
Write-Output "============================================================"
Write-Output "Source Server:$sourceServerName DB: $sourceDbName"
Write-Output "Target Server:$targetServerName DB: $targetDbName"
Write-Output "============================================================"
Write-Output ""

Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Output "Disable all constraints"
Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

$result = $dbTarget.ExecuteWithResults("SELECT 'ALTER TABLE [' + s.name + '].[' + o.name + '] NOCHECK CONSTRAINT ALL' FROM sys.foreign_keys i INNER JOIN sys.objects o ON i.parent_object_id = o.OBJECT_ID INNER JOIN sys.schemas s ON o.schema_id = s.schema_id")
$disableForeignKeys = ($result.Tables[0].Rows | select -ExpandProperty Column1) -join "`r`n"
$dbTarget.ExecuteNonQuery($disableForeignKeys)

Write-Output ""

Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Output "Copying Data"
Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

foreach ($table in $dbTarget.Tables)
{
    if ($table.Name -eq '__RefactorLog')
    {
        continue
    }
    
    if (($dbSource.Tables | select -ExpandProperty Name) -contains $table.Name)
    {
        Write-Host "Table - $table" -NoNewline

        $dbTarget.ExecuteNonQuery("DELETE FROM $table");
        Write-Host "." -NoNewline

        $result = $dbTarget.ExecuteWithResults("SELECT name FROM sys.columns WHERE is_computed = 0 AND object_id = OBJECT_ID('$table')")
        $columns = ($result.Tables[0].Rows | select -ExpandProperty name)
        Write-Host "." -NoNewline

        $bulkCopy = new-object System.Data.SqlClient.SqlBulkCopy ($targetConnection, ([System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity -bor [System.Data.SqlClient.SqlBulkCopyOptions]::KeepNulls -bor [System.Data.SqlClient.SqlBulkCopyOptions]::TableLock), $null)
        $bulkCopy.BatchSize = 10000

        foreach ($column in $columns)
        {
            $bulkCopy.ColumnMappings.Add($column, $column) | Out-Null
        }

        $connection = $sourceConnection.Clone()
        $connection.Open()
        try
        {
            $command = new-object System.Data.SqlClient.SqlCommand (("SELECT [" + ($columns -join "],[") + "] FROM $table"), $connection)
            $bulkCopy.DestinationTableName = "$table"
            $bulkCopy.WriteToServer($command.ExecuteReader())
        }
        finally
        {
            $bulkCopy.Close()
            $connection.Close()
        }

        Write-Output "."
    }
    else
    {
        Write-Output "!!!!! - $table.Name (NOT FOUND)"
    }
}

Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Output ""

Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Output "Enable constraints"
Write-Output "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

$result = $dbTarget.ExecuteWithResults("SELECT 'ALTER TABLE [' + s.name + '].[' + o.name + '] WITH CHECK CHECK CONSTRAINT [' + i.name + ']' FROM sys.foreign_keys i INNER JOIN sys.objects o ON i.parent_object_id = o.OBJECT_ID INNER JOIN sys.schemas s ON o.schema_id = s.schema_id")
$enableForeignKeys = ($result.Tables[0].Rows | select -ExpandProperty Column1) -join "`r`n"
$dbTarget.ExecuteNonQuery("$enableForeignKeys")

Write-Output ""

Write-Output (Get-Date -format 'yyyy-MM-dd HH:mm:ss')
Write-Output "Done"