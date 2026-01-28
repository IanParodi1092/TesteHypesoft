using Hypesoft.Application.Caching;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Commands.Categories;

public sealed record DeleteCategoryCommand(string Id) : IRequest;

public sealed class DeleteCategoryCommandHandler : IRequestHandler<DeleteCategoryCommand>
{
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMemoryCache _cache;

    public DeleteCategoryCommandHandler(ICategoryRepository categoryRepository, IMemoryCache cache)
    {
        _categoryRepository = categoryRepository;
        _cache = cache;
    }

    public async Task Handle(DeleteCategoryCommand request, CancellationToken cancellationToken)
    {
        await _categoryRepository.DeleteAsync(request.Id, cancellationToken);

        _cache.Remove(CacheKeys.CategoriesAll);
        _cache.Remove(CacheKeys.Dashboard);
    }
}
