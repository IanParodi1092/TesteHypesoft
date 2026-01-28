using Hypesoft.Domain.Entities;
using Hypesoft.Domain.ValueObjects;

namespace Hypesoft.Domain.Repositories;

public interface IProductRepository
{
    Task<Product?> GetByIdAsync(string id, CancellationToken cancellationToken);
    Task<IReadOnlyList<Product>> GetAllAsync(CancellationToken cancellationToken);
    Task<PagedResult<Product>> GetPagedAsync(string? search, string? categoryId, int page, int pageSize, CancellationToken cancellationToken);
    Task<IReadOnlyList<Product>> GetLowStockAsync(int threshold, CancellationToken cancellationToken);
    Task CreateAsync(Product product, CancellationToken cancellationToken);
    Task UpdateAsync(Product product, CancellationToken cancellationToken);
    Task DeleteAsync(string id, CancellationToken cancellationToken);
    Task<long> CountAsync(CancellationToken cancellationToken);
    Task<decimal> GetTotalStockValueAsync(CancellationToken cancellationToken);
}
