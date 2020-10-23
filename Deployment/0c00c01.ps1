# Deploy CDB Commands...slot environment and region is covered by CDB redundancy mechanisms
param ($tenant='apico', $set='ba', $project='rt', $service='co', $version='00', $lane='1', $slot='g', $environment='p', $region='s', $defaultregion='s', $subscription='aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken='', $gitpath='https://github.com/alfred-madl/')

$objecttype = '0c'
# Publish commands
$operation = 'pb'
# Commands handling
$area = 'c'
$leasecdbaccount = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'c','0',$lane,$slot,$environment,$region)
$leasedatabase = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'d','0',$lane,$slot,$environment,$region)
# Lease collection
$leasecollection = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'l','0',$lane,$slot,$environment,$region)
$group = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'00',$area,'g','0',$lane,$slot,$environment,$region)

$location = switch($defaultregion) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
 }

$cdbtemplate=-join('00','00','0','c','0','.template.json')

$egdtemplate=-join('00','00','0','e','0','.template.json')

$egdname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'e','0',$lane,$slot,$environment,$region)

$plntemplate=-join('00','00','0','p','0','.template.json')

$plnname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'p','0',$lane,$slot,$environment,$region)
    
$sactemplate=-join('00','00','0','s','0','.template.json')

$sacname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'s','0',$lane,$slot,$environment,$region)

$fnctemplate=-join('00','00','0','a','0','.template.json')

$fncname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'a','0',$lane,$slot,$environment,$region)

#$fncrepo = `
#    -join($gitpath, $tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'a','0','0','0','0','0','.git')

$fncrepo = -join($gitpath,'apicobartco000cpbca00000','.git')

#$fncbranch = `
#    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'a','0',$lane,$slot,$environment,$region)
    
$fncbranch = 'apicobartco000cpbca01gps'

# EGD API connection for Clear Command processing Logic App Trigger
$egdconname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'cl',$area,'t','g',$lane,$slot,$environment,$region)


Write-Host "==========================="
Write-Host "Delete RG Command Handling"
Write-Host "==========================="

Remove-AzResourceGroup -Name $group -Force -ErrorAction SilentlyContinue


Write-Host "==========================="
Write-Host "Create RG Command Handling"
Write-Host "==========================="

New-AzResourceGroup -Name $group -Location $location

Write-Host "================================="
Write-Host "Create CDB Command Publish Lease"
Write-Host "================================="

New-AzResourceGroupDeployment -ResourceGroupName $group -TemplateFile $cdbtemplate -TemplateParameterObject @{ name = $leasecdbaccount;  location = $location; database = $leasedatabase; collection = $leasecollection; }


Write-Host "==========================="
Write-Host "Create EGD Command Publish"
Write-Host "==========================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $group `
    -TemplateFile $egdtemplate `
    -TemplateParameterObject @{ name = $egdname;  location = $location; }


Write-Host "================="
Write-Host "Set GitHub Token"
Write-Host "================="

if ($gittoken -eq '') {
    $gittoken = Get-Content -Path gittoken.txt | Out-String
} else {
}

Set-AzResource -PropertyObject @{ token = "$gittoken"; } -ResourceId /providers/Microsoft.Web/sourcecontrols/GitHub -ApiVersion 2015-08-01 -Force #| Out-Null


Write-Host "==============================="
Write-Host "Create Command Publish App Plan"
Write-Host "==============================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $group `
    -TemplateFile $plntemplate `
    -TemplateParameterObject @{ name = $plnname;  location = $location; }

Write-Host "=================================="
Write-Host "Create Command Publish App Storage"
Write-Host "=================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $group `
    -TemplateFile $sactemplate `
    -TemplateParameterObject @{ name = $sacname;  location = $location; }


Write-Host "==============================="
Write-Host "Create Command Publish Function"
Write-Host "==============================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $group `
    -TemplateFile $fnctemplate `
    -TemplateParameterObject @{ name = $fncname;  location = $location; `
            plan = $plnname; plansubscription = $subscription; `
            plangroup = $group; repo = $fncrepo; `
            branch = $fncbranch; }


Write-Host "============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to Store Command"
Write-Host "============================================================="



$cmdslot='0'
$cmdenvironment='0'
$cmdregion='0'

$cmdobjecttype = '0c'
$cmdoperation = '00'
$cmdarea = 'd'
$cmdaccountname = `
    -join($tenant,$set,$project,$service,$version,$cmdobjecttype,$cmdoperation,$cmdarea,'c','0',$lane,$cmdslot,$cmdenvironment,$cmdregion)
$cmddatabase = `
    -join($tenant,$set,$project,$service,$version,$cmdobjecttype,$cmdoperation,$cmdarea,'d','0',$lane,$cmdslot,$cmdenvironment,$cmdregion)
$cmdcollection = `
    -join($tenant,$set,$project,$service,$version,$cmdobjecttype,$cmdoperation,$cmdarea,'o','0',$lane,$cmdslot,$cmdenvironment,$cmdregion)
$cmdgroup = `
    -join($tenant,$set,$project,$service,$version,$cmdobjecttype,$cmdoperation,$cmdarea,'g','0',$lane,$cmdslot,$cmdenvironment,$cmdregion)

$cmdconname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'cr',$area,'t','e',$lane,$slot,$environment,$region)

$cmdcontemplate=-join('00','00','0','t','c','.template.json')

New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $cmdcontemplate `
    -TemplateParameterObject @{ name = $cmdconname;  location = $location; `
            account = $cmdaccountname; accountsubscription = $subscription; `
            accountgroup = $cmdgroup; }

<#

Write-Host "==========================="
Write-Host "Logic Apps to Store Command"
Write-Host "==========================="

# Execute
New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps -TemplateFile Logic/apicobartco000ccrcle1gps.template.json
# HTTP Trigger
New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps -TemplateFile Logic/apicobartco000ccrclh1gps.template.json
# Get URL for Proxy App Settings
$commandurl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName "apicobartco000c00cg01gps" -Name "apicobartco000ccrclh1gps" -TriggerName "manual").Value.TrimStart("https:").TrimStart("/")


Write-Host "======================================================================="
Write-Host "Create Event Grid Domain API Connection for Logic App to Clear Commands"
Write-Host "======================================================================="

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps `
    -TemplateFile Logic//egdapiconn.template.json `
    -TemplateObject @{ name = "apicobartco0000clctg1gps";  location = "southeastasia"; subscription = "aec9ffa0-e92d-492d-87b7-a26053b2e22c"; `
            clientId = ""; clientSecret = ""; `
            tenantId = ""; }


Write-Host "============================"
Write-Host "Logic Apps to Clear Commands"
Write-Host "============================"

# Execute
New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps -TemplateFile Logic/apicobartco000cclcle1gps.template.json
#HTTP Trigger
New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps -TemplateFile Logic/apicobartco000cclclh1gps.template.json
# Grid Trigger
New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps -TemplateFile Logic/apicobartco000cclclg1gps.template.json


Write-Host "============================="
Write-Host "Stop Command Publish Function"
Write-Host "============================="

Stop-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -Force



Write-Host "========================================"
Write-Host "Create Command Publish Function Settings"
Write-Host "========================================"


Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=" + "apicobartco000000bsa1gps" + ";AccountKey=" + (Get-AzStorageAccountKey -ResourceGroupName apicobartco000000bga1gps -AccountName apicobartco000000bsa1gps)[0].Value + ";EndpointSuffix=core.windows.net" } -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"FUNCTIONS_EXTENSION_VERSION" = "~3"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"FUNCTIONS_WORKER_RUNTIME" = "dotnet"} -Force | Out-Null

Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-rm" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-cl" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-in" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-up" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-cr" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-de" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-re" = "xxx"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-url-li" = "xxx"} -Force | Out-Null

Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-key-re" = "xxx"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"x-apico-operation-key-li" = "xxx"} -Force | Out-Null

$dbconn = (Get-AzCosmosDBAccountKey -ResourceGroupName apicobartco000000dg01000 -Name apicobartco000000dc01000 -Type "ConnectionStrings")['Primary SQL Connection String']
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_ConnectionString" = "$dbconn"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_LeaseConnectionString" = "$dbconn"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_DatabaseName" = "apicobartco000000dd01000"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_LeaseDatabaseName" = "apicobartco000000dd01000"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_CollectionName" = "apicobartco000c00coc1000"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_LeaseCollectionName" = "apicobartco000cpbcol1gps"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_LeaseCollectionPrefix" = "apicobartco000cpbcp01gps"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_PreferrredLocations" = "Southeast Asia"} -Force | Out-Null

$egdkey = (Get-AzEventGridDomainKey -ResourceGroupName apicobartco000c00cg01gps -Name apicobartco000cpbce01gps).Key1
$egdendpoint = (Get-AzEventGridDomain -ResourceGroupName apicobartco000c00cg01gps -Name apicobartco000cpbce01gps).Endpoint
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_Event_TopicEndpoint" = "$egdendpoint"} -Force | Out-Null
Update-AzFunctionAppSetting -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -AppSetting @{"CDBPF_Event_TopicKey" = "$egdkey"} -Force | Out-Null

Write-Host "=============================="
Write-Host "Start Command Publish Function"
Write-Host "=============================="

Start-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps

#>