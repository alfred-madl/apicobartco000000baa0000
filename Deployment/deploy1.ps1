#if ($PSVersionTable.PSEdition -eq 'Desktop' -and (Get-Module -Name AzureRM -ListAvailable)) {
#    Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
#      'Az modules installed at the same time is not supported.')
#} else {
#    Install-Module -Name Az -AllowClobber -Scope AllUsers
#}

#Install-Module -Name Az.CosmosDB

#Connect-AzAccount

#Get-AzSubscription

#$context = Get-AzSubscription -SubscriptionId aec9ffa0-e92d-492d-87b7-a26053b2e22c
#Set-AzContext $context

Write-Host "================="
Write-Host "Stop Function"
Write-Host "================="

Stop-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -Force -ErrorAction SilentlyContinue


Write-Host "================="
Write-Host "Delete RG Backend"
Write-Host "================="

Remove-AzResourceGroup -Name apicobartco000000bga1gps -Force -ErrorAction SilentlyContinue

Write-Host "================="
Write-Host "Delete RG Data"
Write-Host "================="

Remove-AzResourceGroup -Name apicobartco000000dg01000 -Force -ErrorAction SilentlyContinue

Write-Host "================="
Write-Host "Delete RG Commands"
Write-Host "================="

Remove-AzResourceGroup -Name apicobartco000c00cg01gps -Force -ErrorAction SilentlyContinue

Write-Host "================="
Write-Host "Set GitHub Token"
Write-Host "================="

$token = Get-Content -Path gittoken.txt | Out-String

Set-AzResource -PropertyObject @{ token = "$token"; } -ResourceId /providers/Microsoft.Web/sourcecontrols/GitHub -ApiVersion 2015-08-01 -Force | Out-Null

Write-Host "================="
Write-Host "Create RG Backend"
Write-Host "================="

New-AzResourceGroup -Name apicobartco000000bga1gps -Location 'Southeast Asia'

Write-Host "================="
Write-Host "Create RG Data"
Write-Host "================="

New-AzResourceGroup -Name apicobartco000000dg01000 -Location 'Southeast Asia'

Write-Host "================="
Write-Host "Create RG Commands"
Write-Host "================="

New-AzResourceGroup -Name apicobartco000c00cg01gps -Location 'Southeast Asia'

Write-Host "================="
Write-Host "Create Plan"
Write-Host "================="

New-AzResourceGroupDeployment `
    -ResourceGroupName apicobartco000000bga1gps `
    -TemplateFile ./0000bpa.template.json `
    -TemplateObject @{ name = "apicobartco000000bpa1gps";  location = "Southeast Asia"; }

Write-Host "================="
Write-Host "Create Storage"
Write-Host "================="

New-AzResourceGroupDeployment `
    -ResourceGroupName apicobartco000000bga1gps `
    -TemplateFile ./0000bsa.template.json `
    -TemplateObject @{ name = "apicobartco000000bsa1gps";  location = "southeastasia"; }


Write-Host "================="
Write-Host "Create CDB"
Write-Host "================="

New-AzResourceGroupDeployment `
    -ResourceGroupName apicobartco000000dg01000 `
    -TemplateFile ./0000dc0.template.json `
    -TemplateObject @{ name = "apicobartco000000dc01000";  location = "Southeast Asia"; `
            database = "apicobartco000000dd01000"; readcollection = "apicobartco000000roo1gps"; `
            commandcollection = "apicobartco000c00coc1000"; leasecollection = "apicobartco000cpbcol1gps"; }

Write-Host "================="
Write-Host "Create EGD"
Write-Host "================="

New-AzResourceGroupDeployment `
    -ResourceGroupName apicobartco000c00cg01gps `
    -TemplateFile ./0cpbce0.template.json `
    -TemplateObject @{ name = "apicobartco000cpbce01gps";  location = "southeastasia"; }

Write-Host "================="
Write-Host "Create Function"
Write-Host "================="

New-AzResourceGroupDeployment `
    -ResourceGroupName apicobartco000000bga1gps `
    -TemplateFile ./functionapp.template.json `
    -TemplateObject @{ name = "apicobartco000000baa1gps";  location = "Southeast Asia"; `
            plan = "apicobartco000000bpa1gps"; plansubscription = "aec9ffa0-e92d-492d-87b7-a26053b2e22c"; `
            plangroup = "apicobartco000000bga1gps"; repo = "https://github.com/alfred-madl/apicobartco000000baa0000.git"; `
            branch = "apicobartco000000baa1gps"; }

Write-Host "========================="
Write-Host "Create CDB API Connection"
Write-Host "========================="

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps `
    -TemplateFile Logic//cdbapiconn.template.json `
    -TemplateObject @{ name = "apicobartco000ccrcte1gps";  location = "southeastasia"; `
            account = "apicobartco000000dc01000"; subscription = "aec9ffa0-e92d-492d-87b7-a26053b2e22c"; `
            group = "apicobartco000000dg01000"; }


Write-Host "========================="
Write-Host "Create EGD API Connection"
Write-Host "========================="

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps `
    -TemplateFile Logic//egdapiconn.template.json `
    -TemplateObject @{ name = "apicobartco0000clctg1gps";  location = "southeastasia"; subscription = "aec9ffa0-e92d-492d-87b7-a26053b2e22c"; `
            clientId = ""; clientSecret = ""; `
            tenantId = ""; }

#Write-Host "================="
#Write-Host "Stop Function"
#Write-Host "================="

#Stop-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -Force

#Write-Host "================="
#Write-Host "Logic Apps"
#Write-Host "================="

#New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps -TemplateFile ../Logic/apicobartco000ccrclh1gps.template.json
#$commandurl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName "apicobartco000c00cg01gps" -Name "apicobartco000ccrclh1gps" -TriggerName "manual").Value.TrimStart("https:").TrimStart("/")

#Write-Host "================="
#Write-Host "Function Settings"
#Write-Host "================="

#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=" + "apicobartco000000bsa1gps" + ";AccountKey=" + (Get-AzStorageAccountKey -ResourceGroupName apicobartco000000bga1gps -AccountName apicobartco000000bsa1gps)[0].Value + ";EndpointSuffix=core.windows.net" } -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"FUNCTIONS_EXTENSION_VERSION" = "~3"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"FUNCTIONS_WORKER_RUNTIME" = "dotnet"} -Force | Out-Null

#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-rm" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-cl" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-in" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-up" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-cr" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-de" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-re" = "xxx"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-li" = "xxx"} -Force | Out-Null

#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-key-re" = "xxx"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-key-li" = "xxx"} -Force | Out-Null

#Write-Host "================="
#Write-Host "Start Function"
#Write-Host "================="

#Start-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps
