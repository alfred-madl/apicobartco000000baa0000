#if ($PSVersionTable.PSEdition -eq 'Desktop' -and (Get-Module -Name AzureRM -ListAvailable)) {
#    Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
#      'Az modules installed at the same time is not supported.')
#} else {
#    Install-Module -Name Az -AllowClobber -Scope AllUsers
#}

#Connect-AzAccount

#Get-AzSubscription

#$context = Get-AzSubscription -SubscriptionId aec9ffa0-e92d-492d-87b7-a26053b2e22c
#Set-AzContext $context

Write-Host "================="
Write-Host "Delete RG Backend"
Write-Host "================="

Remove-AzResourceGroup -Name apicobartco000000bga1gps -Force

Write-Host "================="
Write-Host "Delete RG Data"
Write-Host "================="

Remove-AzResourceGroup -Name apicobartco000000dg01000 -Force

#Write-Host "================="
#Write-Host "Set GitHub Token"
#Write-Host "================="

#Set-AzResource -PropertyObject @{ token = "xxxxx"; } -ResourceId /providers/Microsoft.Web/sourcecontrols/GitHub -ApiVersion 2015-08-01 -Force

Write-Host "================="
Write-Host "Create RG Backend"
Write-Host "================="

New-AzResourceGroup -Name apicobartco000000bga1gps -Location 'Southeast Asia'

Write-Host "================="
Write-Host "Create Plan"
Write-Host "================="

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000000bga1gps -TemplateFile ./appserviceplan.template.json

Write-Host "================="
Write-Host "Create Storage"
Write-Host "================="

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000000bga1gps -TemplateFile ./storageaccount.template.json

Write-Host "================="
Write-Host "Create RG Data"
Write-Host "================="

New-AzResourceGroup -Name apicobartco000000dg01000 -Location 'Southeast Asia'

Write-Host "================="
Write-Host "Create CDB"
Write-Host "================="

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000000dg01000 -TemplateFile ./cosmosdb.template.json

Write-Host "================="
Write-Host "Create Function"
Write-Host "================="

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000000bga1gps -TemplateFile ./functionapp.template.json

Write-Host "================="
Write-Host "Stop Function"
Write-Host "================="

Stop-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -Force

Write-Host "================="
Write-Host "Function Settings"
Write-Host "================="

Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=" + "apicobartco000000bsa1gps" + ";AccountKey=" + (Get-AzStorageAccountKey -ResourceGroupName apicobartco000000bga1gps -AccountName apicobartco000000bsa1gps)[0].Value + ";EndpointSuffix=core.windows.net" } -Force
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"FUNCTIONS_EXTENSION_VERSION" = "~3"} -Force
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"FUNCTIONS_WORKER_RUNTIME" = "dotnet"} -Force
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-command-functions-key" = "xxx"} -Force

Write-Host "================="
Write-Host "Start Function"
Write-Host "================="

Start-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps
