Write-Host "================="
Write-Host "Stop Function"
Write-Host "================="

Stop-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps -Force

Write-Host "================="
Write-Host "Logic Apps"
Write-Host "================="

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps -TemplateFile ../Logic/apicobartco000ccrcle1gps.template.json

New-AzResourceGroupDeployment -ResourceGroupName apicobartco000c00cg01gps -TemplateFile ../Logic/apicobartco000ccrclh1gps.template.json
$commandurl = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName "apicobartco000c00cg01gps" -Name "apicobartco000ccrclh1gps" -TriggerName "manual").Value.TrimStart("https:").TrimStart("/")

Write-Host "================="
Write-Host "Function Settings"
Write-Host "================="

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

Write-Host "================="
Write-Host "Start Function"
Write-Host "================="

Start-AzFunctionApp -Name apicobartco000000baa1gps -ResourceGroupName apicobartco000000bga1gps
