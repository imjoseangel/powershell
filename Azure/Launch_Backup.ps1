$computers = @("computer1","computer2")

Get-AzureRmRecoveryServicesVault -Name "Vault" | Set-AzureRmRecoveryServicesVaultContext

foreach ($computer in $computers) {

    $namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -FriendlyName $computer
    $item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
    $job = Backup-AzureRmRecoveryServicesBackupItem -Item $item

}