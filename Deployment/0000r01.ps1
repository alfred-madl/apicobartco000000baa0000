# Read view
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.read_view_group_sub_0000rg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.read_view_group_sub_0000rg0s
    Set-AzContext $context | Out-Null
}

Write-Host "==========================="
Write-Host "Delete RG Read View"
Write-Host "==========================="

Remove-AzResourceGroup `
    -Name $params.read_view_group_0000rg0 `
    -Force -ErrorAction SilentlyContinue | Out-Null


Write-Host "==========================="
Write-Host "Create RG Read View"
Write-Host "==========================="

New-AzResourceGroup `
    -Name $params.read_view_group_0000rg0 `
    -Location $params.read_view_group_loc_0000rg0l | Out-Null

            
Write-Host "================================="
Write-Host "Create CDB Read View"
Write-Host "================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.read_view_group_0000rg0 `
    -TemplateFile $params.read_view_cdb_tpl_0000rc0t `
    -TemplateParameterObject @{ 
        name = $params.read_view_cdb_account_0000rc0;  
        location = $params.read_view_group_loc_0000rg0l; 
        database = $params.read_view_cdb_database_0000rd0; 
        collection = $params.read_view_cdb_collection_0000ro0; 
    } | Out-Null

Write-Host "==============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to write Read View"
Write-Host "==============================================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.read_view_group_0000rg0 `
    -TemplateFile $params.read_view_cdb_apiconn_tpl_00exrtct `
    -TemplateParameterObject @{ 
        name = $params.read_view_cdb_apiconn_00exrtc;  
        location = $params.read_view_group_loc_0000rg0l; 
        locationkey = $params.read_view_group_lkey_0000rg0k;
        account = $params.read_view_cdb_account_0000rc0; 
        accountsubscription = $params.read_view_group_sub_0000rg0s;
        accountgroup = $params.read_view_group_0000rg0; 
    } | Out-Null

Write-Host "==============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to read Commands"
Write-Host "==============================================================="

New-AzResourceGroupDeployment -ResourceGroupName $params.read_view_group_0000rg0 `
    -TemplateFile $params.read_view_cdb_apiconn_tpl_00prrtct `
    -TemplateParameterObject @{ 
        name = $params.read_view_cdb_apiconn_00prrtc;  
        location = $params.read_view_group_loc_0000rg0l; 
        locationkey = $params.read_view_group_lkey_0000rg0k;
        account = $params.command_storage_cdb_account_0c00dc0; 
        accountsubscription = $params.command_storage_group_sub_0c00dg0s;
        accountgroup = $params.command_storage_group_0c00dg0; 
    } | Out-Null

return $params