param ($tenant='apico', $set='ba', $project='rt', $service='co', $version='00', $lane='1', $slot='g', $environment='p', $region='s', $defaultregion='s', $subscription='aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken='', $gitpath='https://github.com/alfred-madl/', $tenantid='36459f7c-f2a9-49f0-845f-eead0c94bd39')

$objecttype = '00'

$operation = '00'
# Read view
$area = 'r'

$cdbaccount = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'c','0',$lane,$slot,$environment,$region)
$database = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'d','0',$lane,$slot,$environment,$region)
$collection = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'o','0',$lane,$slot,$environment,$region)

$cdbconname = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'sy',$area,'t','e',$lane,$slot,$environment,$region)

$cdbtemplate=-join('00','00','r','c','0','.template.json')

$cdbcontemplate=-join('00','00','0','t','c','.template.json')

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

$defaultlocation = switch($defaultregion) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
}

 $defaultlocationkey = switch($defaultregion) {
    's' {'southeastasia'; break} 
    'e' {'eastasia'; break} 
}

$egdname = `
    -join($tenant,$set,$project,$service,$version,'0c','pb','c','e','0',$lane,$slot,$environment,$region)

$egdtopicname = `
    -join ($tenant, $set, $project, $service, $version, '0c', 'pb', 'c', 'b', '0', $lane, $slot, $environment, $region)

$egdsubscrname = `
    -join ($tenant, $set, $project, $service, $version, $objecttype, 'sy', $area, 'u', '0', $lane, $slot, $environment, $region)

$egdconname = `
    -join ($tenant, $set, $project, $service, $version, $objecttype, 'sy', $area, 't', 'g', $lane, $slot, $environment, $region)


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
    -join($tenant,$set,$project,$service,$version,$objecttype,'re',$area,'t','0',$lane,$slot,$environment,$region)
    
$cmdcontemplate=-join('00','00','0','t','c','.template.json')
    


Write-Host "==========================="
Write-Host "Delete RG Read View"
Write-Host "==========================="

Remove-AzResourceGroup -Name $group -Force -ErrorAction SilentlyContinue


Write-Host "==========================="
Write-Host "Create RG Read View"
Write-Host "==========================="

New-AzResourceGroup -Name $group -Location $location

            
Write-Host "================================="
Write-Host "Create CDB Read View"
Write-Host "================================="

New-AzResourceGroupDeployment -ResourceGroupName $group -TemplateFile $cdbtemplate -TemplateParameterObject @{ name = $cdbaccount;  location = $location; database = $database; collection = $collection; }

Write-Host "==============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to write Read View"
Write-Host "==============================================================="

New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $cdbcontemplate `
    -TemplateParameterObject @{ name = $cdbconname;  location = $location; locationkey = $locationkey; `
            account = $cdbaccount; accountsubscription = $subscription; `
            accountgroup = $group; }

Write-Host "==============================================================="
Write-Host "Create CosmosDB API Connection for Logic App to read Commands"
Write-Host "==============================================================="

New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $cmdcontemplate `
    -TemplateParameterObject @{ name = $cmdconname;  location = $defaultlocation; locationkey = $defaultlocationkey; `
            account = $cmdcdbaccount; accountsubscription = $subscription; `
            accountgroup = $cmdgroup; }