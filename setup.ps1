# Windows PowerShell Development Environment Setup Script
# Equivalent to the cross-platform bash script for Windows

# Requires PowerShell 5.0 or later
#Requires -Version 5.0

# Set execution policy for current user (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Color codes for output
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$BLUE = "Cyan"
$WHITE = "White"

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $BLUE
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $GREEN
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $YELLOW
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $RED
}

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to install Chocolatey
function Install-Chocolatey {
    Write-Status "Installing Chocolatey..."
    
    if (Test-Command "choco") {
        Write-Warning "Chocolatey is already installed"
        return
    }
    
    try {
        # Set TLS 1.2 for security
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        
        # Download and install Chocolatey
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Success "Chocolatey installed successfully"
    }
    catch {
        Write-Error "Failed to install Chocolatey: $_"
        throw
    }
}

# Function to install curl
function Install-Curl {
    Write-Status "Installing curl..."
    
    if (Test-Command "curl") {
        Write-Warning "curl is already installed"
        return
    }
    
    try {
        choco install curl -y
        Write-Success "curl installed successfully"
    }
    catch {
        Write-Error "Failed to install curl: $_"
        throw
    }
}

# Function to install wget
function Install-Wget {
    Write-Status "Installing wget..."
    
    if (Test-Command "wget") {
        Write-Warning "wget is already installed"
        return
    }
    
    try {
        choco install wget -y
        Write-Success "wget installed successfully"
    }
    catch {
        Write-Error "Failed to install wget: $_"
        throw
    }
}

# Function to install Miniconda
function Install-Miniconda {
    Write-Status "Installing Miniconda..."
    
    if (Test-Command "conda") {
        Write-Warning "Conda is already installed"
        return
    }
    
    try {
        # Check if miniconda directory exists and remove it
        $minicondaPath = "$env:USERPROFILE\miniconda3"
        if (Test-Path $minicondaPath) {
            Write-Warning "Miniconda directory already exists, removing it first..."
            Remove-Item $minicondaPath -Recurse -Force
        }
        
        # Install Miniconda via Chocolatey
        choco install miniconda3 -y
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Alternative: Download and install manually if chocolatey fails
        if (-not (Test-Command "conda")) {
            Write-Status "Chocolatey installation failed, trying manual installation..."
            
            $installerUrl = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
            $installerPath = "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe"
            
            # Download installer
            Write-Status "Downloading Miniconda installer..."
            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
            
            # Install silently
            Write-Status "Installing Miniconda silently..."
            Start-Process -FilePath $installerPath -ArgumentList "/InstallationType=JustMe", "/RegisterPython=1", "/S", "/D=$minicondaPath" -Wait
            
            # Remove installer
            Remove-Item $installerPath -Force
            
            # Add to PATH
            $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
            $newPath = "$minicondaPath;$minicondaPath\Scripts;$minicondaPath\Library\bin"
            [System.Environment]::SetEnvironmentVariable("Path", "$userPath;$newPath", "User")
            
            # Refresh current session PATH
            $env:Path = "$env:Path;$newPath"
        }
        
        # Initialize conda for PowerShell
        if (Test-Command "conda") {
            conda init powershell
            Write-Success "Miniconda installed and initialized successfully"
        }
        else {
            throw "Conda command not found after installation"
        }
    }
    catch {
        Write-Error "Failed to install Miniconda: $_"
        throw
    }
}

# Function to install Visual Studio Code
function Install-VSCode {
    Write-Status "Installing Visual Studio Code..."
    
    if (Test-Command "code") {
        Write-Warning "VS Code is already installed"
        return
    }
    
    try {
        choco install vscode -y
        Write-Success "Visual Studio Code installed successfully"
    }
    catch {
        Write-Error "Failed to install VS Code: $_"
        throw
    }
}

# Function to install Git
function Install-Git {
    Write-Status "Installing Git..."
    
    if (Test-Command "git") {
        Write-Warning "Git is already installed"
        return
    }
    
    try {
        choco install git -y
        Write-Success "Git installed successfully"
    }
    catch {
        Write-Error "Failed to install Git: $_"
        throw
    }
}

# Function to install GCC (MinGW)
function Install-GCC {
    Write-Status "Installing GCC (MinGW)..."
    
    if (Test-Command "gcc") {
        Write-Warning "GCC is already installed"
        return
    }
    
    try {
        choco install mingw -y
        Write-Success "GCC (MinGW) installed successfully"
    }
    catch {
        Write-Error "Failed to install GCC: $_"
        throw
    }
}

# Function to create conda environment and install packages
function New-CondaEnvironment {
    Write-Status "Creating conda environment 'J' and installing packages..."
    
    try {
        # Ensure conda is available
        if (-not (Test-Command "conda")) {
            Write-Error "Conda is not available. Please restart PowerShell or refresh environment variables."
            return
        }
        
        # Configure conda
        conda config --set auto_activate_base false
        
        # Check if environment already exists
        $envList = conda env list | Out-String
        if ($envList -match "^J\s") {
            Write-Warning "Environment 'J' already exists, removing it first..."
            conda env remove -n J -y
        }
        
        # Create environment
        Write-Status "Creating conda environment 'J' with Python 3.9..."
        conda create -n J python=3.9 -y
        
        # Install packages using conda run
        Write-Status "Installing packages in environment 'J'..."
        conda run -n J python -m pip install --upgrade pip
        conda run -n J pip install numpy pandas matplotlib seaborn gradio
        
        Write-Success "Conda environment 'J' created successfully with all required packages!"
        Write-Status "To activate the environment, run: conda activate J"
        
        # Show installed packages
        Write-Status "Installed packages in environment 'J':"
        $packages = conda run -n J pip list | Select-String -Pattern "(numpy|pandas|matplotlib|seaborn|gradio|pip)"
        $packages | ForEach-Object { Write-Host "  $_" -ForegroundColor $WHITE }
    }
    catch {
        Write-Error "Failed to create conda environment: $_"
        throw
    }
}

# Function to refresh environment variables
function Update-Environment {
    Write-Status "Refreshing environment variables..."
    
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Remove duplicates and empty entries
    $env:Path = ($env:Path -split ';' | Where-Object { $_ -ne '' } | Sort-Object -Unique) -join ';'
}

# Main execution function
function Main {
    Write-Status "Starting Windows PowerShell development environment setup..."
    Write-Status "Detected OS: Windows"
    
    # Check if running as administrator
    if (-not (Test-Administrator)) {
        Write-Warning "Running without administrator privileges. Some installations might fail."
        Write-Status "Consider running PowerShell as Administrator for best results."
    }
    
    try {
        # Task 1: Install curl, wget, and chocolatey
        Write-Status "=== TASK 1: Installing curl, wget, and Chocolatey ==="
        
        Install-Chocolatey
        Update-Environment
        Install-Curl
        Install-Wget
        
        Write-Success "Task 1 completed!"
        
        # Task 2: Install miniconda, vscode, git, and GCC
        Write-Status "=== TASK 2: Installing development tools ==="
        
        Install-Miniconda
        Update-Environment
        Install-VSCode
        Install-Git
        Install-GCC
        
        Write-Success "Task 2 completed!"
        
        # Task 3: Create conda environment and install Python packages
        Write-Status "=== TASK 3: Creating conda environment and installing packages ==="
        
        New-CondaEnvironment
        
        Write-Success "Task 3 completed!"
        
        Write-Success "All tasks completed successfully!"
        Write-Status "Your development environment is now ready to use."
        Write-Status ""
        Write-Status "IMPORTANT: To use conda in future PowerShell sessions:"
        Write-Status "1. Restart PowerShell, OR"
        Write-Status "2. Run: conda init powershell (if not already done)"
        Write-Status ""
        Write-Status "To activate the conda environment, run: conda activate J"
        Write-Status "To verify the installation, run: conda env list"
        Write-Status ""
        Write-Status "If you encounter PATH issues, restart PowerShell or run:"
        Write-Status "`$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')"
    }
    catch {
        Write-Error "Setup failed: $_"
        Write-Status "Please check the error messages above and try running the script again."
        Write-Status "You may need to run PowerShell as Administrator."
        exit 1
    }
}

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "This script requires PowerShell 5.0 or later. Current version: $($PSVersionTable.PSVersion)"
    exit 1
}

# Run main function
Main