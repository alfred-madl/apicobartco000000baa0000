# API Proxy
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.api_proxy_group_sub_0000ag0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.api_proxy_group_sub_0000ag0s
    Set-AzContext $context | Out-Null
}

Write-Host "============================"
Write-Host "Delete RG API Function Proxy"
Write-Host "============================"

Remove-AzResourceGroup -Name $params.api_proxy_group_0000ag0 -Force -ErrorAction SilentlyContinue | Out-Null



Write-Host "============================"
Write-Host "Create RG API Function Proxy"
Write-Host "============================"

New-AzResourceGroup -Name $params.api_proxy_group_0000ag0 -Location $params.api_proxy_group_loc_0000ag0l | Out-Null


Write-Host "================="
Write-Host "Set GitHub Token"
Write-Host "================="

# no idea why thats necessary...and all that must happen LONG before Function is created...othwise we get STRANGE errors...
$gittoken = $params.gittoken

Set-AzResource -PropertyObject @{ token = "$gittoken"; } -ResourceId /providers/Microsoft.Web/sourcecontrols/GitHub -ApiVersion 2015-08-01 -Force | Out-Null

Write-Host "=================================="
Write-Host "Create API Function Proxy App Plan"
Write-Host "=================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.api_proxy_group_0000ag0 `
    -TemplateFile $params.api_proxy_appsvcpln_tpl_0000ap0t `
    -TemplateParameterObject @{ name = $params.api_proxy_appsvcpln_name_0000ap0;  location = $params.api_proxy_group_loc_0000ag0l; } | Out-Null


Write-Host "====================================="
Write-Host "Create API Function Proxy App Storage"
Write-Host "====================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.api_proxy_group_0000ag0 `
    -TemplateFile $params.api_proxy_storage_tpl_0000as0t `
    -TemplateParameterObject @{ name = $params.api_proxy_storage_account_0000as0;  location = $params.api_proxy_group_loc_0000ag0l; } | Out-Null



Write-Host "==============================="
Write-Host "Create API Proxy Function App"
Write-Host "==============================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $params.api_proxy_group_0000ag0 `
    -TemplateFile $params.api_proxy_funcapp_tpl_0000aa0t `
    -TemplateParameterObject @{ name = $params.api_proxy_funcapp_name_0000aa0;  location = $params.api_proxy_group_loc_0000ag0l; `
            plan = $params.api_proxy_appsvcpln_name_0000ap0; plansubscription = $params.api_proxy_group_sub_0000ag0s; `
            plangroup = $params.api_proxy_group_0000ag0; repo = $params.api_proxy_funcapp_repos_0000aa0r; `
            branch = $params.api_proxy_funcapp_branch_0000aa0b; } | Out-Null



Write-Host "============================="
Write-Host "Stop API Proxy Function"
Write-Host "============================="

Stop-AzFunctionApp -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -Force | Out-Null




Write-Host "========================================"
Write-Host "Create API Proxy Function Settings"
Write-Host "========================================"

$commandurl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $params.command_handling_group_0c00cg0 -Name $params.command_create_logapp_httptrig_0ccrclh -TriggerName $params.command_create_logapp_httptrig_name_0ccrclhn).Value.TrimStart("https:").TrimStart("/")

Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 `
    -ResourceGroupName $params.api_proxy_group_0000ag0 `
    -AppSetting @{"AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=" + $params.api_proxy_storage_account_0000as0 + ";AccountKey=" + (Get-AzStorageAccountKey -ResourceGroupName $params.api_proxy_group_0000ag0 -AccountName $params.api_proxy_storage_account_0000as0)[0].Value + ";EndpointSuffix=core.windows.net" } -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"FUNCTIONS_EXTENSION_VERSION" = $params.api_proxy_funcapp_extvers_0000aa0v} -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"FUNCTIONS_WORKER_RUNTIME" = $params.api_proxy_funcapp_runtime_0000aa0n} -Force | Out-Null

Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-url-rm" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-url-cl" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-url-in" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-url-up" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-url-cr" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-url-de" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-url-re" = "xxx"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-url-li" = "xxx"} -Force | Out-Null

#Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-key-re" = "xxx"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 -AppSetting @{"x-apico-operation-key-li" = "xxx"} -Force | Out-Null

Write-Host "=============================="
Write-Host "Start API Proxy Function"
Write-Host "=============================="

Start-AzFunctionApp -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 | Out-Null


return $params