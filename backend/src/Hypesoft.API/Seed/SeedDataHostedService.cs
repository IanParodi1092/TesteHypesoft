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

        var categories = new List<Category>
        {
            new() { Name = "Eletrônicos" },
            new() { Name = "Casa & Decoração" },
            new() { Name = "Moda" },
            new() { Name = "Esportes" },
            new() { Name = "Beleza" },
            new() { Name = "Livros" },
            new() { Name = "Pet" },
            new() { Name = "Brinquedos" }
        };
        var categoriesByName = existingCategories.ToDictionary(category => category.Name, category => category);

        foreach (var category in categories)
        {
            if (categoriesByName.ContainsKey(category.Name))
            {
                continue;
            }

            await categoryRepository.CreateAsync(category, cancellationToken);
            categoriesByName[category.Name] = category;
        }

        var products = new List<Product>
        {
            new()
            {
                Name = "Fone Bluetooth",
                Description = "Fone de ouvido sem fio com cancelamento de ruído.",
                Price = 299.90m,
                CategoryId = categoriesByName["Eletrônicos"].Id,
                Quantity = 12
            },
            new()
            {
                Name = "Smartwatch Fitness",
                Description = "Monitoramento cardíaco e GPS integrado.",
                Price = 599.00m,
                CategoryId = categoriesByName["Eletrônicos"].Id,
                Quantity = 7
            },
            new()
            {
                Name = "Luminária Minimalista",
                Description = "Luz quente com base de madeira.",
                Price = 189.50m,
                CategoryId = categoriesByName["Casa & Decoração"].Id,
                Quantity = 15
            },
            new()
            {
                Name = "Tapete Geométrico",
                Description = "Tapete de sala 1.5m x 2m.",
                Price = 249.90m,
                CategoryId = categoriesByName["Casa & Decoração"].Id,
                Quantity = 4
            },
            new()
            {
                Name = "Jaqueta Corta-vento",
                Description = "Modelo unissex para dias frios.",
                Price = 219.00m,
                CategoryId = categoriesByName["Moda"].Id,
                Quantity = 18
            },
            new()
            {
                Name = "Tênis Urbano",
                Description = "Conforto para uso diário.",
                Price = 349.90m,
                CategoryId = categoriesByName["Moda"].Id,
                Quantity = 9
            },
            new()
            {
                Name = "Bola de Futebol",
                Description = "Bola oficial tamanho 5.",
                Price = 129.90m,
                CategoryId = categoriesByName["Esportes"].Id,
                Quantity = 25
            },
            new()
            {
                Name = "Kit Halteres",
                Description = "Par de halteres ajustáveis até 10kg.",
                Price = 279.90m,
                CategoryId = categoriesByName["Esportes"].Id,
                Quantity = 6
            },
            new()
            {
                Name = "Kit Skincare",
                Description = "Hidratante e sérum facial para uso diário.",
                Price = 159.90m,
                CategoryId = categoriesByName["Beleza"].Id,
                Quantity = 14
            },
            new()
            {
                Name = "Máscara Capilar",
                Description = "Tratamento nutritivo para todos os tipos de cabelo.",
                Price = 89.90m,
                CategoryId = categoriesByName["Beleza"].Id,
                Quantity = 22
            },
            new()
            {
                Name = "Livro Gestão Moderna",
                Description = "Boas práticas de liderança e produtividade.",
                Price = 74.90m,
                CategoryId = categoriesByName["Livros"].Id,
                Quantity = 30
            },
            new()
            {
                Name = "Livro UX Essencial",
                Description = "Fundamentos de experiência do usuário.",
                Price = 64.90m,
                CategoryId = categoriesByName["Livros"].Id,
                Quantity = 19
            },
            new()
            {
                Name = "Ração Premium",
                Description = "Alimento balanceado para cães adultos.",
                Price = 129.90m,
                CategoryId = categoriesByName["Pet"].Id,
                Quantity = 16
            },
            new()
            {
                Name = "Brinquedo Mordedor",
                Description = "Brinquedo resistente para pets.",
                Price = 39.90m,
                CategoryId = categoriesByName["Pet"].Id,
                Quantity = 28
            },
            new()
            {
                Name = "Blocos Criativos",
                Description = "Kit de montar para crianças acima de 6 anos.",
                Price = 119.90m,
                CategoryId = categoriesByName["Brinquedos"].Id,
                Quantity = 11
            },
            new()
            {
                Name = "Quebra-cabeça 1000 peças",
                Description = "Tema paisagens com alta qualidade.",
                Price = 89.90m,
                CategoryId = categoriesByName["Brinquedos"].Id,
                Quantity = 13
            }
        };

        var existingProducts = await productRepository.GetAllAsync(cancellationToken);
        var productsByName = existingProducts.ToDictionary(product => product.Name, product => product);

        var addedProducts = 0;

        foreach (var product in products)
        {
            if (productsByName.ContainsKey(product.Name))
            {
                continue;
            }

            await productRepository.CreateAsync(product, cancellationToken);
            addedProducts++;
        }

        _logger.LogInformation(
            "Seed inicial garantiu {CategoryCount} categorias e {ProductCount} produtos.",
            categoriesByName.Count,
            productsByName.Count + addedProducts
        );
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}

public sealed class SeedOptions
{
    public bool Enabled { get; set; } = true;
}
