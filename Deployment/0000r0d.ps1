# Delete Read view
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.read_view_group_sub_0000rg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.read_view_group_sub_0000rg0s
    Set-AzContext $context | Out-Null
}

Write-Host "==========================="
Write-Host "Delete RG Read View"
Write-Host "==========================="

Remove-AzResourceGroup `
    -Name $params.read_view_group_0000rg0 `
    -Force -ErrorAction SilentlyContinue | Out-Null

return $params