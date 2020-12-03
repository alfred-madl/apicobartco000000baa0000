# Command handling startup
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.command_handling_group_sub_0c00cg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.command_handling_group_sub_0c00cg0s
    Set-AzContext $context | Out-Null
}

Write-Host "=============================="
Write-Host "Start Command Publish Function"
Write-Host "=============================="

Start-AzFunctionApp `
    -Name $params.command_publishing_funcapp_name_0cpbca0 `
    -ResourceGroupName $params.command_handling_group_0c00cg0 | Out-Null

return $params