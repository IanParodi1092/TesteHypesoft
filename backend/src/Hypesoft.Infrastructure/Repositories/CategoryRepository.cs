using Hypesoft.Domain.Entities;
using Hypesoft.Domain.Repositories;
using Hypesoft.Infrastructure.Data;
using MongoDB.Driver;

namespace Hypesoft.Infrastructure.Repositories;

public sealed class CategoryRepository : ICategoryRepository
{
    private readonly IMongoCollection<Category> _categories;

    public CategoryRepository(MongoContext context)
    {
        _categories = context.Categories;
    }

    public async Task<Category?> GetByIdAsync(string id, CancellationToken cancellationToken)
    {
        return await _categories.Find(c => c.Id == id).FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Category>> GetAllAsync(CancellationToken cancellationToken)
    {
        return await _categories.Find(FilterDefinition<Category>.Empty)
            .SortBy(c => c.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task CreateAsync(Category category, CancellationToken cancellationToken)
    {
        await _categories.InsertOneAsync(category, cancellationToken: cancellationToken);
    }

    public async Task DeleteAsync(string id, CancellationToken cancellationToken)
    {
        await _categories.DeleteOneAsync(c => c.Id == id, cancellationToken);
    }

    public async Task<long> CountAsync(CancellationToken cancellationToken)
    {
        return await _categories.CountDocumentsAsync(FilterDefinition<Category>.Empty, cancellationToken: cancellationToken);
    }
}
