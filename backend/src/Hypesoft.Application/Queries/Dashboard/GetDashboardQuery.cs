using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Caching;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Queries.Dashboard;

public sealed record GetDashboardQuery : IRequest<DashboardDto>;

public sealed class GetDashboardQueryHandler : IRequestHandler<GetDashboardQuery, DashboardDto>
{
    private readonly IProductRepository _productRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public GetDashboardQueryHandler(
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

    public async Task<DashboardDto> Handle(GetDashboardQuery request, CancellationToken cancellationToken)
    {
        if (_cache.TryGetValue(CacheKeys.Dashboard, out DashboardDto? cached) && cached is not null)
        {
            return cached;
        }

        var products = await _productRepository.GetAllAsync(cancellationToken);
        var categories = await _categoryRepository.GetAllAsync(cancellationToken);
        var categoryLookup = categories.ToDictionary(x => x.Id, x => x.Name);

        var lowStock = products
            .Where(p => p.Quantity < 10)
            .Select(p =>
            {
                var dto = _mapper.Map<ProductDto>(p);
                dto.CategoryName = categoryLookup.TryGetValue(p.CategoryId, out var name) ? name : null;
                return dto;
            })
            .ToList();

        var byCategory = products
            .GroupBy(p => p.CategoryId)
            .Select(group => new CategoryCountDto
            {
                CategoryId = group.Key,
                CategoryName = categoryLookup.TryGetValue(group.Key, out var name) ? name : "Sem categoria",
                Count = group.Count()
            })
            .OrderByDescending(x => x.Count)
            .ToList();

        var result = new DashboardDto
        {
            TotalProducts = products.LongCount(),
            TotalStockValue = products.Sum(p => p.Price * p.Quantity),
            LowStockProducts = lowStock,
            ProductsByCategory = byCategory,
            Products = products.Select(p =>
            {
                var dto = _mapper.Map<ProductDto>(p);
                dto.CategoryName = categoryLookup.TryGetValue(p.CategoryId, out var name) ? name : null;
                return dto;
            }).ToList()
        };

        _cache.Set(CacheKeys.Dashboard, result, TimeSpan.FromMinutes(1));
        return result;
    }
}
