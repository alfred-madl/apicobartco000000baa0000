param ($params)

if (((Get-AzContext).subscription).id -ne $params.command_handling_group_sub_0c00cg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.command_handling_group_sub_0c00cg0s
    Set-AzContext $context
}

Write-Host "==========================="
Write-Host "Delete RG Command Handling"
Write-Host "==========================="

Remove-AzResourceGroup `
    -Name $params.command_handling_group_0c00cg0 `
    -Force -ErrorAction SilentlyContinue


Write-Host "==========================="
Write-Host "Create RG Command Handling"
Write-Host "==========================="

New-AzResourceGroup `
    -Name $params.command_handling_group_0c00cg0  `
    -Location $params.command_handling_group_loc_0c00cg0l 


Write-Host "============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to Store Command"
Write-Host "============================================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0  `
    -TemplateFile $params.command_create_cdb_apiconn_tpl_0ccrctct  `
    -TemplateParameterObject @{ 
        name = $params.command_create_cdb_apiconn_0ccrctc ;  
        location = $params.command_handling_group_loc_0c00cg0l ; 
        locationkey = $params.command_handling_group_lkey_0c00cg0k ;
        account = $params.command_storage_cdb_account_0c00dc0 ; 
        accountsubscription = $params.command_storage_group_sub_0c00dg0s ;
        accountgroup = $params.command_storage_group_0c00dg0 ; 
    }
            
Write-Host "================================="
Write-Host "Create CDB Command Publish Lease"
Write-Host "================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0  `
    -TemplateFile $params.command_publishing_lease_tpl_0cpbcclt  `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_lease_account_0cpbccl;  
        location = $params.command_handling_group_loc_0c00cg0l ; 
        database = $params.command_publishing_lease_database_0cpbdcl ; 
        collection = $params.command_publishing_lease_collection_0cpbcol ; 
    }

Write-Host "==========================="
Write-Host "Create EGD Command Publish"
Write-Host "==========================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0  `
    -TemplateFile $params.command_publishing_egd_tpl_0cpbce0t  `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_egd_name_0cpbce0;  
        location = $params.command_handling_group_loc_0c00cg0l; 
    }


Write-Host "================="
Write-Host "Set GitHub Token"
Write-Host "================="

Set-AzResource 
    -PropertyObject @{ token = $params.gittoken; } `
    -ResourceId $params.gitprovider `
    -ApiVersion 2015-08-01 -Force #| Out-Null


Write-Host "==============================="
Write-Host "Create Command Publish App Plan"
Write-Host "==============================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0  `
    -TemplateFile $params.command_publishing_appsvcpln_tpl_0cpbcp0t  `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_appsvcpln_name_0cpbcp0;  
        location = $params.command_handling_group_loc_0c00cg0l; 
    }

Write-Host "=================================="
Write-Host "Create Command Publish App Storage"
Write-Host "=================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0  `
    -TemplateFile $params.command_publishing_storage_tpl_0cpbcs0t  `
    -TemplateParameterObject @{ 
        name = $params.command_publishing_storage_account_0cpbcs0;  
        location = $params.command_handling_group_loc_0c00cg0l; 
    }


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
    }


Write-Host "==========================="
Write-Host "Logic Apps to Store Command"
Write-Host "==========================="

# Execute
New-AzResourceGroupDeployment `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.xxxxxxx `
    -TemplateParameterObject @{ 
        name = $params.xxxxxxx;  
        location = $params.xxxxxxx;
        locationkey = $params.xxxxxxx; 
        accountsubscription = $params.xxxxxxx;
        accountconnection=$params.xxxxxxx;
        database = $params.xxxxxxx; 
        collection=$params.xxxxxxx; 
    }

# HTTP Trigger
New-AzResourceGroupDeployment 
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -TemplateFile $params.xxxxxxx `
    -TemplateParameterObject @{ 
        name = $params.xxxxxxx;  
        location = $params.xxxxxxx;
        logicname = $params.xxxxxxx; 
        logicsubscription = $params.xxxxxxx;
        logicgroup = $params.xxxxxxx; 
    }

# Get URL for Proxy App Settings
# $commandurl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $group -Name $httptriggerlogicname -TriggerName "manual").Value.TrimStart("https:").TrimStart("/")

Write-Host "============================="
Write-Host "Stop Command Publish Function"
Write-Host "============================="

Stop-AzFunctionApp 
    -Name $params.xxxxxxx `
    -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -Force



Write-Host "========================================"
Write-Host "Create Command Publish Function Settings"
Write-Host "========================================"


Update-AzFunctionAppSetting `
    -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -AppSetting @{"AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=" + $params.xxxxxxx  + ";AccountKey=" + `
        (
            Get-AzStorageAccountKey -ResourceGroupName $params.xxxxxxx  -AccountName $params.xxxxxxx 
        )[0].Value + ";EndpointSuffix=core.windows.net" } `
    -Force | Out-Null

Update-AzFunctionAppSetting 
    -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -AppSetting @{"FUNCTIONS_EXTENSION_VERSION" = "~3"} -Force | Out-Null

Update-AzFunctionAppSetting 
    -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0 `
    -AppSetting @{"FUNCTIONS_WORKER_RUNTIME" = "dotnet"} -Force | Out-Null

$cmddbconn = 
    (
        Get-AzCosmosDBAccountKey `
            -ResourceGroupName $params.command_handling_group_0c00cg0 `
            -Name $params.xxxxxxx `
            -Type "ConnectionStrings"
    )['Primary SQL Connection String']

$leasedbconn = 
    (
        Get-AzCosmosDBAccountKey `
            -ResourceGroupName $params.command_handling_group_0c00cg0 `
            -Name $params.xxxxxxx `
            -Type "ConnectionStrings"
    )['Primary SQL Connection String']

Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_ConnectionString" = $params.xxxxxxx } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_LeaseConnectionString" = $params.xxxxxxx } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_DatabaseName" = $params.xxxxxxx } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_LeaseDatabaseName" = $params.xxxxxxx } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_CollectionName" = $params.xxxxxxx } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_LeaseCollectionName" = $params.xxxxxxx } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_LeaseCollectionPrefix" = $params.xxxxxxx } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_PreferredLocations" = $params.xxxxxxx } -Force | Out-Null

$egdkey = (Get-AzEventGridDomainKey -ResourceGroupName $params.command_handling_group_0c00cg0  -Name $params.xxxxxxx ).Key1
$egdendpoint = (Get-AzEventGridDomain -ResourceGroupName $params.command_handling_group_0c00cg0  -Name $params.xxxxxxx ).Endpoint

Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_Event_TopicEndpoint" = "$params.xxxxxxx "} -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.xxxxxxx -ResourceGroupName $params.command_handling_group_0c00cg0  -AppSetting @{"CDBPF_Event_TopicKey" = "$params.xxxxxxx "} -Force | Out-Null

Write-Host "=============================="
Write-Host "Start Command Publish Function"
Write-Host "=============================="

Start-AzFunctionApp 
    -Name $params.xxxxxxx `
    -ResourceGroupName $params.command_handling_group_0c00cg0

