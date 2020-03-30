#Lync Conference 2013 Session-Downloader Script
#Provided by www.msdigest.net / Peter Schmidt (Exchange MVP)
#Blog: www.msdigest.net
#version: 1.6 (Last update: 2013-05-16)
#How to run the script: powershell.exe -executionpolicy unrestricted -command c:\scripts\LyncConf2013_Downloader.ps1
#You will need 26Gb of diskspace for the full collection of videos and powerpoints from the Lync Conf.
#Wishlist for features in next version: File Exist check and Download Speed progress bar

# Inspired and Based on the original TechEd 2012 Orlando Session-Downloader Script - JaredonTech style
# Credits for the original TechEd downloader scripts go to:
# - Stefan Roth - http://blog.SCOMfaq.ch
# - Tim Nilimaa - http://infoworks.tv
# - Jared Shockley - http://jaredontech.com
# - Brad Huffman - http://bradhuffman.com
# All of these guys did a great work, I have updated and optimized it for my own purpose and changed it to handle LyncConf 2013
# Most of the original file is Stefan's and Tim's credit, with optimzed code from Jared and Brad.

Write-Host "  _                   ___           __   ___ __  _ ____                      "  -ForegroundColor Yellow
Write-Host " | |  _  _ _ _  __   / __|___ _ _  / _| |_  )  \/ |__ /                      "  -ForegroundColor Yellow
Write-Host " | |_| || | ' \/ _| | (__/ _ \ ' \|  _|  / / () | ||_ \                      "  -ForegroundColor Yellow
Write-Host " |____\_, |_||_\__|  \___\___/_||_|_|   /___\__/|_|___/           _          "  -ForegroundColor Yellow
Write-Host " / __||__/ _____(_)___ _ _   |   \ _____ __ ___ _ | |___  __ _ __| |___ _ _  "  -ForegroundColor Yellow
Write-Host " \__ \/ -_|_-<_-< / _ \ ' \  | |) / _ \ V  V / ' \| / _ \/ _` / _` / -_) '_| "  -ForegroundColor Yellow
Write-Host " |___/\___/__/__/_\___/_||_| |___/\___/\_/\_/|_||_|_\___/\__,_\__,_\___|_|   "  -ForegroundColor Yellow
Write-Host "                                                                             "  -ForegroundColor Yellow
Write-Host "============================================================================="  -ForegroundColor Yellow
Write-Host "                                                                             "  -ForegroundColor Yellow
Write-Host "      This script downloads all the sessions from Lync Conference 2013       "  -ForegroundColor White
Write-Host "  Go to the official www.LyncConf.com website for more info on the sessions  "  -ForegroundColor White
Write-Host "                                                                             "  -ForegroundColor Yellow
Write-Host "            Script published on my blog: http://www.msdigest.net             "  -ForegroundColor White
Write-Host "                                                                             "  -ForegroundColor Yellow
Write-Host "============================================================================="  -ForegroundColor Yellow

#Pick file type for download
$title = "Pick a file type"
$message = "What type of files would you like to download?"

$vids = New-Object System.Management.Automation.Host.ChoiceDescription "&Videos", `
    "Download videos only."

$ppt = New-Object System.Management.Automation.Host.ChoiceDescription "&PowerPoints", `
    "Download Powerpoint files only."
	
$both = New-Object System.Management.Automation.Host.ChoiceDescription "&Both", `
    "Download both videos and Powerpoints for all available sessions."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($vids, $ppt, $both)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {$downloadType = "vid"}
        1 {$downloadType = "ppt"}
		2 {$downloadType = "both"}
    }
	
$downloadType = $downloadType.ToLower()

#Check that downloadType is valid type
If ("vid","ppt","both" -NotContains $downloadType)
        {
            Throw "$($downloadType) is not a valid type! Please use video, powerpoint, or both.  Default is video."
        } 

Write-Host ""
[string]$path= Read-Host "Enter the path you'd like files to be saved to (eg. c:\temp\) - default path is C:\ : "

#-----------Don't change----------------------------
$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()

$scriptdir = split-path -Parent $myInvocation.MyCommand.Path

#this is if . was entered in the path (relative path).  Not sure why, but it was causing a problem with the DownloadFileAsync method. -Brad
if ($path -eq "."){$path = $scriptdir}

#Target Path where the files will be saved - Modify if you want it in a different subdirectory on path

#File which contains the sessions for download
$sessionsfile = $scriptdir + "\Lyncconf_sessions.txt"
if ((test-path -path $sessionsfile)){$sessions =get-content $sessionsfile}
else {write-host -ForegroundColor Red ("Cannot find session.txt file. Please copy the file into the same directory as the script! Path $scriptdir")}

#Get total session count for calculations on the download progress bar - From Tim
#If downloading both media types or ppt, modify sessions list appropriately. -Brad
if ($downloadType -eq "both")
{
	$ppt_sessions = @()
	
	$x = 0
	
	do
	{$ppt_sessions += $sessions[$x].Replace(".mp4",".pptx")
	$x++}
	while($x -le $sessions.length - 1)
	
	$sessions = $sessions + $ppt_sessions
	$sessions = $sessions | sort
	#Write-Output $sessions
}
elseif($downloadType -eq "ppt")
{
	$x = 0
	
	do
	{$sessions[$x] = $sessions[$x].Replace(".mp4",".pptx")
	$x++}
	while($x -le $sessions.length - 1)
	
	#Write-Output $sessions
}

$totalsessions = $sessions.count

#Downloading the files from this URL. Don't change!
$url="http://lyncconf.blob.core.windows.net/published/"

#Creating WebClient object and downloading sessions...
$wclient = new-object System.Net.WebClient
$wclient.Credentials = new-object System.Net.NetworkCredential($username, $password, '')

#Declared item number variable
$i = 0
Foreach($session in $sessions){

#Changed Stefan's code to use this style from Tim's code
$i++

#Move targetpath declaration here to put file in appropriate folder based on filetype.
if ($session.EndsWith(".pptx")){
$target="\PPT\"
}
else{
$target="\Videos\"
}
$targetpath=$path+$target
if (!(test-path -path $targetpath)) { new-item $targetpath -type directory};

try {
	    #Output the status of downloaded files - From Tim
	    write-progress -id 1 -Activity "Downloading Lync Conference 2013 Sessions" -Status "Session $i of $totalsessions" -PercentComplete (($i / $totalsessions)*100)
            #Creation of URL and File output
            $file=$url+$session
            $download=$targetpath+$session
            #Checking of the filesize to manage the progress bars - From Tim
	    $webRequest = [net.WebRequest]::Create($file)
	    $webResponse = $webRequest.GetResponse()
	    $SessionSize = $webResponse.ContentLength
	    $webResponse.Close()
	    $webRequest.Abort()
	    $SizeInMB = ($SessionSize/1024/1024).ToString().Remove(3)
            #Start of download changed to Async based on Tim's code
            $wclient.DownloadFileAsync($file,$download)
            #While loop to determine the size of the download
    	    While ((Get-Item $download).Length -lt $SessionSize) {
  	      $CurrentSizeOfDownload = [System.Math]::Round(((Get-Item $download).Length/1024/1024),2)
    	        Write-Progress -id 2 -Activity "Downloading $session ($CurrentSizeOfDownload MB of $SizeInMB MB)" -Status "Progress:" -PercentComplete (((Get-Item $download).Length / $SessionSize)*100)

		   }
     } 
#Tim's great Try-Catch to create the sessions_notavailable.txt file
catch {
            
            $errorfile = $scriptdir + "\sessions_notavailable.txt";
            write-host -foregroundColor Red ("Session not available please check $errorfile")
            if(!(test-path -path $errorfile)) { new-item $errorfile -type file};
            $session | out-file $errorfile -Append
        }
}

write-host -ForegroundColor Green "Finished!"
Write-Host -ForegroundColor Green "Total download time: " $ElapsedTime.Elapsed.ToString()
