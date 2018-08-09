param (
    [string][Parameter(Mandatory=$true)]$ConnectedServiceName,
    [string][Parameter(Mandatory=$true)]$ResourceGroupName,
    [string][Parameter(Mandatory=$true)]$AutomationAccountName,
    [string][Parameter(Mandatory=$false)]$ModulesFile = $null,
    [string][Parameter(Mandatory=$false)]$ModuleStorageAccountName
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$StorageAccountName = Get-AzureRMStorageAccount -AccountName $ModuleStorageAccountName

& ".\ImportModules.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName -ModulePath $ModulesFile -StorageAccountName $ModuleStorageAccountName
