Invoke-WebRequest -Uri https://aka.ms/download-jdk/microsoft-jdk-17.0.1.12.1-windows-x64.msi -OutFile javajdk.msi

msiexec.exe /q /i `
  'javajdk.msi' `
  INSTALLLOCATION='"c:\Program Files\Microsoft\\"' ADDLOCAL='all'

$JMETER_VERSION="5.2.1"
Invoke-WebRequest -Uri "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.zip" -OutFile jmeter.zip
Expand-Archive -Path jmeter.zip -DestinationPath "C:\Program Files\jmeter" -Force

$TargetFile = "C:\Program Files\jmeter\apache-jmeter-$JMETER_VERSION\bin\jmeter.bat"
$ShortcutFile = "$env:Public\Desktop\JMeter GUI.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

$TargetFile = "C:\Program Files\jmeter\apache-jmeter-$JMETER_VERSION\bin\jmeter.properties"
$ShortcutFile = "$env:Public\Desktop\JMeter Properties.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
