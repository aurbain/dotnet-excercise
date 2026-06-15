# HelloWorldWebApp Project

This project is a .NET web application that features an interactive "Running Horse" animation and a robust health monitoring system.

## Project Structure
- `HelloWorldWebApp`: The source code for the .NET web application.
- `deploy.sh`: The main deployment script.
- `monitoring.md`: Monitoring configuration details.
- `alloy.config`: Alloy configuration for data collection.
- `plan.md`: Project logic and technical plan.

## Core Features
- **Interactive Animation**: A web page where clicking a horse image spawns a running horse.
- **Dynamic Frame Cycling**: The running horse cycles through four different images (`horse1.jpg` through `horse4.jpg`) as it moves across the screen.
- **Health Monitoring**: Custom health checks for Disk Space and Database (mocked) with detailed JSON responses.
- **Production Ready**: Includes a systemd service configuration and Nginx integration for deployment.

## Deployment Plan
The deployment process is automated via `deploy.sh` and follows these steps:

1. **Build and Publish**:
   - Compile the application in Release mode.
   - Publish it to a `./publish` directory.

2. **Permissions**:
   - Ensure the application directory has correct ownership and permissions.

3. **Systemd Service**:
   - Copy the service definition to `/etc/systemd/system/`.
   - Reload the systemd daemon.
   - Enable and start the `HelloWorldWebApp.service`.

4. **Nginx Configuration**:
   - Copy the provided `nginx.conf` to `/etc/nginx/sites-enabled/`.
   - Test and reload the Nginx service.

## How to Deploy
Run the following command:
```bash
chmod +x deploy.sh
./deploy.sh
```
