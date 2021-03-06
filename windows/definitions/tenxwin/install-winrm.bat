# original chef instructions
# http://wiki.opscode.com/display/chef/Knife+Windows+Bootstrap#KnifeWindowsBootstrap-Requirements%2FVersion
#
# Enable WinRM Basic Authentication (plaintext)
# TODO Enable SSL
# http://pubs.vmware.com/orchestrator-plugins/index.jsp?topic=/com.vmware.using.powershell.plugin.doc_10/GUID-D4ACA4EF-D018-448A-866A-DECDDA5CC3C1.html

cmd /c winrm quickconfig -q
cmd /c winrm quickconfig -transport:http # needs to be auto no questions asked
cmd /c winrm set winrm/config @{MaxTimeoutms="1800000"}
cmd /c winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"}
cmd /c winrm set winrm/config/service @{AllowUnencrypted="true"}
cmd /c winrm set winrm/config/service/auth @{Basic="true"}
cmd /c winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}
cmd /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
cmd /c netsh firewall add portopening TCP 5985 "Port 5985"
cmd /c net stop winrm
cmd /c net start winrm
