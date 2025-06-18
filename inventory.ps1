# inventory.ps1
# Audit Script for Windows Server 2022
# Generates report on Installed Programs, Running Services, Open Ports, and Firewall Rules

# === CONFIGURATION ===
$BaseOutputDir = "C:\AuditOutput"

# === PREPARE OUTPUT FOLDER ===
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
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

# === Chrome Bookmarks ===
Write-Host "Collecting Chrome Bookmarks"
# Path to Chrome Bookmarks JSON file
$BookmarksPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks"

# Read JSON file
$Bookmarks = Get-Content -Raw -Path $BookmarksPath | ConvertFrom-Json

# Recursive function with Folder Path
function Get-Bookmarks ($Nodes, $CurrentPath) {
    $Results = @()

    foreach ($Node in $Nodes) {
        if ($Node.type -eq 'url') {
            $Results += [PSCustomObject]@{
                FolderPath = $CurrentPath
                Name       = $Node.name
                URL        = $Node.url
            }
        }
        elseif ($Node.type -eq 'folder' -and $Node.children) {
            # Recurse into subfolder
            $SubPath = if ($CurrentPath) { "$CurrentPath\$($Node.name)" } else { $Node.name }
            $Results += Get-Bookmarks $Node.children $SubPath
        }
    }

    return $Results
}

# Now handle each root that exists
$Roots = @(
    @{ Name = 'Bookmark Bar'; Node = $Bookmarks.roots.bookmark_bar },
    @{ Name = 'Other Bookmarks'; Node = $Bookmarks.roots.other },
    @{ Name = 'Synced'; Node = $Bookmarks.roots.synced }
)

$AllBookmarks = @()

foreach ($Root in $Roots) {
    if ($Root.Node -and $Root.Node.children) {
        $RootPath = $Root.Name
        $AllBookmarks += Get-Bookmarks $Root.Node.children $RootPath
    }
}

# Export result to CSV (preserving order — no Sort-Object!)
$ChromeBookmarksPath = "$OutputDir\Chrome_Bookmarks.csv"
if ($AllBookmarks.Count -gt 0) {
    $AllBookmarks | Export-Csv -Path $ChromeBookmarksPath -NoTypeInformation
} else {
    Write-Host "No bookmarks found to export. (You may only have folders)"
}

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

Add-Content $CombinedFile "`n`n===== Chrome Bookmarks =====`n`n"
Get-Content $ChromeBookmarksPath | Add-Content $CombinedFile

# === DONE ===
Write-Host "Audit completed. All reports saved in $OutputDir"
