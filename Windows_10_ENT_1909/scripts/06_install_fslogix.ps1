# Download FSLogix
$tempFolder = "C:\Temp"
$fslogixUrl = "https://aka.ms/fslogix_download"
$fslogixZip = $tempFolder + "\fslogix.zip"
$wc = New-Object net.webclient
$wc.Downloadfile($fslogixUrl, $fslogixZip)

# Expand FSLogix
$fslogixLocalPath = $tempFolder + "\fslogix"
Expand-Archive -Path $fslogixZip -DestinationPath $fslogixLocalPath

# Install FSLogix
$fslogixExePath = $fslogixLocalPath + "\x64\Release\FSLogixAppsSetup.exe"
Start-Process -FilePath $fslogixExePath -Wait -ArgumentList "/install /quiet"
