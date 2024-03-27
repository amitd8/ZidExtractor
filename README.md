## Welcome to ZidExtractor!                                                    
```
 _______     _ _____     _                  _             
|___  (_)   | |  ___|   | |                | |            
   / / _  __| | |____  _| |_ _ __ __ _  ___| |_ ___  _ __ 
  / / | |/ _` |  __\ \/ / __| '__/ _` |/ __| __/ _ \| '__|
./ /__| | (_| | |___>  <| |_| | | (_| | (__| || (_) | |   
\_____/_|\__,_\____/_/\_\\__|_|  \__,_|\___|\__\___/|_|   
```                                               

Invoke-ZidExtractor.ps1 is a PowerShell script that automates the extraction process of Zone.identifer data of a file! 

Zone.identifer (Zid) is a metadata attribute that is used by the NTFS flie system to store information about the origin of a file and its [security zone](https://learn.microsoft.com/en-us/deployedge/per-site-configuration-by-policy)!

This data can be useful for Digital Forensics Investigators to determine the website from which a file was downloaded.

![image](https://github.com/amitd8/ZidExtractor/assets/97177937/63b95ae2-5f0b-423c-908f-7c67b2ee7114)
![image](https://github.com/amitd8/ZidExtractor/assets/97177937/52b9be30-dbd7-4ca7-aad6-994fbbb71a4e)

Zone.identifer is stored in an ADS ([Alternative Data Stream](https://www.malwarebytes.com/blog/news/2015/07/introduction-to-alternate-data-streams)) of a file, due to that, it's not always straight forward to access.
This script will extract the following useful data about files scanned:

`Host URL` - Includes the URL from which the file was downloaded

`Referral URL` - Includes the URL that hoseted the download link
## Running ZidExtractor
Running `Invoke-ZidExtractor.ps1` with no parameters will result with an Error, Always supply a `-Scope`.

**If a file doesn't have a Zid (like most files outside of Downloads folder) the script will output none.**
<a name="Scope" id="Mode0"></a>
#### -Scope CurrentUser - Get Zid of all files under Downloads folder of running User  
``` powershell
# Script Syntax for -Scope CurrentUser
PS .\Invoke-ZidExtractor.ps1 -Scope CurrentUser
```
#### -Scope AllUsers - Get Zid of all files under Downloads folder of All Existing user on Host  
``` powershell
# Script Syntax for -Scope CurrentUser 
PS .\Invoke-ZidExtractor.ps1 -Scope AllUsers
```
#### -Scope AllUsers - Get Zid of given file or dir (none-recursive)
``` powershell
# Script Syntax for -Scope CurrentUser 
PS .\Invoke-ZidExtractor.ps1 -Scope C:\path\to\file\or\dir
```
## Output Data to CSV (Recommended), CSV later can be loaded in TimelimeExplorer for further analysis
Adding the argument `-CSV` will output the data to given file path.
``` powershell
# Script Syntax for outputing data to CSV
PS .\Invoke-ZidExtractor.ps1 -Scope CurrentUser -CSV ..\artifacts\ZidsofUserAmitd.csv
```
## Output To console Example
``` powershell
PS .\Invoke-ZidExtractor.ps1 -Scope ..\TimelineExplorer.zip
ZidExtractor initializes!
CreationTime, File, ReferalURL, HostURL
03/22/2024 12:13:49,C:\Users\amida\Desktop\TimelineExplorer.zip,https://ericzimmerman.github.io/,https://f001.backblazeb2.com/file/EricZimmermanTools/net6/TimelineExplorer.zip
```

