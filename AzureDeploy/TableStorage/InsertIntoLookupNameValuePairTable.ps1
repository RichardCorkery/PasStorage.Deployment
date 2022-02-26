param (
    [string]$ResourceGroupName = $(throw "-ResourceGroupName is required."),
    [string]$StorageAccountName = $(throw "-StorageAccountName is required."),
    [string]$DataPath
)

Install-Module AzureRmStorageTable -Force

$tableName = "LookupNameValuePair"

$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName

$storageTable = Get-AzStorageTable `
    -Name $tableName `
    -Context $storageAccount.Context `
    -ErrorVariable ev `
    -ErrorAction SilentlyContinue

if ($ev) {       
    New-AzStorageTable -Name $tableName -Context $storageAccount.Context
    $storageTable = Get-AzStorageTable -Name $tableName -Context $storageAccount.Context
}

$tableDataPath = "LookupNameValuePairTableData.json"

if ($DataPath) {
    $tableDataPath = $DataPath + $tableDataPath
}

$rows = Get-Content -Raw -Path $tableDataPath | ConvertFrom-Json

ForEach ($row in $rows) {
    try {
        Add-AzTableRow `
            -table $storageTable.CloudTable `
            -partitionKey $row.PartitionKey`
            -rowKey $row.RowKey `
            -property @{"LookupKey" = $row.Name; "Value" = $row.Value } `
            -ErrorVariable ev `
            -ErrorAction SilentlyContinue
    }
    catch [System.Management.Automation.MethodInvocationException] {
        $tableRow = Get-AzTableRow `
            -table $storageTable.CloudTable `
            -partitionKey $row.PartitionKey `
            -rowKey $row.RowKey
            
        $tableRow.LookupKey = $row.Name
        $tableRow.Value = $row.Value

        $tableRow | Update-AzTableRow -table $storageTable.CloudTable  

        Write-Host $tableRow
    }
}