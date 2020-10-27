param ($tenant='apico', $set='ba', $project='rt', $service='co', $version='00', $lane='1', $slot='g', $environment='p', $region='s', $subscription='aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken='', $gitpath='https://github.com/alfred-madl/', $tenantid='36459f7c-f2a9-49f0-845f-eead0c94bd39')

$objecttype = '0c'
# Publish commands
$operation = 'pb'
# Commands handling
$area = 'c'
$leasecdbaccount = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'c','l',$lane,$slot,$environment,$region)
$leasedatabase = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'d','l',$lane,$slot,$environment,$region)
$leasecollection = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'o','l',$lane,$slot,$environment,$region)
$leasecollectionprefix = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'p','l',$lane,$slot,$environment,$region)


$cmdslot='0'
$cmdenvironment='0'
$cmdregion='0'

$cmdobjecttype = '0c'
$cmdoperation = '00'
$cmdarea = 'd'
$cmdcdbaccount = `
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

$group = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'00',$area,'g','0',$lane,$slot,$environment,$region)

$location = switch($region) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
}

 $locationkey = switch($region) {
    's' {'southeastasia'; break} 
    'e' {'eastasia'; break} 
}

$cdbleasetemplate=-join('00','00','0','c','l','.template.json')

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


Write-Host "==========================="
Write-Host "Delete RG Command Handling"
Write-Host "==========================="

Remove-AzResourceGroup -Name $group -Force -ErrorAction SilentlyContinue


Write-Host "==========================="
Write-Host "Create RG Command Handling"
Write-Host "==========================="

New-AzResourceGroup -Name $group -Location $location


Write-Host "============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to Store Command"
Write-Host "============================================================="

New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $cmdcontemplate `
    -TemplateParameterObject @{ name = $cmdconname;  location = $location; locationkey = $locationkey; `
            account = $cmdcdbaccount; accountsubscription = $subscription; `
            accountgroup = $cmdgroup; }
            
Write-Host "================================="
Write-Host "Create CDB Command Publish Lease"
Write-Host "================================="

New-AzResourceGroupDeployment -ResourceGroupName $group -TemplateFile $cdbleasetemplate -TemplateParameterObject @{ name = $leasecdbaccount;  location = $location; database = $leasedatabase; collection = $leasecollection; }

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


Write-Host "==========================="
Write-Host "Logic Apps to Store Command"
Write-Host "==========================="

$httptriggerlogictemplate=-join('00','00','0','l','h','.template.json')

$sublogictemplate=-join('0c','cr','c','l','e','.template.json')

$httptriggerlogicname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'cr',$area,'l','h',$lane,$slot,$environment,$region)

$httptriggersublogicname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'cr',$area,'l','e',$lane,$slot,$environment,$region)

# Execute
New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $sublogictemplate `
    -TemplateParameterObject @{ name = $httptriggersublogicname;  location = $location; `
        locationkey = $locationkey; 
        accountsubscription = $subscription; `
        accountconnection=$cmdconname; `
        database = $cmddatabase; collection=$cmdcollection; }

# HTTP Trigger
New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $httptriggerlogictemplate `
    -TemplateParameterObject @{ name = $httptriggerlogicname;  location = $location; `
        logicname = $httptriggersublogicname; logicsubscription = $subscription; `
        logicgroup = $group; }

# Get URL for Proxy App Settings
# $commandurl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $group -Name $httptriggerlogicname -TriggerName "manual").Value.TrimStart("https:").TrimStart("/")

Write-Host "============================="
Write-Host "Stop Command Publish Function"
Write-Host "============================="

Stop-AzFunctionApp -Name $fncname -ResourceGroupName $group -Force



Write-Host "========================================"
Write-Host "Create Command Publish Function Settings"
Write-Host "========================================"


Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=" + $sacname + ";AccountKey=" + (Get-AzStorageAccountKey -ResourceGroupName $group -AccountName $sacname)[0].Value + ";EndpointSuffix=core.windows.net" } -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"FUNCTIONS_EXTENSION_VERSION" = "~3"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"FUNCTIONS_WORKER_RUNTIME" = "dotnet"} -Force | Out-Null

#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-rm" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-cl" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-in" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-up" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-cr" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-de" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-re" = "xxx"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-li" = "xxx"} -Force | Out-Null

#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-key-re" = "xxx"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-key-li" = "xxx"} -Force | Out-Null

$cmddbconn = (Get-AzCosmosDBAccountKey -ResourceGroupName $cmdgroup -Name $cmdcdbaccount -Type "ConnectionStrings")['Primary SQL Connection String']
$leasedbconn = (Get-AzCosmosDBAccountKey -ResourceGroupName $group -Name $leasecdbaccount -Type "ConnectionStrings")['Primary SQL Connection String']
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_ConnectionString" = $cmddbconn} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_LeaseConnectionString" = $leasedbconn} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_DatabaseName" = $cmddatabase} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_LeaseDatabaseName" = $leasedatabase} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_CollectionName" = $cmdcollection} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_LeaseCollectionName" = $leasecollection} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_LeaseCollectionPrefix" = $leasecollectionprefix} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_PreferredLocations" = $location} -Force | Out-Null

$egdkey = (Get-AzEventGridDomainKey -ResourceGroupName $group -Name $egdname).Key1
$egdendpoint = (Get-AzEventGridDomain -ResourceGroupName $group -Name $egdname).Endpoint
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_Event_TopicEndpoint" = "$egdendpoint"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"CDBPF_Event_TopicKey" = "$egdkey"} -Force | Out-Null

Write-Host "=============================="
Write-Host "Start Command Publish Function"
Write-Host "=============================="

Start-AzFunctionApp -Name $fncname -ResourceGroupName $group

