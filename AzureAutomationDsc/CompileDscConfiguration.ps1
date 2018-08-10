param (
    [string][Parameter(Mandatory=$true)]$ConnectedServiceName,
    [string][Parameter(Mandatory=$true)]$ResourceGroupName,
    [string][Parameter(Mandatory=$true)]$AutomationAccountName,
    [string][Parameter(Mandatory=$False)]$DscConfigurationFile = $null,
    [string][Parameter(Mandatory=$False)]$AADscConfiguration = $null,
    [string][Parameter(Mandatory=$False)]$ParametersFile = $null,
    [string][Parameter(Mandatory=$False)]$ConfigurationDataFile = $null,
    [string][Parameter(Mandatory=$False)]$DscNodeNames
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "Executing script 'CompileDscConfiguration' from: https://github.com/azureautomation/vststasks/tree/master/AzureAutomationDsc"

$ConfigurationData = @{}
$ConfigurationParameters = @{}
$ConfigurationName = ""
$CompilationJob = ""

# Check if user provided a configuration that is already in the Automation Account
if ($AADscConfiguration)
{
    $ConfigurationName = $AADscConfiguration
}

# Check if the user provided a new configuration not already in Automation and needs to be imported first
elseif ($DscConfigurationFile -and (-not($AADscConfiguration))) 
{
    $ConfigurationName = [System.IO.Path]::GetFileNameWithoutExtension($DscConfigurationFile)   
}

# Get the required parameters for the configuration by checking if the parameters file is json
if ($ParametersFile.Split('.')[-1] -match "json") 
{
    $ConfigParams = @{}
    $ConfigurationParameters = @{}
    $Parameters = Get-Content -Path $ParametersFile -Raw 
    (ConvertFrom-Json $Parameters).psobject.properties | ForEach-Object { $ConfigParams[$_.Name] = $_.Value } 
    foreach ($Param in $ConfigParams.Keys) 
    {
        if ($ConfigurationParameters[$Param] -eq $null) 
        {
            $ConfigurationParameters.Add($Param, $ConfigParams[$Param])
        }
    }
}

# Get the required parameters for the configuration by checking if the parameters file is psd1
elseif ($ParametersFile.Split('.')[-1] -match "psd1") 
{
    $ConfigurationParameters = Import-PowerShellDataFile -Path $ParametersFile
}

# Get the configuration data for the configuration
if ($ConfigurationDataFile.Split('.')[-1] -match "psd1") {
    $ConfigurationData = Import-PowerShellDataFile -Path $ConfigurationDataFile
}

# If the user provides a configuration that requires both parameters and configuration data 
if ((($ParametersFile.Split('.')[-1] -match "psd1") -or ($ParametersFile.Split('.')[-1] -match "json")) -and ($ConfigurationDataFile.Split('.')[-1] -match "psd1")) 
{ 
    $CompilationJob = Start-AzureRmAutomationDscCompilationJob -ConfigurationName $ConfigurationName -ConfigurationData $ConfigurationData `
    -Parameters $ConfigurationParameters -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName
}

# If the user provides a configuration that only requires configuration data
elseif (((($ParametersFile.Split('.')[-1] -match "psd1") -eq $false) -and (($ParametersFile.Split('.')[-1] -match "json") -eq $false)) -and ($ConfigurationDataFile.Split('.')[-1] -match "psd1")) 
{
    $CompilationJob = Start-AzureRmAutomationDscCompilationJob -ConfigurationName $ConfigurationName -ConfigurationData $ConfigurationData `
    -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName
}

# If the user provides a configuration that requires only parameters
elseif ((($ParametersFile.Split('.')[-1] -match "psd1") -or ($ParametersFile.Split('.')[-1] -match "json")) -and (($ConfigurationDataFile.Split('.')[-1] -match "psd1") -eq $false)) 
{
    $CompilationJob = Start-AzureRmAutomationDscCompilationJob -ConfigurationName $ConfigurationName -Parameters $ConfigurationParameters `
    -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName
}

# If the user provides a simple configuration that doesn't require parameters or configuration data
else
{
    $CompilationJob = Start-AzureRmAutomationDscCompilationJob -ConfigurationName $ConfigurationName `
    -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName
}

Write-Host "Compilation job of configuration '$ConfigurationName' started"

# Wait to make sure the configuration compilation was successful
$Timeout = 180
while (($CompilationJob.Status -ne "Completed") -and ($CompilationJob.Status -ne "Suspended") -and ($Timeout -gt 0))
{
     $CompilationJob = $CompilationJob | Get-AzureRmAutomationDscCompilationJob
     Start-Sleep -Seconds 5
     $Timeout = $Timeout - 5
}

if ($CompilationJob.Status -ne "Completed") {
    Throw "Compilation suspended or failed to complete"
}

Write-Host "Configuration compilation job completed"

# Apply the DSC configuration if nodes are specified
if ($DscNodeNames)
{
    # If multiple node configurations were generated, get all of them
    $ConfigurationMetadata = Get-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName -ConfigurationName $ConfigurationName
    $CompiledMofs = @()

    foreach ($Metadata in $ConfigurationMetadata)
    {
        $CompiledMofs += ,($Metadata.Name)
    }

    $NodeNames = $DscNodeNames -Split ","

    foreach ($NodeName in $NodeNames)
    {
        $Id = [GUID](Get-AzureRmAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
             | Where {$_.Name -eq $NodeName} | Select Id | Format-Table -HideTableHeaders | out-string)

        # If node configurations with VM name extensions were generated, assign configurations to those VMs
        if ($CompiledMofs.Contains("$ConfigurationName.$NodeName"))
        {
            $NodeConfiguration = $ConfigurationName + "." + $NodeName
            Set-AzureRmAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
                -NodeConfigurationName $NodeConfiguration -Id $Id -Force

             Write-Host "Assigning node configuration $NodeConfiguration to $NodeName"
        }

        # If node configurations were not generataed for specific VMs, don't assign
        else
        {
             Write-Host "A specific node configuration for the node: $NodeName was not generated. Therefore this node was not assigned a configuration"
             Write-Host "Adjust your configuration to generate a node configuration with the node's name present in the node configuration name"
        }
    }

    foreach ($NodeName in $NodeNames) 
    {
        # Check to make sure the configuration was successfully applied to the VM
        $Id = [GUID](Get-AzureRmAutomationDscNode -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
             | Where {$_.Name -eq $NodeName} | Select Id | Format-Table -HideTableHeaders | out-string)
        $Node = Get-AzureRmAutomationDscNode -AutomationAccountName $AutomationAccountName `
        -ResourceGroupName $ResourceGroupName -NodeId $Id 

        if ($Node.Status -eq "Compliant") {
            Write-Host "Configuration successfully applied to Node: $NodeName. Node is compliant"
            continue
        }

        while ($Node.Status -eq "Pending") 
        {
            Start-Sleep -Seconds 10 
            $Node = Get-AzureRmAutomationDscNode -AutomationAccountName $AutomationAccountName `
                    -ResourceGroupName $ResourceGroupName -NodeId $Id 
            if ($Node.Status -eq "Failed")
            {
                Throw "Failed to apply configuration to node: $NodeName"
            }
            elseif ($Node.Status -eq "Compliant")
            {
                Write-Host "Configuration successfully applied to Node: $NodeName. Node is compliant"
            }
        } 
    }
}

Write-Host "Script 'CompileDscConfiguration.ps1' completed"



