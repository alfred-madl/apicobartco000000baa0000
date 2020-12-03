# Delete CDB Commands...slot environment and region is covered by CDB redundancy mechanisms
param ([hashtable]$params = @{})

if (((Get-AzContext).subscription).id -ne $params.command_storage_group_sub_0c00dg0s)
{
    $context = Get-AzSubscription -SubscriptionId $params.command_storage_group_sub_0c00dg0s
    Set-AzContext $context | Out-Null
}

# do NOT delete in production !
if ($lane -ne 'z') {
    Write-Host "======================="
    Write-Host "Delete RG Commands Data"
    Write-Host "======================="

    Remove-AzResourceGroup `
        -Name $params.command_storage_group_0c00dg0 `
        -Force -ErrorAction SilentlyContinue | Out-Null
}

return $params