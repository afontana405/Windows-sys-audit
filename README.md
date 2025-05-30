# Windows-sys-audit

## Description

This PowerShell script collects detailed hardware, software, and network information from a Windows system for auditing or documentation purposes. It outputs the data to a designated directory on the local machine.

## Usage

Upon cloning the Repo to a Windows machine within powershell

1. **Navigate into the project directory**:  
   `cd Windows-sys-audit`

2. **Run the script** using one of the following methods:

   ### Option A – Run Normally (if your system allows scripts):  
   `.\inventory.ps1`

   ### Option B – If You See a "Running scripts is disabled" Error:  
   Bypass the execution policy for this session:  
   `powershell -ExecutionPolicy Bypass -File .\inventory.ps1`

3. **View the results**:  
   The output of the system audit will be saved within `Documents\software_inventory`.

## Features

- **System Overview**: Collects general computer info such as OS version, architecture, and build.
- **Hardware Inventory**:
  - CPU details
  - Physical memory (RAM) modules
  - Disk drive specifications
- **Network Information**:
  - Adapter configurations (IP, DNS, Gateway)
  - Active TCP/UDP connections (`netstat`)
  - Shared folders over SMB
- **Installed Software**: Collects data on installed applications from the registry (including 32-bit programs), identifies programs configured to run at system startup or user login, and reports on antivirus and firewall status.
- **Output Management**: Automatically creates an output directory in `Documents\software_inventory` if it doesn't exist.

## Output File Structure
```
Documents\
└─ software_inventory\
   ├── hardware\
   │   ├── ComputerInfo.txt
   │   ├── CPU.txt
   │   ├── Memory.txt
   │   └── Disk.txt
   ├── software\
   │   ├── InstalledPrograms.txt
   │   ├── StartupPrograms.txt
   │   └── SecuritySoftware.txt
   └── network\
       ├── Network.txt
       ├── IPConfiguration.txt
       ├── ActiveConnections.txt
       └── SharedFolders.txt
```
## License 

Please refer to the LICENSE in the repo.
