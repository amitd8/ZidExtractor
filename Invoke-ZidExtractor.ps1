param(
    [string]$Scope,
    [string]$CSV
    )
 
# Check if arguments are provided
if (-not $Scope) {
    Write-Error "Usage: Invoke-ZidExtractor.ps1 -Scope 'AllUsers' or 'CurrentUser' or 'C:\your\path\to\dir' (None-Recursive) or 'C:\your\path\to\file'" -Category SyntaxError
    exit
}
 

if ($Scope -eq "AllUsers" ) {
    
    $Users = Get-ChildItem "$env:SystemDrive\\Users"
    # Loop through all users with user profile
    $o = "UserName, File, ReferalURL, HostURL"
    foreach ($User in $Users) 
    {
        #Locate Downloads folder
        
        $dfolder = "$env:SystemDrive\\Users\\$User\\Downloads"
        $downloadedFiles = Get-ChildItem -Recurse -File $dfolder 
        #For each download extract Zone identifier data stream 
        foreach ($file in $downloadedFiles)
        {
             $path = $file.FullName
             $zid = Get-Content $path -Stream Zone.Identifier -ErrorAction SilentlyContinue 
             $zidreferalUrl = $zid | sls -Pattern "ReferrerUrl=(.*)" | % {"$($_.matches.groups[1])"}
             $zidhost = $zid | sls -Pattern "HostUrl=(.*)" | % {"$($_.matches.groups[1])"}
             if ($zidreferalUrl -ne $null -and $zidhost -ne $null ){
                $o += "$User,$path,$zidreferalUrl,$zidhost"
         }
             
        }
     }
 }

 elseif ( $Scope -eq "CurrentUser")
 {
        $User = $env:USERNAME
        $o = "UserName, File, ReferalURL, HostURL"
        $dfolder = "$env:HOMEPATH\\Downloads"
        $downloadedFiles = Get-ChildItem -Recurse -File $dfolder
        #For each download extract Zone identifier data stream 
        foreach ($file in $downloadedFiles)
        {
             $path = $file.FullName
             $zid = Get-Content $path -Stream Zone.Identifier -ErrorAction SilentlyContinue 
             $zidreferalUrl = $zid | sls -Pattern "ReferrerUrl=(.*)" | % {"$($_.matches.groups[1])"}
             $zidhost = $zid | sls -Pattern "HostUrl=(.*)" | % {"$($_.matches.groups[1])"}
             if ($zidreferalUrl -ne $null -and $zidhost -ne $null ){
                $o += "$User,$path,$zidreferalUrl,$zidhost"
            }
             #Add-Content -Value $User","$env:HOMEDRIVE\$dfolder\$file","$zidreferalUrl","$zidhost -Path $env:HOMEPATH\\Desktop\\ZidCurrentUser.csv
        }

        
 }
else{
        $ifpossible = Test-Path $Scope
        if (-not $ifpossible)
        {
        Write-Error "The Scope is unreachable, Try providing a scope with exsiting path (Directory or file on disk)" -Category ObjectNotFound
        exit
        }
        else{
            $User = $env:USERNAME
            $dfolder = "$Scope"
            $downloadedFiles = Get-ChildItem -File -Recurse $dfolder
            #For each download extract Zone identifier data stream 

            Write-Host "File, ReferalURL, HostURL"
            foreach ($file in $downloadedFiles)
            {
                 $path = $file.FullName
              
                 $zid = Get-Content $path -Stream Zone.Identifier -ErrorAction SilentlyContinue 
                 $zidreferalUrl = $zid | sls -Pattern "ReferrerUrl=(.*)" | % {"$($_.matches.groups[1])"}
                 $zidhost = $zid | sls -Pattern "HostUrl=(.*)" | % {"$($_.matches.groups[1])"}
                 if ($zidreferalUrl -ne $null -and $zidhost -ne $null ){
                    Write-Host $path","$zidreferalUrl","$zidhost
                }
                }

}     
        
 }  

if ( $CSV) {  
    $o | Out-File -FilePath $CSV 
    }
 
else {
    $o}