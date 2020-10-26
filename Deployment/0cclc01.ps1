param ($tenant = 'apico', $set = 'ba', $project = 'rt', $service = 'co', $version = '00', $lane = '1',  $slot='g', $environment='p', $region='s', $subscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c', $gittoken = '', $gitpath = 'https://github.com/alfred-madl/', $tenantid = '36459f7c-f2a9-49f0-845f-eead0c94bd39')
# we dont deploy that in production for security reasons !
if ($lane -ne 'z') {
    $objecttype = '0c'
    # Clear commands
    $operation = 'cl'
    # Commands handling
    $area = 'c'

    $cmdslot = '0'
    $cmdenvironment = '0'
    $cmdregion = '0'

    $cmdoperation = '00'
    $cmdarea = 'd'
    $cmdcdbaccount = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $cmdoperation, $cmdarea, 'c', '0', $lane, $cmdslot, $cmdenvironment, $cmdegion)
    $cmddatabase = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $cmdoperation, $cmdarea, 'd', '0', $lane, $cmdslot, $cmdenvironment, $cmdregion)
    $cmdcollection = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $cmdoperation, $cmdarea, 'o', '0', $lane, $cmdslot, $cmdenvironment, $cmdregion)
    $cmdgroup = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $cmdoperation, $cmdarea, 'g', '0', $lane, $cmdslot, $cmdenvironment, $cmdregion)

    $cmdconname = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, 'cl', $area, 't', 'e', $lane, $slot, $environment, $region)

    $cmdcontemplate = -join ('00', '00', '0', 't', 'c', '.template.json')

    $group = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $operation, $area, 'g', '0', $lane, $slot, $environment, $region)

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


    # EGD API connection for Clear Command processing Logic App Trigger
    $egdconname = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $operation, $area, 't', 'g', $lane, $slot, $environment, $region)


    Write-Host "=================================="
    Write-Host "Delete RG Command Clear Processing"
    Write-Host "=================================="

    Remove-AzResourceGroup -Name $group -Force -ErrorAction SilentlyContinue


    Write-Host "=================================="
    Write-Host "Create RG Command Clear Processing"
    Write-Host "=================================="

    New-AzResourceGroup -Name $group -Location $location

    Write-Host "=============================================================="
    Write-Host "Create CosmosDB API Connection for Logic App to Clear Commands"
    Write-Host "=============================================================="

    New-AzResourceGroupDeployment -ResourceGroupName $group `
        -TemplateFile $cmdcontemplate `
        -TemplateParameterObject @{ name = $cmdconname; location = $location; locationkey = $locationkey; `
            account = $cmdcdbaccount; accountsubscription = $subscription; `
            accountgroup = $cmdgroup; 
    }


    Write-Host "============================"
    Write-Host "Logic Apps to Clear Commands"
    Write-Host "============================"

    $httptriggerlogictemplate = -join ('00', '00', '0', 'l', 'h', '.template.json')

    $sublogictemplate = -join ('0c', 'cl', 'c', 'l', 'e', '.template.json')

    $httptriggerlogicname = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $operation, $area, 'l', 'h', $lane, $slot, $environment, $region)

    $httptriggersublogicname = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $operation, $area, 'l', 'e', $lane, $slot, $environment, $region)

    # Execute
    New-AzResourceGroupDeployment -ResourceGroupName $group `
        -TemplateFile $sublogictemplate `
        -TemplateParameterObject @{ name = $httptriggersublogicname; location = $location; `
            locationkey = $locationkey; 
            accountsubscription = $subscription; `
            accountgroup = $cmdgroup; accountconnection = $cmdconname; `
            database = $cmddatabase; collection = $cmdcollection; 
    }

    # HTTP Trigger
    New-AzResourceGroupDeployment -ResourceGroupName $group `
        -TemplateFile $httptriggerlogictemplate `
        -TemplateParameterObject @{ name = $httptriggerlogicname; location = $location; `
            logicname = $httptriggersublogicname; logicsubscription = $subscription; `
            logicgroup = $group; 
    }


    Write-Host "==========================================================================================="
    Write-Host "Create AAD Application for Event Grid Domain API Connection for Logic App to Clear Commands"
    Write-Host "==========================================================================================="


    $aadappname = `
        -join ($tenant, $set, $project, $service, $version, $objecttype, $operation, $area, 'r', 'g', $lane, $slot, $environment, $region)

    Remove-AzADApplication -DisplayName $aadappname -Force -ErrorAction SilentlyContinue

    $aadappuri = -join ('https://', $aadappname, '.apico.io')

    $aadapp = New-AzADApplication -DisplayName $aadappname -IdentifierUris $aadappuri

    $aadappid = $aadapp.ApplicationId.Guid
    $aadappid

    $aadapppwd = [guid]::NewGuid().Guid
    $aadapppwd

    $aadapppwdsecure = ConvertTo-SecureString -String $aadapppwd -AsPlainText -Force 

    $aadappstart = get-date 

    $aadappend = $aadappstart.AddYears(2)  

    $aadappcred = New-AzADAppCredential -ObjectId $aadapp.ObjectID -Password $aadapppwdsecure -startDate $aadappstart -enddate $aadappend

    Get-AzADApplication -ObjectId $aadapp.ObjectID | New-AzADServicePrincipal -startDate $aadappstart -enddate $aadappend 

    $egdcontemplate = -join ('00', '00', '0', 't', 'g', '.template.json')

    New-AzResourceGroupDeployment -ResourceGroupName $group `
        -TemplateFile $egdcontemplate `
        -TemplateParameterObject @{ name = $egdconname; location = $location; locationkey = $locationkey; subscription = $subscription; `
            clientId = $aadappid; clientSecret = $aadapppwd; `
            tenantId = $tenantid; 
    }

    <#

Write-Host "============================"
Write-Host "Logic Apps to Clear Commands"
Write-Host "============================"

$httptriggerlogictemplate2=-join('00','00','0','l','h','.template.json')

$egdtriggerlogictemplate2=-join('00','00','0','l','g','.template.json')

$sublogictemplate2=-join('0c','cl','c','l','e','.template.json')

$httptriggerlogicname2 = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'cl',$area,'l','h',$lane,$slot,$environment,$region)

$egdtriggerlogicname2 = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'cl',$area,'l','g',$lane,$slot,$environment,$region)

$httptriggersublogicname2 = `
    -join($tenant,$set,$project,$service,$version,$objecttype,'cl',$area,'l','e',$lane,$slot,$environment,$region)

# Execute
New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $sublogictemplate2 `
    -TemplateParameterObject @{ name = $httptriggersublogicname2;  location = $location; `
        locationkey = $locationkey; 
        accountsubscription = $subscription; }

# HTTP Trigger
New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $httptriggerlogictemplate2 `
    -TemplateParameterObject @{ name = $httptriggerlogicname2;  location = $location; `
        logicname = $httptriggersublogicname2; logicsubscription = $subscription; `
        logicgroup = $group; }

# EGD Trigger
New-AzResourceGroupDeployment -ResourceGroupName $group `
    -TemplateFile $egdtriggerlogictemplate2 `
    -TemplateParameterObject @{ name = $egdtriggerlogicname2;  location = $location; `
        logicname = $httptriggersublogicname2; logicsubscription = $subscription; `
        logicgroup = $group; }
#>



}
else {
}
