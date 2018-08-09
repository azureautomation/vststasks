Configuration SimpleConfiguration 
{
    param(
        [Parameter(Mandatory=$false)]
        [string] $FeatureName = "MyFeature",

        [Parameter(Mandatory=$false)]
        [boolean] $IsPresent = $false
    )

    $EnsureString = "Present"
    if($IsPresent -eq $false)
    {
        $EnsureString = "Absent"
    }

    Node "sample"
    {
        WindowsFeature ($FeatureName + "Feature")
        {
            Ensure = $EnsureString
            Name = $FeatureName
        }
    }
}