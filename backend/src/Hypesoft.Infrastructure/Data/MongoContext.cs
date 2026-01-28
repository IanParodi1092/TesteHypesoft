using Hypesoft.Domain.Entities;
using Hypesoft.Infrastructure.Configurations;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Hypesoft.Infrastructure.Data;

public sealed class MongoContext
{
    private readonly IMongoDatabase _database;
    private readonly MongoSettings _settings;

    public MongoContext(IOptions<MongoSettings> options)
    {
        _settings = options.Value;
        var client = new MongoClient(_settings.ConnectionString);
        _database = client.GetDatabase(_settings.DatabaseName);
    }

    public IMongoCollection<Product> Products => _database.GetCollection<Product>(_settings.ProductsCollection);
    public IMongoCollection<Category> Categories => _database.GetCollection<Category>(_settings.CategoriesCollection);
}
