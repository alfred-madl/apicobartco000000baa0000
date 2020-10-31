# Stop API Function App
param ($params)

if (((Get-AzContext).subscription).id -ne $params.api_proxy_group_sub_0000ag0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.api_proxy_group_sub_0000ag0s
    Set-AzContext $context
}

Write-Host "====================="
Write-Host "Stop API Function App"
Write-Host "====================="
Write-Host $params.api_proxy_app_0000aa0

Stop-AzFunctionApp `
    -Name $params.api_proxy_app_0000aa0 `
    -ResourceGroupName $params.api_proxy_group_0000ag0 `
    -Force -ErrorAction SilentlyContinue

return $params
