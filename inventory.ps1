$output_dir = "$HOME\Documents\software_inventory"
if (-not (Test-Path $output_dir)) {
    New-Item -Path $output_dir -ItemType Directory | Out-Null
}

# 1. Computer
Write-Output "[+] Collecting Computer Info..."
Get-ComputerInfo | Out-File "$output_dir\ComputerInfo.txt"

# 2. CPU
Write-Output "[+] Collecting CPU Info..."
Get-CimInstance -ClassName Win32_Processor | Out-File "$output_dir\CPU.txt"

# 3. Memory
Write-Output "[+] Collection Memory Info..."
Get-CimInstance -ClassName Win32_PhysicalMemory | Out-File "$output_dir\Memory.txt"

# 4. Disk
Write-Output "[+] Collection Disk Info..."
Get-CimInstance -ClassName Win32_DiskDrive | Out-File "$output_dir\Disk.txt"

# 5. Network
Write-Output "[+] Collecting Network Info..."
Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Out-File "$output_dir\Network.txt"

# 6. Installed programs (registry-based method, more reliable)
Write-Output "[+] Collecting Installed Programs..."
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Out-File "$output_dir\InstalledPrograms.txt"

Write-Output "Inventory complete. Output saved to: $output_dir"