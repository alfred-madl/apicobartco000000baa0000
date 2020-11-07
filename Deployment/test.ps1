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

Remove-AzADServicePrincipal -DisplayName $params.command_clear_logapp_egdtrig_0cclclgr -Force -ErrorAction SilentlyContinue | Out-Null

Remove-AzADApplication -DisplayName $params.command_clear_logapp_egdtrig_0cclclgr -Force -ErrorAction SilentlyContinue | Out-Null


Write-Host "==========================================================================================="
Write-Host "Create AAD Application for Event Grid Domain API Connection for Logic App to Clear Commands"
Write-Host "==========================================================================================="

$aadapp = New-AzADApplication -DisplayName $params.command_clear_logapp_egdtrig_0cclclgr -IdentifierUris $params.command_clear_logapp_egdtrig_0cclclgu

$aadappid = $aadapp.ApplicationId.Guid

$aadapppwdsecure = ConvertTo-SecureString -String $params.command_clear_logapp_egdtrig_0cclclgp -AsPlainText -Force 

$aadappcred = New-AzADAppCredential -ObjectId $aadapp.ObjectID -Password $aadapppwdsecure -startDate $params.command_clear_logapp_egdtrig_0cclclgb -enddate $params.command_clear_logapp_egdtrig_0cclclge

Write-Host "================================================================================================"
Write-Host "Create AAD ServicePrincipal for Event Grid Domain API Connection for Logic App to Clear Commands"
Write-Host "================================================================================================"

$egdscope = -join("/subscriptions/",$params.command_handling_group_sub_0c00cg0s,"/resourceGroups/",$params.command_handling_group_0c00cg0,"/providers/Microsoft.EventGrid/domains/",$params.command_publishing_egd_name_0cpbce0)

New-AzADServicePrincipal -ApplicationId $aadappid -StartDate $params.command_clear_logapp_egdtrig_0cclclgb -Enddate $params.command_clear_logapp_egdtrig_0cclclge -Scope $egdscope -Role Contributor | Out-Null 

#$credentials = New-Object -TypeName Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{
#    StartDate=$params.command_clear_logapp_egdtrig_0cclclgb; EndDate=$params.command_clear_logapp_egdtrig_0cclclge; Password=$params.command_clear_logapp_egdtrig_0cclclgp}

#$aadappid = (New-AzADServicePrincipal -Scope $egdscope -DisplayName $params.command_clear_logapp_egdtrig_0cclclgr -PasswordCredential $credentials).ApplicationId
