#!/bin/bash
set -e

# --- Configuration ---
PACKAGE_NAME="helloworldwebapp"
VERSION="1.0.0"
BUILD_DIR="./build_pkg"
APP_SOURCE_DIR="./HelloWorldWebApp"
PUBLISH_DIR="$APP_SOURCE_DIR/publish"
DEBIAN_DIR="$BUILD_DIR/DEBIAN"

echo "🔨 Preparing build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/opt/$PACKAGE_NAME"
mkdir -p "$DEBIAN_DIR"
mkdir -p "$BUILD_DIR/etc/nginx/sites-enabled"
mkdir -p "$BUILD_DIR/lib/systemd/system"

echo "📂 Copying application binaries..."
# Create the destination directory first
mkdir -p "$BUILD_DIR/opt/$PACKAGE_NAME/publish"
# Copy the content of the publish directory into the package's publish directory
cp -r "$PUBLISH_DIR/." "$BUILD_DIR/opt/$PACKAGE_NAME/publish/"

echo "🌐 Configuring Nginx..."
cp "$APP_SOURCE_DIR/nginx.conf" "$BUILD_DIR/etc/nginx/sites-enabled/helloworldwebapp"

echo "⚙️  Configuring Systemd service..."
# Copy the service file
cp "$APP_SOURCE_DIR/HelloWorldWebApp.service" "$BUILD_DIR/lib/systemd/system/HelloWorldWebApp.service"

# Update paths in the service file to use /opt/helloworldwebapp
# This ensures it works regardless of the user's home directory
sed -i "s|$APP_SOURCE_DIR|/opt/$PACKAGE_NAME|g" "$BUILD_DIR/lib/systemd/system/HelloWorldWebApp.service"

echo "📝 Creating control file..."
cat <<EOF > "$DEBIAN_DIR/control"
Package: $PACKAGE_NAME
Version: $VERSION
Section: web
Priority: optional
Architecture: amd64
Maintainer: Aaron <aaron@example.com>
Description: .NET HelloWorldWebApp with Nginx and Systemd.
Dependencies: dotnet-runtime, nginx
EOF

echo "🚀 Creating post-installation script..."
cat <<EOF > "$DEBIAN_DIR/postinst"
#!/bin/bash
set -e
systemctl daemon-reload
systemctl enable --now $PACKAGE_NAME.service
nginx -t && systemctl reload nginx
EOF

echo "🛑 Creating pre-removal script..."
cat <<EOF > "$DEBIAN_DIR/prerm"
#!/bin/bash
set -e
systemctl disable $PACKAGE_NAME.service
systemctl stop $PACKAGE_NAME.service
EOF

chmod +x "$DEBIAN_DIR/postinst"
chmod +x "$DEBIAN_DIR/prerm"

echo "📦 Building the Debian package..."
dpkg-deb --build "$BUILD_DIR" "$PACKAGE_NAME.deb"

echo "✅ Package created: $PACKAGE_NAME.deb"
