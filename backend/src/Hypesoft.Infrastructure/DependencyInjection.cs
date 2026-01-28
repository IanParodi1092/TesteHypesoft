using Hypesoft.Domain.Repositories;
using Hypesoft.Infrastructure.Configurations;
using Hypesoft.Infrastructure.Data;
using Hypesoft.Infrastructure.Repositories;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Hypesoft.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<MongoSettings>(configuration.GetSection("Mongo"));
        services.AddSingleton<MongoContext>();

        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<ICategoryRepository, CategoryRepository>();

        return services;
    }
}
