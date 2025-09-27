# Software Backup & Recovery Checklist

## 🎯 BACKUP PRIORITIES (Tomorrow's Tasks)

### **Priority 1: Critical Data**
- [ ] **Sticky Notes** - Export to Word document or verify Microsoft account sync
- [ ] **Browser bookmarks/passwords** (Chrome, Edge, Firefox)
- [ ] **SSH keys** (`~/.ssh/` folder)
- [ ] **Git configurations** (`.gitconfig`, credentials)
- [ ] **Project files** (entire `Desktop\2025_apps` folder)
- [ ] **Documents folder** contents
- [ ] **Downloads folder** important files

### **Priority 2: Configuration Files**  
- [ ] **PowerShell profiles** (`$PROFILE` locations)
- [ ] **Terminal settings** (Windows Terminal, WSL configs)
- [ ] **VS Code/Cursor settings** (export settings sync)
- [ ] **Environment variables** (PATH, custom variables)
- [ ] **Registry exports** for critical app settings

### **Priority 3: System Backup**
- [ ] **Create system image** to external drive (Control Panel > System and Security > Backup and Restore)
- [ ] **Verify system restore point** exists
- [ ] **Document current Windows version** (`winver` screenshot)

---

## 💾 INSTALLED SOFTWARE INVENTORY

### **Development Tools** (Will need reinstallation if Windows Reset)
- [ ] **Cursor** - Modern AI-powered code editor
- [ ] **Visual Studio Code** (if separate from Cursor)
- [ ] **Git for Windows** 
- [ ] **Node.js/npm** (check version: `node --version`)
- [ ] **Python** (check version: `python --version`)
- [ ] **WSL distributions** (Ubuntu, etc.)
- [ ] **Docker Desktop** (the original problem!)

### **Browsers & Communication**
- [ ] **Google Chrome**
- [ ] **Mozilla Firefox** 
- [ ] **Microsoft Edge** (built-in, but extensions/settings)
- [ ] **Discord**
- [ ] **Slack**
- [ ] **Teams**

### **Media & Creative**
- [ ] **VLC Media Player**
- [ ] **Adobe products** (if any)
- [ ] **OBS Studio**
- [ ] **Spotify**

### **Productivity**
- [ ] **Microsoft Office** (or Office 365)
- [ ] **Notepad++**
- [ ] **7-Zip** or **WinRAR**
- [ ] **PDF readers**

### **Gaming** (if applicable)
- [ ] **Steam** (games can be re-downloaded)
- [ ] **Epic Games Launcher**
- [ ] **Battle.net**

### **System Utilities**
- [ ] **Antivirus software**
- [ ] **CCleaner** or similar
- [ ] **Hardware monitoring tools**

### **Specialized Software**
- [ ] **[Your specific work tools]**
- [ ] **[Industry-specific software]**
- [ ] **[Any custom/rare software]**

---

## 🔧 QUICK INVENTORY COMMANDS

Run these to document current installations:

```powershell
# Installed programs via Windows Programs & Features
Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Sort-Object Name

# Windows Store apps
Get-AppxPackage | Select-Object Name, Version | Sort-Object Name

# Python packages (if Python installed)
pip list

# Node.js packages (if Node installed)  
npm list -g --depth=0

# Git configuration
git config --list
```

---

## 🗂️ BACKUP LOCATIONS TO CHECK

### **Common Software Settings Locations:**
- `%APPDATA%` - Most application data
- `%LOCALAPPDATA%` - Local application data  
- `%USERPROFILE%` - User profile folder
- `C:\Users\[username]\AppData\Roaming`
- `C:\Users\[username]\AppData\Local`

### **Development Environment Backups:**
- **Cursor/VS Code**: Settings, extensions, keybindings, snippets
- **SSH Keys**: `%USERPROFILE%\.ssh\`
- **Git Config**: `.gitconfig` in user home
- **Terminal**: Windows Terminal settings JSON

---

## 📋 RECOVERY STRATEGY OPTIONS

### **Option 1: System Restore** (Try First)
- **Pros**: Preserves everything, quick rollback
- **Cons**: Might not fix deep FOD system corruption
- **Time**: 30 minutes
- **Data Loss**: None

### **Option 2: In-Place Windows 11 Upgrade** 
- **Pros**: Likely fixes FOD system, preserves most software
- **Cons**: Some reconfiguration needed
- **Time**: 2-3 hours
- **Data Loss**: Minimal (some settings)

### **Option 3: Windows Reset "Keep Files"**
- **Pros**: Guaranteed fix, clean Windows install
- **Cons**: Must reinstall ALL software
- **Time**: 4-6 hours (including software reinstalls)
- **Data Loss**: All software, most settings

---

## ✅ TOMORROW'S ACTION PLAN

1. **Run inventory commands** above to document current software
2. **Export critical configurations** (Cursor settings, browser bookmarks, etc.)
3. **Copy project files** to external drive
4. **Create system image backup** to external drive
5. **Verify sticky notes** are backed up
6. **Choose recovery strategy** based on backup completeness

**Remember**: Your personal files (Documents, Desktop, etc.) are safe in ALL scenarios. The risk is only to installed software and system configurations.
