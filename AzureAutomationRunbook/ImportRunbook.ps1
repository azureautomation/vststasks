param (
    [string][Parameter(Mandatory=$true)]$ConnectedServiceName,
    [string][Parameter(Mandatory=$true)]$ResourceGroupName,
    [string][Parameter(Mandatory=$true)]$AutomationAccountName,
    [string][Parameter(Mandatory=$true)]$RunbookPath
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "Executing script 'ImportRunbook.ps1' from https://github.com/azureautomation/vststasks/tree/master/AzureAutomationRunbook"

# Get all runbooks from the path provided
$Runbooks = Get-ChildItem -Path $RunbookPath -File -Include ('*.ps1', '*.py') -Recurse -Depth 1

# Go through each runbook to check if it is python, powershell, or powershell workflow
foreach ($Runbook in $Runbooks)
{
    if ($Runbook.Extension.ToLower() -eq ".py")
    {
        $RunbookType = "Python2"
    }

    elseif ($Runbook.Extension.ToLower() -eq ".graphrunbook") {
        $RunbookType = "Graph"
    }

    else
    {
        $AST = [System.Management.Automation.Language.Parser]::ParseFile($Runbook.FullName, [ref]$null, [ref]$null);
        if ($AST.EndBlock -ne $null -and $AST.EndBlock.Extent.Text.ToLower().StartsWith("workflow"))
        {
            Write-Verbose "File is a PowerShell workflow"
            $RunbookType = "PowerShellWorkflow"
        }

        if ($AST.EndBlock -ne $null -and (!($AST.EndBlock.Extent.Text.ToLower().StartsWith("workflow"))))
        {
            Write-Verbose "File is a PowerShell script"
            $RunbookType = "PowerShell"
        }
    }

    # After determining the type of the runbook, import it into the Automation Account
    $ImportRunbook = Import-AzureRmAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
        -Path $Runbook.FullName -Type $RunbookType -Published -Force

        Write-Host "Runbook $Runbook has been imported to Automation Account"
}

Write-Host "Script 'ImportRunbook.ps1' completed"

