# Open WebUI Development Startup Scripts

Automated startup scripts for Open WebUI development with WSL + Windows hybrid setup.

> **✨ Latest Updates:** See [UPDATES.md](UPDATES.md) for recent enhancements including unified Windows script, robust directory navigation, and enhanced venv handling!

## 🎯 Recommended: Unified Startup

### 1️⃣ Start Windows Environment (PowerShell)
```powershell
.\startup_scripts\start-windows.ps1
```

**What it does:**
- ✅ Detects if Ollama is already running
- ✅ Checks if Ollama is listening on correct interface (0.0.0.0 vs 127.0.0.1)
- ✅ Offers to restart Ollama if needed with proper WSL configuration
- ✅ Starts Ollama in background if not running (with `OLLAMA_HOST=0.0.0.0:11434`)
- ✅ Checks for `node_modules` and auto-installs if missing
- ✅ Starts Vite frontend dev server on port 5173

**Smart handling:**
- If Ollama is running correctly → keeps it
- If Ollama is listening on localhost only → offers to restart
- If Ollama is not running → starts it with correct settings

**Keep this terminal open!**

---

### 2️⃣ Start Backend (WSL)
```bash
./startup_scripts/start-backend.sh
```

**What it does:**
- Validates Ollama connectivity before starting
- Activates Python virtual environment
- Loads `.env` configuration
- Detects Windows host IP dynamically
- Counts available models
- Starts FastAPI backend with hot reload on port 8080

**Requirements:**
- `.env` file with `OLLAMA_BASE_URL='http://<windows-host-ip>:11434'`
- Virtual environment at `.venv` with dependencies installed

**Keep this terminal open!**

---

## 🔧 Alternative: Individual Scripts

If you prefer more control over each component:

### Start Ollama Only (PowerShell)
```powershell
.\startup_scripts\start-ollama.ps1
```

**What it does:**
- Sets `OLLAMA_HOST=0.0.0.0:11434` to allow WSL connections
- Checks if Ollama is already running
- Offers to restart if needed
- Starts Ollama server with correct configuration (blocks terminal)

---

### Start Frontend Only (PowerShell)
```powershell
.\startup_scripts\start-frontend.ps1
```

**What it does:**
- Checks for `node_modules` and installs if missing
- Starts Vite development server with hot reload on port 5173

**Keep this terminal open!**

---

## First-Time Setup

Before using these scripts, complete the one-time setup:

### 1. Configure Environment
Create `.env` in project root:
```bash
# Get Windows host IP from WSL
ip route show | grep -i default | awk '{ print $3}'

# Create .env with that IP
OLLAMA_BASE_URL='http://172.29.144.1:11434'  # Use your actual IP
```

### 2. Make Scripts Executable (WSL)
```bash
chmod +x startup_scripts/start-backend.sh
```

### 3. Install Dependencies

**Backend (WSL):**
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r backend/requirements.txt
```

**Frontend (Windows PowerShell):**
```powershell
npm install --legacy-peer-deps
```

---

## Script Details

### start-ollama.ps1
**Platform:** Windows PowerShell  
**Purpose:** Start Ollama with WSL-compatible configuration  
**Features:**
- ✅ Sets environment variable for WSL access
- ✅ Process detection and restart handling
- ✅ User-friendly prompts and status messages
- ✅ Color-coded output

### start-backend.sh
**Platform:** WSL (Bash)  
**Purpose:** Start FastAPI backend with validation  
**Features:**
- ✅ Pre-flight Ollama connectivity check
- ✅ Dynamic Windows host IP detection
- ✅ Model count display
- ✅ Fails fast with helpful error messages
- ✅ Hot reload enabled (`--reload`)

### start-frontend.ps1
**Platform:** Windows PowerShell  
**Purpose:** Start Vite development server  
**Features:**
- ✅ Dependency check and auto-install
- ✅ Configuration display
- ✅ Hot reload enabled

---

## Troubleshooting

### Models not showing in UI

**Symptom:** Backend starts but no models appear in the UI.

**Cause:** Ollama is not accessible from WSL.

**Solution:**
1. Check if Ollama is listening on all interfaces:
   ```powershell
   netstat -ano | findstr :11434
   ```
   Should show: `0.0.0.0:11434` (not `127.0.0.1:11434`)

2. If showing `127.0.0.1:11434`, restart Ollama:
   ```powershell
   # Stop Ollama
   Get-Process -Name "ollama" | Stop-Process -Force
   
   # Restart with correct settings
   .\startup_scripts\start-ollama.ps1
   ```

3. Test connectivity from WSL:
   ```bash
   # Get Windows host IP
   WINDOWS_HOST=$(ip route show | grep -i default | awk '{ print $3}')
   
   # Test connection
   curl http://${WINDOWS_HOST}:11434/api/tags
   ```

### Backend won't start

**Check prerequisites:**
```bash
# Is virtual environment activated?
which python  # Should show path to .venv/bin/python

# Is .env configured?
cat .env  # Should show OLLAMA_BASE_URL

# Can WSL reach Ollama?
curl http://$(ip route show | grep -i default | awk '{ print $3}'):11434/api/tags
```

### Windows host IP changed

**Symptom:** Backend starts but can't reach Ollama after network change.

**Solution:** Update `.env` with new IP:
```bash
# Get new IP
ip route show | grep -i default | awk '{ print $3}'

# Update .env
nano .env
# Change OLLAMA_BASE_URL to new IP
```

### Port already in use

**Backend (8080):**
```bash
# Find process using port 8080
lsof -i :8080
# Kill it if needed
kill -9 <PID>
```

**Frontend (5173):**
```powershell
# Find process using port 5173
Get-NetTCPConnection -LocalPort 5173 | Select-Object OwningProcess
# Kill it if needed
Stop-Process -Id <PID> -Force
```

---

## Architecture

```
Windows (PowerShell)          WSL (Ubuntu)
┌─────────────────┐          ┌──────────────────┐
│  Ollama Server  │◄─────────│  FastAPI Backend │
│  :11434         │  HTTP    │  :8080           │
│  0.0.0.0        │          │  0.0.0.0         │
└─────────────────┘          └──────────────────┘
        ▲                             ▲
        │                             │
        └─────────────┬───────────────┘
                      │
              ┌───────┴────────┐
              │ Vite Dev Server│
              │ :5173          │
              │ (Windows)      │
              └────────────────┘
```

**Key Points:**
- Ollama must listen on `0.0.0.0:11434` (all interfaces) for WSL access
- Backend forwards requests to Ollama via Windows host IP
- Frontend connects to backend for API calls
- All three must be running simultaneously

---

## Comparison with Other Scripts

| Script | Location | Purpose | Terminals | Use Case |
|--------|----------|---------|-----------|----------|
| **`start-windows.ps1`** | `startup_scripts/` | **Unified: Ollama + Frontend** | **1** | **⭐ RECOMMENDED** |
| `start-backend.sh` | `startup_scripts/` | Backend with validation | 1 | **Use this** always |
| `start-ollama.ps1` | `startup_scripts/` | Ollama only | 1 | When you need separate control |
| `start-frontend.ps1` | `startup_scripts/` | Frontend only | 1 | When you need separate control |
| `run-dev.sh` | Project root | Basic backend startup | 1 | Minimal version, no validation |
| `backend/dev.sh` | `backend/` | Project's default dev script | 1 | Generic, no WSL support |
| `run.sh` | Project root | Production-like startup | 1 | Not for development |

**Recommendation:** Use `start-windows.ps1` + `start-backend.sh` for the simplest workflow (2 terminals). The unified script handles Ollama intelligently and starts the frontend automatically.

---

## Development Workflow

### Recommended (2 terminals):
```
1. PowerShell → .\startup_scripts\start-windows.ps1
2. WSL → ./startup_scripts/start-backend.sh
3. Browser → http://localhost:5173
```

### Alternative (3 terminals):
```
1. PowerShell → .\startup_scripts\start-ollama.ps1
2. PowerShell → .\startup_scripts\start-frontend.ps1
3. WSL → ./startup_scripts/start-backend.sh
4. Browser → http://localhost:5173
```

**Hot reload is enabled** - just edit and save:
- Frontend: Instant updates in browser
- Backend: Auto-reloads on file save

**Stopping:**
- Press `Ctrl+C` in each terminal window

---

## Advanced Usage

### Custom Port Configuration

Edit `.env`:
```bash
PORT=3000  # Change backend port
```

Frontend proxy configuration is in `vite.config.ts` if you need to update it.

### Running Without Validation

If you want to skip Ollama validation (not recommended):
```bash
# Use the basic script instead
./run-dev.sh
```

### Windows Firewall Configuration

If WSL can't reach Ollama, ensure firewall rule exists:
```powershell
New-NetFirewallRule -DisplayName "Ollama for WSL" -Direction Inbound -LocalPort 11434 -Protocol TCP -Action Allow
```

---

## See Also

- [DEV_GUIDE.md](../docs/DEV_GUIDE.md) - Complete development guide
- [STARTUP_SCRIPTS.md](../docs/STARTUP_SCRIPTS.md) - Detailed script comparison
- [Official Documentation](https://docs.openwebui.com/)
