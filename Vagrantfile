# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

# NB this is a PowerShell script that is run as Administrator.
$root_provision_script = <<'ROOT_PROVISION_SCRIPT'
# set keyboard layout.
# NB you can get the name from the list:
#      [System.Globalization.CultureInfo]::GetCultures('InstalledWin32Cultures') | out-gridview
Set-WinUserLanguageList pt-PT -Force

# set the date format, number format, etc.
Set-Culture pt-PT

# set the timezone.
# tzutil /l lists all available timezone ids
& $env:windir\system32\tzutil /s "GMT Standard Time"

# install Boxstarter.
# NB Do NOT install chocolatey before Boxstarter. If you do, strange things
#    will happen...
$boxstarterSetupPath = "$env:TEMP\Boxstarter-setup"
$boxstarterSetupZipPath = $boxstarterSetupPath + ".zip"
Invoke-WebRequest http://boxstarter.org/downloads/Boxstarter.2.4.209.zip -OutFile $boxstarterSetupZipPath
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory($boxstarterSetupZipPath, $boxstarterSetupPath)
& $boxstarterSetupPath\setup.bat -Force

echo NBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNB
echo NB
echo 'NB Boxstarter might need to reboot the machine, in that case, vagrant will'
echo 'NB fail, but that is expected. you need to monitor the install yourself to'
echo 'NB known when its done...'
echo NB
echo NBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNBNB

# TODO this should be abstracted in a "boxstarter" provisioner.
# NB if any of the choco packages need to access the desktop, you need to force
#    a reboot at start of the boxstarter script. when you do that Boxstarter
#    will run the script again, but in a auto-logon session. the easiest way to
#    do that, is to install google chrome.
$env:PSModulePath = "$([System.Environment]::GetEnvironmentVariable('PSModulePath', 'User'));$([System.Environment]::GetEnvironmentVariable('PSModulePath', 'Machine'))"
cp C:\vagrant\setup.ps1 $env:TEMP
Import-Module Boxstarter.Chocolatey
$credential = New-Object System.Management.Automation.PSCredential("vagrant", (ConvertTo-SecureString "vagrant" -AsPlainText -Force))
Install-BoxstarterPackage $env:TEMP\setup.ps1 -Credential $credential
ROOT_PROVISION_SCRIPT

Vagrant.configure("2") do |config|
    config.vm.define "selenium-server"
    config.vm.box = "windows_2012_r2"

    config.vm.provider :virtualbox do |v, override|
        v.gui = true
        v.customize ["modifyvm", :id, "--cpus", 2]
        v.customize ["modifyvm", :id, "--memory", 2048]
        v.customize ["modifyvm", :id, "--vram", 32]
    end

    config.vm.provision "shell", inline: $root_provision_script

    config.vm.network "forwarded_port", guest: 4444, host: 4444
end
