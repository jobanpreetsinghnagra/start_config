

# 🔧 Setup Script

Automatically detects your operating system (Linux, macOS, or Windows with WSL/PowerShell) and installs essential tools and environments.

---

## 🧰 Prerequisites

Make sure you have:

* bash (on Linux/macOS) or PowerShell on Windows.
* Internet access for downloading packages.

---

## 🚀 Installation

Make the setup script executable and run it:

```bash
chmod +x setup.sh
./setup.sh
```

---

## 🛠️ What the Script Installs

### 1. Package Managers

* `wget`
* `curl`
* `chocolatey` 

### 2. Developer Tools

* **Visual Studio Code**
* **GCC**
* **Miniconda**
* **Git**

### 3. Python Environment

* Creates a conda environment named `J`
* Installs these Python packages:

```
pip
numpy
pandas
matplotlib
seaborn
gradio
notebook
```

---

## ✅ Usage

Once installation completes:

```bash
source ~/.bashrc (linux)
source ~/.bash_profile (MacOS)
conda activate J
jupyter notebook
```

This will launch Jupyter Notebook in your default browser, with all packages ready to use.

---

## 📋 Directory Structure

```
.
├── setup.sh      # The installation script
└── README.md     # This guide
```

Add more scripts or folders as needed; this basic structure is easily extensible. ([tilburgsciencehub.com][1], [medium.com][2])

---

## 📚 Contributing

1. Fork the project
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push and open a pull request

---

## 👥 Authors & Acknowledgements

* Original script by Joban