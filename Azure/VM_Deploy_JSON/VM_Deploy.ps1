Get-AzureRmSubscription -SubscriptionName "Subscription"

$DeployName = "VMDeploy"
$RGName = "VMDeployRG"
$Location = "West Europe"
$TemplateURI = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-windows/azuredeploy.json"

New-AzureRmResourceGroup -Name $RGName -Location $Location
New-AzureRmResourceGroupDeployment -Name $DeployName -ResourceGroupName $RGName -TemplateUri $TemplateURI -TemplateParameterUri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-storage-account-create/azuredeploy.parameters.json"

New-AzureRmResourceGroupDeployment -Name $DeployName -ResourceGroupName $RGName -TemplateUri $TemplateURI -newStorageAccountname mystorageaccount -adminUsername myuser -adminPassword 'Myp#44wrd' –dnsNameForPublicIP 'dnsname' –windowsOsVersion '2012-R2-Datacenter'

$TemplateFile = "C:\Users\imjoseangel\SimpleVM.json"
New-AzureRmResourceGroupDeployment -Name $DeployName -ResourceGroupName $RGName -TemplateUri $TemplateFile $TemplateFile

Remove-AzureRmResourceGroup -Name $RGName -Force