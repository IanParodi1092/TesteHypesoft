using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Domain.Repositories;
using MediatR;

namespace Hypesoft.Application.Queries.Products;

public sealed record GetProductByIdQuery(string Id) : IRequest<ProductDto?>;

public sealed class GetProductByIdQueryHandler : IRequestHandler<GetProductByIdQuery, ProductDto?>
{
    private readonly IProductRepository _productRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;

    public GetProductByIdQueryHandler(
        IProductRepository productRepository,
        ICategoryRepository categoryRepository,
        IMapper mapper)
    {
        _productRepository = productRepository;
        _categoryRepository = categoryRepository;
        _mapper = mapper;
    }

    public async Task<ProductDto?> Handle(GetProductByIdQuery request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdAsync(request.Id, cancellationToken);
        if (product is null)
        {
            return null;
        }

        var dto = _mapper.Map<ProductDto>(product);
        var category = await _categoryRepository.GetByIdAsync(product.CategoryId, cancellationToken);
        dto.CategoryName = category?.Name;
        return dto;
    }
}
