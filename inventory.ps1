$output_dir = "$HOME\Documents\software_inventory"
mkdir "$output_dir"

# Computer
Write-Output "[+] Collecting Computer Info..."
Get-ComputerInfo | Out-File "$output_dir\ComputerInfo.txt"

# CPU
Write-Output "[+] Collecting CPU Info..."
Get-CimInstance -ClassName Win32_Processor | Out-File "$output_dir\CPU.txt"

# Memory
Write-Output "[+] Collection Memory Info..."
Get-CimInstance -ClassName Win32_PhysicalMemory | Out-File "$output_dir\Memory.txt"

# Disk
Write-Output "[+] Collection Disk Info..."
Get-CimInstance -ClassName Win32_DiskDrive | Out-File "$output_dir\Disk.txt"