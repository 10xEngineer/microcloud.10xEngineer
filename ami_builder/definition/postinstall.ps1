# Script: 10xlabs-win-ami setup

# change administrator password
# WinRM setup
& "winrm" "quickconfig" "-q"
#& "winrm" "quickconfig" "-transport:http"
Set-Item WSMAN:\localhost\MaxTimeoutms -Value 1800000
Set-Item WSMAN:\localhost\Shell\MaxMemoryPerShellMB -Value 300
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
#Set-Item WSMan:\localhost\Listener\Listener?Address=*+Transport=HTTP\Port -Value 5985

#cmd /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
#cmd /c netsh firewall add portopening TCP 5985 "Port 5985"

net stop winrm
net start winrm

# TODO hardcoded for now 
#      will be replaced once postinstall script is generated from template
net user Administrator C9fcx2vTZAzeQt

# create default directory
$serviceDir = "C:\Program Files\10xLabs\service"
[IO.Directory]::CreateDirectory($serviceDir)

# download 10xlabs-win-vm distribution
# TODO temporary URL
$downloadURL = "http://ops-images.s3.amazonaws.com/10xlabs-win-vm.zip"

cd $serviceDir
$webclient = New-Object System.Net.WebClient
$file = "$serviceDir\10xlabs-win-vm.zip"
$webclient.DownloadFile($downloadURL,$file)

# unzip distribution
$shell_app=new-object -com shell.application 
$destination = $shell_app.namespace((Get-Location).Path)
$zipfile = $shell_app.namespace($file)
$destination.CopyHere($zipfile.items())

Remove-Item $file

# install service
cd $serviceDir
& '.\10xlabs-win-vm.exe' '--install'

