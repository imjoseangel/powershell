Select-AzureRmSubscription -SubscriptionName DVT_IT_DEV

New-AzureRmResourceGroupDeployment -name Route_from_DEV -ResourceGroupName rgnedvtitdevarm -TemplateFile 'template.json'