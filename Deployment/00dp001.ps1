# Main deployment script
param ($tenant = 'apico', $set = 'ba', $project = 'rt', $service = 'co', $version = '00', $lane = '1', $slot = 'g', $environment = 'p', $region = 's', $defaultregion = 's', $subscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c', $defaultsubscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken = '', $now = (Get-Date))
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
    Install-Module -Name Az.CosmosDB -AllowClobber -Scope AllUsers
}

if (Get-Module -Name AzureAD -ListAvailable) {
    Write-Host -Message ('AzureAD module already installed.')
}
else {
    Install-Module -Name AzureAD -AllowClobber -Scope AllUsers
}

if (((get-azcontext).subscription).id -ne $subscription)
{
    $context = Get-AzSubscription -SubscriptionId $subscription
    Set-AzContext $context
}

if ($gittoken -eq '') {
    $gittoken = Get-Content -Path gittoken.txt | Out-String
}
else {
}

$params = @{
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
    gittoken = $gittoken;
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

<#
# clear command NOT in production !
if ($lane -ne 'z') {
    # Deploy Commands Clearance
    & "./0cclc01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane  -slot $slot -environment $environment -region $region -subscription $subscription
}
# Deploy Read View
& "./0000r01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -slot $slot -environment $environment -region $region -defaultregion $defaultregion -subscription $subscription
# Deploy API Function App
& "./0000a01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -slot $slot -environment $environment -region $region -defaultregion $defaultregion -subscription $subscription
# Start API Function App
# & "./00sta01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -slot $slot -environment $environment -region $region -defaultregion $defaultregion -subscription $subscription

#>