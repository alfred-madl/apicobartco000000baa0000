param ($tenant='apico', $set='ba', $project='rt', $service='co', $version='00', $lane='1', $slot='g', $environment='p', $region='s', $subscription='aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken='', $gitpath='https://github.com/alfred-madl/', $tenantid='36459f7c-f2a9-49f0-845f-eead0c94bd39')

$objecttype = '00'
# Publish commands
$operation = '00'
# Commands handling
$area = 'a'

$group = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'g','0',$lane,$slot,$environment,$region)

$location = switch($region) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
}

 $locationkey = switch($region) {
    's' {'southeastasia'; break} 
    'e' {'eastasia'; break} 
}

$plntemplate=-join('00','00','0','p','0','.template.json')

$plnname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'p','0',$lane,$slot,$environment,$region)
    
$sactemplate=-join('00','00','0','s','0','.template.json')

$sacname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'s','0',$lane,$slot,$environment,$region)

$fnctemplate=-join('00','00','0','a','0','.template.json')

$fncname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'a','0',$lane,$slot,$environment,$region)

$fncrepo = `
    -join($gitpath, $tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'a','0','0','0','0','0','.git')

$fncbranch = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'a','0',$lane,$slot,$environment,$region)
   

Write-Host "============================"
Write-Host "Delete RG API Function Proxy"
Write-Host "============================"

Remove-AzResourceGroup -Name $group -Force -ErrorAction SilentlyContinue


Write-Host "============================"
Write-Host "Create RG API FUnction Proxy"
Write-Host "============================"

New-AzResourceGroup -Name $group -Location $location

Write-Host "================="
Write-Host "Set GitHub Token"
Write-Host "================="

if ($gittoken -eq '') {
    $gittoken = Get-Content -Path gittoken.txt | Out-String
} else {
}

Set-AzResource -PropertyObject @{ token = "$gittoken"; } -ResourceId /providers/Microsoft.Web/sourcecontrols/GitHub -ApiVersion 2015-08-01 -Force #| Out-Null


Write-Host "=================================="
Write-Host "Create API Function Proxy App Plan"
Write-Host "=================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $group `
    -TemplateFile $plntemplate `
    -TemplateParameterObject @{ name = $plnname;  location = $location; }

Write-Host "====================================="
Write-Host "Create API Function Proxy App Storage"
Write-Host "====================================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $group `
    -TemplateFile $sactemplate `
    -TemplateParameterObject @{ name = $sacname;  location = $location; }


Write-Host "==============================="
Write-Host "Create API Proxy Function App"
Write-Host "==============================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $group `
    -TemplateFile $fnctemplate `
    -TemplateParameterObject @{ name = $fncname;  location = $location; `
            plan = $plnname; plansubscription = $subscription; `
            plangroup = $group; repo = $fncrepo; `
            branch = $fncbranch; }


Write-Host "============================="
Write-Host "Stop Command Publish Function"
Write-Host "============================="

Stop-AzFunctionApp -Name $fncname -ResourceGroupName $group -Force



Write-Host "========================================"
Write-Host "Create Command Publish Function Settings"
Write-Host "========================================"

# Get URL for Proxy App Settings
$commandgroup = `
    -join($tenant,$set,$project,$service,$version,'0c','00','c','g','0',$lane,$slot,$environment,$region)

$httptriggerlogicname = `
    -join($tenant,$set,$project,$service,$version,'0c','cr','c','l','h',$lane,$slot,$environment,$region)

$commandurl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $commandgroup -Name $httptriggerlogicname -TriggerName "manual").Value.TrimStart("https:").TrimStart("/")

Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"AzureWebJobsStorage" = "DefaultEndpointsProtocol=https;AccountName=" + $sacname + ";AccountKey=" + (Get-AzStorageAccountKey -ResourceGroupName $group -AccountName $sacname)[0].Value + ";EndpointSuffix=core.windows.net" } -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"FUNCTIONS_EXTENSION_VERSION" = "~3"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"FUNCTIONS_WORKER_RUNTIME" = "dotnet"} -Force | Out-Null

Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-rm" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-cl" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-in" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-up" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-cr" = "$commandurl"} -Force | Out-Null
Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-de" = "$commandurl"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-re" = "xxx"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-url-li" = "xxx"} -Force | Out-Null

#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-key-re" = "xxx"} -Force | Out-Null
#Update-AzFunctionAppSetting -Name $fncname -ResourceGroupName $group -AppSetting @{"x-apico-operation-key-li" = "xxx"} -Force | Out-Null

Write-Host "=============================="
Write-Host "Start Command Publish Function"
Write-Host "=============================="

Start-AzFunctionApp -Name $fncname -ResourceGroupName $group

