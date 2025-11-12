# Open WebUI - Development Guide

Complete guide for running Open WebUI in development mode with WSL + Windows.

---

## 🚀 Quick Start (Daily Workflow)

**Two terminals needed: PowerShell → WSL**

### Step 1: Start Windows Environment (PowerShell)
```powershell
.\startup_scripts\start-windows.ps1
```
✅ Configures and starts Ollama for WSL access  
✅ Detects if Ollama already running (offers restart if needed)  
✅ Checks if listening on correct interface (0.0.0.0 vs 127.0.0.1)  
✅ Starts frontend dev server  
✅ Auto-installs dependencies if needed  
**Keep terminal open**

### Step 2: Start Backend (WSL)
```bash
./startup_scripts/start-backend.sh
```
✅ Validates Ollama connectivity  
✅ Shows model count  
✅ Fails fast with helpful errors  
**Keep terminal open**

### Step 3: Open Browser
**http://localhost:5173** 🎉

---

### Alternative: Separate Scripts

If you prefer more control over each component:

```powershell
# Terminal 1: Just Ollama
.\startup_scripts\start-ollama.ps1

# Terminal 2: Just Frontend  
.\startup_scripts\start-frontend.ps1

# Terminal 3: Backend (WSL)
./startup_scripts/start-backend.sh
```

> **💡 Tip:** See detailed documentation in [`startup_scripts/README.md`](../startup_scripts/README.md)

---

## 🛑 Stopping Everything

Press `Ctrl+C` in each terminal (in any order)

---

## 📍 Service URLs

| Service  | URL | Location |
|----------|-----|----------|
| UI | http://localhost:5173 | Windows |
| Backend API | http://localhost:8080 | WSL |
| Ollama | http://172.29.144.1:11434 | Windows |

---

## 🔍 Troubleshooting

> **💡 Pro Tip:** The automated startup scripts in `startup_scripts/` include built-in validation and will catch most issues before they become problems!

### Models Not Showing Up?

**Using the automated scripts?** The `start-backend.sh` script checks this automatically and will show you an error if Ollama isn't accessible.

**Manual testing - Test Ollama from WSL:**
```bash
curl http://172.29.144.1:11434/api/tags
```
✅ **Should return:** JSON with your models list  
❌ **If fails:** Restart Ollama with: `.\startup_scripts\start-ollama.ps1`

**Test backend connection:**
```javascript
// In browser console (F12)
fetch('http://localhost:8080/ollama/api/tags').then(r => r.json()).then(console.log)
```
✅ **Should return:** `{"models": [...]}`

### Backend Not Starting?

**Check Python version:**
```bash
python3.11 --version  # Should show Python 3.11.x
```

**Reinstall dependencies:**
```bash
source .venv/bin/activate
pip install -r backend/requirements.txt
```

### Frontend Build Errors?

**Clear cache:**
```powershell
Remove-Item -Recurse -Force node_modules\.vite
npm run dev
```

### Port Already in Use?

**Backend (8080):**
```bash
# In WSL
lsof -ti:8080 | xargs kill -9
```

**Frontend (5173):**
```powershell
# In PowerShell
netstat -ano | findstr :5173
# Note PID, then: taskkill /F /PID <PID>
```

### Ollama Not Reachable from WSL?

**Check if listening on all interfaces:**
```powershell
netstat -ano | findstr :11434
```
✅ **Good:** `0.0.0.0:11434`  
❌ **Bad:** `127.0.0.1:11434`

**Fix:** Set environment variable and restart Ollama
```powershell
$env:OLLAMA_HOST = "0.0.0.0:11434"
ollama serve
```

---

## ⚙️ One-Time Setup

**Skip this if already configured.**

### 1. Install Python 3.11 (WSL)
```bash
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev
python3.11 --version
```

### 2. Create Virtual Environment (WSL)
```bash
cd /mnt/c/Usha/GHOrgs/open-webui
python3.11 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r backend/requirements.txt
```

### 3. Install Frontend Dependencies (PowerShell)
```powershell
cd C:\Usha\GHOrgs\open-webui
npm install --legacy-peer-deps
```

### 4. Configure Environment
```bash
# Copy template
cp .env.example .env

# Find Windows IP from WSL
ip route show | grep -i default | awk '{ print $3}'
# Example: 172.29.144.1
```

**Edit `.env` file:**
```properties
OLLAMA_BASE_URL='http://172.29.144.1:11434'
```

### 5. Configure Firewall (PowerShell as Admin)
```powershell
New-NetFirewallRule -DisplayName "Ollama for WSL" -Direction Inbound -LocalPort 11434 -Protocol TCP -Action Allow
```

### 6. Set Ollama Environment Variable (PowerShell)
```powershell
[System.Environment]::SetEnvironmentVariable('OLLAMA_HOST', '0.0.0.0:11434', 'User')
```
**Restart Ollama** after this.

---

## 📁 Project Structure

```
open-webui/
├── backend/                 # Python/FastAPI backend
│   ├── open_webui/         # Application code
│   │   ├── main.py         # FastAPI entry point
│   │   ├── routers/        # API routes
│   │   ├── models/         # Database models
│   │   └── utils/          # Utilities
│   ├── requirements.txt    # Python dependencies
│   └── data/              # SQLite database
├── src/                    # Svelte frontend
│   ├── lib/               # Components
│   └── routes/            # Pages
├── .env                   # Local configuration
└── run-dev.sh            # Backend startup script
```

---

## 💡 Development Tips

**Hot Reload:**
- Backend: Python files auto-reload
- Frontend: Svelte files update instantly

**Database:**
- Location: `backend/data/webui.db`
- Reset: Delete file and restart backend

**Logs:**
- Backend: WSL terminal
- Frontend: Browser console (F12)
- Ollama: Ollama terminal

**Making Changes:**
1. Edit files in VSCode
2. Save
3. See changes immediately (usually)
4. Refresh browser if needed

---

## 🔑 Key Files

| File | Purpose |
|------|---------|
| `.env` | Backend environment variables |
| `run-dev.sh` | Backend startup script |
| `backend/requirements.txt` | Python dependencies |
| `package.json` | Node.js dependencies |
| `vite.config.ts` | Frontend build config |

---

## 🆘 Still Having Issues?

1. **Check all 3 services are running** (Ollama, Backend, Frontend)
2. **Verify URLs** in browser and configuration
3. **Check terminal output** for error messages
4. **Restart everything** in order (Ollama → Backend → Frontend)
5. **Check Windows host IP** hasn't changed: `ip route show | grep -i default | awk '{ print $3}'`
