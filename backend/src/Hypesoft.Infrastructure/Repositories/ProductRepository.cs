using Hypesoft.Domain.Entities;
using Hypesoft.Domain.Repositories;
using Hypesoft.Domain.ValueObjects;
using Hypesoft.Infrastructure.Data;
using MongoDB.Driver;

namespace Hypesoft.Infrastructure.Repositories;

public sealed class ProductRepository : IProductRepository
{
    private readonly IMongoCollection<Product> _products;

    public ProductRepository(MongoContext context)
    {
        _products = context.Products;
    }

    public async Task<Product?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        return await _products.Find(p => p.Id == id).FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Product>> GetAllAsync(CancellationToken cancellationToken)
    {
        return await _products.Find(FilterDefinition<Product>.Empty).ToListAsync(cancellationToken);
    }

    public async Task<PagedResult<Product>> GetPagedAsync(
        string? search,
        string? categoryId,
        int page,
        int pageSize,
        CancellationToken cancellationToken)
    {
        var filter = Builders<Product>.Filter.Empty;

        if (!string.IsNullOrWhiteSpace(search))
        {
            filter &= Builders<Product>.Filter.Regex(p => p.Name, new MongoDB.Bson.BsonRegularExpression(search, "i"));
        }

        if (!string.IsNullOrWhiteSpace(categoryId))
        {
            filter &= Builders<Product>.Filter.Eq(p => p.CategoryId, categoryId);
        }

        var totalCount = await _products.CountDocumentsAsync(filter, cancellationToken: cancellationToken);

        var items = await _products.Find(filter)
            .SortByDescending(p => p.UpdatedAt)
            .Skip((page - 1) * pageSize)
            .Limit(pageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Product>(items, totalCount, page, pageSize);
    }

    public async Task<IReadOnlyList<Product>> GetLowStockAsync(int threshold, CancellationToken cancellationToken)
    {
        var filter = Builders<Product>.Filter.Lt(p => p.Quantity, threshold);
        return await _products.Find(filter)
            .SortBy(p => p.Quantity)
            .Limit(50)
            .ToListAsync(cancellationToken);
    }

    public async Task CreateAsync(Product product, CancellationToken cancellationToken)
    {
        await _products.InsertOneAsync(product, cancellationToken: cancellationToken);
    }

    public async Task UpdateAsync(Product product, CancellationToken cancellationToken)
    {
        await _products.ReplaceOneAsync(p => p.Id == product.Id, product, cancellationToken: cancellationToken);
    }

    public async Task DeleteAsync(string id, CancellationToken cancellationToken)
    {
        await _products.DeleteOneAsync(p => p.Id == id, cancellationToken);
    }

    public async Task<long> CountAsync(CancellationToken cancellationToken)
    {
        return await _products.CountDocumentsAsync(FilterDefinition<Product>.Empty, cancellationToken: cancellationToken);
    }

    public async Task<decimal> GetTotalStockValueAsync(CancellationToken cancellationToken)
    {
        var products = await _products.Find(FilterDefinition<Product>.Empty)
            .Project(p => new { Value = p.Price * p.Quantity })
            .ToListAsync(cancellationToken);

        return products.Sum(x => x.Value);
    }
}
