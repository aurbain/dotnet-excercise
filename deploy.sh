#!/bin/bash
set -e

# --- Configuration ---
APP_DIR="/home/aaron/dotnet/HelloWorldWebApp"
SERVICE_NAME="HelloWorldWebApp.service"
NGINX_CONF_DEST="/etc/nginx/sites-enabled/helloworldwebapp"

echo "🚀 Starting deployment for HelloWorldWebApp..."

# Check if running as user with sudo privileges (needed for systemctl/nginx)
if [ "$(id -u)" -ne 0 ]; then
    echo "⚠️  Warning: You are not running as root. Some commands may prompt for sudo password."
fi

# 1. Build and Publish
echo "📦 Building and publishing the .NET application..."
cd "$APP_DIR"

# Clean up existing publish directory to avoid nested folders
if [ -d "publish" ]; then
    echo "🧹 Cleaning up existing publish directory..."
    rm -rf publish
fi

# Using unique temp paths to avoid permission issues with existing obj/bin folders
dotnet publish -c Release -o ./publish \
    /p:BaseIntermediateOutputPath=/tmp/hwwa_publish_obj/ \
    /p:BaseOutputPath=/tmp/hwwa_publish_bin/ \
    /p:MSBuildProjectExtensionsPath=/tmp/hwwa_publish_ext/

# 2. Permissions
echo "🔑 Setting permissions..."
sudo chown -R aaron:aaron "$APP_DIR"
sudo chmod -R 755 "$APP_DIR"

# 3. Systemd Service Setup
echo "⚙️  Configuring systemd service..."
sudo cp "$APP_DIR/$SERVICE_NAME" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now "$SERVICE_NAME"

# 4. Nginx Configuration
echo "🌐 Configuring Nginx..."
if [ -f "$APP_DIR/nginx.conf" ]; then
    # Create a backup of existing config if it exists
    if [ -f "$NGINX_CONF_DEST" ]; then
        sudo mv "$NGINX_CONF_DEST" "${NGINX_CONF_DEST}.bak.$(date +%Y%m%d%H%M%S)"
    fi
    sudo cp "$APP_DIR/nginx.conf" "$NGINX_CONF_DEST"
    sudo nginx -t
    sudo systemctl reload nginx
else
    echo "⚠️  nginx.conf not found in $APP_DIR, skipping Nginx setup."
fi

echo "✅ Deployment successful!"
echo "-------------------------------------------------------"
echo "Service Status:"
sudo systemctl status "$SERVICE_NAME" --no-pager
echo "-------------------------------------------------------"
