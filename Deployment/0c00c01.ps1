# Deploy CDB Commands...slot environment and region is covered by CDB redundancy mechanisms
param ($tenant='apico', $set='ba', $project='rt', $service='co', $version='00', $lane='1', $slot='g', $environment='p', $region='s', $defaultregion='s', $subscription='aec9ffa0-e92d-492d-87b7-a26053b2e22c')

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

Write-Host "==========================="
Write-Host "Delete RG Commands Handling"
Write-Host "==========================="

Remove-AzResourceGroup -Name $group -Force -ErrorAction SilentlyContinue


Write-Host "==========================="
Write-Host "Create RG Commands Handling"
Write-Host "==========================="

New-AzResourceGroup -Name $group -Location $location

Write-Host "================================="
Write-Host "Create CDB Commands Publish Lease"
Write-Host "================================="

New-AzResourceGroupDeployment -ResourceGroupName $group -TemplateFile $cdbtemplate -TemplateParameterObject @{ name = $cdbaccount;  location = $location; database = $database; collection = $leasecollection; }



$egdname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'e','0',$lane,$slot,$environment,$region)

Write-Host "==========================="
Write-Host "Create EGD Commands Publish"
Write-Host "==========================="

New-AzResourceGroupDeployment `
    -ResourceGroupName $group `
    -TemplateFile $egdtemplate `
    -TemplateParameterObject @{ name = $egdname;  location = $location; }