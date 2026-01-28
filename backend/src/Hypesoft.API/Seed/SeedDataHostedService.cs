using Hypesoft.Domain.Entities;
using Hypesoft.Domain.Repositories;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Hypesoft.API.Seed;

public sealed class SeedDataHostedService : IHostedService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<SeedDataHostedService> _logger;
    private readonly SeedOptions _options;

    public SeedDataHostedService(
        IServiceScopeFactory scopeFactory,
        ILogger<SeedDataHostedService> logger,
        IOptions<SeedOptions> options)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
        _options = options.Value;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        if (!_options.Enabled)
        {
            return;
        }

        using var scope = _scopeFactory.CreateScope();
        var categoryRepository = scope.ServiceProvider.GetRequiredService<ICategoryRepository>();
        var productRepository = scope.ServiceProvider.GetRequiredService<IProductRepository>();

        var existingCategories = await categoryRepository.GetAllAsync(cancellationToken);
        if (existingCategories.Count > 0)
        {
            return;
        }

        var categories = new List<Category>
        {
            new() { Name = "Eletrônicos" },
            new() { Name = "Casa & Decoração" },
            new() { Name = "Moda" },
            new() { Name = "Esportes" }
        };

        foreach (var category in categories)
        {
            await categoryRepository.CreateAsync(category, cancellationToken);
        }

        var products = new List<Product>
        {
            new()
            {
                Name = "Fone Bluetooth",
                Description = "Fone de ouvido sem fio com cancelamento de ruído.",
                Price = 299.90m,
                CategoryId = categories[0].Id,
                Quantity = 12
            },
            new()
            {
                Name = "Smartwatch Fitness",
                Description = "Monitoramento cardíaco e GPS integrado.",
                Price = 599.00m,
                CategoryId = categories[0].Id,
                Quantity = 7
            },
            new()
            {
                Name = "Luminária Minimalista",
                Description = "Luz quente com base de madeira.",
                Price = 189.50m,
                CategoryId = categories[1].Id,
                Quantity = 15
            },
            new()
            {
                Name = "Tapete Geométrico",
                Description = "Tapete de sala 1.5m x 2m.",
                Price = 249.90m,
                CategoryId = categories[1].Id,
                Quantity = 4
            },
            new()
            {
                Name = "Jaqueta Corta-vento",
                Description = "Modelo unissex para dias frios.",
                Price = 219.00m,
                CategoryId = categories[2].Id,
                Quantity = 18
            },
            new()
            {
                Name = "Tênis Urbano",
                Description = "Conforto para uso diário.",
                Price = 349.90m,
                CategoryId = categories[2].Id,
                Quantity = 9
            },
            new()
            {
                Name = "Bola de Futebol",
                Description = "Bola oficial tamanho 5.",
                Price = 129.90m,
                CategoryId = categories[3].Id,
                Quantity = 25
            },
            new()
            {
                Name = "Kit Halteres",
                Description = "Par de halteres ajustáveis até 10kg.",
                Price = 279.90m,
                CategoryId = categories[3].Id,
                Quantity = 6
            }
        };

        foreach (var product in products)
        {
            await productRepository.CreateAsync(product, cancellationToken);
        }

        _logger.LogInformation("Seed inicial criado com {CategoryCount} categorias e {ProductCount} produtos.", categories.Count, products.Count);
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}

public sealed class SeedOptions
{
    public bool Enabled { get; set; } = true;
}
