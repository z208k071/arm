# Overwrite UI language
Set-WinUILanguageOverride -Language ja-JP

# Set Time/Date format with same windows language
Set-WinCultureFromLanguageListOptOut -OptOut $False

# Set Location to Japan
Set-WinHomeLocation -GeoId 0x7A

# Set system locale to Japan
Set-WinSystemLocale -SystemLocale ja-JP

# Set timezone to Tokyo (JST)
Set-TimeZone -Id "Tokyo Standard Time"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableTimeZoneRedirection /t REG_DWORD /d 1 /f

# Set culture to Japan
Set-Culture ja-JP

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

# Configute default user and system display language
$DefaultHKEY = "HKU\DEFAULT_USER"
$DefaultRegPath = "C:\Users\Default\NTUSER.DAT"
$tempFolder = "C:\Temp"
$defaultPath = $tempFolder + "\ja-JP-default.reg"
$welcomePath = $tempFolder + "\ja-JP-welcome.reg"

REG LOAD $DefaultHKEY $DefaultRegPath
REG IMPORT $defaultPath
REG UNLOAD $DefaultHKEY
REG IMPORT $welcomePath

gpupdate /force
