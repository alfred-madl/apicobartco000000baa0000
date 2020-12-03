# Read view
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.read_view_group_sub_0000rg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.read_view_group_sub_0000rg0s
    Set-AzContext $context | Out-Null
}

Write-Host "=============================================================================================================="
Write-Host "Create AAD Application for Event Grid Domain API Connection for Logic App to process Commands in the read view"
Write-Host "=============================================================================================================="

$aadapp = New-AzADApplication -DisplayName $params.read_view_logapp_egdtrig_00prrlgr -IdentifierUris $params.read_view_logapp_egdtrig_00prrlgu

$aadappid = $aadapp.ApplicationId.Guid

$aadapppwdsecure = ConvertTo-SecureString -String $params.read_view_logapp_egdtrig_00prrlgp -AsPlainText -Force 

New-AzADAppCredential -ObjectId $aadapp.ObjectID -Password $aadapppwdsecure -startDate $params.read_view_logapp_egdtrig_00prrlgb -enddate $params.read_view_logapp_egdtrig_00prrlge | Out-Null

Write-Host "==================================================================================================================="
Write-Host "Create AAD ServicePrincipal for Event Grid Domain API Connection for Logic App to process Commands in the read view"
Write-Host "==================================================================================================================="

New-AzADServicePrincipal -ApplicationId $aadappid -StartDate $params.read_view_logapp_egdtrig_00prrlgb -Enddate $params.read_view_logapp_egdtrig_00prrlge -Scope $params.command_publishing_egd_scope_0cpbce0s | Out-Null 

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

Write-Host "==========================================================================================="
Write-Host "Create Event Grid Domain API Connection for Logic App to process Commands in the read view"
Write-Host "==========================================================================================="

New-AzResourceGroupDeployment -ResourceGroupName $params.read_view_group_0000rg0 `
    -TemplateFile $params.read_view_egd_apiconn_tpl_00prrtgt `
    -TemplateParameterObject @{ 
        name = $params.read_view_egd_apiconn_00prrtg; 
        location = $params.read_view_group_loc_0000rg0l; 
        locationkey = $params.read_view_group_lkey_0000rg0k; 
        subscription = $params.read_view_group_sub_0000rg0s;
        clientId = $aadappid; 
        clientSecret = $params.read_view_logapp_egdtrig_00prrlgp;
        tenantId = $params.tenantid; 
} | Out-Null
    

return $params