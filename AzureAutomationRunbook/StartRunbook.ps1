param (
    [string][Parameter(Mandatory=$true)]$ConnectedServiceName,
    [string][Parameter(Mandatory=$true)]$ResourceGroupName,
    [string][Parameter(Mandatory=$true)]$AutomationAccountName,
    [string][Parameter(Mandatory=$False)]$RunbookName = $null,
    [string][Parameter(Mandatory=$False)]$RunOn = $null,
    [string][Parameter(Mandatory=$False)]$RunbookParameters = $null,
    [string][Parameter(Mandatory=$False)]$RunbookParametersFile = $null,
    [string][Parameter(Mandatory=$False)]$RunbookParametersInJson = $null
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "Executing script 'StartRunbook.ps1' from: https://github.com/azureautomation/vststasks/tree/master/AzureAutomationRunbook"

# Get runbook parameters from parameters file or editor text box
$Parameters = @{}
if ($RunbookParameters -ne "RunbookParametersInJson")
{
    if ($RunbookParametersFile.Split('.')[-1] -match "json")
    {
        $ParametersFile = @{}
        # Read json file passed in for the parameters
        $RunbookParameters = Get-Content -Path $RunbookParametersFile -Raw

        # Create a hash table from the json values passed in
        (ConvertFrom-Json $RunbookParameters).psobject.properties | ForEach-Object { $ParametersFile[$_.Name] = $_.Value }

        # Add in the parameters to the list if they don't already exist.
        foreach ($Param in $ParametersFile.Keys)
        {
            if ($Parameters[$Param] -eq $null)
            {
                $Parameters.Add($Param, $ParametersFile[$Param])
            }
        }
    }
}
else {
    if ($null -ne $RunbookParametersInJson)
    {
        $Parameters = ConvertFrom-Json $RunbookParametersInJson
    }
}
# Start the runbook checking if parameters are provided and hybrid worker is specified
if ($Parameters.Count -gt 0)
{
    if ($RunOn -eq $null -or $RunOn -eq "Azure")
    {
        $RunbookJob = Start-AzureRMAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
                                        -Name $RunbookName -Parameters $Parameters
    }
    else
    {
        $RunbookJob = Start-AzureRMAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
                                        -Name $RunbookName -Parameters $Parameters -RunOn $RunOn 
    }
}

else
{
    if ($RunOn -eq $null -or $RunOn -eq "Azure")
    {
        $RunbookJob = Start-AzureRMAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
                                        -Name $RunbookName
    }
    else
    {
        $RunbookJob = Start-AzureRMAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
                                        -Name $RunbookName -RunOn $RunOn
    }
}

Write-Host "Job for runbook: $RunbookName has been successfully started in Automation Account"

$Job = Get-AzureRmAutomationJob -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Id $RunbookJob.JobId

while (($Job.Status -eq "Queued") -or ($Job.Status -eq "Starting") -or ($Job.Status -eq "New") -or ($Job.Status -eq "Running") -or ($Job.Status -eq "Activating")) 
{
    Start-Sleep -Seconds 5
    $Job = $Job | Get-AzureRmAutomationJob
    if ($Job.Status -eq "Failed")
    {
        $Stream = (Get-AzureRmAutomationJobOutput -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
                -Id $RunbookJob.JobId -Stream Error) | Get-AzureRmAutomationJobOutputRecord
        Write-Host "Job Failed: $($Stream.Summary)"
        Throw $Error
    }

    elseif ($Job.Status -eq "Completed")
    {
        $Stream = (Get-AzureRmAutomationJobOutput -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
                -Id $RunbookJob.JobId -Stream Output) | Get-AzureRmAutomationJobOutputRecord
        Write-Host "Job Completed: $($Stream.Summary)"
        # Populate output variable with result so it can be used in other tasks.
        Write-Host "##vso[task.setVariable variable=jobOutput]$($Stream.Summary)"
    }

    elseif (($Job.Status -eq "Stopped") -or ($Job.Status -eq "Suspended"))
    {
        $Stream = (Get-AzureRmAutomationJobOutputRecord -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
                -Id $RunbookJob.JobId -Stream Any) | Get-AzureRmAutomationJobOutputRecord
        Write-Host "Job has been Stopped or Suspended: $($Stream.Summary)"
        Throw $Error
    }
}

Write-Host "Script 'StartRunbook.ps1' completed"