# 🚀 Open WebUI - Quick Reference

## Daily Startup (2 terminals)

```
1. PowerShell: .\startup_scripts\start-windows.ps1
2. WSL:        ./startup_scripts/start-backend.sh  
3. Browser:    http://localhost:5173
```

**OR** if you prefer separate control:
```
1. PowerShell: .\startup_scripts\start-ollama.ps1
2. PowerShell: .\startup_scripts\start-frontend.ps1
3. WSL:        ./startup_scripts/start-backend.sh
```

## Stop Everything
Press `Ctrl+C` in each terminal

## Ports
- Frontend: 5173
- Backend:  8080
- Ollama:   11434

## Documentation
- [`startup_scripts/README.md`](startup_scripts/README.md) - Detailed startup guide
- [`docs/DEV_GUIDE.md`](docs/DEV_GUIDE.md) - Complete development guide
- [`docs/STARTUP_SCRIPTS.md`](docs/STARTUP_SCRIPTS.md) - Script comparison

## Troubleshooting
If models don't show, restart Ollama with: `.\startup_scripts\start-ollama.ps1`
