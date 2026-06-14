"# Production Monitoring Guide: HelloWorldWebApp

This document outlines the strategy for monitoring the .NET web application and its Nginx reverse proxy infrastructure.

## 1. The Four Golden Signals
We will monitor these four core metrics to ensure a healthy user experience:

| Signal | Description | Target Goal |
| :--- | :--- | :--- |
| **Latency** | Time taken to service a request. | P99 < 200ms |
| **Traffic** | Demand on the system (Requests Per Second). | Monitor for spikes/anomalies |
| **Errors** | Rate of requests that fail (5xx, 4xx). | < 0.1% failure rate |
| **Saturation** | How "full" the system is (CPU, RAM, Disk). | Alert at > 80% utilization |

## 2. Application Metrics (.NET)
Since we are using ASP.NET Core, we will focus on:
- **Garbage Collection (GC):** Monitor Gen 2 collection frequency to detect memory leaks.
- **Thread Pool:** Track thread usage to prevent starvation.
- **Connection Pooling:** Monitor database/external service connection limits.
- **Endpoint Performance:** Track specific response times for different routes.

## 3. Infrastructure & Proxy Metrics
- **Nginx Upstream Latency:** Measure time taken by the .NET app to respond to Nginx.
- **Active Connections:** Monitor concurrent connections at the Nginx layer.
- **System Resources:** CPU, Memory, and Disk I/O on the host machine.

## 4. Recommended Tooling Stack
To achieve full observability, we aim to implement the following:

| Layer | Tool | Purpose |
| :--- | :--- | :--- |
| **Instrumentation** | OpenTelemetry | Standardized data collection for .NET |
| **Metrics Database** | Prometheus | Time-series storage for all metrics |
| **Visualization** | Grafana | Dashboards and alerting |
| **Logging** | Serilog + Loki | Structured logging for error debugging |
| **Health Checks** | ASP.NET Core Health Checks | Automated liveness/readiness probes |

## 5. Action Plan
- [ ] **Step 1:** Implement `Microsoft.AspNetCore.HealthChecks` to provide a `/health` endpoint.
- [ ] **Step 2:** Integrate **Serilog** for structured logging (JSON format).
- [ ] **Step 3:** Configure **Prometheus** exporter to expose metrics.
- [ ] **Step 4:** Build a **Grafana** dashboard to visualize the Four Golden Signals.
- [ ] **Step 5:** Set up **Alerting** (Slack/Email) for high error rates or service downtime.
"