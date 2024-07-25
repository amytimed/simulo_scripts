# Simulo Scripts

Welcome! Here I have my Simulo scripting projects.

## Setup

### Linux
Bash
```bash
git clone https://github.com/aMyTimed/simulo_scripts.git ~/.config/simulo/scripts/@amy
```

### Windows
PowerShell (untested)
```powershell
$DocumentsPath = [Environment]::GetFolderPath("MyDocuments")
git clone https://github.com/aMyTimed/simulo_scripts.git "$DocumentsPath/simulo/scripts/@amy"
```

## Updating

### Linux
Bash
```bash
bash -c "cd ~/.config/simulo/scripts/@amy; git pull;"
```

### Windows
PowerShell (untested)
```powershell
$ScriptPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "simulo", "scripts", "@amy")
cd $ScriptPath
git pull
```
