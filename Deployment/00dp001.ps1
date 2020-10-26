# Main deployment script
param ($tenant = 'apico', $set = 'ba', $project = 'rt', $service = 'co', $version = '00', $lane = '1', $slot = 'g', $environment = 'p', $region = 's', $defaultregion = 's', $subscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken = '')

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

$context = Get-AzSubscription -SubscriptionId $subscription
Set-AzContext $context


if ($gittoken -eq '') {
    $gittoken = Get-Content -Path gittoken.txt | Out-String
}
else {
}

# Stop API Function App
& "./00spa01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -slot $slot -environment $environment -region $region -defaultregion $defaultregion

# only one CDB command storage per lane
if (($slot -eq 'g') -AND ($environment -eq 'p') -AND ($region -eq $defaultregion)) {
    # Deploy CDB Commands Data Storage
    & "./0c00d01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -defaultregion $defaultregion
}
# Deploy Commands Processing
& "./0c00c01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -slot $slot -environment $environment -region $region -subscription $subscription -gittoken $gittoken

# only one clear command processing per lane
if (($slot -eq 'g') -AND ($environment -eq 'p') -AND ($region -eq $defaultregion)) {
    # Deploy Commands Clearance
    & "./0cclc01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane  -slot $slot -environment $environment -region $region -subscription $subscription
}
# Deploy API Function App
# & "./0000b01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -slot $slot -environment $environment -region $region -defaultregion $defaultregion -subscription $subscription
# Deploy Read View
# & "./0000r01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -slot $slot -environment $environment -region $region -defaultregion $defaultregion -subscription $subscription
# Start API Function App
# & "./00stb01.ps1" -tenant $tenant -set $set -project $project -service $service -version $version -lane $lane -slot $slot -environment $environment -region $region -defaultregion $defaultregion -subscription $subscription
