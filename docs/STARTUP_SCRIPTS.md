# Startup Scripts Comparison

This document explains the different startup scripts in Open WebUI and why we created `run-dev.sh`.

---

## 📋 Available Scripts

### 1. `run-dev.sh` (Custom - Created for WSL Development)

**Location:** Project root  
**Purpose:** Simplified development startup for WSL environment  
**What it does:**
- ✅ Activates Python virtual environment automatically
- ✅ Loads environment variables from `.env` file
- ✅ Sets CORS for frontend/backend communication
- ✅ Provides helpful console output (emoji, clear status)
- ✅ Runs from project root (no need to `cd backend/`)
- ✅ Uses hot reload for development

**Usage:**
```bash
cd /mnt/c/Usha/GHOrgs/open-webui
./run-dev.sh
```

**Why we created it:**
- Original scripts assume you're already in certain directories
- Need to manually activate venv and load .env
- Wanted a single command to start everything
- Better user experience with clear output

---

### 2. `backend/dev.sh` (Original)

**Location:** `backend/` folder  
**Purpose:** Basic development server startup  
**What it does:**
- Sets CORS_ALLOW_ORIGIN
- Starts uvicorn with hot reload
- Minimal configuration

**Usage:**
```bash
cd backend
source ../.venv/bin/activate
export $(grep -v '^#' ../.env | xargs)  # Manual .env load
bash dev.sh
```

**Limitations:**
- ❌ Must be run from `backend/` directory
- ❌ Doesn't activate virtual environment
- ❌ Doesn't load `.env` file automatically
- ❌ No user-friendly output

---

### 3. `run.sh` (Original - Docker)

**Location:** Project root  
**Purpose:** Production Docker deployment  
**What it does:**
- Builds Docker image
- Stops/removes old container
- Starts new container with Docker
- Maps port 3000:8080
- Runs as daemon with auto-restart

**Usage:**
```bash
./run.sh
```

**When to use:**
- Production deployment
- Running with Docker
- Testing containerized version
- **NOT for development** (no hot reload, hard to debug)

---

## 🔄 Comparison

| Feature | `run-dev.sh` (Custom) | `backend/dev.sh` (Original) | `run.sh` (Docker) |
|---------|----------------------|---------------------------|-------------------|
| **Activates venv** | ✅ Automatic | ❌ Manual | N/A (Docker) |
| **Loads .env** | ✅ Automatic | ❌ Manual | ❌ Manual |
| **Hot reload** | ✅ Yes | ✅ Yes | ❌ No |
| **Run from root** | ✅ Yes | ❌ No (must cd) | ✅ Yes |
| **User-friendly output** | ✅ Yes | ❌ Minimal | ❌ Minimal |
| **Sets CORS** | ✅ Yes | ✅ Yes | ❌ No |
| **Environment** | Native/WSL | Native/WSL | Docker |
| **Best for** | Daily development | Quick server start | Production |

---

## 💡 Why `run-dev.sh` is Better for Development

### Before (using `backend/dev.sh`):
```bash
cd /mnt/c/Usha/GHOrgs/open-webui
source .venv/bin/activate
export $(grep -v '^#' .env | xargs)
cd backend
bash dev.sh
```
**5 commands, easy to forget steps**

### After (using `run-dev.sh`):
```bash
cd /mnt/c/Usha/GHOrgs/open-webui
./run-dev.sh
```
**2 commands, everything handled automatically**

---

## 📝 Key Improvements in `run-dev.sh`

1. **Automatic venv activation**
   ```bash
   source .venv/bin/activate
   ```

2. **Automatic .env loading**
   ```bash
   export $(grep -v '^#' .env | xargs)
   ```

3. **Clear status output**
   ```bash
   echo "🚀 Starting Open WebUI Development Server..."
   echo "Environment configured:"
   echo "  OLLAMA_BASE_URL: $OLLAMA_BASE_URL"
   ```

4. **Works from project root**
   ```bash
   cd "$(dirname "$0")"  # Always runs from script location
   cd backend             # Then navigates to backend
   ```

5. **WSL-specific configuration**
   ```bash
   --host 0.0.0.0                    # Listen on all interfaces
   --forwarded-allow-ips '*'         # Allow WSL-to-Windows access
   ```

---

## 🎯 When to Use Each Script

### Use `run-dev.sh`
- ✅ Daily development
- ✅ Working with WSL + Windows setup
- ✅ Need hot reload
- ✅ Want simple, one-command startup

### Use `backend/dev.sh`
- ⚠️ Already in backend directory
- ⚠️ venv already activated
- ⚠️ .env already loaded
- ⚠️ Prefer minimal script

### Use `run.sh`
- 🐳 Testing Docker build
- 🐳 Production deployment
- 🐳 Running multiple instances
- ❌ NOT for development (slow, no hot reload)

---

## 🔍 Technical Details

### Hot Reload Mechanism
```bash
uvicorn open_webui.main:app --reload
```
- Watches Python files for changes
- Automatically restarts server on file save
- Fast development iteration

### CORS Configuration
```bash
export CORS_ALLOW_ORIGIN="http://localhost:5173;http://localhost:8080"
```
- Allows frontend (5173) to call backend (8080)
- Semicolon-separated list of allowed origins
- Required for WSL/Windows cross-environment setup

### Network Binding
```bash
--host 0.0.0.0 --forwarded-allow-ips '*'
```
- `0.0.0.0`: Listen on all network interfaces (not just localhost)
- `--forwarded-allow-ips '*'`: Trust all proxied requests
- Required for WSL backend to be accessible from Windows frontend

---

## 🛠️ Customization

You can modify `run-dev.sh` to add:

**Different port:**
```bash
export PORT="8000"  # Default is 8080
```

**Additional environment variables:**
```bash
export DEBUG="true"
export LOG_LEVEL="debug"
```

**Different uvicorn options:**
```bash
uvicorn open_webui.main:app --reload --log-level debug
```

---

## 📚 Summary

**We created `run-dev.sh` to:**
1. Simplify the development startup process
2. Automate common setup steps (venv, .env)
3. Provide clear feedback during startup
4. Make WSL development more convenient
5. Reduce errors from forgetting steps

**It's essentially a wrapper around `backend/dev.sh` with:**
- Automatic environment setup
- Better user experience
- WSL-specific optimizations
