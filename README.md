# Windows-sys-audit

## Description

This PowerShell script collects detailed hardware, software, and network information from a Windows system for auditing or documentation purposes. It outputs the data to a designated directory on the local machine.

## Usage

Upon cloning the Repo to a Windows machine

1. **Navigate into the project directory**:  
   `cd Linux-sys-audit`

2. **Run the script**:  
   `./inventory.sh`

3. **View the results**:  
   The output of the system audit will be saved in within `Documents/software_inventory`.

## 📁 Features

- **System Overview**: Collects general computer info such as OS version, architecture, and build.
- **Hardware Inventory**:
  - CPU details
  - Physical memory (RAM) modules
  - Disk drive specifications
- **Network Information**:
  - Adapter configurations (IP, DNS, Gateway)
  - Active TCP/UDP connections (`netstat`)
  - Shared folders over SMB
- **Installed Software**: Gathers installed program data from the registry (including 32-bit apps).
- **Output Management**: Automatically creates an output directory in `Documents\software_inventory` if it doesn't exist.

## 📄 Output Files
- `ComputerInfo.txt`
- `CPU.txt`
- `Memory.txt`
- `Disk.txt`
- `Network.txt`
- `InstalledPrograms.txt`
- `IPConfiguration.txt`
- `ActiveConnections.txt`
- `SharedFolders.txt`

## License 

Please refer to the LICENSE in the repo.
