# Deploy CDB Commands...slot environment and region is covered by CDB redundancy mechanisms
param ($params)

if (((Get-AzContext).subscription).id -ne $params.command_storage_group_sub_0c00dg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.command_storage_group_sub_0c00dg0s
    Set-AzContext $context
}

# not in production !
if ($lane -ne 'z') {
    Write-Host "======================="
    Write-Host "Delete RG Commands Data"
    Write-Host "======================="

    Remove-AzResourceGroup `
        -Name $params.command_storage_group_0c00dg0 `
        -Force -ErrorAction SilentlyContinue
}

Write-Host "======================="
Write-Host "Create RG Commands Data"
Write-Host "======================="

New-AzResourceGroup `
    -Name $params.command_storage_group_0c00dg0 `
    -Location $params.command_storage_group_loc_0c00dg0l

Write-Host "========================"
Write-Host "Create CDB Commands Data"
Write-Host "========================"

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_storage_group_0c00dg0 `
    -TemplateFile $params.command_storage_cdb_tpl_0c00dc0t `
    -TemplateParameterObject @{
        name = $params.command_storage_cdb_account_0c00dc0;
        location = $params.command_storage_group_loc_0c00dg0l;
        database = $params.command_storage_cdb_database_0c00dd0;
        collection = $params.command_storage_cdb_collection_0c00do0;
    }

# Connection string into params for leasers (command handling and publishing)
$cmddbconn = 
    (
        Get-AzCosmosDBAccountKey `
            -ResourceGroupName $params.command_storage_group_0c00dg0 `
            -Name $params.command_storage_cdb_account_0c00dc0 `
            -Type "ConnectionStrings"
    )['Primary SQL Connection String']

$params = $params + @{
    command_storage_cdb_connstr_0c00dc0c = $cmddbconn;
}

return $params