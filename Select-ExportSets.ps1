$Exportsets = Get-ChildItem C:\testfiles\Ex_ConfigExport -directory |
  select -expand fullname | 
  Out-GridView -OutputMode Multiple -Title "Select two export sets to compare."

If ($Exportsets.count -ne 2)
  {
    Write-Warning "Select two (and only two) export sets to compare"
    Return
  }

 $changes =  C:\scripts\Ex_Backup\Compare-ExportSets.ps1 $Exportsets[0] $Exportsets[1]

 $changes
