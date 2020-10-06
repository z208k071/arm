# Change display language to Japansese
Set-WinUserLanguageList -LanguageList ja-JP,en-US -Force

# Change input method to Japanese
Set-WinDefaultInputMethodOverride -InputTip "0411:00000411"

# Change MS-IME input bar
Set-WinLanguageBarOption -UseLegacySwitchMode -UseLegacyLanguageBar

# Change Hardware keyboard layout
reg add HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters /f /v "LayerDriver JPN" /t REG_SZ /d kbd106.dll
reg add HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters /f /v "OverrideKeyboardIdentifier" /t REG_SZ /d PCAT_106KEY
reg add HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters /f /v "OverrideKeyboardSubtype" /t REG_DWORD /d 2
reg add HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters /f /v "OverrideKeyboardType" /t REG_DWORD /d 7
