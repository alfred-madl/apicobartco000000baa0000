# Deploy CDB Commands...slot environment and region is covered by CDB redundancy mechanisms
param ($tenant='apico', $set='ba', $project='rt', $service='co', $version='00', $lane='1', $defaultregion='s')

$slot='0'
$environment='0'
$region='0'

$objecttype = '0c'
$operation = '00'
$area = 'd'
$name = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'c','0',$lane,$slot,$environment,$region)
$database = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'d','0',$lane,$slot,$environment,$region)
$collection = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'o','0',$lane,$slot,$environment,$region)
$group = `
    -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'g','0',$lane,$slot,$environment,$region)

$location = switch($defaultregion) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
 }

 $template=-join('00','00','0','c','0','.template.json')


Write-Host "======================="
Write-Host "Delete RG Commands Data"
Write-Host "======================="

Remove-AzResourceGroup -Name $group -Force -ErrorAction SilentlyContinue


Write-Host "======================="
Write-Host "Create RG Commands Data"
Write-Host "======================="

New-AzResourceGroup -Name $group -Location $location

Write-Host "========================"
Write-Host "Create CDB Commands Data"
Write-Host "========================"

New-AzResourceGroupDeployment -ResourceGroupName $group -TemplateFile $template -TemplateParameterObject @{ name = $name;  location = $location; database = $database; collection = $collection; }