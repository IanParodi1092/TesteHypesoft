using System.Net;
using System.Net.Http.Headers;
using FluentAssertions;

namespace Hypesoft.Tests.Integration;

public sealed class ProductsApiTests : IClassFixture<ApiFixture>
{
    private readonly HttpClient _client;

    public ProductsApiTests(ApiFixture fixture)
    {
        _client = fixture.CreateClient();
    }

    [Fact]
    public async Task Get_products_requires_authentication()
    {
        if (!ApiFixture.ShouldRun())
        {
            return;
        }

        var response = await _client.GetAsync("/api/products?page=1&pageSize=10");

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Get_products_returns_seeded_items_when_authenticated()
    {
        if (!ApiFixture.ShouldRun())
        {
            return;
        }

        if (!await IsKeycloakAvailableAsync())
        {
            return;
        }

        var token = await GetTokenAsync();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await _client.GetAsync("/api/products?page=1&pageSize=10");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var payload = await response.Content.ReadAsStringAsync();
        payload.Should().Contain("items");
    }

    private static async Task<string> GetTokenAsync()
    {
        var baseUrl = Environment.GetEnvironmentVariable("KEYCLOAK_URL") ?? "http://localhost:8080";
        using var http = new HttpClient();
        using var content = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["client_id"] = "hypesoft-api",
            ["client_secret"] = "hypesoft-api-secret",
            ["grant_type"] = "password",
            ["username"] = "admin",
            ["password"] = "admin"
        });

        var response = await http.PostAsync($"{baseUrl}/realms/hypesoft/protocol/openid-connect/token", content);
        response.EnsureSuccessStatusCode();
        var json = await response.Content.ReadAsStringAsync();

        var token = System.Text.Json.JsonDocument.Parse(json).RootElement.GetProperty("access_token").GetString();
        return token ?? string.Empty;
    }

    private static async Task<bool> IsKeycloakAvailableAsync()
    {
        var baseUrl = Environment.GetEnvironmentVariable("KEYCLOAK_URL") ?? "http://localhost:8080";
        using var http = new HttpClient { Timeout = TimeSpan.FromSeconds(2) };

        try
        {
            var response = await http.GetAsync($"{baseUrl}/realms/hypesoft/.well-known/openid-configuration");
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }
}
