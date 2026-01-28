using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Caching;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Queries.Categories;

public sealed record ListCategoriesQuery : IRequest<IReadOnlyList<CategoryDto>>;

public sealed class ListCategoriesQueryHandler : IRequestHandler<ListCategoriesQuery, IReadOnlyList<CategoryDto>>
{
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public ListCategoriesQueryHandler(ICategoryRepository categoryRepository, IMapper mapper, IMemoryCache cache)
    {
        _categoryRepository = categoryRepository;
        _mapper = mapper;
        _cache = cache;
    }

    public async Task<IReadOnlyList<CategoryDto>> Handle(ListCategoriesQuery request, CancellationToken cancellationToken)
    {
        if (_cache.TryGetValue(CacheKeys.CategoriesAll, out IReadOnlyList<CategoryDto>? cached) && cached is not null)
        {
            return cached;
        }

        var categories = await _categoryRepository.GetAllAsync(cancellationToken);
        var result = categories.Select(category => _mapper.Map<CategoryDto>(category)).ToList();

        _cache.Set(CacheKeys.CategoriesAll, result, TimeSpan.FromMinutes(2));
        return result;
    }
}
