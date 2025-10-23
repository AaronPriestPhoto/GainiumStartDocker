# Gainium Docker Windows Launcher

A simple Windows batch script wrapper for the official [Gainium Docker setup](https://github.com/Gainium/docker-sh). This script automatically starts Docker Desktop (if not running), pulls the latest Gainium configuration, and manages the Docker containers.

## 🚀 What This Does

This repository provides convenient Windows batch scripts that:

1. **Checks if Docker Desktop is running** - If not, it starts Docker Desktop automatically
2. **Downloads the latest configuration** - Pulls the most recent `docker-compose.yml` from the official Gainium repository
3. **Manages containers** - Starts or stops the Gainium trading platform containers
4. **Automatic backups** - Creates timestamped backups of all data volumes before updates
5. **Data restoration** - Restore from previous backups if needed
6. **Opens the dashboard** - Automatically opens your browser to the Gainium web interface

## 📋 Prerequisites

- **Windows 10/11** (this is a Windows batch script)
- **Docker Desktop** installed ([Download here](https://www.docker.com/products/docker-desktop/))
- **At least 4GB RAM** and **5GB free disk space**

## ⚡ Quick Start

### 1. Clone This Repository
```bash
git clone https://github.com/AaronPriestPhoto/GainiumStartDocker.git
cd GainiumStartDocker
```

### 2. Set Up Environment (Optional)
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your configuration (only needed for API keys)
notepad .env
```

### 3. Run the Script
```bash
# Double-click Gainium.bat or run from command line
Gainium.bat
```

### 4. Choose Your Action
The script will present you with options:
- **[U] Backup + Update/Start** - Creates backups, downloads latest config, and starts containers
- **[D] Shut Down** - Gracefully stops all containers
- **[Q] Quit** - Exits the script

### 5. Restore from Backup (if needed)
```bash
# If you need to restore from a backup
restore_Gainium.bat
```

## 🏗️ What Gets Started

This script launches the complete Gainium trading platform from the [official repository](https://github.com/Gainium/docker-sh), which includes:

- **Frontend Dashboard** - Web interface at http://localhost:7500
- **API Server** - GraphQL API at http://localhost:7503  
- **WebSocket Stream** - Real-time data at ws://localhost:7502
- **Trading Bots** - DCA, Grid, Combo, and Hedge strategies
- **Infrastructure** - MongoDB, Redis, RabbitMQ
- **Supporting Services** - Paper trading, backtesting, indicators

## ⚙️ Configuration

### Environment Variables (Optional)

If you want to use exchange APIs or customize settings, copy `.env.example` to `.env` and configure:

```env
# Only needed if using Coinbase Pro
COINBASEKEY=your_coinbase_api_key
COINBASESECRET=your_coinbase_secret

# Optional: Customize which exchanges to connect to
PRICE_CONNECTOR_EXCHANGES=binance,kucoin,bybit
```

**Note:** The system works out-of-the-box with default settings. You only need to configure `.env` if you want to connect to real exchanges.

## 🛠️ Usage

### Starting Gainium with Backup
```bash
Gainium.bat
# Choose [U] for Backup + Update/Start
```

The script will:
1. Start Docker Desktop if needed
2. **Create timestamped backups** of all data volumes (mongo, redis, rabbitmq, backtest data)
3. Download the latest `docker-compose.yml` from the official repository
4. Pull the latest Docker images
5. Start all services
6. Open http://localhost:7500 in your browser

### Stopping Gainium
```bash
Gainium.bat
# Choose [D] for Shut Down
```

This gracefully stops all containers but keeps your data intact.

### Restoring from Backup
```bash
restore_Gainium.bat
```

This script allows you to:
- View available backups
- Select which volumes to restore
- Restore from the most recent backup
- Automatically restart services after restoration

### Backup Features

The enhanced scripts include robust backup capabilities:

- **Automatic backups** before every update
- **Timestamped archives** (format: `volume_backup_YYYYMMDD_HHMM.tar.gz`)
- **Integrity verification** of backup files
- **Automatic cleanup** (keeps 7 most recent backups per volume)
- **Selective restoration** of individual volumes
- **Lock file protection** prevents multiple simultaneous operations

### Manual Docker Commands

You can also use Docker Compose directly:

```bash
# Start services
docker compose --env-file .env up -d

# Stop services  
docker compose down

# View logs
docker compose logs -f

# Check status
docker compose ps
```

## 🔧 Troubleshooting

### Docker Won't Start
- Ensure Docker Desktop is installed
- The script will try to start Docker Desktop automatically
- If it fails, manually start Docker Desktop and try again

### Port Conflicts
- Default ports: 7500 (frontend), 7503 (API), 7502 (WebSocket)
- If ports are in use, check what's using them: `netstat -ano | findstr :7500`

### Out of Memory
- Ensure you have at least 4GB RAM available
- Close other applications if needed
- Increase Docker Desktop memory limit in settings

### Services Won't Start
```bash
# Check what's running
docker compose ps

# View error logs
docker compose logs

# Reset everything (WARNING: deletes data)
docker compose down -v
```

### Data Recovery
```bash
# If you need to restore from backup
restore_Gainium.bat

# List available backups
dir *_backup_*.tar.gz

# Manual backup verification
tar -tzf volume_backup_YYYYMMDD_HHMM.tar.gz
```

## 📊 Monitoring

### Check Service Status
```bash
docker compose ps
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f frontend
```

### Access Points
- **Web Dashboard**: http://localhost:7500
- **API Health**: http://localhost:7503/health
- **GraphQL API**: http://localhost:7503/graphql
- **WebSocket**: ws://localhost:7502

## 🔒 Security Notes

- The `.env` file is ignored by Git (never committed)
- Use strong passwords if you customize database settings
- Keep API keys secure and never share them
- This is for development/testing - use proper security for production

## 📝 About This Repository

This is a **wrapper script** for the official [Gainium Docker setup](https://github.com/Gainium/docker-sh). 

- **Official Repository**: https://github.com/Gainium/docker-sh
- **This Repository**: Simple Windows launcher script
- **Purpose**: Make it easier for Windows users to get started

The actual Docker configuration, images, and services are maintained by the official Gainium team.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork this repository
2. Make improvements to the Windows launcher script
3. Test thoroughly
4. Submit a pull request

## 📞 Support

For issues with:
- **This launcher script**: Create an issue in this repository
- **Gainium platform itself**: Check the [official repository](https://github.com/Gainium/docker-sh)
- **Docker issues**: Check Docker Desktop documentation

---

**Disclaimer**: This is a development tool for the Gainium trading platform. Ensure you understand the risks involved in cryptocurrency trading before using this system.
