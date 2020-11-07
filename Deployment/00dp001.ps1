# Main deployment script
param ([hashtable]$params = @{}, $tenant = 'apico', $set = 'ba', $project = 'rt', $service = 'co', $version = '00', $lane = '1', $slot = 'g', $environment = 'p', $region = 's', `
    $defaultregion = 's', $subscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c', $defaultsubscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c', `
    $gittoken = '', $now = (Get-Date), $reposprefix = 'https://github.com/alfred-madl/', $tenantid = '36459f7c-f2a9-49f0-845f-eead0c94bd39')
if (Get-Module -Name Az -ListAvailable) {
    Write-Host -Message ('Az module already installed.')
}
else {
    Install-Module -Name Az -AllowClobber -Scope AllUsers
}

if (Get-Module -Name Az.CosmosDB -ListAvailable) {
    Write-Host -Message ('Az.CosmosDB module already installed.')
}
else {
    Install-Module -Name Az.CosmosDB -AllowClobber -Scope AllUsers | Out-Null
}

if (Get-Module -Name AzureAD -ListAvailable) {
    Write-Host -Message ('AzureAD module already installed.')
}
else {
    Install-Module -Name AzureAD -AllowClobber -Scope AllUsers | Out-Null
}

if (((get-azcontext).subscription).id -ne $subscription)
{
    $context = Get-AzSubscription -SubscriptionId $subscription
    Set-AzContext $context | Out-Null
}

$params = $params + @{ 
    now = $now;
    tenant = $tenant;
    set = $set;
    project = $project;
    service = $service;
    version = $version;
    lane = $lane;
    slot = $slot;
    environment = $environment;
    region = $region;
    defaultregion = $defaultregion;
    subscription = $subscription;
    defaultsubscription = $defaultsubscription;
    reposprefix = $reposprefix;
    tenantid = $tenantid;
}

$params = &"./00pm001.ps1" -params $params

# Stop API Function Proxy App
$params = &"./00spa01.ps1" -params $params


# only one CDB command storage per lane
if (($slot -eq 'g') -AND ($environment -eq 'p') -AND ($region -eq $defaultregion)) {
    # Deploy CDB Commands Data Storage
    $params = &"./0c00d01.ps1" -params $params
}

# Deploy Commands Processing
$params = &"./0c00c01.ps1" -params $params

# clear command - NO deployment in production !
if ($lane -ne 'z') {
    # Deploy Commands Clearance
    $params = &"./0cclc01.ps1" -params $params
}

# Deploy Read View - not complete yet...
$params = &"./0000r01.ps1" -params $params

# Deploy API Function App
$params = &"./0000a01.ps1" -params $params

<#
# Start API Function App
# $params &"./00sta01.ps1" -params $params
#>