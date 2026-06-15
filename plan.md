# Project Logic and Technical Plan

## Overview
This project is a .NET web application designed to demonstrate a combination of interactive web content (an animated horse) and production-grade health monitoring.

## Technical Stack
- **Backend**: .NET 10 (ASP.NET Core)
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Assets**: ImageMagick (used for pre-processing images)
- **Infrastructure**: Systemd (Process Management), Nginx (Reverse Proxy), Prometheus (Metrics)

## Feature Breakdown

### 1. Interactive Horse Animation
- **Functionality**: Users click a static horse image on the page. A new "runner" element is created that animates from left to right across the screen.
- **Animation Logic**:
    - **CSS Keyframes**: Defines the `runAcross` animation which handles the translation from `left: -260px` to `left: calc(100vw + 260px)`.
    - **JavaScript Cloning**: The `runner` element is a clone of the original horse, ensuring visual consistency.
    - **Independent State**: Each runner instance maintains its own `localCurrentImg` variable. This prevents "race conditions" where multiple runners would try to cycle through the same image sequence simultaneously.
    - **Frame Cycling**: A `setInterval` updates the `src` attribute of the runner every 750ms for a duration of 3 seconds, creating the illusion of a walking/running animation.

### 2. Health Monitoring System
- **Middleware**: A custom `ResponseWriter` is used in `MapHealthChecks` to return structured JSON instead of plain text.
- **Checks**:
    - **DiskSpaceHealthCheck**: Verifies available storage (mocked for this exercise).
    - **MockDatabaseHealthCheck**: Simulates a database connection check with latency reporting.
- **Observability**: Integrated with `Prometheus` for real-time metric collection.

## Deployment Strategy
- **Environment**: Production environment variables are set via `Systemd` environment files.
- **Web Server**: Nginx serves as a reverse proxy, handling SSL/HTTP termination and routing to the Kestrel web server.
- **Automation**: `deploy.sh` handles the full lifecycle: building, publishing, permission setting, and service restart.

## Future Improvements
- [ ] Implement actual `DriveInfo` logic for real Disk Space monitoring.
- [ ] Replace Mock Database check with a real Entity Framework / Dapper connection check.
- [ ] Add a configuration page to adjust animation speed and image sequence via the UI.
