param ($tenant = 'test', $set = 'xx', $project = 'yy', $service = 'zz', $version = '00', $lane = '1',  $slot='g', $environment='p', $region='s', $subscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken = '', $gitpath = 'https://github.com/alfred-madl/', $tenantid = '36459f7c-f2a9-49f0-845f-eead0c94bd39')

$group = `
-join ($tenant, $set, $project, $service, $version, $objecttype, $operation, $area, 'g', '0', $lane, $slot, $environment, $region)

$aadappname = `
-join ($tenant, $set, $project, $service, $version, $objecttype, $operation, $area, 'r', 'g', $lane, $slot, $environment, $region)

$location = switch ($region) {
    's' { 'Southeast Asia'; break } 
    'e' { 'East Asia'; break } 
}

$locationkey = switch ($region) {
    's' { 'southeastasia'; break } 
    'e' { 'eastasia'; break } 
}
$egdname = `
-join ($tenant, $set, $project, $service, $version, $objecttype, '00', $area, 'e', '0', $lane, $slot, $environment, $region)

$egdconname = `
-join ($tenant, $set, $project, $service, $version, $objecttype, $operation, $area, 't', 'g', $lane, $slot, $environment, $region)

Remove-AzResourceGroup -Name $group -Force -ErrorAction SilentlyContinue

New-AzResourceGroup -Name $group -Location $location

Remove-AzADServicePrincipal -DisplayName $aadappname -Force #-ErrorAction SilentlyContinue

Remove-AzADApplication -DisplayName $aadappname -Force #-ErrorAction SilentlyContinue

$aadappuri = -join ('https://', $aadappname, '.test.io')

$aadapp = New-AzADApplication -DisplayName $aadappname -IdentifierUris $aadappuri

$aadappid = $aadapp.ApplicationId.Guid

$aadapppwd = [guid]::NewGuid().Guid

$aadapppwdsecure = ConvertTo-SecureString -String $aadapppwd -AsPlainText -Force 

$aadappstart = get-date 

$aadappend = $aadappstart.AddYears(2)  

$aadappcred = New-AzADAppCredential -ObjectId $aadapp.ObjectID -Password $aadapppwdsecure -startDate $aadappstart -enddate $aadappend

Get-AzADApplication -ObjectId $aadapp.ObjectID | New-AzADServicePrincipal -startDate $aadappstart -enddate $aadappend 

$egdcontemplate = 'con.template.json'

New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $egdcontemplate `
    -TemplateParameterObject @{ name = $egdconname; location = $location; locationkey = $locationkey; subscription = $subscription; `
        clientId = $aadappid; clientSecret = $aadapppwd; `
        tenantId = $tenantid; 
    }