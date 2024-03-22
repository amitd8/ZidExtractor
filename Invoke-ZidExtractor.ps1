param(
    [string]$Scope,
    [string]$CSV
    )
    Write-Host "ZidExtractor initializes!" -ForegroundColor Blue
    Start-Sleep -Seconds 2

# Do not continue if -Scope argument is not inputted by user
if (-not $Scope) {
    Write-Error "Usage: Invoke-ZidExtractor.ps1 -Scope 'AllUsers' or 'CurrentUser' or 'C:\your\path\to\dir' (None-Recursive) or 'C:\your\path\to\file', Optional -CSV <path>" -Category SyntaxError
    exit
}
 
# Extract Zids from all Download folders of any user with UserProfile
if ($Scope -eq "AllUsers" ) {
    
    $Users = Get-ChildItem "$env:SystemDrive\\Users"
    # Loop through all users with user profile
    $o = "CreationTime, UserName, File, ReferalURL, HostURL`n"
    foreach ($User in $Users) 
    {
        #Locate Downloads folder
        
        $dfolder = "$env:SystemDrive\\Users\\$User\\Downloads"
        $downloadedFiles = Get-ChildItem -Recurse -File $dfolder 
        #For each download extract Zone identifier data stream 
        foreach ($file in $downloadedFiles)
        {
             $path = $file.FullName
             $time = $file.CreationTime
             $zid = Get-Content $path -Stream Zone.Identifier -ErrorAction SilentlyContinue 
             $zidreferalUrl = $zid | Select-String -Pattern "ReferrerUrl=(.*)" | ForEach-Object {"$($_.matches.groups[1])"}
             $zidhost = $zid | Select-String -Pattern "HostUrl=(.*)" | ForEach-Object {"$($_.matches.groups[1])"}
             if ($null -ne $zidreferalUrl -and $null -ne $zidhost ){
                $o += "$time,$User,$path,$zidreferalUrl,$zidhost`n"

         }
             
        }
     }
 }

 elseif ( $Scope -eq "CurrentUser")
 {
        $User = $env:USERNAME
        $o = "CreationTime, UserName, File, ReferalURL, HostURL`n"
        $dfolder = "$env:HOMEPATH\\Downloads"
        $downloadedFiles = Get-ChildItem -Recurse -File $dfolder
        #For each download extract Zone identifier data stream 
        foreach ($file in $downloadedFiles)
        {
             $path = $file.FullName
             $time = $file.CreationTime
             $zid = Get-Content $path -Stream Zone.Identifier -ErrorAction SilentlyContinue 
             $zidreferalUrl = $zid | Select-String -Pattern "ReferrerUrl=(.*)" | ForEach-Object {"$($_.matches.groups[1])"}
             $zidhost = $zid | Select-String -Pattern "HostUrl=(.*)" | ForEach-Object {"$($_.matches.groups[1])"}
             if ($null -ne $zidreferalUrl -and $null -ne $zidhost ){
                $o += "$time,$User,$path,$zidreferalUrl,$zidhost`n"

            }
             
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

            $o = "CreationTime, File, ReferalURL, HostURL`n"
            foreach ($file in $downloadedFiles)
            {
                 $path = $file.FullName
                 $time = $file.CreationTime
                 $zid = Get-Content $path -Stream Zone.Identifier -ErrorAction SilentlyContinue 
                 $zidreferalUrl = $zid | Select-String -Pattern "ReferrerUrl=(.*)" | ForEach-Object {"$($_.matches.groups[1])"}
                 $zidhost = $zid | Select-String -Pattern "HostUrl=(.*)" | ForEach-Object {"$($_.matches.groups[1])"}
                 if ($null -ne $zidreferalUrl -and $null -ne $zidhost ){
                    $o = "$time,$path,$zidreferalUrl,$zidhost`n"
                }
                }

}     
        
 }  


if ( $CSV) {  
     try {
        $o | Out-File -FilePath $CSV -ErrorAction Stop
        $x = (Get-Item $CSV).FullName
        Write-Host "CSV Successfuly Written to $x" -ForegroundColor Green
    }
    catch {
        Write-Host "Error occurred while writing CSV file: $_" -ForegroundColor Red
        exit 1 
    }
}
 
else {
    $o}