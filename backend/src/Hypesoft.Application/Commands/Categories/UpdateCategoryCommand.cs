using AutoMapper;
using Hypesoft.Application.Caching;
using Hypesoft.Application.DTOs;
using Hypesoft.Application.Exceptions;
using Hypesoft.Domain.Repositories;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace Hypesoft.Application.Commands.Categories;

public sealed record UpdateCategoryCommand(string Id, string Name) : IRequest<CategoryDto>;

public sealed class UpdateCategoryCommandHandler : IRequestHandler<UpdateCategoryCommand, CategoryDto>
{
    private readonly ICategoryRepository _categoryRepository;
    private readonly IMapper _mapper;
    private readonly IMemoryCache _cache;

    public UpdateCategoryCommandHandler(
        ICategoryRepository categoryRepository,
        IMapper mapper,
        IMemoryCache cache)
    {
        _categoryRepository = categoryRepository;
        _mapper = mapper;
        _cache = cache;
    }

    public async Task<CategoryDto> Handle(UpdateCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await _categoryRepository.GetByIdAsync(request.Id, cancellationToken);
        if (category is null)
        {
            throw new NotFoundException("Categoria não encontrada.");
        }

        category.Name = request.Name;
        category.Touch();

        await _categoryRepository.UpdateAsync(category, cancellationToken);

        _cache.Remove(CacheKeys.CategoriesAll);
        _cache.Remove(CacheKeys.Dashboard);

        return _mapper.Map<CategoryDto>(category);
    }
}