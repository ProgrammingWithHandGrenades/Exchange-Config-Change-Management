
 <#
 .Synopsis
    Compare two export object sets
 .DESCRIPTION
    Compares deserialized objects from two directories of .clixml files.
 
 #>
     [CmdletBinding()]

     Param
     (
         # First export object set directory
         [Parameter(Mandatory=$true)]
         $ExportSetPath1,
 
         # Second export object set directory
         [Parameter(Mandatory=$true)]
         $ExportSetPath2
     )
 
     Begin
     {
       
      $CompareSetTimestamps = Get-Item $ExportSetPath1,$ExportSetPath2 |
       Select FullName,LastWriteTime |
       Sort LastWriteTime

      $ReferenceSetPath  = $CompareSetTimestamps[0].FullName
      $DifferenceSetPath = $CompareSetTimestamps[1].FullName

      $ExcludedProperties = @(
                              'PSShowComputerName',
                              'RunspaceId',
                              'OriginatingServer',
                              'WhenChanged'
                              )

      $ExcludeRegex = [regex]($ExcludedProperties -join '|')

     }
     Process
     {
     }
     End
     {
      $ReferenceSetFolders =
         Get-ChildItem $ReferenceSetPath -Directory

      Write-Verbose "Found $($ReferenceSetFolders.count) Export set folders"

      foreach ( $ReferenceSetFolder in $ReferenceSetFolders )
        { 
          Write-Verbose "***** Comparing $ReferenceSetFolder Objects*****`n"
 
          $ReferenceObjectTypeFolders =
           Get-ChildItem $ReferenceSetFolder.FullName -Directory

          foreach ( $ReferenceObjectTypeFolder in  $ReferenceObjectTypeFolders )
            {
              Write-Verbose "     *****Comparing  $ReferenceObjectTypeFolder Objects*****`n"
            
              $ReferenceObjectFiles = 
                Get-ChildItem $ReferenceObjectTypeFolder.FullName -File

              $DifferenceObjectTypeFolderPath = 
                       @(
                         $DifferenceSetPath,
                         $ReferenceSetFolder,
                         $ReferenceObjectTypeFolder
                         ) -join '\'

              $DifferenceObjectFiles = 
                Get-ChildItem $ReferenceObjectTypeFolder.FullName -File

              $AddedObjectFiles = 
                $DifferenceObjectFiles |
                Where { $ReferenceObjectFiles.name -notcontains $_.name }

              $DeletedObjectFiles = 
                $ReferenceObjectFiles |
                Where { $DifferenceObjectFiles.name -notcontains $_.name }

              $ComparedObjectFiles = 
              $ReferenceObjectFiles |
                Where { $DifferenceObjectFiles.name -Contains $_.name }

              foreach ( $ComparedObjectFile in $ComparedObjectFiles )
                {  
 
                  $DifferenceObjectFilePath = 
                    "$DifferenceObjectTypeFolderPath\$($ComparedObjectFile.Name)"

                  $DifferenceObject = Import-Clixml $DifferenceObjectFilePath

                  if ($DifferenceObject.WhenChanged -le $ComparedObjectFile.LastWriteTime)
                    { Continue }

                  Write-Verbose "   Change detected in $($ReferenceObjectTypeFolder.Name) $($DifferenceObject.Identity)"

                  $ReferenceObject = Import-Clixml $ComparedObjectFile.FullName

                  
                  Write-Debug "  Comparing properties of $($ReferenceObject.Identity)"
                  $Properties = 
                    $ReferenceObject.psobject.properties.name -notmatch $ExcludeRegex

                  foreach ( $Property in $Properties )
                    {
                      if ([string]$ReferenceObject.$Property -ne [string]$DifferenceObject.$Property)
                        {

                         Write-Verbose "    Found change in property $Property of $($ReferenceObjectTypeFolder.Name) $($ReferenceObject.Identity)`n"
                         Write-verbose "`n`nOld value = $($ReferenceObject.$Property)`n`nNew value = $($DifferenceObject.$Property)`n" 

                         [PSCustomObject]@{
                             Guid = $ReferenceObject.Guid
                             RefExportObjectPath = $ComparedObjectFile.FullName
                             DiffExportObjectPath = $DifferenceObjectFilePath
                             ObjectClass = $ReferenceObject.ObjectClass
                             Identity = $ReferenceObject.Identity
                             Property = $Property
                             RefWhenChanged = $ReferenceObject.WhenChanged
                             RefPropertyValue = $ReferenceObject.$Property
                             DiffWhenChanged = $DifferenceObject.WhenChanged
                             DiffPropertyValue = $DifferenceObject.$Property
                            }
                         
                        }

                  }#end property loop

              }#end object loop

           }#end  object type folder loop

      }#end export set folder loop

    }#end End block
