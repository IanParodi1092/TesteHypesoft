using Hypesoft.Application.Caching;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Commands.Products;

public sealed record DeleteProductCommand(string Id) : IRequest;

public sealed class DeleteProductCommandHandler : IRequestHandler<DeleteProductCommand>
{
    private readonly IProductRepository _productRepository;
    private readonly IMemoryCache _cache;

    public DeleteProductCommandHandler(IProductRepository productRepository, IMemoryCache cache)
    {
        _productRepository = productRepository;
        _cache = cache;
    }

    public async Task Handle(DeleteProductCommand request, CancellationToken cancellationToken)
    {
        await _productRepository.DeleteAsync(request.Id, cancellationToken);

        _cache.Remove(CacheKeys.Dashboard);
        _cache.Remove(CacheKeys.LowStock(10));
    }
}
