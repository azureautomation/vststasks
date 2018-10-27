param (
    [string][Parameter(Mandatory=$true)]$ConnectedServiceName,
    [string][Parameter(Mandatory=$true)]$ResourceGroupName,
    [string][Parameter(Mandatory=$true)]$AutomationAccountName,
    [string][Parameter(Mandatory=$false)]$RunbookLocation,
    [string][Parameter(Mandatory=$false)]$AutomationRunbook = $null,
    [string][Parameter(Mandatory=$false)]$RunbookFile = $null,
    [string][Parameter(Mandatory=$false)]$StartRunbookJob = "false",
    [string][Parameter(Mandatory=$false)]$RunbookToStart,
    [string][Parameter(Mandatory=$false)]$RunbookParameters = $null,
    [string][Parameter(Mandatory=$false)]$RunbookParametersFile = $null,
    [string][Parameter(Mandatory=$False)]$RunbookParametersInJson = $null,
    [string][Parameter(Mandatory=$false)]$HybridWorker = $null,
    [string][Parameter(Mandatory=$false)]$SpecifiedRunOn
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

if ($RunbookLocation -ne "RunbookFromAutomation") {
    & ".\ImportRunbook.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName -RunbookPath $RunbookFile
}

# Start the runbook if specified.
if ($StartRunbookJob -eq "true" -or $RunbookLocation -eq "RunbookFromAutomation") {
    if ($StartRunbookJob -eq "true")
    {
        $AutomationRunbook = $RunbookToStart
    }
    if ($HybridWorker -eq "Azure") {
        & ".\StartRunbook.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName -RunbookName $AutomationRunbook -RunbookParametersFile $RunbookParametersFile `
        -RunbookParametersInJson $RunbookParametersInJson -RunbookParameters $RunbookParameters -RunOn $HybridWorker
    }
    else { 
        & ".\StartRunbook.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName -RunbookName $AutomationRunbook -RunbookParametersFile $RunbookParametersFile `
        -RunbookParametersInJson $RunbookParametersInJson -RunbookParameters $RunbookParameters -RunOn $SpecifiedRunOn
    }
}

