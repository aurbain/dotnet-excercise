# HelloWorldWebApp Project

This project is a .NET web application with a deployment pipeline.

## Project Structure
- `HelloWorldWebApp`: The source code for the .NET web application.
- `deploy.sh`: The main deployment script.
- `monitoring.md`: Monitoring configuration details.
- `alloy.config`: Alloy configuration for data collection.

## Deployment Plan
The deployment process is automated via `deploy.sh` and follows these steps:

1. **Build and Publish**:
   - Compile the application in Release mode.
   - Publish it to a `./publish` directory using temporary paths for intermediate outputs to avoid permission issues.

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
