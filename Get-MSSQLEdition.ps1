<#
.SYNOPSIS
  Ermittelt Edition und Version von MSSQL auf dem angegebenen Computer.

.DESCRIPTION
  Ermittelt Edition und Version aller Instanzen von MSSQL auf dem angegebenen Computer über Abfrage entsprechender Registry-Werte.

.EXAMPLE
  Get-MSSQLEdition -Computer SQL01

.EXAMPLE
  $ListOfSQLServers | Get-MSSQLEdition

.NOTES
  Version : 1.0
  Datum   : 2015-09-15
  Autor   : Frank Peter Schultze
#>
function Get-MSSQLEdition
{
  [CmdletBinding()]
  Param
  (
    # Gibt den Computernamen des MSSQL Servers an.
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [String]
    $ComputerName
  )

  Begin
  {
    $ErrorActionPreference = 'Stop'

    $RegKey = 'SOFTWARE\\Microsoft\\Microsoft SQL Server'
  }

  Process
  {
    try
    {
      Write-Verbose 'Verbinden mit Registry'
      $HKLM = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)

      Write-Verbose 'Ermitteln der installierten MSSQL-Instanzen'
      $InstalledInstances = ($HKLM.OpenSubKey($RegKey)).GetValue('InstalledInstances')

      foreach ($Instance in $InstalledInstances)
      {
        Write-Verbose "MSSQL-Instanz: $Instance"
        $p = ($HKLM.OpenSubKey("$RegKey\\Instance Names\\SQL")).GetValue($Instance)

        Write-Verbose 'Ermitteln der Edition'
        $Edition = ($HKLM.OpenSubKey("$RegKey\\$p\\Setup")).GetValue('Edition')

        Write-Verbose 'Ermitteln der Version'
        $Version = ($HKLM.OpenSubKey("$RegKey\\$p\\Setup")).GetValue('Version')

        New-Object -TypeName psobject -Property @{
          ComputerName = $ComputerName
          Edition = $Edition
          Version = $Version
        }
      }
    }
    catch
    {
      $_
    }
  }
}
