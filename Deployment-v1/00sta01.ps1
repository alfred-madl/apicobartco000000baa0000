# Start API Function App
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.api_proxy_group_sub_0000ag0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.api_proxy_group_sub_0000ag0s
    Set-AzContext $context | Out-Null
}

Write-Host "=============================="
Write-Host "Start API Proxy Function"
Write-Host "=============================="

Start-AzFunctionApp -Name $params.api_proxy_funcapp_name_0000aa0 -ResourceGroupName $params.api_proxy_group_0000ag0 | Out-Null

return $params
