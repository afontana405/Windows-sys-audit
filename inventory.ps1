$output_dir = "$HOME\Documents\software_inventory"
mkdir "$output_dir"

# Computer Info
Write-Output "[+] Collecting Computer Info..."
Get-ComputerInfo | Out-File "$output_dir\ComputerInfo.txt"
