# Disable Windows Update and store app automatic update
REG ADD "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f
#REG ADD "HKLM\Software\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d 2 /f
REG ADD "HKLM\Software\Policies\Microsoft\WindowsStore" /v "DisableOSUpgrade" /t REG_DWORD /d 1 /f
gpupdate /force

# Add a firewall rule for remote management
netsh advfirewall firewall add rule name="Windows Remote Management (HTTP-In)" dir=in action=allow service=any enable=yes profile=any localport=5985 protocol=tcp
