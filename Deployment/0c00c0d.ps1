# Delete Command handling
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

return $params