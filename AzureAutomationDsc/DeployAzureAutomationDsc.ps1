param (
    [string][Parameter(Mandatory=$true)]$ConnectedServiceName,
    [string][Parameter(Mandatory=$true)]$ResourceGroupName,
    [string][Parameter(Mandatory=$true)]$AutomationAccountName,
    [string][Parameter(Mandatory=$false)]$ConfigurationFromArtifacts,
    [string][Parameter(Mandatory=$false)]$ConfigurationFromAutomation,
    [string][Parameter(Mandatory=$false)]$AutomationDscConfiguration = $null,
    [string][Parameter(Mandatory=$false)]$DscConfigurationFile = $null,
    [string][Parameter(Mandatory=$False)]$DscStorageAccountName,
    [string][Parameter(Mandatory=$false)]$CompileArtifactConfiguration,
    [string][Parameter(Mandatory=$false)]$CompileAutomationConfiguration,
    [string][Parameter(Mandatory=$false)]$DscParametersFile = $null,
    [string][Parameter(Mandatory=$false)]$DscConfigurationDataFile = $null,
    [string][Parameter(Mandatory=$false)]$DscNodes
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

if ($AutomationDscConfiguration -and (-not($DscConfigurationFile) -or (-not($DscConfigurationFile.Split('.')[-1] -match "ps1")))) {
    if ($CompileAutomationConfiguration -eq "true") {
        & ".\CompileDscConfiguration.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName -AADscConfiguration $AutomationDscConfiguration -ParametersFile $DscParametersFile `
        -ConfigurationDataFile $DscConfigurationDataFile -DscNodeNames $DscNodes
    }
}

elseif ($DscConfigurationFile -and (-not($AutomationDscConfiguration))) {
    if ($DscStorageAccountName) {
        & ".\ImportDscConfiguration.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName -DscConfigurationPath $DscConfigurationFile -StorageAccountName $DscStorageAccountName
    }
    else {
        & ".\ImportDscConfiguration.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName -DscConfigurationPath $DscConfigurationFile
    }
    if ($CompileArtifactConfiguration -eq "true") {
        & ".\CompileDscConfiguration.ps1" -ConnectedServiceName $ConnectedServiceName -ResourceGroupName $ResourceGroupName `
        -AutomationAccountName $AutomationAccountName -DscConfigurationFile $DscConfigurationFile -ParametersFile $DscParametersFile `
        -ConfigurationDataFile $DscConfigurationDataFile -DscNodeNames $DscNodes
    }
}

elseif ($AutomationDscConfiguration -and ($DscConfigurationFile -and ($DscConfigurationFile -ne "D:\a\r1\a"))) {
    Throw "Go back and check task parameters. You cannot specify both a configuration from the Automation Account and a configuration from build artifacts"
}


