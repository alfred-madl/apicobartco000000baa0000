# Deploy CDB Commands...slot environment and region is covered by CDB redundancy mechanisms
param ($tenant='apico', $set='ba', $project='rt', $service='co', $version='00', $lane='1', $slot='g', $environment='p', $region='s', $defaultregion='s', $subscription='aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken='', $gitpath='https://github.com/alfred-madl/')

$objecttype = '0c'
# Publish commands
$operation = 'pb'
# Commands handling
$area = 'c'
$cdbaccount = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'c','0',$lane,$slot,$environment,$region)
$database = `
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

$fncrepo = 'apicobartco000cpbca00000'

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

Write-Host "================================="
Write-Host "Create CDB Command Publish Lease"
Write-Host "================================="

New-AzResourceGroupDeployment -ResourceGroupName $group -TemplateFile $cdbtemplate -TemplateParameterObject @{ name = $cdbaccount;  location = $location; database = $database; collection = $leasecollection; }


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
    -TemplateObject @{ name = $fncname;  location = $location; `
            plan = $plnname; plansubscription = $subscription; `
            plangroup = $group; repo = $fncrepo; `
            branch = $fncpath; }
