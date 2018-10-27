
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$ConnectedServiceName = Get-VstsInput -Name ConnectedServiceName
$ResourceGroupName = Get-VstsInput -Name ResourceGroupName
$AutomationAccountName = Get-VstsInput -Name AutomationAccountName
$Location = Get-VstsInput -Name Location
$CreateRunAs = Get-VstsInput -Name CreateRunAs

# Get credentials from service connection for Azure
$endpoint = Get-VstsEndpoint -Name $ConnectedServiceName 
$Credentials = $endpoint.Auth.Parameters

# Log into Azure with the service connection information
$SecurePassword = ConvertTo-SecureString $Credentials.serviceprincipalkey -AsPlainText -Force
$AzureCreds = New-Object System.Management.Automation.PSCredential ($Credentials.serviceprincipalid, $SecurePassword)
Login-AzureRmAccount -Credential $AzureCreds -TenantId $Credentials.tenantid -ServicePrincipal

# Create new resoruce group if it doesn't exist.
$ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if ($Null -eq $ResourceGroup)
{
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
}

# Create automation account if it doesn't exist
$Account = Get-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName -ErrorAction SilentlyContinue
if ($Null -eq $Account)
{
    New-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName `
                    -Name $AutomationAccountName -Location $Location
}

# If RunAs is specified, create the Azure Automation RunAs. The service principal must have read access on the Azure AD directory
# for this to work. You can add this permission by clicking on the Manage Service Principal from the serivce connection page.
if ($CreateRunAs -eq "true")
{
    $SelfSignedCertPlainPassword = (New-Guid).Guid
    $SelfSignedCertNoOfMonthsUntilExpired = 12
    $ApplicationDisplayName = $AutomationAccountName + $ResourceGroupName + $Location.replace(' ','')
    function CreateSelfSignedCertificate([string] $certificateName, [string] $selfSignedCertPlainPassword,
        [string] $certPath, [string] $certPathCer, [string] $selfSignedCertNoOfMonthsUntilExpired ) {
        $Cert = New-SelfSignedCertificate -DnsName $certificateName -CertStoreLocation Cert:\LocalMachine\My `
            -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
            -NotBefore (Get-Date).AddDays(-1) -NotAfter (Get-Date).AddMonths($selfSignedCertNoOfMonthsUntilExpired) -HashAlgorithm SHA256

        $CertPassword = ConvertTo-SecureString $selfSignedCertPlainPassword -AsPlainText -Force
        Export-PfxCertificate -Cert ("Cert:\LocalMachine\My\" + $Cert.Thumbprint) -FilePath $certPath -Password $CertPassword -Force | Write-Verbose
        Export-Certificate -Cert ("Cert:\LocalMachine\My\" + $Cert.Thumbprint) -FilePath $certPathCer -Type CERT | Write-Verbose
    }

    function CreateServicePrincipal([System.Security.Cryptography.X509Certificates.X509Certificate2] $PfxCert, [string] $applicationDisplayName) {  
        
        $Application = Get-AzureRmADApplication -DisplayName $applicationDisplayName | Select-Object -First 1
        if ($null -eq $Application)
        {
            $keyValue = [System.Convert]::ToBase64String($PfxCert.GetRawCertData())
            $keyId = $applicationDisplayName

            Write-Host "Creating AD application"
            #Create an Azure AD application, AD App Credential, AD ServicePrincipal
            $Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage ("http://" + $applicationDisplayName) -IdentifierUris ("http://" + $keyId) 
            Write-Host "Creating AD application credential"
            $ApplicationCredential = New-AzureRmADAppCredential -ApplicationId $Application.ApplicationId -CertValue $keyValue -StartDate $PfxCert.NotBefore -EndDate $PfxCert.NotAfter
            Write-Host "Creating service principal"
            $ServicePrincipal = New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId 
            $GetServicePrincipal = Get-AzureRmADServicePrincipal -ObjectId $ServicePrincipal.Id
        }
        # Sleep here for a few seconds to allow the service principal application to become active (ordinarily takes a few seconds)
        Start-Sleep -s 15
        Write-Host "Creating role assignment"
        $Retries = 0;
        While ($Retries -le 3) {
            try {
                New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId -ErrorAction Stop
            }
            catch
            {
                if ($_.Exception.Message -match "The role assignment already exists.")
                {
                    break
                }
                $Retries++
            }
        }
        if ($Retries -eq 3)
        {
            New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId
        }  
        $Application.ApplicationId.ToString();
    }

    function CreateAutomationCertificateAsset ([string] $resourceGroup, [string] $automationAccountName, [string] $certifcateAssetName, [string] $certPath, [string] $certPlainPassword, [Boolean] $Exportable) {
        $CertPassword = ConvertTo-SecureString $certPlainPassword -AsPlainText -Force   
        Remove-AzureRmAutomationCertificate -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $certifcateAssetName -ErrorAction SilentlyContinue
        New-AzureRmAutomationCertificate -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Path $certPath -Name $certifcateAssetName -Password $CertPassword -Exportable:$Exportable  | write-verbose
    }

    function CreateAutomationConnectionAsset ([string] $resourceGroup, [string] $automationAccountName, [string] $connectionAssetName, [string] $connectionTypeName, [System.Collections.Hashtable] $connectionFieldValues ) {
        Remove-AzureRmAutomationConnection -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $connectionAssetName -Force -ErrorAction SilentlyContinue
        New-AzureRmAutomationConnection -ResourceGroupName $ResourceGroup -AutomationAccountName $automationAccountName -Name $connectionAssetName -ConnectionTypeName $connectionTypeName -ConnectionFieldValues $connectionFieldValues
    }

    # Create a Run As account by using a service principal
    $CertifcateAssetName = "AzureRunAsCertificate"
    $ConnectionAssetName = "AzureRunAsConnection"
    $ConnectionTypeName = "AzureServicePrincipal"
    $CertificateName = $AutomationAccountName + $CertifcateAssetName
    $PfxCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".pfx")
    $PfxCertPlainPasswordForRunAsAccount = $SelfSignedCertPlainPassword
    $CerCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".cer")
    
    Write-Host "Creating certificate"
    CreateSelfSignedCertificate $CertificateName $PfxCertPlainPasswordForRunAsAccount $PfxCertPathForRunAsAccount $CerCertPathForRunAsAccount $SelfSignedCertNoOfMonthsUntilExpired

    Write-Host "Creating service principal"
    $PfxCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($PfxCertPathForRunAsAccount, $PfxCertPlainPasswordForRunAsAccount)
    $ApplicationId = CreateServicePrincipal $PfxCert $ApplicationDisplayName

    Write-Host "Creating certificate asset"
    CreateAutomationCertificateAsset $ResourceGroupName $AutomationAccountName $CertifcateAssetName $PfxCertPathForRunAsAccount $PfxCertPlainPasswordForRunAsAccount $true

    # Populate the ConnectionFieldValues
    $SubscriptionInfo = Get-AzureRmContext
    $TenantID = $SubscriptionInfo.Tenant
    $Thumbprint = $PfxCert.Thumbprint
    $ConnectionFieldValues = @{"ApplicationId" = $ApplicationId; "TenantId" = $TenantID; "CertificateThumbprint" = $Thumbprint; "SubscriptionId" = $SubscriptionInfo.Subscription }

    Write-Host "Creating Connection asset"
    # Create an Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal.
    CreateAutomationConnectionAsset $ResourceGroupName $AutomationAccountName $ConnectionAssetName $ConnectionTypeName $ConnectionFieldValues
}