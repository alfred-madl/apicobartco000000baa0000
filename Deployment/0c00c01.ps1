# Command handling
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.command_handling_group_sub_0c00cg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.command_handling_group_sub_0c00cg0s
    Set-AzContext $context | Out-Null
}

Write-Host "==========================="
Write-Host "Delete RG Command Handling"
Write-Host "==========================="

Remove-AzResourceGroup `
    -Name $params.command_handling_group_0c00cg0 `
    -Force -ErrorAction SilentlyContinue | Out-Null


Write-Host "==========================="
Write-Host "Create RG Command Handling"
Write-Host "==========================="

New-AzResourceGroup `
    -Name $params.command_handling_group_0c00cg0 `
    -Location $params.command_handling_group_loc_0c00cg0l  | Out-Null


Write-Host "================="
Write-Host "Set GitHub Token"
Write-Host "================="

# no idea why thats necessary...and all that must happen LONG before FUnction is created...othwise we get STRANGE errors...
$gittoken = $params.gittoken

Set-AzResource -PropertyObject @{ token = "$gittoken"; } -ResourceId /providers/Microsoft.Web/sourcecontrols/GitHub -ApiVersion 2015-08-01 -Force | Out-Null

Write-Host "============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to Store Command"
Write-Host "============================================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.command_create_cdb_apiconn_tpl_0ccrctct `
    -TemplateParameterObject @{ 
        name = $params.command_create_cdb_apiconn_0ccrctc ;  
        location = $params.command_handling_group_loc_0c00cg0l ; 
        locationkey = $params.command_handling_group_lkey_0c00cg0k ;
        account = $params.command_storage_cdb_account_0c00dc0 ; 
        accountsubscription = $params.command_storage_group_sub_0c00dg0s ;
        accountgroup = $params.command_storage_group_0c00dg0 ; 
    } | Out-Null
            
Write-Host "================================="
Write-Host "Create CDB Command Publish Lease"
Write-Host "================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.command_publishing_lease_tpl_0cpbcclt `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_lease_account_0cpbccl;  
        location = $params.command_handling_group_loc_0c00cg0l ; 
        database = $params.command_publishing_lease_database_0cpbdcl ; 
        collection = $params.command_publishing_lease_collection_0cpbcol ; 
    } | Out-Null

Write-Host "==========================="
Write-Host "Create EGD Command Publish"
Write-Host "==========================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.command_publishing_egd_tpl_0cpbce0t `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_egd_name_0cpbce0;  
        location = $params.command_handling_group_loc_0c00cg0l; 
    } | Out-Null

Write-Host "==============================="
Write-Host "Create Command Publish App Plan"
Write-Host "==============================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.command_publishing_appsvcpln_tpl_0cpbcp0t `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_appsvcpln_name_0cpbcp0;  
        location = $params.command_handling_group_loc_0c00cg0l; 
    } | Out-Null

Write-Host "=================================="
Write-Host "Create Command Publish App Storage"
Write-Host "=================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.command_publishing_storage_tpl_0cpbcs0t `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_storage_account_0cpbcs0;  
        location = $params.command_handling_group_loc_0c00cg0l; 
    } | Out-Null


Write-Host "==============================="
Write-Host "Create Command Publish Function"
Write-Host "==============================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.command_publishing_funcapp_tpl_0cpbca0t `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_funcapp_name_0cpbca0;  
        location = $params.command_handling_group_loc_0c00cg0l;
        plan = $params.command_publishing_appsvcpln_name_0cpbcp0; 
        plansubscription = $params.command_handling_group_sub_0c00cg0s;
        plangroup = $params.command_handling_group_0c00cg0; 
        repo = $params.command_publishing_funcapp_repos_0cpbca0r;
        branch = $params.command_publishing_funcapp_branch_0cpbca0b; 
    } | Out-Null


Write-Host "==========================="
Write-Host "Logic Apps to Store Command"
Write-Host "==========================="

# Storage
New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.command_create_logapp_storage_tpl_0ccrlst `
    -TemplateParameterObject @{ 
        name = $params.command_create_logapp_storage_0ccrcls;  
        location = $params.command_handling_group_loc_0c00cg0l;
        locationkey = $params.command_handling_group_lkey_0c00cg0k; 
        accountsubscription = $params.command_storage_group_sub_0c00dg0s;
        accountconnection=$params.command_create_cdb_apiconn_0ccrctc;
        database = $params.command_storage_cdb_database_0c00dd0; 
        collection=$params.command_storage_cdb_collection_0c00do0; 
    } | Out-Null

# HTTP Trigger
New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.command_create_logapp_httptrig_tpl_0ccrlht `
    -TemplateParameterObject @{ 
        name = $params.command_create_logapp_httptrig_0ccrclh;  
        location = $params.command_handling_group_loc_0c00cg0l;
        logicname = $params.command_create_logapp_storage_0ccrcls; 
        logicsubscription = $params.command_handling_group_sub_0c00cg0s;
        logicgroup = $params.command_handling_group_0c00cg0; 
    } | Out-Null

Write-Host "============================="
Write-Host "Stop Command Publish Function"
Write-Host "============================="

Stop-AzFunctionApp `
    -Name $params.command_publishing_funcapp_name_0cpbca0 `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -Force | Out-Null

    # Prepare some params
$egdkey = (Get-AzEventGridDomainKey -ResourceGroupName $params.command_handling_group_0c00cg0  -Name $params.command_publishing_egd_name_0cpbce0 ).Key1
$egdendpoint = (Get-AzEventGridDomain -ResourceGroupName $params.command_handling_group_0c00cg0  -Name $params.command_publishing_egd_name_0cpbce0 ).Endpoint

$leasedbconn = 
    (
        Get-AzCosmosDBAccountKey `
            -ResourceGroupName $params.command_handling_group_0c00cg0 `
            -Name $params.command_publishing_lease_account_0cpbccl `
            -Type "ConnectionStrings"
    )['Primary SQL Connection String']



Write-Host "========================================"
Write-Host "Create Command Publish Function Settings"
Write-Host "========================================"


Update-AzFunctionAppSetting `
    -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -AppSetting @{"AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=" + $params.command_publishing_storage_account_0cpbcs0  + ";AccountKey=" + `
        (
            Get-AzStorageAccountKey -ResourceGroupName $params.command_handling_group_0c00cg0  -AccountName $params.command_publishing_storage_account_0cpbcs0 
        )[0].Value + ";EndpointSuffix=core.windows.net" } `
    -Force | Out-Null

Update-AzFunctionAppSetting `
    -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -AppSetting @{"FUNCTIONS_EXTENSION_VERSION" = $params.command_publishing_funcapp_extvers_0cpbca0v} -Force | Out-Null

Update-AzFunctionAppSetting `
    -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -AppSetting @{"FUNCTIONS_WORKER_RUNTIME" = $params.command_publishing_funcapp_runtime_0cpbca0n} -Force | Out-Null


Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_ConnectionString" = $params.command_storage_cdb_connstr_0c00dc0c } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_LeaseConnectionString" = $leasedbconn } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_DatabaseName" = $params.command_storage_cdb_database_0c00dd0 } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_LeaseDatabaseName" = $params.command_publishing_lease_database_0cpbdcl } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_CollectionName" = $params.command_storage_cdb_collection_0c00do0 } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_LeaseCollectionName" = $params.command_publishing_lease_collection_0cpbcol } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_LeaseCollectionPrefix" = $params.command_publishing_lease_prefix_0cpbca0f } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_PreferredLocations" = $params.command_handling_group_loc_0c00cg0l } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_Event_TopicEndpoint" = "$egdendpoint"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.command_publishing_funcapp_name_0cpbca0 -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_Event_TopicKey" = "$egdkey"} -Force | Out-Null

Write-Host "=============================="
Write-Host "Start Command Publish Function"
Write-Host "=============================="

Start-AzFunctionApp `
    -Name $params.command_publishing_funcapp_name_0cpbca0 `
    -ResourceGroupName $params.command_handling_group_0c00cg0 | Out-Null

# Get URL for Proxy App Settings
# $commandurl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $params.command_handling_group_0c00cg0 -Name $params.command_create_logapp_httptrig_0ccrclh -TriggerName $params.command_create_logapp_httptrig_name_0ccrclhn).Value.TrimStart("https:").TrimStart("/")

return $params