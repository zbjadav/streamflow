#!/bin/bash
set -e

echo "🚀 StreamFlow VPS Deployment Started"

# -----------------------------
# CONFIG (EDIT THESE)
# -----------------------------
APP_NAME="streamflow"
APP_DIR="/opt/streamflow"
GIT_REPO="https://github.com/YOUR_USERNAME/streamflow.git"

# -----------------------------
# SYSTEM PREP
# -----------------------------
echo "📦 Updating system..."
apt update -y && apt upgrade -y

echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
fi

echo "🐳 Installing Docker Compose..."
if ! docker compose version &> /dev/null; then
  apt install docker-compose-plugin -y
fi

# -----------------------------
# CLONE REPO
# -----------------------------
echo "📥 Cloning StreamFlow..."
mkdir -p /opt
cd /opt

if [ -d "$APP_DIR" ]; then
  echo "🔁 Updating existing repo"
  cd $APP_DIR
  git pull
else
  git clone $GIT_REPO
  cd $APP_NAME
fi

# -----------------------------
# ENV SETUP
# -----------------------------
echo "⚙️ Setting environment variables..."

if [ ! -f backend/.env ]; then
  cp backend/.env.example backend/.env

  sed -i "s/JWT_SECRET=.*/JWT_SECRET=$(openssl rand -hex 32)/" backend/.env
  sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$(openssl rand -hex 16)/" backend/.env
fi

# -----------------------------
# DOCKER BUILD & RUN
# -----------------------------
echo "🐳 Building containers..."
docker compose build

echo "🚀 Starting StreamFlow..."
docker compose up -d

# -----------------------------
# FIREWALL (SAFE DEFAULTS)
# -----------------------------
echo "🔥 Configuring firewall..."
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 1935
ufw --force enable

# -----------------------------
# DONE
# -----------------------------
IP=$(curl -s ifconfig.me)

echo "✅ DEPLOYMENT COMPLETE"
echo "🌐 Access your platform:"
echo "   http://$IP"
echo ""
echo "📦 App directory: $APP_DIR"
echo "🐳 Docker running: docker compose ps"
echo ""
echo "🏁 StreamFlow is LIVE"
