

function StandardLogging-End
{
    ###################################################################
    # StandardLogging-End
    ###################################################################

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage='Connection information')]
        [PSObject]$Connection,

        [Parameter(Mandatory=$false)]
        [Hashtable]$Properties = @{},

        [Parameter(Mandatory=$false)]
        [System.String]$Filters = ''
    )

    process
    {
        $inputProperties = @{}
        $inputProperties += $Properties
        $inputProperties['SQL Trusted Connection'] = $Connection.SQLTrustedConnection
        $inputProperties['SQL Server Name'] = $Connection.SQLServerName
        $inputProperties['SQL Server Database'] = $Connection.SQLServerDatabase
        $inputProperties['SQL User ID'] = $Connection.SQLUserID
        $inputProperties['SQL Password'] = $Connection.SQLPassword
        $inputProperties['File System Output Enabled'] = $Connection.FileSystemOutputEnabled

        $assemblyName = 'StandardLogging.dll'
        $className = 'StandardLogging.EndLog'

        Invoke-OrchestratorActivity -AssemblyName $assemblyName -ClassName $className -Properties $inputProperties -Filters $Filters
    }
}

function StandardLogging-Failure
{
    ###################################################################
    # StandardLogging-Failure
    ###################################################################

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage='Connection information')]
        [PSObject]$Connection,

        [Parameter(Mandatory=$false)]
        [Hashtable]$Properties = @{},

        [Parameter(Mandatory=$false)]
        [System.String]$Filters = ''
    )

    process
    {
        $inputProperties = @{}
        $inputProperties += $Properties
        $inputProperties['SQL Trusted Connection'] = $Connection.SQLTrustedConnection
        $inputProperties['SQL Server Name'] = $Connection.SQLServerName
        $inputProperties['SQL Server Database'] = $Connection.SQLServerDatabase
        $inputProperties['SQL User ID'] = $Connection.SQLUserID
        $inputProperties['SQL Password'] = $Connection.SQLPassword
        $inputProperties['File System Output Enabled'] = $Connection.FileSystemOutputEnabled

        $assemblyName = 'StandardLogging.dll'
        $className = 'StandardLogging.FailureLog'

        Invoke-OrchestratorActivity -AssemblyName $assemblyName -ClassName $className -Properties $inputProperties -Filters $Filters
    }
}

function Get-StandardLoggingLogData
{
    ###################################################################
    # Get-StandardLoggingLogData
    ###################################################################

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage='Connection information')]
        [PSObject]$Connection,

        [Parameter(Mandatory=$false)]
        [Hashtable]$Properties = @{},

        [Parameter(Mandatory=$false)]
        [System.String]$Filters = ''
    )

    process
    {
        $inputProperties = @{}
        $inputProperties += $Properties
        $inputProperties['SQL Trusted Connection'] = $Connection.SQLTrustedConnection
        $inputProperties['SQL Server Name'] = $Connection.SQLServerName
        $inputProperties['SQL Server Database'] = $Connection.SQLServerDatabase
        $inputProperties['SQL User ID'] = $Connection.SQLUserID
        $inputProperties['SQL Password'] = $Connection.SQLPassword
        $inputProperties['File System Output Enabled'] = $Connection.FileSystemOutputEnabled

        $assemblyName = 'StandardLogging.dll'
        $className = 'StandardLogging.GetLogData'

        Invoke-OrchestratorActivity -AssemblyName $assemblyName -ClassName $className -Properties $inputProperties -Filters $Filters
    }
}

function StandardLogging-Restart
{
    ###################################################################
    # StandardLogging-Restart
    ###################################################################

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage='Connection information')]
        [PSObject]$Connection,

        [Parameter(Mandatory=$false)]
        [Hashtable]$Properties = @{},

        [Parameter(Mandatory=$false)]
        [System.String]$Filters = ''
    )

    process
    {
        $inputProperties = @{}
        $inputProperties += $Properties
        $inputProperties['SQL Trusted Connection'] = $Connection.SQLTrustedConnection
        $inputProperties['SQL Server Name'] = $Connection.SQLServerName
        $inputProperties['SQL Server Database'] = $Connection.SQLServerDatabase
        $inputProperties['SQL User ID'] = $Connection.SQLUserID
        $inputProperties['SQL Password'] = $Connection.SQLPassword
        $inputProperties['File System Output Enabled'] = $Connection.FileSystemOutputEnabled

        $assemblyName = 'StandardLogging.dll'
        $className = 'StandardLogging.RestartRunbook'

        Invoke-OrchestratorActivity -AssemblyName $assemblyName -ClassName $className -Properties $inputProperties -Filters $Filters
    }
}

function StandardLogging-Start
{
    ###################################################################
    # StandardLogging-Start
    ###################################################################

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage='Connection information')]
        [PSObject]$Connection,

        [Parameter(Mandatory=$false)]
        [Hashtable]$Properties = @{},

        [Parameter(Mandatory=$false)]
        [System.String]$Filters = ''
    )

    process
    {
        $inputProperties = @{}
        $inputProperties += $Properties
        $inputProperties['SQL Trusted Connection'] = $Connection.SQLTrustedConnection
        $inputProperties['SQL Server Name'] = $Connection.SQLServerName
        $inputProperties['SQL Server Database'] = $Connection.SQLServerDatabase
        $inputProperties['SQL User ID'] = $Connection.SQLUserID
        $inputProperties['SQL Password'] = $Connection.SQLPassword
        $inputProperties['File System Output Enabled'] = $Connection.FileSystemOutputEnabled

        $assemblyName = 'StandardLogging.dll'
        $className = 'StandardLogging.StartLog'

        Invoke-OrchestratorActivity -AssemblyName $assemblyName -ClassName $className -Properties $inputProperties -Filters $Filters
    }
}

function StandardLogging-Success
{
    ###################################################################
    # StandardLogging-Success
    ###################################################################

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage='Connection information')]
        [PSObject]$Connection,

        [Parameter(Mandatory=$false)]
        [Hashtable]$Properties = @{},

        [Parameter(Mandatory=$false)]
        [System.String]$Filters = ''
    )

    process
    {
        $inputProperties = @{}
        $inputProperties += $Properties
        $inputProperties['SQL Trusted Connection'] = $Connection.SQLTrustedConnection
        $inputProperties['SQL Server Name'] = $Connection.SQLServerName
        $inputProperties['SQL Server Database'] = $Connection.SQLServerDatabase
        $inputProperties['SQL User ID'] = $Connection.SQLUserID
        $inputProperties['SQL Password'] = $Connection.SQLPassword
        $inputProperties['File System Output Enabled'] = $Connection.FileSystemOutputEnabled

        $assemblyName = 'StandardLogging.dll'
        $className = 'StandardLogging.SuccessLog'

        Invoke-OrchestratorActivity -AssemblyName $assemblyName -ClassName $className -Properties $inputProperties -Filters $Filters
    }
}

function StandardLogging-Warning
{
    ###################################################################
    # StandardLogging-Warning
    ###################################################################

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage='Connection information')]
        [PSObject]$Connection,

        [Parameter(Mandatory=$false)]
        [Hashtable]$Properties = @{},

        [Parameter(Mandatory=$false)]
        [System.String]$Filters = ''
    )

    process
    {
        $inputProperties = @{}
        $inputProperties += $Properties
        $inputProperties['SQL Trusted Connection'] = $Connection.SQLTrustedConnection
        $inputProperties['SQL Server Name'] = $Connection.SQLServerName
        $inputProperties['SQL Server Database'] = $Connection.SQLServerDatabase
        $inputProperties['SQL User ID'] = $Connection.SQLUserID
        $inputProperties['SQL Password'] = $Connection.SQLPassword
        $inputProperties['File System Output Enabled'] = $Connection.FileSystemOutputEnabled

        $assemblyName = 'StandardLogging.dll'
        $className = 'StandardLogging.WarningLog'

        Invoke-OrchestratorActivity -AssemblyName $assemblyName -ClassName $className -Properties $inputProperties -Filters $Filters
    }
}

