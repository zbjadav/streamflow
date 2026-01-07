#!/bin/bash
set -e

echo "🚀 StreamFlow single-command deployment starting..."

# ---- CONFIG ----
APP_DIR="/opt/streamflow"
REPO_URL="https://github.com/YOUR_USERNAME/streamflow.git"
DOMAIN="yourdomain.com"
# ----------------

echo "📦 Updating system..."
apt update -y && apt upgrade -y

echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
fi

echo "📦 Installing Docker Compose..."
apt install -y docker-compose-plugin git

echo "📁 Cloning repository..."
rm -rf $APP_DIR
git clone $REPO_URL $APP_DIR
cd $APP_DIR

echo "⚙️ Preparing environment..."
if [ ! -f backend/.env ]; then
  cp backend/.env.example backend/.env
  sed -i "s/change_me/$(openssl rand -hex 32)/g" backend/.env
fi

echo "🐳 Building containers..."
docker compose build

echo "▶️ Starting services..."
docker compose up -d

echo "🔄 Enabling auto-start..."
docker update --restart unless-stopped $(docker ps -q)

echo "✅ Deployment complete!"
echo ""
echo "🌐 Access:"
echo "Frontend: http://YOUR_VPS_IP"
echo "API:      http://YOUR_VPS_IP/api"
