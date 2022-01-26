Invoke-WebRequest -Uri https://aka.ms/download-jdk/microsoft-jdk-17.0.1.12.1-windows-x64.msi -OutFile javajdk.msi

msiexec.exe /q /i `
  'javajdk.msi' `
  INSTALLLOCATION='"c:\Program Files\Microsoft\\"' ADDLOCAL='all'

$JMETER_VERSION="5.2.1"
$USR = "loadtest"
Invoke-WebRequest -Uri "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.zip" -OutFile jmeter.zip
$ShortcutPath = "JMeter.lnk" 
Expand-Archive -Path jmeter.zip -DestinationPath "C:\Users\$USR\jmeter"

# Create Jmeter Config
$SourceFilePath = "C:\Users\$USR\jmeter\apache-jmeter-$JMETER_VERSION\bin\jmeter.properties"
$ShortcutPath = "C:\Users\$USR\Desktop\JMeterConfig.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = $SourceFilePath
$shortcut.Save()

# Create Jmeter Shortcut
$SourceFilePath = "C:\Users\$USR\jmeter\apache-jmeter-$JMETER_VERSION\bin\jmeter.bat"
$ShortcutPath = "C:\Users\$USR\Desktop\JMeter.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = $SourceFilePath
$shortcut.Save()
