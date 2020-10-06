# Download language pack
## Define download environment variables
### Temporary working folder
$tempFolder = "C:\Temp"
New-Item -Path $tempFolder -ItemType Directory

## Disable delete unused language pack
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup"
REG ADD "HKLM\Software\Policies\Microsoft\Control Panel\International" /v "BlockCleanupOfUnusedPreinstalled" /t REG_DWORD /d 1 /f

### Language pack URL
$msContentUrl = "https://software-download.microsoft.com/download/pr/"
$lpkFileName = "19041.1.191206-1406.vb_release_CLIENTLANGPACKDVD_OEM_MULTI.iso"
$lpkUrl = $msContentUrl + $lpkFileName
$lpkLocalPath = $tempFolder + '\' + $lpkFileName
### FOD file URL
$fodFileName = "19041.1.191206-1406.vb_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso"
$fodUrl = $msContentUrl + $fodFileName
$fodLocalPath = $tempFolder + '\' + $fodFileName
## Download
$wc = New-Object net.webclient
$wc.Downloadfile($lpkUrl, $lpkLocalPath)
$wc.Downloadfile($fodUrl, $fodLocalPath)

# Install language pack
## Language pack ISO mount
Mount-DiskImage $lpkLocalPath
$lpkDriveLetter = (Get-DiskImage -ImagePath $lpkLocalPath | Get-Volume).DriveLetter + ':'
$lpkCabPath = $lpkDriveLetter + '\x64\langpacks'
$lpkAppxPath = $lpkDriveLetter + '\LocalExperiencePack\ja-jp'
Add-AppProvisionedPackage -Online -PackagePath $lpkAppxPath\LanguageExperiencePack.ja-jp.Neutral.appx -LicensePath $lpkAppxPath\License.xml
Add-WindowsPackage -Online -PackagePath $lpkCabPath\Microsoft-Windows-Client-Language-Pack_x64_ja-jp.cab
## FOD file ISO mount 
Mount-DiskImage $fodLocalPath
$fodDriveLetter = (Get-DiskImage -ImagePath $fodLocalPath | Get-Volume).DriveLetter + ':'
## Install
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-LanguageFeatures-Basic-ja-jp-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-LanguageFeatures-Fonts-Jpan-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-LanguageFeatures-Handwriting-ja-jp-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-LanguageFeatures-OCR-ja-jp-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-LanguageFeatures-Speech-ja-jp-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-LanguageFeatures-TextToSpeech-ja-jp-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~ja-jp~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~ja-jp~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-MSPaint-FoD-Package~31bf3856ad364e35~amd64~ja-jp~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-Notepad-FoD-Package~31bf3856ad364e35~amd64~ja-jp~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-PowerShell-ISE-FOD-Package~31bf3856ad364e35~amd64~ja-jp~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-Printing-WFS-FoD-Package~31bf3856ad364e35~amd64~ja-jp~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-StepsRecorder-Package~31bf3856ad364e35~amd64~ja-jp~.cab
Add-WindowsPackage -Online -PackagePath $fodDriveLetter\Microsoft-Windows-WordPad-FoD-Package~31bf3856ad364e35~amd64~ja-jp~.cab
