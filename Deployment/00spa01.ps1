# Stop API Function App
param ($tenant='apico', $set='ba', $project='rt', $service='co', $version='00', $lane='1', $slot='g', $environment='p', $region='s', $defaultregion='s')

$objecttype = '00'
$operation = '00'
$area = 'a'
$function = -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'a','0',$lane,$slot,$environment,$region)
$group = -join($tenant,$set,$project,$service,$version,$objecttype,$operation,$area,'g','0',$lane,$slot,$environment,$region)

Write-Host "====================="
Write-Host "Stop API Function App"
Write-Host "====================="

Stop-AzFunctionApp -Name $function -ResourceGroupName $group -Force -ErrorAction SilentlyContinue
