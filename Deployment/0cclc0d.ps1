# Delete Command clear handling
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.command_clear_group_sub_0cclcg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.command_clear_group_sub_0cclcg0s
    Set-AzContext $context | Out-Null
}

Write-Host "==========================================================================================="
Write-Host "Delete AAD Application for Event Grid Domain API Connection for Logic App to Clear Commands"
Write-Host "==========================================================================================="

Remove-AzADServicePrincipal -DisplayName $params.command_clear_logapp_egdtrig_0cclclgr -Force -ErrorAction SilentlyContinue | Out-Null

Remove-AzADApplication -DisplayName $params.command_clear_logapp_egdtrig_0cclclgr -Force -ErrorAction SilentlyContinue | Out-Null

Write-Host "=================================="
Write-Host "Delete RG Command Clear Processing"
Write-Host "=================================="

Remove-AzResourceGroup -Name $params.command_clear_group_0cclcg0 -Force -ErrorAction SilentlyContinue | Out-Null

return $params