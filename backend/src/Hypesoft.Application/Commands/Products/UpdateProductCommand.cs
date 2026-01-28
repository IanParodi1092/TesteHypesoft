using AutoMapper;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Caching;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Commands.Products;

public sealed record UpdateProductCommand(
    string Id,
    string Name,
    string Description,
    decimal Price,
    string CategoryId,
    int Quantity
) : IRequest<ProductDto>;

public sealed class UpdateProductCommandHandler : IRequestHandler<UpdateProductCommand, ProductDto>
{
    private readonly IProductRepository _productRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public UpdateProductCommandHandler(
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

    public async Task<ProductDto> Handle(UpdateProductCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdAsync(request.Id, cancellationToken);
        if (product is null)
        {
            throw new InvalidOperationException("Produto não encontrado.");
        }

        var category = await _categoryRepository.GetByIdAsync(request.CategoryId, cancellationToken);
        if (category is null)
        {
            throw new InvalidOperationException("Categoria não encontrada.");
        }

        product.Name = request.Name;
        product.Description = request.Description;
        product.Price = request.Price;
        product.CategoryId = request.CategoryId;
        product.Quantity = request.Quantity;
        product.Touch();

        await _productRepository.UpdateAsync(product, cancellationToken);

        _cache.Remove(CacheKeys.Dashboard);
        _cache.Remove(CacheKeys.LowStock(10));

        var dto = _mapper.Map<ProductDto>(product);
        dto.CategoryName = category.Name;
        return dto;
    }
}
