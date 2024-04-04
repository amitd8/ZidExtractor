param(
    [string]$Scope,
    [string]$CSV
    )
    Write-Host "ZidExtractor initializes!" -ForegroundColor Blue
    Start-Sleep -Seconds 2
function Get-Zids {
    param (
        [string]$Scope,
        $Workfolder,
        $User
        )
    foreach ($file in $Workfolder)
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
    return $o   
    }
# Do not continue if -Scope argument is not inputted by user
if (-not $Scope) {
    Write-Error "Usage: Invoke-ZidExtractor.ps1 -Scope 'AllUsers' or 'CurrentUser' or 'C:\your\path\to\dir' (None-Recursive) or 'C:\your\path\to\file', Optional -CSV <path>" -Category SyntaxError
    exit
}
# Extract Zids from all Download folders of any user with UserProfile
if ($Scope -eq "AllUsers" ) {
    
    $Users = Get-ChildItem "$env:SystemDrive\\Users"
    $o = "CreationTime, UserName, File, ReferalURL, HostURL`n"
    # Loop through all users with user profile
    foreach ($User in $Users) 
    {
        #Locate Downloads folder
        $dfolder = "$env:SystemDrive\\Users\\$User\\Downloads"
        $downloadedFiles = Get-ChildItem -Recurse -File $dfolder 
        #For each download extract Zone identifier data stream 
        $o += Get-Zids -Scope AllUsers -Workfolder $downloadedFiles -User $User  
        }
     }
# Scan files in downloads folder of current user
 elseif ( $Scope -eq "CurrentUser")
 {
        $User = $env:USERNAME
        $o = "CreationTime, UserName, File, ReferalURL, HostURL`n"
        $dfolder = "$env:HOMEPATH\\Downloads"
        $downloadedFiles = Get-ChildItem -Recurse -File $dfolder
        #For each download extract Zone identifier data stream 
        $o += Get-Zids -Scope AllUsers -Workfolder $downloadedFiles -User $User        
 }
# If the scope is not AllUsers or CurrentUser, check if a path to file or directory was supplied, and scan it for zids
else{
        $ifpossible = Test-Path $Scope
        if (-not $ifpossible)
        {
        Write-Error "The Scope is unreachable, Try providing a scope with existing path (Directory or file on disk)" -Category ObjectNotFound
        exit
        }
        else{
            $User = $env:USERNAME
            $dfolder = "$Scope"
            $downloadedFiles = Get-ChildItem -File -Recurse $dfolder
            #For each download extract Zone identifier data stream 
            $o = "CreationTime, UserName, File, ReferalURL, HostURL`n"
            #For each download extract Zone identifier data stream 
            $o += Get-Zids -Scope AllUsers -Workfolder $downloadedFiles -User $User  
            }         
    }  

# if CSV argument was supplied, try writing the output to path supplied
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
# Output collected data
else {
    $o}
