using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Testcontainers.MongoDb;

namespace Hypesoft.Tests.Integration;

public sealed class ApiFixture : WebApplicationFactory<global::Program>, IAsyncLifetime
{
    private MongoDbContainer? _mongoDb;

    public async Task InitializeAsync()
    {
        if (ShouldRun())
        {
            _mongoDb = new MongoDbBuilder().Build();
            await _mongoDb.StartAsync();
        }
    }

    public new async Task DisposeAsync()
    {
        if (ShouldRun())
        {
            if (_mongoDb is not null)
            {
                await _mongoDb.DisposeAsync();
            }
        }
    }

    public static bool ShouldRun() =>
        string.Equals(Environment.GetEnvironmentVariable("RUN_INTEGRATION_TESTS"), "true", StringComparison.OrdinalIgnoreCase);

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        if (!ShouldRun())
        {
            return;
        }

        builder.ConfigureAppConfiguration((context, config) =>
        {
            if (_mongoDb is null)
            {
                return;
            }

            var settings = new Dictionary<string, string?>
            {
                ["Mongo:ConnectionString"] = _mongoDb.GetConnectionString(),
                ["Mongo:DatabaseName"] = "hypesoft-tests",
                ["Seed:Enabled"] = "true",
                ["Keycloak:Authority"] = "http://localhost:8080/realms/hypesoft",
                ["Keycloak:Audience"] = "hypesoft-api",
                ["Keycloak:RequireHttpsMetadata"] = "false"
            };

            config.AddInMemoryCollection(settings!);
        });
    }
}
