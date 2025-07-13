#!/bin/bash

# Cross-Platform Development Environment Setup Script
# Works on Linux, macOS, and Windows (Git Bash/WSL)

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to detect Linux distribution
detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    elif command -v lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install curl
install_curl() {
    print_status "Installing curl..."
    
    case $OS in
        "linux")
            case $LINUX_DISTRO in
                "ubuntu"|"debian")
                    sudo apt update && sudo apt install -y curl
                    ;;
                "centos"|"rhel"|"fedora")
                    if command_exists dnf; then
                        sudo dnf install -y curl
                    else
                        sudo yum install -y curl
                    fi
                    ;;
                "arch")
                    sudo pacman -S --noconfirm curl
                    ;;
                *)
                    print_error "Unsupported Linux distribution for automatic curl installation"
                    return 1
                    ;;
            esac
            ;;
        "macos")
            if command_exists brew; then
                brew install curl
            else
                print_warning "curl should be available by default on macOS"
            fi
            ;;
        "windows")
            print_warning "curl should be available by default on Windows 10/11"
            ;;
    esac
}

# Function to install wget
install_wget() {
    print_status "Installing wget..."
    
    case $OS in
        "linux")
            case $LINUX_DISTRO in
                "ubuntu"|"debian")
                    sudo apt update && sudo apt install -y wget
                    ;;
                "centos"|"rhel"|"fedora")
                    if command_exists dnf; then
                        sudo dnf install -y wget
                    else
                        sudo yum install -y wget
                    fi
                    ;;
                "arch")
                    sudo pacman -S --noconfirm wget
                    ;;
                *)
                    print_error "Unsupported Linux distribution for automatic wget installation"
                    return 1
                    ;;
            esac
            ;;
        "macos")
            if command_exists brew; then
                brew install wget
            else
                print_error "Please install Homebrew first to install wget on macOS"
                return 1
            fi
            ;;
        "windows")
            print_warning "wget will be installed via chocolatey"
            ;;
    esac
}

# Function to install chocolatey (Windows only)
install_chocolatey() {
    if [ "$OS" = "windows" ]; then
        print_status "Installing Chocolatey..."
        if ! command_exists choco; then
            powershell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        else
            print_warning "Chocolatey is already installed"
        fi
    else
        print_warning "Chocolatey is Windows-only, skipping on $OS"
    fi
}

# Function to install Homebrew (macOS only)
install_homebrew() {
    if [ "$OS" = "macos" ]; then
        print_status "Installing Homebrew..."
        if ! command_exists brew; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            print_warning "Homebrew is already installed"
        fi
    fi
}

# Function to install miniconda
install_miniconda() {
    print_status "Installing Miniconda..."
    
    if command_exists conda; then
        print_warning "Conda is already installed"
        return 0
    fi
    
    case $OS in
        "linux")
            # Check if miniconda directory already exists
            if [ -d "$HOME/miniconda3" ]; then
                print_warning "Miniconda directory already exists, removing it first..."
                rm -rf "$HOME/miniconda3"
            fi
            
            curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
            # Install with batch mode and accept license
            bash miniconda.sh -b -p $HOME/miniconda3
            rm miniconda.sh
            
            # Add conda to PATH in bashrc if not already present
            if ! grep -q "miniconda3/bin" ~/.bashrc; then
                echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
            fi
            
            # Initialize conda for bash
            $HOME/miniconda3/bin/conda init bash
            
            # Make conda available in current session
            export PATH="$HOME/miniconda3/bin:$PATH"
            ;;
        "macos")
            # Check if miniconda directory already exists
            if [ -d "$HOME/miniconda3" ]; then
                print_warning "Miniconda directory already exists, removing it first..."
                rm -rf "$HOME/miniconda3"
            fi
            
            curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -o miniconda.sh
            # Install with batch mode and accept license
            bash miniconda.sh -b -p $HOME/miniconda3
            rm miniconda.sh
            
            # Add conda to PATH in bash_profile if not already present
            if ! grep -q "miniconda3/bin" ~/.bash_profile 2>/dev/null; then
                echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bash_profile
            fi
            
            # Initialize conda for bash
            $HOME/miniconda3/bin/conda init bash
            
            # Make conda available in current session
            export PATH="$HOME/miniconda3/bin:$PATH"
            ;;
        "windows")
            if command_exists choco; then
                choco install miniconda3 -y
                # Refresh environment variables
                refreshenv
            else
                print_error "Chocolatey is required to install Miniconda on Windows"
                return 1
            fi
            ;;
    esac
}

# Function to install VS Code
install_vscode() {
    print_status "Installing Visual Studio Code..."
    
    if command_exists code; then
        print_warning "VS Code is already installed"
        return 0
    fi
    
    case $OS in
        "linux")
            case $LINUX_DISTRO in
                "ubuntu"|"debian")
                    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
                    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
                    sudo apt update && sudo apt install -y code
                    ;;
                "centos"|"rhel"|"fedora")
                    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
                    if command_exists dnf; then
                        sudo dnf install -y code
                    else
                        sudo yum install -y code
                    fi
                    ;;
                "arch")
                    sudo pacman -S --noconfirm code
                    ;;
            esac
            ;;
        "macos")
            if command_exists brew; then
                brew install --cask visual-studio-code
            else
                print_error "Homebrew is required to install VS Code on macOS"
                return 1
            fi
            ;;
        "windows")
            if command_exists choco; then
                choco install vscode -y
            else
                print_error "Chocolatey is required to install VS Code on Windows"
                return 1
            fi
            ;;
    esac
}

# Function to install Git
install_git() {
    print_status "Installing Git..."
    
    if command_exists git; then
        print_warning "Git is already installed"
        return 0
    fi
    
    case $OS in
        "linux")
            case $LINUX_DISTRO in
                "ubuntu"|"debian")
                    sudo apt update && sudo apt install -y git
                    ;;
                "centos"|"rhel"|"fedora")
                    if command_exists dnf; then
                        sudo dnf install -y git
                    else
                        sudo yum install -y git
                    fi
                    ;;
                "arch")
                    sudo pacman -S --noconfirm git
                    ;;
            esac
            ;;
        "macos")
            if command_exists brew; then
                brew install git
            else
                print_warning "Git should be available via Xcode command line tools"
                xcode-select --install
            fi
            ;;
        "windows")
            if command_exists choco; then
                choco install git -y
            else
                print_error "Chocolatey is required to install Git on Windows"
                return 1
            fi
            ;;
    esac
}

# Function to install GCC
install_gcc() {
    print_status "Installing GCC..."
    
    if command_exists gcc; then
        print_warning "GCC is already installed"
        return 0
    fi
    
    case $OS in
        "linux")
            case $LINUX_DISTRO in
                "ubuntu"|"debian")
                    sudo apt update && sudo apt install -y build-essential
                    ;;
                "centos"|"rhel"|"fedora")
                    if command_exists dnf; then
                        sudo dnf groupinstall -y "Development Tools"
                    else
                        sudo yum groupinstall -y "Development Tools"
                    fi
                    ;;
                "arch")
                    sudo pacman -S --noconfirm base-devel
                    ;;
            esac
            ;;
        "macos")
            if command_exists brew; then
                brew install gcc
            else
                print_warning "GCC should be available via Xcode command line tools"
                xcode-select --install
            fi
            ;;
        "windows")
            if command_exists choco; then
                choco install mingw -y
            else
                print_error "Chocolatey is required to install GCC on Windows"
                return 1
            fi
            ;;
    esac
}

# Function to create conda environment and install packages
create_conda_env() {
    print_status "Creating conda environment 'J' and installing packages..."
    
    # Ensure conda is available in current session
    if [ "$OS" != "windows" ]; then
        export PATH="$HOME/miniconda3/bin:$PATH"
        
        # Source conda setup if it exists
        if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
            source "$HOME/miniconda3/etc/profile.d/conda.sh"
        fi
    fi
    
    # Verify conda is available
    if ! command_exists conda; then
        print_error "Conda is not available. Please restart your terminal or run: export PATH=\"\$HOME/miniconda3/bin:\$PATH\""
        return 1
    fi
    
    # Configure conda
    conda config --set auto_activate_base false
    
    # Check if environment already exists
    if conda env list | grep -q "^J "; then
        print_warning "Environment 'J' already exists, removing it first..."
        conda env remove -n J -y
    fi
    
    # Create environment
    print_status "Creating conda environment 'J' with Python 3.9..."
    conda create -n J python=3.9 -y
    
    # Activate environment and install packages
    print_status "Activating environment and installing packages..."
    
    # Use conda run to execute commands in the environment
    conda run -n J python -m pip install --upgrade pip
    conda run -n J pip install numpy pandas matplotlib seaborn gradio
    
    print_success "Conda environment 'J' created successfully with all required packages!"
    print_status "To activate the environment, run: conda activate J"
    
    # Show installed packages
    print_status "Installed packages in environment 'J':"
    conda run -n J pip list | grep -E "(numpy|pandas|matplotlib|seaborn|gradio|pip|notebook)"
}

# Main execution
main() {
    print_status "Starting cross-platform development environment setup..."
    
    # Detect OS
    OS=$(detect_os)
    print_status "Detected OS: $OS"
    
    if [ "$OS" = "unknown" ]; then
        print_error "Unsupported operating system"
        exit 1
    fi
    
    # Detect Linux distribution if on Linux
    if [ "$OS" = "linux" ]; then
        LINUX_DISTRO=$(detect_linux_distro)
        print_status "Detected Linux distribution: $LINUX_DISTRO"
    fi
    
    # Task 1: Install curl, wget, and chocolatey
    print_status "=== TASK 1: Installing curl, wget, and package managers ==="
    
    # Install package managers first
    if [ "$OS" = "macos" ]; then
        install_homebrew
    elif [ "$OS" = "windows" ]; then
        install_chocolatey
    fi
    
    # Install curl
    if ! command_exists curl; then
        install_curl
    else
        print_warning "curl is already installed"
    fi
    
    # Install wget
    if ! command_exists wget; then
        install_wget
    else
        print_warning "wget is already installed"
    fi
    
    print_success "Task 1 completed!"
    
    # Task 2: Install miniconda, vscode, git, and GCC
    print_status "=== TASK 2: Installing development tools ==="
    
    install_miniconda
    install_vscode
    install_git
    install_gcc
    
    print_success "Task 2 completed!"
    
    # Task 3: Create conda environment and install Python packages
    print_status "=== TASK 3: Creating conda environment and installing packages ==="
    
    create_conda_env
    
    print_success "Task 3 completed!"
    
    print_success "All tasks completed successfully!"
    print_status "Your development environment is now ready to use."
    print_status ""
    print_status "IMPORTANT: To use conda in future terminal sessions, either:"
    print_status "1. Restart your terminal, OR"
    print_status "2. Run: source ~/.bashrc (Linux) or source ~/.bash_profile (macOS)"
    print_status ""
    print_status "To activate the conda environment, run: conda activate J"
    print_status "To verify the installation, run: conda env list"
}

# Run main function
main "$@"