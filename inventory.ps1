# inventory.ps1
# Audit Script for Windows Server 2022
# Generates report on Installed Programs, Running Services, Open Ports, and Firewall Rules

# === CONFIGURATION ===
$BaseOutputDir = "C:\AuditOutput"

# === PREPARE OUTPUT FOLDER ===
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutputDir = Join-Path -Path $BaseOutputDir -ChildPath "Server_Audit_$Timestamp"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Write-Host "Audit output will be saved to: $OutputDir"

# === INSTALLED PROGRAMS ===
Write-Host "Collecting Installed Programs..."
$InstalledProgramsPath = "$OutputDir\Installed_Programs.txt"

# 64-bit Programs
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object {$_.DisplayName} |
    Sort-Object DisplayName |
    Out-File $InstalledProgramsPath

# 32-bit Programs
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object {$_.DisplayName} |
    Sort-Object DisplayName |
    Out-File -Append $InstalledProgramsPath

# === RUNNING SERVICES ===
Write-Host "Collecting Running Services..."
$RunningServicesPath = "$OutputDir\Running_Services.txt"

Get-Service | Where-Object {$_.Status -eq 'Running'} | 
    Select-Object Name, DisplayName, Status, StartType |
    Sort-Object Name |
    Out-File $RunningServicesPath

# === OPEN PORTS ===
# Get TCP listeners and add Protocol label
$tcp = Get-NetTCPConnection -State Listen | ForEach-Object {
    [PSCustomObject]@{
        Protocol      = 'TCP'
        LocalAddress  = $_.LocalAddress
        LocalPort     = $_.LocalPort
        OwningProcess = $_.OwningProcess
    }
}

# Get UDP listeners and add Protocol label
$udp = Get-NetUDPEndpoint | ForEach-Object {
    [PSCustomObject]@{
        Protocol      = 'UDP'
        LocalAddress  = $_.LocalAddress
        LocalPort     = $_.LocalPort
        OwningProcess = $_.OwningProcess
    }
}

# Combine and export
$combinedPorts = $tcp + $udp
$OpenPortsPath = "$OutputDir\OpenPorts.csv"
$combinedPorts | Sort-Object Protocol, LocalPort | Export-Csv -Path $OpenPortsPath -NoTypeInformation

# === FIREWALL RULES ===
Write-Host "Collecting Firewall Rules..."
$FirewallRulesPath = "$OutputDir\Firewall_Rules.txt"

Get-NetFirewallRule | 
    Select-Object DisplayName, Direction, Action, Enabled, Profile |
    Sort-Object DisplayName |
    Out-File $FirewallRulesPath

# === COMBINE INTO ONE REPORT ===
Write-Host "Combining all reports into Server_Audit_Report.txt..."
$CombinedFile = "$OutputDir\Server_Audit_Report.txt"

Add-Content $CombinedFile "===== INSTALLED PROGRAMS =====`n`n"
Get-Content $InstalledProgramsPath | Add-Content $CombinedFile

Add-Content $CombinedFile "`n`n===== RUNNING SERVICES =====`n`n"
Get-Content $RunningServicesPath | Add-Content $CombinedFile

Add-Content $CombinedFile "`n`n===== OPEN PORTS =====`n`n"
Get-Content $OpenPortsPath | Add-Content $CombinedFile

Add-Content $CombinedFile "`n`n===== FIREWALL RULES =====`n`n"
Get-Content $FirewallRulesPath | Add-Content $CombinedFile

# === DONE ===
Write-Host "Audit completed. All reports saved in $OutputDir"
