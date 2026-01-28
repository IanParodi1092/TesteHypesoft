using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Caching;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Commands.Products;

public sealed record UpdateProductStockCommand(string Id, int Quantity) : IRequest<ProductDto>;

public sealed class UpdateProductStockCommandHandler : IRequestHandler<UpdateProductStockCommand, ProductDto>
{
    private readonly IProductRepository _productRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public UpdateProductStockCommandHandler(
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

    public async Task<ProductDto> Handle(UpdateProductStockCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdAsync(request.Id, cancellationToken);
        if (product is null)
        {
            throw new InvalidOperationException("Produto não encontrado.");
        }

        product.Quantity = request.Quantity;
        product.Touch();

        await _productRepository.UpdateAsync(product, cancellationToken);

        _cache.Remove(CacheKeys.Dashboard);
        _cache.Remove(CacheKeys.LowStock(10));

        var dto = _mapper.Map<ProductDto>(product);
        var category = await _categoryRepository.GetByIdAsync(product.CategoryId, cancellationToken);
        dto.CategoryName = category?.Name;
        return dto;
    }
}
