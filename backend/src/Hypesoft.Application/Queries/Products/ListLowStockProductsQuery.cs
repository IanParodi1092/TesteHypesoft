using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Caching;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Queries.Products;

public sealed record ListLowStockProductsQuery(int Threshold = 10) : IRequest<IReadOnlyList<ProductDto>>;

public sealed class ListLowStockProductsQueryHandler : IRequestHandler<ListLowStockProductsQuery, IReadOnlyList<ProductDto>>
{
    private readonly IProductRepository _productRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public ListLowStockProductsQueryHandler(
        IProductRepository productRepository,
        ICategoryRepository categoryRepository,
        IMapper mapper,
        IMemoryCache cache)
    {
        _productRepository = productRepository;
        _categoryRepository = categoryRepository;
        _mapper = mapper;
        _cache = cache;
    }

    public async Task<IReadOnlyList<ProductDto>> Handle(ListLowStockProductsQuery request, CancellationToken cancellationToken)
    {
        var cacheKey = CacheKeys.LowStock(request.Threshold);
        if (_cache.TryGetValue(cacheKey, out IReadOnlyList<ProductDto>? cached) && cached is not null)
        {
            return cached;
        }

        var products = await _productRepository.GetLowStockAsync(request.Threshold, cancellationToken);
        var categories = await _categoryRepository.GetAllAsync(cancellationToken);
        var categoryLookup = categories.ToDictionary(x => x.Id, x => x.Name);

        var result = products
            .Select(product =>
            {
                var dto = _mapper.Map<ProductDto>(product);
                dto.CategoryName = categoryLookup.TryGetValue(product.CategoryId, out var name) ? name : null;
                return dto;
            })
            .ToList();

        _cache.Set(cacheKey, result, TimeSpan.FromMinutes(1));
        return result;
    }
}
