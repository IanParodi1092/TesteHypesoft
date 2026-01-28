using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Domain.Repositories;
using Hypesoft.Domain.ValueObjects;
using MediatR;

namespace Hypesoft.Application.Queries.Products;

public sealed record ListProductsQuery(
    string? Search,
    string? CategoryId,
    int Page = 1,
    int PageSize = 20
) : IRequest<PagedResult<ProductDto>>;

public sealed class ListProductsQueryHandler : IRequestHandler<ListProductsQuery, PagedResult<ProductDto>>
{
    private readonly IProductRepository _productRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;

    public ListProductsQueryHandler(
        IProductRepository productRepository,
        ICategoryRepository categoryRepository,
        IMapper mapper)
    {
        _productRepository = productRepository;
        _categoryRepository = categoryRepository;
        _mapper = mapper;
    }

    public async Task<PagedResult<ProductDto>> Handle(ListProductsQuery request, CancellationToken cancellationToken)
    {
        var result = await _productRepository.GetPagedAsync(
            request.Search,
            request.CategoryId,
            request.Page,
            request.PageSize,
            cancellationToken);

        var categories = await _categoryRepository.GetAllAsync(cancellationToken);
        var categoryLookup = categories.ToDictionary(x => x.Id, x => x.Name);

        var items = result.Items
            .Select(product =>
            {
                var dto = _mapper.Map<ProductDto>(product);
                dto.CategoryName = categoryLookup.TryGetValue(product.CategoryId, out var name) ? name : null;
                return dto;
            })
            .ToList();

        return new PagedResult<ProductDto>(items, result.TotalCount, result.Page, result.PageSize);
    }
}
