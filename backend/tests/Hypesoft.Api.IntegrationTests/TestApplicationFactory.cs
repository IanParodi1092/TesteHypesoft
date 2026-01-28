using System.Security.Claims;
using System.Text.Encodings.Web;
using Hypesoft.Domain.Entities;
using Hypesoft.Domain.Repositories;
using Hypesoft.Domain.ValueObjects;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Hypesoft.Api.IntegrationTests;

public sealed class TestApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");

        builder.ConfigureServices(services =>
        {
            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = TestAuthHandler.Scheme;
                options.DefaultChallengeScheme = TestAuthHandler.Scheme;
            }).AddScheme<AuthenticationSchemeOptions, TestAuthHandler>(TestAuthHandler.Scheme, _ => { });

            services.AddSingleton<IProductRepository>(new InMemoryProductRepository());
            services.AddSingleton<ICategoryRepository>(new InMemoryCategoryRepository());
        });
    }
}

public sealed class TestAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    public const string Scheme = "Test";

    public TestAuthHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder,
        ISystemClock clock)
        : base(options, logger, encoder, clock)
    {
    }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, "test-user"),
            new Claim(ClaimTypes.Name, "test-user"),
            new Claim(ClaimTypes.Role, "Admin")
        };
        var identity = new ClaimsIdentity(claims, Scheme);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, Scheme);

        return Task.FromResult(AuthenticateResult.Success(ticket));
    }
}

public sealed class InMemoryProductRepository : IProductRepository
{
    private readonly List<Product> _products = new()
    {
        new Product
        {
            Id = "prod-1",
            Name = "Produto Teste",
            Description = "Descricao",
            Price = 10m,
            CategoryId = "cat-1",
            Quantity = 5
        }
    };

    public Task<Product?> GetByIdAsync(string id, CancellationToken cancellationToken)
        => Task.FromResult(_products.FirstOrDefault(p => p.Id == id));

    public Task<IReadOnlyList<Product>> GetAllAsync(CancellationToken cancellationToken)
        => Task.FromResult<IReadOnlyList<Product>>(_products);

    public Task<PagedResult<Product>> GetPagedAsync(string? search, string? categoryId, int page, int pageSize, CancellationToken cancellationToken)
    {
        var query = _products.AsQueryable();
        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(p => p.Name.Contains(search, StringComparison.OrdinalIgnoreCase));
        }

        if (!string.IsNullOrWhiteSpace(categoryId))
        {
            query = query.Where(p => p.CategoryId == categoryId);
        }

        var total = query.LongCount();
        var items = query.Skip((page - 1) * pageSize).Take(pageSize).ToList();
        return Task.FromResult(new PagedResult<Product>(items, total, page, pageSize));
    }

    public Task<IReadOnlyList<Product>> GetLowStockAsync(int threshold, CancellationToken cancellationToken)
    {
        var items = _products.Where(p => p.Quantity < threshold).ToList();
        return Task.FromResult<IReadOnlyList<Product>>(items);
    }

    public Task CreateAsync(Product product, CancellationToken cancellationToken)
    {
        _products.Add(product);
        return Task.CompletedTask;
    }

    public Task UpdateAsync(Product product, CancellationToken cancellationToken)
    {
        var index = _products.FindIndex(p => p.Id == product.Id);
        if (index >= 0)
        {
            _products[index] = product;
        }
        return Task.CompletedTask;
    }

    public Task DeleteAsync(string id, CancellationToken cancellationToken)
    {
        _products.RemoveAll(p => p.Id == id);
        return Task.CompletedTask;
    }

    public Task<long> CountAsync(CancellationToken cancellationToken)
        => Task.FromResult((long)_products.Count);

    public Task<decimal> GetTotalStockValueAsync(CancellationToken cancellationToken)
        => Task.FromResult(_products.Sum(p => p.Price * p.Quantity));
}

public sealed class InMemoryCategoryRepository : ICategoryRepository
{
    private readonly List<Category> _categories = new()
    {
        new Category { Id = "cat-1", Name = "Categoria Teste" }
    };

    public Task<Category?> GetByIdAsync(string id, CancellationToken cancellationToken)
        => Task.FromResult(_categories.FirstOrDefault(c => c.Id == id));

    public Task<IReadOnlyList<Category>> GetAllAsync(CancellationToken cancellationToken)
        => Task.FromResult<IReadOnlyList<Category>>(_categories);

    public Task CreateAsync(Category category, CancellationToken cancellationToken)
    {
        _categories.Add(category);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(string id, CancellationToken cancellationToken)
    {
        _categories.RemoveAll(c => c.Id == id);
        return Task.CompletedTask;
    }

    public Task<long> CountAsync(CancellationToken cancellationToken)
        => Task.FromResult((long)_categories.Count);
}
