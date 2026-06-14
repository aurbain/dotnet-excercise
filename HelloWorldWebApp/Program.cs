using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Text.Json;
using Prometheus;

var builder = WebApplication.CreateBuilder(args);

// Add Health Checks with custom logic
builder.Services.AddHealthChecks()
    .AddCheck("DiskSpace", new DiskSpaceHealthCheck())
    .AddCheck("Database", new MockDatabaseHealthCheck());

var app = builder.Build();

app.UseHttpMetrics();
app.MapMetrics();

// Configure /health to return detailed JSON instead of plain text
app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var response = new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(entry => new
            {
                name = entry.Key,
                status = entry.Value.Status.ToString(),
                description = entry.Value.Description,
                data = entry.Value.Data
            })
        };
        await context.Response.WriteAsync(JsonSerializer.Serialize(response, new JsonSerializerOptions { WriteIndented = true }));
    }
});

app.UseStaticFiles();

app.MapGet("/", () =>
{
    var html = """
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>Running Horse</title>
      <style>
        html, body { height: 100%; }
        body {
          margin: 0;
          background: #f0f0f0;
          overflow: hidden;
          display: flex;
          align-items: center;
          justify-content: center;
          font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
        }

        #horse {
          width: 220px;
          cursor: pointer;
          user-select: none;
          -webkit-user-drag: none;
          transition: transform .15s ease-in-out;
        }

        #horse:hover { transform: scale(1.05); }

        .runner {
          position: absolute;
          top: 60%;
          transform: translateY(-50%);
          left: -260px;
          width: 220px;
          animation: runAcross 3s linear forwards;
          pointer-events: none;
        }

        @keyframes runAcross {
          from { left: -260px; }
          to { left: calc(100vw + 260px); }
        }
      </style>
    </head>
    <body>
      <img id="horse" src="/horse.jpg" alt="Horse" />

      <script>
        const horse = document.getElementById('horse');

        horse.addEventListener('click', () => {
          const runner = horse.cloneNode(true);
          runner.removeAttribute('id');
          runner.classList.add('runner');

          // Randomize vertical position a bit so repeated clicks look fun
          const min = 25, max = 75;
          runner.style.top = (min + Math.random() * (max - min)) + '%';

          runner.addEventListener('animationend', () => runner.remove());
          document.body.appendChild(runner);
        });
      </script>
    </body>
    </html>
    """;

    return Results.Text(html, "text/html");
});

app.Run();

// --- Custom Health Check Implementations ---

public sealed class DiskSpaceHealthCheck : IHealthCheck
{
    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, System.Threading.CancellationToken cancellationToken = default)
    {
        // In a real app, you'd use DriveInfo to get actual free space
        var data = new Dictionary<string, object> { { "free_gb", 45.5 } };
        return Task.FromResult(HealthCheckResult.Healthy("Disk space is sufficient", data));
    }
}

public sealed class MockDatabaseHealthCheck : IHealthCheck
{
    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, System.Threading.CancellationToken cancellationToken = default)
    {
        // Mocking a database latency measurement
        var data = new Dictionary<string, object> { { "latency_ms", 12 } };
        return Task.FromResult(HealthCheckResult.Healthy("Database connection is stable", data));
    }
}
