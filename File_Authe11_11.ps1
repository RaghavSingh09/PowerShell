





#  Set-ExecutionPolicy Unrestricted -Scope CurrentUser

 
  
  
 param($FolderPath,$Destination,$filenames,$UserName,$Password)


   
   
                                                          # Get current domain using logged-on user's credentials
 $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
 $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

 If ($domain.name -eq $null)
 {
      write-host "Authentication failed - please verify your username and password."
      exit                                               #terminate the script.
 }
 else
  { 
       write-host  "$UserName&$Password"                #"Successfully authenticated with domain $domain.name"

        foreach ($filename in $filenames) 
           {
              if (!(Test-Path $FolderPath\$filename)) 
                  {
                          #if the file is not there in either of the folder
                     Write-Host "NotExist"
                   } 
  
              else 
                   {
                       Write-Host "$filename"

                      if (!(Test-Path $Destination\$filename)) 
                      {
                         
                      Copy-Item $FolderPath'\'$filename -Destination $Destination
                         #Copy-Item  -Path $FolderPath'\'$filename $Destination -Recurse
                      }
                      else
                      {
                          Write-Host "$filename alrady exist in destination location"
                      }
                      
                                        
                   }
            }

  }


