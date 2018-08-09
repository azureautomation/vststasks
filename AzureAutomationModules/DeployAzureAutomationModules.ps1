param (
    [string][Parameter(Mandatory=$true)]$ConnectedServiceName,
    [string][Parameter(Mandatory=$true)]$ResourceGroupName,
    [string][Parameter(Mandatory=$true)]$AutomationAccountName,
    [string][Parameter(Mandatory=$true)]$ModulesFile = $null,
    [string][Parameter(Mandatory=$true)]$ModuleStorageAccountName
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

& ".\ImportModules.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName -ModulePath $ModulesFile -StorageAccountName $ModuleStorageAccountName
