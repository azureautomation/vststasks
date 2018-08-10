Configuration ComplexConfiguration 
{
    param (
	[Parameter(Mandatory=$false)]
        [string[]]$ComputerName = "localhost"
    )

    Import-DscResource -ModuleName xWebAdministration

    Node $ComputerName 
    {
        WindowsFeature MyFeatureInstance {
            Ensure = 'Present'
            Name = 'RSAT'
        }
        WindowsFeature My2ndFeatureInstance {
            Ensure = 'Present'
            Name = 'Bitlocker'
        }
    }

    Node $AllNodes.Where{$_.Role -eq "WebServer"}.NodeName
    {
        xWebsite Site
        {
            Name = $Node.SiteName
            PhysicalPath = $Node.SiteContents
            Ensure   = "Present"
        }
    }
}
