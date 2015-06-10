# NB this file has to be idempotent. it will be run several times if the computer needs to be restarted.
#    when that happens, Boxstarter schedules this script to run again with an auto-logon.
# NB always remember to pass -y to choco install!
# NB already installed packages will refuse to install again; so we are safe to run this entire script again.

# NB make sure this is the first software you install, because, as a side
#    effect, this will trigger a reboot, which in turn, will fix the vagrant bug
#    that prevents the machine from rebooting after setting the hostname.
choco install -y google-chrome-x64

choco install -y firefox

choco install -y jre8

choco install -y notepad2

choco install -y pstools

# Enable Show Window Contents While Dragging
reg ADD "HKCU\Control Panel\Desktop" /v DragFullWindows /t REG_SZ /d 1 /f
#taskkill /IM explorer.exe /F ; explorer.exe

# disable password complexity.
echo 'Disabling password complexity...'
secedit /export /cfg policy.cfg
(gc policy.cfg) -replace '(PasswordComplexity\s*=\s*).+', '${1}0' | sc policy.cfg
secedit /configure /db $env:windir\security\policy.sdb /cfg policy.cfg /areas SECURITYPOLICY
del policy.cfg

# create the selenium-server user account.
echo 'Creating selenium-server user account...'
$seleniumServerPassword = "password"
net user selenium-server $seleniumServerPassword /add /y /fullname:"Selenium Server"
wmic useraccount where "name='selenium-server'" set PasswordExpires=FALSE
# grant it Remote Desktop access.
net localgroup 'Remote Desktop Users' selenium-server /add

# install selenium server and setup Windows to Run it on logon.
echo 'Waiting for C:\Vagrant to be available...'
# NB for some whacky reason we need to start a new explorer window to speedup
#    the mounting of C:\Vagrant...
Start-Process explorer
while (-not (Test-Path -Path C:\Vagrant\Vagrantfile)) { Sleep 3 }
@'
echo 'Waiting for the USERPROFILE to become available...'
while (-not (Test-Path -Path $env:USERPROFILE)) { Sleep 3 }

echo 'Extracting Selenium Server...'
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory("C:\Vagrant\selenium-server.zip", "$env:USERPROFILE\selenium-server")

echo 'Configuring logon to run Selenium Server Hub and Node...'
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v selenium-server-hub /t REG_EXPAND_SZ /d "%USERPROFILE%\selenium-server\selenium-server-hub.cmd" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v selenium-server-node /t REG_EXPAND_SZ /d "%USERPROFILE%\selenium-server\selenium-server-node.cmd" /f

echo 'DONE installing the Selenium Server!'
Sleep 5
'@ | Out-File C:\tmp\install-selenium-server.ps1

# NB the psexec command line has a limit of 260 bytes or so. thats why we use a temporary file.
# NB we have to use psexec because I don't known a better way of doing this with powershell...
echo 'Intalling the Selenium Server...'
psexec -accepteula -u selenium-server -p $seleniumServerPassword powershell -File C:\tmp\install-selenium-server.ps1

# poke a hole in the firewall to allow access to the 4444 TCP port.
echo 'Configuring the firewall to allow access to the Selenium Server Hub...'
netsh advfirewall firewall add rule name="Selenium Server Hub (HTTP-In)" dir=in action=allow protocol=TCP localport=4444

# configure auto-logon to the selenium-server user.
# NB this has to run AFTER this script ends! So be sure this is always at the
#    end of this script.
#    This is needed because Boxstarter will automatically disable the auto-logon
#    it has set initially (for implementing the Reboot Resilient feature). BUT
#    we also want to change the Auto-Logon configuration... so we have to make
#    sure that the $enableAutoLogonScript script always executes after this
#    script ends; that way we always override what Boxstarter did.
$enableAutoLogonScript = @"
echo 'Configuring auto-logon to the selenium-server account...'
Sleep 5

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d selenium-server /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d $seleniumServerPassword /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonSID /f

echo 'DONE!'
echo yes | Out-File -Encoding ascii C:\Vagrant\setup-finished.txt
"@

$encodedEnableAutoLogonScript = [Convert]::ToBase64String(
  [System.Text.Encoding]::Unicode.GetBytes($enableAutoLogonScript)
)

Start-Process powershell -ArgumentList '-EncodedCommand',$encodedEnableAutoLogonScript
