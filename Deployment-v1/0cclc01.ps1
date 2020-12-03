# Command clear handling
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.command_clear_group_sub_0cclcg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.command_clear_group_sub_0cclcg0s
    Set-AzContext $context | Out-Null
}

Write-Host "==========================================================================================="
Write-Host "Create AAD Application for Event Grid Domain API Connection for Logic App to Clear Commands"
Write-Host "==========================================================================================="

$aadapp = New-AzADApplication -DisplayName $params.command_clear_logapp_egdtrig_0cclclgr -IdentifierUris $params.command_clear_logapp_egdtrig_0cclclgu

$aadappid = $aadapp.ApplicationId.Guid

$aadapppwdsecure = ConvertTo-SecureString -String $params.command_clear_logapp_egdtrig_0cclclgp -AsPlainText -Force 

New-AzADAppCredential -ObjectId $aadapp.ObjectID -Password $aadapppwdsecure -startDate $params.command_clear_logapp_egdtrig_0cclclgb -enddate $params.command_clear_logapp_egdtrig_0cclclge | Out-Null

Write-Host "================================================================================================"
Write-Host "Create AAD ServicePrincipal for Event Grid Domain API Connection for Logic App to Clear Commands"
Write-Host "================================================================================================"

New-AzADServicePrincipal -ApplicationId $aadappid -StartDate $params.command_clear_logapp_egdtrig_0cclclgb -Enddate $params.command_clear_logapp_egdtrig_0cclclge -Scope $params.command_publishing_egd_scope_0cpbce0s | Out-Null

Write-Host "=================================="
Write-Host "Create RG Command Clear Processing"
Write-Host "=================================="

New-AzResourceGroup -Name $params.command_clear_group_0cclcg0 -Location $params.command_clear_group_loc_0cclcg0l | Out-Null


Write-Host "==========================================================================================="
Write-Host "Create Event Grid Domain API Connection for Logic App to Clear Commands"
Write-Host "==========================================================================================="

New-AzResourceGroupDeployment -ResourceGroupName $params.command_clear_group_0cclcg0 `
    -TemplateFile $params.command_clear_egd_apiconn_tpl_0cclctgt `
    -TemplateParameterObject @{ 
        name = $params.command_clear_egd_apiconn_0cclctg; 
        location = $params.command_clear_group_loc_0cclcg0l; 
        locationkey = $params.command_clear_group_lkey_0cclcg0k; 
        subscription = $params.command_clear_group_sub_0cclcg0s;
        clientId = $aadappid; 
        clientSecret = $params.command_clear_logapp_egdtrig_0cclclgp;
        tenantId = $params.tenantid; 
} | Out-Null

Write-Host "=============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to Clear Commands"
Write-Host "=============================================================="

New-AzResourceGroupDeployment -ResourceGroupName $params.command_clear_group_0cclcg0 `
    -TemplateFile $params.command_clear_cdb_apiconn_tpl_0cclctct `
    -TemplateParameterObject @{ 
        name = $params.command_clear_cdb_apiconn_0cclctc;
        location = $params.command_clear_group_loc_0cclcg0l
        locationkey = $params.command_clear_group_lkey_0cclcg0k;
        account = $params.command_storage_cdb_account_0c00dc0; 
        accountsubscription = $params.command_storage_group_sub_0c00dg0s;
        accountgroup = $params.command_storage_group_0c00dg0; 
    } | Out-Null


Write-Host "============================"
Write-Host "Logic Apps to Clear Commands"
Write-Host "============================"

# Delete
New-AzResourceGroupDeployment -ResourceGroupName $params.command_clear_group_0cclcg0 `
    -TemplateFile $params.command_clear_logapp_deletion_tpl_0cclldt `
    -TemplateParameterObject @{ 
        name = $params.command_clear_logapp_deletion_0cclcld; 
        location = $params.command_clear_group_loc_0cclcg0l;
        locationkey = $params.command_clear_group_lkey_0cclcg0k; 
        accountsubscription = $params.command_clear_group_sub_0cclcg0s;
        accountconnection = $params.command_clear_cdb_apiconn_0cclctc;
        database = $params.command_storage_cdb_database_0c00dd0; 
        collection = $params.command_storage_cdb_collection_0c00do0; 
} | Out-Null

# HTTP Trigger
New-AzResourceGroupDeployment -ResourceGroupName $params.command_clear_group_0cclcg0 `
    -TemplateFile $params.command_clear_logapp_httptrig_tpl_0ccllht `
    -TemplateParameterObject @{ 
        name = $params.command_clear_logapp_httptrig_0cclclh; 
        location = $params.command_clear_group_loc_0cclcg0l;
        logicname = $params.command_clear_logapp_deletion_0cclcld; 
        logicsubscription = $params.command_clear_group_sub_0cclcg0s;
        logicgroup = $params.command_clear_group_0cclcg0; 
} | Out-Null

# EGD Trigger
New-AzResourceGroupDeployment -ResourceGroupName $params.command_clear_group_0cclcg0 `
    -TemplateFile $params.command_clear_logapp_egdtrig_tpl_0ccllgt `
    -TemplateParameterObject @{ 
        name = $params.command_clear_logapp_egdtrig_0cclclg;  
        location = $params.command_clear_group_loc_0cclcg0l;
        locationkey = $params.command_clear_group_lkey_0cclcg0k; 
        domainname = $params.command_publishing_egd_name_0cpbce0; 
        egdsubscription = $params.command_handling_group_sub_0c00cg0s; 
        egdgroup = $params.command_handling_group_0c00cg0; 
        topicname = $params.command_clear_egd_topic_0cclctg;
        egdconname = $params.command_clear_egd_apiconn_0cclctg; 
        egdsubscrname = $params.command_clear_logapp_egdtrig_0cclclgs;
        logicname = $params.command_clear_logapp_deletion_0cclcld; 
        logicsubscription = $params.command_clear_group_sub_0cclcg0s;
        logicgroup = $params.command_clear_group_0cclcg0; 
    } | Out-Null

return $params