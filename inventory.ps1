# Define root and category directories
$output_root = "$HOME\Documents\software_inventory"
$hardware_dir = Join-Path $output_root "hardware"
$software_dir = Join-Path $output_root "software"
$network_dir  = Join-Path $output_root "network"

# Create directories if they don't exist
$dirs = @($output_root, $hardware_dir, $software_dir, $network_dir)
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }
}

# 1. Computer
Write-Output "[+] Collecting Computer Info..."
Get-ComputerInfo | Out-File "$hardware_dir\ComputerInfo.txt"

# 2. CPU
Write-Output "[+] Collecting CPU Info..."
Get-CimInstance -ClassName Win32_Processor | Out-File "$hardware_dir\CPU.txt"

# 3. Memory
Write-Output "[+] Collecting Memory Info..."
Get-CimInstance -ClassName Win32_PhysicalMemory | Out-File "$hardware_dir\Memory.txt"

# 4. Disk
Write-Output "[+] Collecting Disk Info..."
Get-CimInstance -ClassName Win32_DiskDrive | Out-File "$hardware_dir\Disk.txt"

# 5. Installed programs (registry-based method, more reliable)
Write-Output "[+] Collecting Installed Programs..."
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Out-File "$software_dir\InstalledPrograms.txt"

# 6. Startup programs for current user and system wide
Write-Output "[+] Collecting Startup Program Info..."
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Out-File "$software_dir\StartupPrograms.txt"
Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" | Out-File "$software_dir\StartupPrograms.txt" -Append

# 7. Antivirus n Firewall
Write-Output "[+] Collecting Security Info..."
Get-CimInstance -Namespace "root/SecurityCenter2" -ClassName AntivirusProduct | Out-File "$software_dir\SecuritySoftware.txt"
Get-NetFirewallProfile | Out-File "$software_dir\SecuritySoftware.txt" -Append

# 6. Network
Write-Output "[+] Collecting Network Info..."
Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Out-File "$network_dir\Network.txt"

# 7. IP configuration
Write-Output "[+] Collecting IP Configuration..."
Get-NetIPConfiguration | Out-File "$network_dir\IPConfiguration.txt"

# 8. Network connections
Write-Output "[+] Collecting Active TCP/UDP Connections..."
netstat -ano | Out-File "$network_dir\ActiveConnections.txt"

# 9. Shared folders
Write-Output "[+] Collecting Local Shared Folders..."
Get-SmbShare | Out-File "$network_dir\SharedFolders.txt"

Write-Output "Inventory complete. Output saved to: $output_root"