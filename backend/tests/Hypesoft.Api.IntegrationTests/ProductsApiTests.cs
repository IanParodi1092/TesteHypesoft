using System.Net;
using System.Net.Http.Json;
using FluentAssertions;

namespace Hypesoft.Api.IntegrationTests;

public sealed class ProductsApiTests : IClassFixture<TestApplicationFactory>
{
    private readonly HttpClient _client;

    public ProductsApiTests(TestApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Get_products_returns_items()
    {
        var response = await _client.GetAsync("/api/products?page=1&pageSize=20");

        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var payload = await response.Content.ReadFromJsonAsync<PagedResultResponse>();
        payload.Should().NotBeNull();
        payload!.Items.Should().NotBeEmpty();
    }

    [Fact]
    public async Task Update_product_returns_not_found_when_missing()
    {
        var response = await _client.PutAsJsonAsync("/api/products/missing", new
        {
            id = "missing",
            name = "Produto",
            description = "Descricao",
            price = 10,
            categoryId = "cat-1",
            quantity = 1
        });

        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    private sealed class PagedResultResponse
    {
        public List<ProductResponse> Items { get; set; } = new();
    }

    private sealed class ProductResponse
    {
        public string Id { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
    }
}
