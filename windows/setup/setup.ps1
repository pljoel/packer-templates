$ErrorActionPreference = "Stop"
[double]$osver = [string][environment]::OSVersion.Version.major + '.' + [environment]::OSVersion.Version.minor

# Switch network connection to private mode
# Required for WinRM firewall rules
if ($osver -gt 6.1)
{
	$profile = Get-NetConnectionProfile
	Set-NetConnectionProfile -Name $profile.Name -NetworkCategory Private
}
elseif ($osver -ge 6)
{
	# Start-Sleep 120 # I don't know why but WinRM gets disabled without a sleep
	$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
	$connections = $networkListManager.GetNetworkConnections()
	$connections | % {$_.GetNetwork().SetCategory(1)} #0: Public, 1:Private, 2:Domain
}
else
{
	echo "Not supported in versions lower than Vista/WS2008"
	return
}

# Enable WinRM service
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

# Eventually if we need to generalize
# & $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /mode:vm /quit

