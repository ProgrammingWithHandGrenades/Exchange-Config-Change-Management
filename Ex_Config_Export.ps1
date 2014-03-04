

$su = get-credential

$Target_Directory = 'C:\testfiles\Ex_ConfigExport'
$ExchangeServer = '006Exch-MBV1'

$SessionParams = 
   @{
     ConfigurationName = 'MicroSoft.Exchange'
     ConnectionURI     = "http://$ExchangeServer/powershell/"
     Authentication    = 'Kerberos'
     ErrorAction       = 'Stop'
     Credential        = $su
    }

$ExSession = New-PSSession @SessionParams

$Ex_Object_Folders = 
   @{
     Server =    @(
                    'MailboxServer',
                    'TransportServer',
                    'ClientAccessServer',
                    'UMServer'
                   )

     UM =        @(
                    'UMDialPlan'
                    'UMAutoAttendant'
                    'UMIPGateway'
                    'UMHuntGroup'
                   )

     Transport = @(
                    'TransportRule',
                    'JournalRule',
                    'SendConnector',
                    'ReceiveConnector',
                    'ForeignConnector',
                    'RoutingGroupConnector',
                    'AcceptedDomain',
                    'RemoteDomain'
                   )

     Database =   @(
                     'MailboxDatabase',
                     'PublicFolderDatabase',
                     'DatabaseAvailabilityGroup'
                   )

     Policy =     @(
                     'ActiveSyncMailboxPolicy',
                     'AddressBookPolicy',
                     'EmailAddressPolicy',
                     'ManagedFolderMailboxPolicy',
                     'OwaMailboxPolicy',
                     'RetentionPolicy',
                     'RetentionPolicyTag',
                     'RoleAssignmentPolicy',
                     'SharingPolicy',
                     'ThrottlingPolicy',
                     'UMMailboxPolicy'
                    )
    }
     
#Export set folder creation

$DirParams = @{
                ItemType    =  'Directory'
                Verbose     =  $true
                ErrorAction =  'Stop'
              }

Write-Verbose "Checking target root folder"
if ( -not ( Test-Path $Target_Directory ) )
  { New-Item  @DirParams -Path $Target_Directory }

$Export_Set = (get-date).tostring('yyyy-MM-dd_HH.mm.ss')

$Export_Set_Path = "$Target_Directory\$Export_Set"
Write-Verbose "Creating folder for this export set ($Export_Set)"
New-Item  @DirParams -Path $Export_Set_Path 

Write-Verbose "Exporting Exchange configuration objects"

foreach ($Ex_Object_Folder in $Ex_Object_Folders.keys)
   {
    $Ex_Object_Folder_Path = "$Export_Set_Path\$Ex_Object_Folder"
    New-Item @DirParams -Path $Ex_Object_Folder_Path

    foreach ( $Ex_Object_Type in $Ex_Object_Folders.$Ex_Object_Folder )
       {
        $Ex_Object_Type_Path = "$Ex_Object_Folder_Path\$Ex_Object_Type"
        New-Item @DirParams -Path $Ex_Object_Type_Path

        $SB = [ScriptBlock]::Create("Get-$Ex_Object_Type")
        Invoke-Command -ScriptBlock $SB -Session $ExSession |
          foreach {
             $_ | Export-Clixml "$Ex_Object_Type_Path\$($_.guid).clixml" -Verbose
           }
       }
   }
  Remove-PSSession $ExSession         
        


   